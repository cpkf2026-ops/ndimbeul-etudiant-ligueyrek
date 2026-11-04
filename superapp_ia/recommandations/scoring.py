"""
Moteur de recommandation (PARTIE 8) — deux étapes bien séparées, comme demandé :

  1) FILTRAGE PAR RÈGLES (éliminatoire) : une formation dont la série de bac du
     profil n'est pas dans `series_acceptees`, ou dont la `moyenne_minimale` dépasse
     la moyenne du profil, est retirée AVANT tout scoring — on ne recommande JAMAIS
     une filière inaccessible, quel que soit son score sur les autres critères.

  2) CLASSEMENT PAR SCORE des formations survivantes, sur 100 points :
       - Compatibilité série bac (déjà garantie par le filtrage, toujours pleine
         note pour les survivantes — affichée pour la transparence) .... 30 pts
       - Métier visé et passions -> domaines d'études (domaines.py) ...... 35 pts
       - Matières fortes -> domaines d'études ............................ 15 pts
       - Région cible correspondante ..................................... 10 pts
       - Bourse disponible ................................................. 5 pts
       - Préférence public / privé respectée .............................. 5 pts

Le champ budget a été volontairement retiré (voir migration
2026_09_23_000002_drop_budget_add_matieres_fortes_to_profils_lyceens_table) : son poids (15 pts)
a été redistribué vers le nouveau critère "matières fortes".
"""
from datetime import date

from django.db.models import Q

from ia.embeddings import encoder_texte, encoder_textes, similarite_cosinus

from . import domaines
from .models import Bourse, Formation

POIDS_SERIE_BAC = 30.0
POIDS_DOMAINE_PASSIONS = 35.0
POIDS_MATIERES_FORTES = 15.0
POIDS_REGION = 10.0
POIDS_BOURSE = 5.0
# Préférence public / privé du profil (renseignée par l'élève, longtemps ignorée).
POIDS_STATUT = 5.0
# En dessous de ce nombre de propositions exactes, les domaines voisins complètent la liste.
MIN_PROPOSITIONS_EXACTES = 3


def _est_compatible_serie(formation, serie_bac):
    """Règle éliminatoire : pas de restriction renseignée => ouverte à toutes les séries."""
    if not serie_bac or not formation.series_acceptees:
        return True
    return serie_bac in formation.series_acceptees


def _est_compatible_moyenne(formation, moyenne):
    """Règle éliminatoire : sans moyenne minimale renseignée (ou sans moyenne dans le
    profil), la formation reste proposée."""
    if moyenne is None or formation.moyenne_minimale is None:
        return True
    return float(moyenne) >= float(formation.moyenne_minimale)


def _score_domaine_passions(embedding_profil, embedding_formation):
    if embedding_profil is None or embedding_formation is None:
        return 0.0
    similarite = max(0.0, similarite_cosinus(embedding_profil, embedding_formation))
    return round(POIDS_DOMAINE_PASSIONS * similarite, 2)


def _score_matieres_fortes(embedding_matieres, embedding_formation):
    if embedding_matieres is None or embedding_formation is None:
        # Non renseigné : score neutre, ni avantagé ni pénalisé.
        return POIDS_MATIERES_FORTES / 2
    similarite = max(0.0, similarite_cosinus(embedding_matieres, embedding_formation))
    return round(POIDS_MATIERES_FORTES * similarite, 2)


def _score_region(formation, region_cible, mobilite):
    if mobilite:
        # L'étudiant se dit mobile : la région ciblée n'est plus un critère discriminant.
        return POIDS_REGION
    if not region_cible:
        return 0.0
    # La cible peut être une région (« Thiès ») ou une ville (« Mbour ») : on compare
    # aux deux champs de l'établissement.
    lieux = {
        (getattr(formation.universite, champ, None) or '').strip().lower()
        for champ in ('region', 'commune')
    } - {''}
    return POIDS_REGION if region_cible.strip().lower() in lieux else 0.0


def _score_bourse(formation, universites_avec_bourse_active):
    return POIDS_BOURSE if str(formation.universite_id) in universites_avec_bourse_active else 0.0


def _precharger_universites_avec_bourse_active():
    aujourd_hui = date.today()
    bourse_valide = Q(date_limite__isnull=True) | Q(date_limite__gte=aujourd_hui)
    bourses_actives = Bourse.objects.filter(bourse_valide)

    universite_ids = {str(b.universite_id) for b in bourses_actives if b.universite_id}
    bourse_nationale_active = any(b.universite_id is None for b in bourses_actives)
    if bourse_nationale_active:
        # Une bourse nationale profite potentiellement à toutes les universités.
        universite_ids |= {str(u) for u in Formation.objects.values_list('universite_id', flat=True).distinct()}
    return universite_ids


def _texte_formation(formation):
    return ' '.join(filter(None, [formation.domaine, formation.intitule, formation.debouches]))


# Cache process-local des embeddings de formation, par id : le texte d'une formation
# (domaine + intitulé + débouchés) ne change quasiment jamais une fois créée par la
# veille IA, mais AVANT ce cache, generer_recommandations() ré-encodait TOUTES les
# formations à CHAQUE requête (69s mesurés avec 213 formations vs ~1-2s pour les
# nouvelles) — un coût qui grossit avec le catalogue alors qu'il ne devrait dépendre
# que du nombre de formations réellement nouvelles depuis la dernière requête.
_CACHE_EMBEDDINGS_FORMATION = {}


def _encoder_formations_avec_cache(formations):
    """Retourne un tableau d'embeddings aligné sur `formations`, en ne calculant que
    ceux absents du cache process-local."""
    a_calculer = [f for f in formations if f.id not in _CACHE_EMBEDDINGS_FORMATION]
    if a_calculer:
        nouveaux = encoder_textes([_texte_formation(f) for f in a_calculer])
        for formation, embedding in zip(a_calculer, nouveaux):
            _CACHE_EMBEDDINGS_FORMATION[formation.id] = embedding
    import numpy as np  # importé à l'usage (voir ia/embeddings.py)

    return np.array([_CACHE_EMBEDDINGS_FORMATION[f.id] for f in formations])


# Métiers et passions que le petit modèle d'embeddings connaît mal (mots rares dans ses
# données d'entraînement) : il les rapprochait presque au hasard (« douane » -> Puériculteur
# 0,69, mesuré le 21/10/2026). On ajoute au profil les DOMAINES de formation qui y mènent,
# pour que la comparaison porte sur un vocabulaire qu'il connaît. Connaissance métier
# générale (filières qui mènent à ces métiers), pas des données inventées sur les écoles.
EXPANSIONS_METIERS = {
    'douane': 'transit douanier commerce international import export logistique fiscalité droit des affaires',
    'douanier': 'transit douanier commerce international import export logistique fiscalité droit des affaires',
    'transitaire': 'transit douanier commerce international import export logistique',
    'impots': 'fiscalité comptabilité finance droit fiscal économie',
    'fiscaliste': 'fiscalité comptabilité finance droit fiscal',
    'diplomate': 'relations internationales sciences politiques droit international langues',
    'diplomatie': 'relations internationales sciences politiques droit international langues',
    'magistrat': 'droit sciences juridiques justice',
    'avocat': 'droit sciences juridiques justice',
    'notaire': 'droit sciences juridiques immobilier',
    'policier': 'droit sciences juridiques sécurité criminologie',
    'gendarme': 'droit sciences juridiques sécurité criminologie',
    'militaire': 'défense sécurité ingénierie sciences politiques',
    'banquier': 'banque finance comptabilité gestion économie',
    'comptable': 'comptabilité finance gestion audit',
    'agronome': 'agriculture agronomie élevage environnement',
    'veterinaire': 'médecine vétérinaire élevage biologie',
    'pharmacien': 'pharmacie santé biologie chimie',
    'sage femme': 'santé obstétrique soins infirmiers',
    'journaliste': 'journalisme communication médias audiovisuel',
    'pilote': 'aéronautique aviation transport aérien ingénierie',
    'architecte': 'architecture urbanisme génie civil design',
    'enseignant': 'éducation enseignement pédagogie sciences de l éducation',
    'professeur': 'éducation enseignement pédagogie sciences de l éducation',
    'entrepreneur': 'entrepreneuriat gestion management commerce marketing',
}


def _expansions(mots):
    from services.cache import normaliser_texte

    ajouts = []
    for mot in mots:
        cle = normaliser_texte(mot).strip()
        if cle in EXPANSIONS_METIERS:
            ajouts.append(EXPANSIONS_METIERS[cle])
    return ajouts


def _texte_profil(profil):
    morceaux = list(profil.get('passions') or []) + list(profil.get('metiers_envisages') or [])
    return ' '.join(morceaux + _expansions(morceaux))


def _texte_matieres_fortes(profil):
    return ' '.join(profil.get('matieres_fortes') or [])


# Cache des embeddings par TEXTE (formations et domaines des fiches : « Finance, banque et
# assurances » revient dans 51 fiches, il n'est encodé qu'une fois).
_CACHE_EMBEDDINGS_TEXTE = {}


def _embeddings_textes(textes):
    a_calculer = [t for t in dict.fromkeys(textes) if t not in _CACHE_EMBEDDINGS_TEXTE]
    if a_calculer:
        for texte, emb in zip(a_calculer, encoder_textes(a_calculer)):
            _CACHE_EMBEDDINGS_TEXTE[texte] = emb
    return [_CACHE_EMBEDDINGS_TEXTE[t] for t in textes]


class CandidatDomaine:
    """Établissement qui propose un DOMAINE (d'après sa fiche) sans formation détaillée en
    base : 160 établissements sur 207 n'étaient sinon jamais recommandés. Mêmes attributs
    qu'une Formation pour le reste du moteur ; conditions d'admission inconnues."""

    est_domaine = True
    series_acceptees = None
    moyenne_minimale = None
    prerequis = None
    debouches = None

    def __init__(self, universite, libelle_domaine, diplomes):
        self.universite = universite
        self.universite_id = universite.id
        self.id = f'domaine:{universite.id}:{abs(hash(libelle_domaine)) % 10 ** 8}'
        self.intitule = libelle_domaine
        self.domaine = libelle_domaine
        self.niveau = ', '.join(diplomes[:3]) if diplomes else None


def _candidats_domaines(formations):
    from veille.models import Universite as Etablissement

    domaines_formations = {}
    for f in formations:
        domaines_formations.setdefault(f.universite_id, set()).update(
            domaines.domaines_du_texte(_texte_formation(f)))
    candidats = []
    for u in Etablissement.objects.filter(statut_actif=True, deleted_at__isnull=True).exclude(domaines__isnull=True):
        for libelle_fiche in u.domaines or []:
            d = domaines.domaines_du_texte(libelle_fiche)
            # Domaine déjà couvert par une formation détaillée du même établissement : pas de doublon.
            if not d or d & domaines_formations.get(u.id, set()):
                continue
            candidats.append(CandidatDomaine(u, libelle_fiche, u.diplomes or []))
    return candidats


def _part(poids, domaines_candidat, sans_exact=frozenset()):
    """Part des domaines du profil couverts : domaine exact = plein crédit, domaine VOISIN
    (aviation -> transport…) = demi-crédit, mais seulement pour un domaine du projet qui n'a
    AUCUNE formation exacte au catalogue (`sans_exact`) : sinon « Mathématiques-Physique »
    passait devant les formations de santé pour un futur médecin. Retourne (part, voisins)."""
    total = sum(poids.values())
    if not total:
        return 0.0, []
    exact, voisin, voisins = 0.0, 0.0, []
    for d, w in poids.items():
        if d in domaines_candidat:
            exact += w
        elif d in sans_exact:
            proches = [v for v in domaines.VOISINS.get(d, []) if v in domaines_candidat]
            if proches:
                voisin += w
                voisins.append((d, proches[0]))
    return min(1.0, (exact + 0.5 * voisin) / total), voisins


def _racines_profil(profil):
    """Débuts des mots du métier et des passions (« medeci », « agrono », « develo ») : une
    formation qui les contient (« Médecine », « Sciences Agronomiques ») est la plus précise."""
    from services.cache import normaliser_texte

    termes = list(profil.get('metiers_envisages') or []) + list(profil.get('passions') or [])
    return {m[:6] for t in termes for m in normaliser_texte(t).split() if len(m) >= 5}


def _relatif(valeurs):
    """Similarités ramenées entre 0 et 1 sur l'ensemble des candidats (le modèle donne des
    valeurs brutes élevées partout : seul l'ÉCART entre candidats est informatif)."""
    if not valeurs:
        return []
    bas, haut = min(valeurs), max(valeurs)
    return [(v - bas) / (haut - bas) if haut > bas else 0.0 for v in valeurs]


def generer_recommandations(profil, limite=10, inclure_domaines=False, max_par_etablissement=None):
    """Retourne les `limite` meilleures propositions COMPATIBLES avec la série et la moyenne,
    triées par score décroissant.

    Le profil est d'abord traduit en DOMAINES d'études (recommandations/domaines.py : le
    métier visé pèse 3, une passion 2, une matière forte 1) ; la similarité du modèle
    d'embeddings ne sert qu'en appoint, pour les mots absents du thésaurus.
    `inclure_domaines` : ajoute les établissements qui proposent un domaine d'après leur fiche.
    Chaque élément : {'formation': Formation | CandidatDomaine, 'score', 'details', ...}.
    """
    from ia import embeddings as module_embeddings

    serie_bac = profil.get('serie_bac')
    moyenne = profil.get('moyenne_generale')
    toutes = list(Formation.objects.select_related('universite').filter(
        deleted_at__isnull=True, universite__statut_actif=True))
    # 1) FILTRAGE ÉLIMINATOIRE — jamais de filière incompatible avec la série ou la moyenne.
    candidats = [f for f in toutes if _est_compatible_serie(f, serie_bac) and _est_compatible_moyenne(f, moyenne)]
    if inclure_domaines:
        candidats += _candidats_domaines(candidats)
    if not candidats:
        return []

    # 2) PROFIL -> DOMAINES
    poids_pm, termes_pm, inconnus_pm = domaines.domaines_du_profil(
        {'metiers_envisages': profil.get('metiers_envisages'), 'passions': profil.get('passions')})
    poids_mat, _, inconnus_mat = domaines.domaines_du_profil({'matieres_fortes': profil.get('matieres_fortes')})
    domaines_candidats = [domaines.domaines_du_texte(_texte_formation(c)) for c in candidats]

    # Appoint sémantique : seulement pour des termes inconnus du thésaurus, et seulement si le
    # modèle est DÉJÀ chargé (le charger maintenant ferait dépasser le délai de l'application).
    sim_pm = sim_mat = None
    if (inconnus_pm or inconnus_mat) and module_embeddings._model is not None:
        embs = _embeddings_textes([_texte_formation(c) for c in candidats])
        if inconnus_pm:
            e = encoder_texte(' '.join(inconnus_pm + _expansions(inconnus_pm)))
            sim_pm = _relatif([max(0.0, similarite_cosinus(e, x)) for x in embs])
        if inconnus_mat:
            e = encoder_texte(' '.join(inconnus_mat))
            sim_mat = _relatif([max(0.0, similarite_cosinus(e, x)) for x in embs])

    bourses = _precharger_universites_avec_bourse_active()
    region_cible = profil.get('region_cible')
    mobilite = bool(profil.get('mobilite'))
    preference = (profil.get('pref_public_prive') or '').lower()

    racines = _racines_profil(profil)
    # Domaines du projet RARES au catalogue (moins de 3 propositions exactes : aviation, douane…) :
    # les domaines voisins complètent alors la liste, présentés comme tels.
    nb_exacts = {d: sum(d in dc for dc in domaines_candidats) for d in poids_pm}
    sans_exact = frozenset(d for d, n in nb_exacts.items() if n < MIN_PROPOSITIONS_EXACTES)
    from services.cache import normaliser_texte

    resultats = []
    for i, c in enumerate(candidats):
        dc = domaines_candidats[i]
        # Passions + métier : part des domaines du profil couverts par la proposition.
        part_pm, voisins = _part(poids_pm, dc, sans_exact) if poids_pm else (None, [])
        lien_projet = bool(part_pm)
        # Le mot du métier lui-même dans l'intitulé (« médecin » -> « Médecine ») : la proposition
        # la plus précise passe devant les autres formations du même domaine.
        mots_candidat = normaliser_texte(_texte_formation(c)).split()
        if part_pm and racines and any(m.startswith(r) for r in racines for m in mots_candidat):
            part_pm = min(1.15, part_pm + 0.15)
        if part_pm is not None and sim_pm is not None:
            s_pm = max(part_pm, 0.6 * sim_pm[i])
        elif part_pm is not None:
            s_pm = part_pm
        elif sim_pm is not None:
            s_pm = 0.8 * sim_pm[i]
        else:
            s_pm = 0.0
        # Matières fortes : même principe ; non renseignées -> score neutre.
        if poids_mat:
            s_mat = _part(poids_mat, dc)[0]
            if sim_mat is not None:
                s_mat = max(s_mat, 0.6 * sim_mat[i])
        elif sim_mat is not None:
            s_mat = 0.8 * sim_mat[i]
        else:
            s_mat = 0.5
        # Matières fortes : elles affinent le choix DANS le projet ; sans lien avec le projet,
        # elles ne comptent qu'en partie (sinon « SVT » faisait passer une licence de physique
        # devant toutes les formations de santé).
        if poids_pm and not lien_projet:
            s_mat *= 0.4
        if getattr(c, 'est_domaine', False):
            s_pm *= 0.9  # une formation détaillée passe avant un simple domaine de fiche, à égalité
        statut = getattr(c.universite, 'type', None)
        details = {
            'serie_bac': POIDS_SERIE_BAC,  # garanti par le filtrage ci-dessus
            'domaine_passions': round(POIDS_DOMAINE_PASSIONS * s_pm, 2),
            'matieres_fortes': round(POIDS_MATIERES_FORTES * s_mat, 2),
            'region': _score_region(c, region_cible, mobilite),
            'bourse': _score_bourse(c, bourses),
            'statut': (POIDS_STATUT if preference in ('public', 'prive') and statut == preference
                       else POIDS_STATUT / 2 if preference not in ('public', 'prive') else 0.0),
        }
        communs = sorted(d for d in dc if d in poids_pm)
        resultats.append({
            'formation': c,
            'score': min(100.0, round(sum(details.values()), 2)),  # affiché en % dans l'application
            'details': details,
            # Pour l'explication : domaines réellement partagés et termes du profil qui y mènent.
            'domaines_communs': [domaines.libelle(d) for d in communs],
            'termes_profil': list(dict.fromkeys(t for d in communs for t in termes_pm.get(d, []))),
            # Domaine seulement VOISIN du projet (aucune formation d'aviation : transport) : dit comme tel.
            'voisins': [{'projet': domaines.libelle(d), 'voisin': domaines.libelle(v),
                         'termes': termes_pm.get(d, []), 'aucune_exacte': nb_exacts.get(d, 0) == 0}
                        for d, v in voisins] if not communs else [],
            'passion_forte': bool(communs) or (sim_pm is not None and sim_pm[i] >= 0.8),
        })

    resultats.sort(key=lambda r: r['score'], reverse=True)
    if not max_par_etablissement:
        return resultats[:limite]
    # Variété : pas toute la liste dans le même établissement.
    choisis, par_etab = [], {}
    for r in resultats:
        uid = r['formation'].universite_id
        if par_etab.get(uid, 0) >= max_par_etablissement:
            continue
        par_etab[uid] = par_etab.get(uid, 0) + 1
        choisis.append(r)
        if len(choisis) == limite:
            break
    return choisis
