"""
Pipeline de veille internet : recherche web (DuckDuckGo) -> filtrage/
classification par le LLM local -> écriture dans les tables Laravel `actualites`,
`offres_emploi` et `universites`, déjà lues par l'app Flutter (aucun changement
front requis).
"""
import hashlib
import json
import logging
import re
import unicodedata
from datetime import date, timedelta

from django.utils import timezone

from ia import llm_gateway
from ia.models import nouvel_uuid

from recommandations.models import Formation

from . import fiabilite, recherche_web
from .models import Actualite, OffreEmploi, Universite
from .prompts import (
    construire_messages_actualites,
    construire_messages_formations,
    construire_messages_offres,
    construire_messages_universites,
    parser_reponse_json_liste,
)
from .requetes import (
    REQUETES_ACTUALITES,
    REQUETES_OFFRES,
    REQUETES_UNIVERSITES,
)

logger = logging.getLogger(__name__)

# Résultats traités par appel LLM : évite un prompt trop long (même logique que
# le regroupement des explications de recommandations, voir recommandations/views.py).
TAILLE_LOT = 8


def _en_lots(liste, taille):
    for i in range(0, len(liste), taille):
        yield liste[i:i + taille]


def _classer(messages, nb_resultats, stats=None):
    """Envoie un lot au LLM et renvoie une fiche (ou None) par article, dans l'ordre.
    Les anomalies (LLM indisponible, JSON invalide, réponse désalignée) sont journalisées
    et comptées dans `stats` sous la clé 'llm_<anomalie>' : on sait ainsi distinguer
    un vrai refus éditorial d'une réponse inexploitable."""
    try:
        reponse = llm_gateway.generer_reponse_sync(
            messages, temperature=0.2, max_tokens=200 * nb_resultats
        )
    except llm_gateway.LLMIndisponibleError as exc:
        logger.warning('Classification LLM indisponible : %s', exc)
        anomalie = 'indisponible'
        fiches = [None] * nb_resultats
    else:
        fiches, anomalie = parser_reponse_json_liste(reponse, nb_resultats)
        if anomalie:
            logger.warning(
                'Réponse LLM inexploitable (%s) pour un lot de %s : lot ignoré.',
                anomalie, nb_resultats,
            )
    if stats is not None:
        stats['llm_lots'] = stats.get('llm_lots', 0) + 1
        if anomalie:
            cle = f'llm_{anomalie}'
            stats[cle] = stats.get(cle, 0) + 1
    return fiches


def _collecter_flux(requetes, stats=None):
    """Interroge le moteur d'ACTUALITÉS (flux RSS Bing News) pour chaque requête et
    rassemble les articles, dédupliqués par URL. Chaque article porte sa date de
    publication et son média réels. Une requête en échec est journalisée et ignorée :
    la veille continue avec les autres."""
    candidats = {}
    for requete in requetes:
        try:
            resultats = recherche_web.rechercher_actualites(requete, nb_resultats=15)
        except recherche_web.RechercheWebIndisponibleError as exc:
            logger.warning('Flux "%s" indisponible : %s', requete, exc)
            if stats is not None:
                stats['flux_en_echec'] = stats.get('flux_en_echec', 0) + 1
            continue
        for r in resultats:
            if r['lien']:
                candidats.setdefault(r['lien'], r)
    return list(candidats.values())


_MOTS_TITRE_GENERIQUE = (
    'accueil |', 'accueil ', 'accéder à mon compte', 'accueil-',
    'portail officiel', "portail d'inscription", 'portail |',
    'concours |', 'concours.sn', 'e-concours',
    'campusen |', 'campusen)', 'office du baccalauréat',
    'liste de tous les concours', 'liste et détails de tous les concours',
    'liste des concours déjà', 'universités au sénégal: liste',
    'senorientation', 'guindima - guide complet',
    'actualité au sénégal', 'actualités au sénégal', 'actualités -- ecoles',
    'actualites | ministère', 'actualités | ministère', 'actualités education',
    'post bac sénégal - post bac', 'sujet | senenews',
    'actualité liée', 'actualites liees', "bourses d'etudes senegal", 'communiqué événement',
)


def _titre_semble_generique(titre):
    """Filtre de sécurité en complément du filtrage LLM (qui peut se tromper) : rejette les
    titres qui ressemblent à la page d'accueil/description d'un SITE (ex: 'Senego.com :
    Actualité au Sénégal', 'CAMPUSEN | Portail officiel...') plutôt qu'à un fait précis et
    daté. Même logique que _nom_semble_valide() pour les établissements."""
    titre_normalise = _normaliser_nom(titre)
    if not titre_normalise:
        return False
    if any(motif in titre.lower() for motif in _MOTS_TITRE_GENERIQUE):
        return False
    return True


def _collecter_candidats_actualites(stats=None):
    """Articles candidats pour les actualités (voir _collecter_flux)."""
    return _collecter_flux(REQUETES_ACTUALITES, stats)


def veiller_actualites():
    """Cherche, vérifie et enregistre les actualités inédites. Retourne le nombre de
    fiches créées.

    Chaîne de contrôle (voir veille/fiabilite.py) — un article n'est publié que s'il
    passe TOUTES les étapes :
      1. source officielle ou presse reconnue ;
      2. pas déjà en base (URL) ni quasi-doublon d'un titre récent ;
      3. date de publication réelle connue et récente (≤ AGE_MAX_JOURS) ;
      4. page de l'article joignable (lien vivant) ;
      5. le LLM confirme un fait précis lié à l'éducation au Sénégal.
    """
    stats = {'candidats': 0, 'source': 0, 'doublon': 0, 'date': 0, 'lien': 0, 'reseau': 0,
             'llm': 0, 'flux_en_echec': 0}
    categories_valides = dict(Actualite.CATEGORIE_CHOICES)

    candidats = _collecter_candidats_actualites(stats)
    stats['candidats'] = len(candidats)

    # 1. Fiabilité de la source.
    retenus = []
    for c in candidats:
        niveau = fiabilite.niveau_fiabilite(c['lien'])
        if niveau is None:
            stats['source'] += 1
            continue
        retenus.append({**c, 'fiabilite': niveau})

    # 2. Doublons : URL déjà connue, ou titre très proche d'une actualité existante.
    liens_connus = set(
        Actualite.objects.filter(source_url__in=[c['lien'][:255] for c in retenus])
        .values_list('source_url', flat=True)
    )
    titres_connus = [
        _tokens_significatifs(t)
        for t in Actualite.objects.filter(
            created_at__gte=timezone.now() - timedelta(days=fiabilite.RETENTION_JOURS)
        ).values_list('titre', flat=True)
    ]

    def _deja_vu(titre):
        tokens = _tokens_significatifs(titre)
        if not tokens:
            return False
        for connus in titres_connus:
            if connus and len(tokens & connus) / max(1, min(len(tokens), len(connus))) >= 0.7:
                return True
        return False

    uniques = []
    for c in retenus:
        if c['lien'][:255] in liens_connus or _deja_vu(c['titre']):
            stats['doublon'] += 1
            continue
        titres_connus.append(_tokens_significatifs(c['titre']))
        uniques.append(c)

    # 3 + 4. Date réelle récente et lien vivant (lecture de la page de l'article).
    verifies = []
    for c in uniques:
        if c['date_publication'] is not None and not fiabilite.est_recente(c['date_publication']):
            stats['date'] += 1
            continue
        meta = recherche_web.extraire_metadonnees_article(c['lien'])
        if not meta['accessible']:
            # Coupure réseau ≠ lien mort : l'article sera retenté au prochain passage.
            stats['reseau' if meta.get('erreur_reseau') else 'lien'] += 1
            continue
        date_reelle = c['date_publication'] or meta['date_publication']
        if not fiabilite.est_recente(date_reelle):
            stats['date'] += 1
            continue
        verifies.append({**c, 'date_publication': date_reelle, 'image_page': meta['image']})

    # 5. Validation éditoriale par le LLM, par lots.
    total_creees = 0
    stats['erreur'] = 0
    for lot in _en_lots(verifies, TAILLE_LOT):
        fiches = _classer(construire_messages_actualites(lot), len(lot), stats)
        for resultat, fiche in zip(lot, fiches):
            if not fiche or not fiche.get('pertinent'):
                stats['llm'] += 1
                continue
            titre_fiche = fiche.get('titre') or resultat['titre']
            if not _titre_semble_generique(titre_fiche):
                stats['llm'] += 1
                continue

            # Une erreur sur UN article (image, base…) est journalisée sans
            # interrompre le reste de la veille.
            try:
                # Image réelle de l'article (métadonnées de la page, sinon vignette du
                # flux d'actualités), téléchargée localement — jamais d'image inventée.
                image_locale = recherche_web.telecharger_image_locale(
                    resultat['image_page']
                ) or recherche_web.telecharger_image_locale(resultat.get('image'))

                categorie = fiche.get('categorie')
                _, cree = Actualite.objects.get_or_create(
                    source_url=resultat['lien'][:255],
                    defaults={
                        'titre': titre_fiche[:255],
                        'contenu': fiche.get('resume') or resultat['extrait'] or '',
                        'categorie': categorie if categorie in categories_valides else 'general',
                        'image_url': image_locale,
                        'date_publication': resultat['date_publication'],
                        'source_nom': fiabilite.nom_source_lisible(
                            resultat['lien'], resultat.get('source_nom')
                        ),
                        'fiabilite': resultat['fiabilite'],
                        'statut': 'publie',
                    },
                )
            except Exception:  # noqa: BLE001 — journalisé, la veille continue
                logger.exception('Actualité ignorée suite à une erreur : %s', resultat['lien'])
                stats['erreur'] += 1
                continue
            if cree:
                total_creees += 1

    stats['creees'] = total_creees
    logger.info('Veille actualités : %s', resume_stats(stats))
    return stats


def resume_stats(stats):
    """'5 créée(s) sur 166 candidat(s) — rejets : 36 source non fiable, …' — résumé
    lisible commun aux veilles actualités et offres (journaux + commande veiller)."""
    libelles = [
        ('source', 'source non fiable'), ('doublon', 'doublon(s)'),
        ('date', 'date absente/ancienne'), ('expiree', 'date limite passée'),
        ('lien', 'lien mort'), ('reseau', 'injoignable (réseau, retenté au prochain passage)'),
        ('llm', 'refus LLM'), ('erreur', 'erreur technique'),
    ]
    rejets = ', '.join(
        f"{stats[cle]} {libelle}" for cle, libelle in libelles if stats.get(cle)
    ) or 'aucun'
    anomalies = ', '.join(
        f"{stats[cle]} {cle[4:].replace('_', ' ')}"
        for cle in ('llm_json_invalide', 'llm_tableau_absent', 'llm_desalignement', 'llm_indisponible')
        if stats.get(cle)
    )
    texte = (
        f"{stats.get('creees', 0)} créée(s) sur {stats.get('candidats', 0)} candidat(s) — "
        f"rejets : {rejets}."
    )
    if stats.get('flux_en_echec'):
        texte += f" Requêtes en échec (Internet/flux) : {stats['flux_en_echec']}."
    if stats.get('limite_non_confirmee'):
        texte += (
            f" Dates limites proposées par le LLM mais absentes du texte (ignorées) : "
            f"{stats['limite_non_confirmee']}."
        )
    if stats.get('llm_lots'):
        texte += f" Lots LLM : {stats['llm_lots']}" + (
            f", dont inexploitables : {anomalies}." if anomalies else ', tous exploitables.'
        )
    return texte


def archiver_actualites_obsoletes():
    """Garde le fil d'actualités frais et fiable : archive (jamais de suppression)
    les actualités de la veille plus anciennes que RETENTION_JOURS, ainsi que celles
    déjà en base dont la source ne satisfait pas les règles de fiabilité actuelles.
    Les actualités rédigées par un administrateur (auteur_id renseigné) ne sont
    jamais touchées. Retourne le nombre de fiches archivées."""
    limite = timezone.now() - timedelta(days=fiabilite.RETENTION_JOURS)
    archivees = 0
    for a in Actualite.objects.filter(statut='publie', auteur_id__isnull=True):
        trop_vieille = a.date_publication is not None and a.date_publication < limite
        niveau = fiabilite.niveau_fiabilite(a.source_url)
        # Fiches indexées avant les règles actuelles (fiabilite vide) : on revérifie
        # aussi que le titre désigne un fait précis et non une page de site.
        ancienne_non_verifiee = a.fiabilite is None and not _titre_semble_generique(a.titre)
        if trop_vieille or niveau is None or ancienne_non_verifiee:
            a.statut = 'archive'
            a.save(update_fields=['statut'])
            archivees += 1
        elif a.fiabilite is None:
            a.fiabilite = niveau
            a.source_nom = a.source_nom or fiabilite.nom_source_lisible(a.source_url)
            a.save(update_fields=['fiabilite', 'source_nom'])
    logger.info('Archivage actualités : %s fiche(s) obsolète(s)/non fiable(s) archivée(s).', archivees)
    return archivees


def _hash_offre(intitule, entreprise, url):
    """Hash de déduplication (Tâche 5) : titre + entreprise + URL normalisés. Complète
    la contrainte unique (source_url, intitule) déjà en base par une vérification
    explicite, insensible à la casse/aux espaces, avant même d'appeler le LLM."""
    brut = f'{intitule.strip().lower()}|{entreprise.strip().lower()}|{url.strip().lower()}'
    return hashlib.sha256(brut.encode('utf-8')).hexdigest()


def _parser_date_limite(valeur):
    """'2026-10-15' -> date(2026, 10, 15) ; toute autre valeur -> None (jamais devinée)."""
    if not valeur or not isinstance(valeur, str):
        return None
    try:
        return date.fromisoformat(valeur.strip()[:10])
    except ValueError:
        return None


_MOIS_FR = (
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août',
    'septembre', 'octobre', 'novembre', 'décembre',
)


def _date_ecrite_dans(d, texte):
    """Vrai si la date `d` est écrite dans `texte` ('5 octobre', '1er octobre',
    '05/10/2026', '05-10', '2026-10-05'…). Contrôle déterministe, indépendant du LLM :
    un petit modèle a tendance à recopier la date de PUBLICATION comme date limite."""
    t = (texte or '').lower()
    jour = d.day
    jours = {str(jour), f'{jour:02d}'} | ({'1er'} if jour == 1 else set())
    mois = _MOIS_FR[d.month - 1]
    for j in jours:
        if re.search(rf'(?<!\d){j}\s+{mois}', t):
            return True
    numeriques = (
        rf'(?<!\d)0?{jour}[/.-]0?{d.month}(?!\d)',
        rf'{d.year}-{d.month:02d}-{jour:02d}',
    )
    return any(re.search(motif, t) for motif in numeriques)


def veiller_offres():
    """Cherche, vérifie et enregistre les offres inédites (emploi, stage, alternance,
    formation, bourse, concours). Même chaîne de contrôle que les actualités — une
    offre n'est publiée que si elle passe TOUTES les étapes :
      1. source officielle, presse reconnue ou plateforme d'offres reconnue ;
      2. pas déjà en base (URL, empreinte titre+organisme+URL, titre quasi identique) ;
      3. date de publication réelle connue et de moins de OFFRES_AGE_MAX_JOURS ;
      4. page de l'annonce joignable (lien vivant) ;
      5. le LLM confirme une opportunité PRÉCISE et ENCORE OUVERTE ;
      6. date limite (si le texte en donne une) pas encore dépassée.
    Retourne le dictionnaire de statistiques (clé 'creees' = nombre créé)."""
    stats = {'candidats': 0, 'source': 0, 'doublon': 0, 'date': 0, 'lien': 0, 'reseau': 0,
             'llm': 0, 'expiree': 0, 'erreur': 0, 'flux_en_echec': 0}
    types_valides = dict(OffreEmploi.TYPE_CHOICES)
    aujourd_hui = timezone.localdate()

    candidats = _collecter_flux(REQUETES_OFFRES, stats)
    stats['candidats'] = len(candidats)

    # 1. Fiabilité de la source.
    retenus = []
    for c in candidats:
        niveau = fiabilite.niveau_fiabilite_offre(c['lien'])
        if niveau is None:
            stats['source'] += 1
            continue
        retenus.append({**c, 'fiabilite': niveau})

    # 2. Doublons (URL déjà connue ou titre quasi identique à une offre récente).
    liens_connus = set(
        OffreEmploi.objects.filter(source_url__in=[c['lien'][:500] for c in retenus])
        .values_list('source_url', flat=True)
    )
    hashes_connus = {
        _hash_offre(o.intitule, o.entreprise or '', o.source_url or '')
        for o in OffreEmploi.objects.all().only('intitule', 'entreprise', 'source_url')
    }
    titres_connus = [
        _tokens_significatifs(t)
        for t in OffreEmploi.objects.filter(
            date_indexation__gte=timezone.now() - timedelta(days=fiabilite.OFFRES_AGE_MAX_JOURS)
        ).values_list('intitule', flat=True)
    ]

    def _deja_vu(titre):
        tokens = _tokens_significatifs(titre)
        return bool(tokens) and any(
            connus and len(tokens & connus) / max(1, min(len(tokens), len(connus))) >= 0.7
            for connus in titres_connus
        )

    uniques = []
    for c in retenus:
        if c['lien'][:500] in liens_connus or _deja_vu(c['titre']):
            stats['doublon'] += 1
            continue
        titres_connus.append(_tokens_significatifs(c['titre']))
        uniques.append(c)

    # 3 + 4. Date réelle récente et lien vivant.
    verifies = []
    for c in uniques:
        if not fiabilite.est_recente(c['date_publication'], fiabilite.OFFRES_AGE_MAX_JOURS):
            stats['date'] += 1
            continue
        meta = recherche_web.extraire_metadonnees_article(c['lien'])
        if not meta['accessible']:
            # Coupure réseau ≠ lien mort : l'article sera retenté au prochain passage.
            stats['reseau' if meta.get('erreur_reseau') else 'lien'] += 1
            continue
        verifies.append(c)

    # 5 + 6. Validation par le LLM (opportunité ouverte, type, date limite écrite).
    total_creees = 0
    for lot in _en_lots(verifies, TAILLE_LOT):
        fiches = _classer(construire_messages_offres(lot), len(lot), stats)
        for resultat, fiche in zip(lot, fiches):
            if not fiche or not fiche.get('pertinent'):
                stats['llm'] += 1
                continue

            date_limite = _parser_date_limite(fiche.get('date_limite'))
            # Date limite gardée seulement si elle est ÉCRITE dans le titre/l'extrait de
            # l'annonce : sinon c'est une invention du LLM, on l'ignore (sans rejeter l'offre).
            if date_limite and not _date_ecrite_dans(
                date_limite, f"{resultat['titre']} {resultat['extrait']}"
            ):
                stats['limite_non_confirmee'] = stats.get('limite_non_confirmee', 0) + 1
                date_limite = None
            if date_limite and date_limite < aujourd_hui:
                stats['expiree'] += 1
                continue

            intitule = (fiche.get('intitule') or resultat['titre'])[:255]
            entreprise = (fiche.get('entreprise') or 'Non précisé')[:255]
            empreinte = _hash_offre(intitule, entreprise, resultat['lien'])
            if empreinte in hashes_connus:
                stats['doublon'] += 1
                continue

            type_offre = fiche.get('type')
            try:
                _, cree = OffreEmploi.objects.get_or_create(
                    source_url=resultat['lien'][:500],
                    intitule=intitule,
                    defaults={
                        'entreprise': entreprise,
                        'type': type_offre if type_offre in types_valides else 'emploi',
                        # Le modèle Flutter attend domaine/region non-null (String requis).
                        'domaine': fiche.get('domaine') or 'Non précisé',
                        'region': fiche.get('region') or 'Non précisée',
                        'description': fiche.get('description') or resultat['extrait'] or '',
                        # Nom réel du média / de l'organisme, et non plus « Recherche web ».
                        'source': fiabilite.nom_source_lisible(
                            resultat['lien'], resultat.get('source_nom')
                        ),
                        'fiabilite': resultat['fiabilite'],
                        # Vraie date de publication de l'annonce (plus date.today()).
                        'date_publication': timezone.localtime(resultat['date_publication']).date(),
                        'date_limite': date_limite,
                        'statut': 'active',
                        'date_indexation': timezone.now(),
                    },
                )
            except Exception:  # noqa: BLE001 — journalisé, la veille continue
                logger.exception('Offre ignorée suite à une erreur : %s', resultat['lien'])
                stats['erreur'] += 1
                continue
            if cree:
                hashes_connus.add(empreinte)
                total_creees += 1

    stats['creees'] = total_creees
    logger.info('Veille offres : %s', resume_stats(stats))
    return stats


def archiver_offres_obsoletes():
    """Retire de l'app (statut 'expiree', jamais de suppression) les offres :
    - dont la date limite est passée ;
    - publiées il y a plus de OFFRES_AGE_MAX_JOURS jours ;
    - indexées avant les règles de fiabilité actuelles (fiabilite vide), car leur
      date de publication n'était pas la vraie (date d'indexation) et leur source
      n'a jamais été vérifiée.
    Exécuté toutes les 2 h avec la veille : ne dépend plus du scheduler Laravel.
    Retourne le nombre d'offres expirées."""
    aujourd_hui = timezone.localdate()
    limite = aujourd_hui - timedelta(days=fiabilite.OFFRES_AGE_MAX_JOURS)
    actives = OffreEmploi.objects.filter(statut='active')

    nb_date_limite = actives.filter(date_limite__lt=aujourd_hui).update(statut='expiree')
    nb_anciennes = actives.filter(date_publication__lt=limite).update(statut='expiree')
    nb_non_verifiees = actives.filter(fiabilite__isnull=True).update(statut='expiree')

    total = nb_date_limite + nb_anciennes + nb_non_verifiees
    logger.info(
        'Archivage offres : %s expirée(s) — %s date limite passée, %s de plus de %s jours, '
        '%s non vérifiée(s) (anciennes règles).',
        total, nb_date_limite, nb_anciennes, fiabilite.OFFRES_AGE_MAX_JOURS, nb_non_verifiees,
    )
    return total


_MOTS_VIDES_NOM = {
    'de', 'du', 'des', 'et', 'la', 'le', 'les', 'l', 'd', 'à', 'a', 'en',
    'universite', 'universit', 'institut', 'ecole', 'superieur', 'superieure',
    'superieurs', 'superieures', 'national', 'nationale', 'sup',
}


def _normaliser_nom(nom):
    """Enlève accents/casse/ponctuation pour comparer deux noms d'établissement de façon
    tolérante (ex: 'Université Cheikh Anta Diop' == 'universite cheikh anta diop')."""
    sans_accents = unicodedata.normalize('NFKD', nom).encode('ascii', 'ignore').decode('ascii')
    return re.sub(r'[^a-z0-9 ]', ' ', sans_accents.lower()).strip()


_MOTS_ANNUAIRE = (
    'liste des', 'toutes les', 'meilleures', 'meilleurs', 'top ', 'classement',
    'comparatif', 'annuaire', 'répertoire', 'repertoire', 'edurank',
    'académie', 'academie', 'direction de', 'direction generale', 'direction générale',
    'ministère', 'ministere', 'grandes ecoles', 'grandes écoles', 'instituts prives',
    'instituts privés', 'instituts specialises', 'instituts spécialisés',
    'universites publiques', 'universités publiques', 'ecoles de commerce',
    'écoles de commerce', 'ecoles a ', 'écoles à ',
)


def _nom_semble_valide(nom):
    """Filtre de sécurité en complément du filtrage LLM (qui peut se tromper) : rejette les
    noms qui ressemblent clairement à un titre de page-annuaire, un nom de site web, une
    entité administrative générique (ministère, académie...) ou du texte concaténé/garbled,
    plutôt qu'au nom propre d'un seul établissement (ex: 'Toutes les écoles au Sénégal',
    'UCAD, UGBSaint-Louis, UIDTThiès', 'senegalecoles.com', 'Universités Publiques')."""
    nom_normalise = _normaliser_nom(nom)
    if not nom_normalise:
        return False
    if any(motif in nom_normalise for motif in _MOTS_ANNUAIRE):
        return False
    if ',' in nom or ' et ' in nom.lower():
        return False  # plusieurs noms concaténés
    if re.search(r'\.(com|sn|net|org)\b', nom, re.IGNORECASE):
        return False  # nom de domaine, pas un nom d'établissement
    if len(nom.split()) > 10:
        return False  # un vrai nom d'établissement est rarement aussi long
    if max((len(mot) for mot in nom.split()), default=0) > 25:
        return False  # mot(s) collé(s)/texte garbled sans espaces
    return True


def _tokens_significatifs(nom):
    return {m for m in _normaliser_nom(nom).split() if m not in _MOTS_VIDES_NOM and len(m) > 2}


def dedupliquer_universites_similaires():
    """Complète _normaliser_nom (égalité stricte) par une comparaison par recouvrement de
    tokens significatifs : détecte les quasi-doublons qui diffèrent par des qualificatifs
    (ex: 'Université Gaston Berger' vs 'Université Gaston Berger (UGB) de Saint-Louis').
    Désactive (statut_actif=False, jamais de suppression) les doublons les moins informatifs
    en gardant celui dont la description/site web est le plus complet. Retourne le nombre
    de fiches désactivées."""
    actives = list(Universite.objects.filter(statut_actif=True).order_by('created_at'))
    desactivees = 0
    traites = set()

    for i, u1 in enumerate(actives):
        if u1.id in traites:
            continue
        tokens1 = _tokens_significatifs(u1.nom)
        if not tokens1:
            continue
        groupe = [u1]
        for u2 in actives[i + 1:]:
            if u2.id in traites:
                continue
            tokens2 = _tokens_significatifs(u2.nom)
            if not tokens2:
                continue
            if tokens1 <= tokens2 or tokens2 <= tokens1:
                groupe.append(u2)

        if len(groupe) < 2:
            continue

        def _score(u):
            return (bool(u.site_web_officiel), len(u.description or ''), -len(u.nom))

        meilleur = max(groupe, key=_score)
        for u in groupe:
            traites.add(u.id)
            if u.id != meilleur.id:
                u.statut_actif = False
                u.save(update_fields=['statut_actif'])
                desactivees += 1

    logger.info('Déduplication universités : %s doublon(s) désactivé(s).', desactivees)
    return desactivees


_NIVEAUX_VALIDES = {'bts', 'licence', 'master', 'doctorat'}


def veiller_formations(limite_etablissements=15):
    """Recherche et enregistre les VRAIES filières/formations de chaque établissement
    actif qui n'en a encore aucune — le moteur de recommandations (recommandations/
    scoring.py) ne peut choisir que parmi les formations en base, or la grande majorité
    des 57+ établissements créés par la Tâche 1 n'en avait aucune. Va lire le texte réel
    du site officiel (ou, à défaut, de la meilleure page trouvée par recherche web) et ne
    retient QUE les filières explicitement nommées dedans (jamais une filière plausible
    mais non trouvée). Retourne (établissements traités, formations créées)."""
    # Formation.universite pointe vers recommandations.models.Universite — une classe
    # Django distincte de veille.models.Universite bien que mappée à la même table
    # `universites` (managed=False des deux côtés) : pas de relation ORM directe entre
    # les deux, d'où l'exclusion manuelle par id plutôt qu'un formations__isnull=True.
    ids_avec_formations = set(Formation.objects.values_list('universite_id', flat=True).distinct())
    a_traiter = list(
        Universite.objects.filter(statut_actif=True)
        .exclude(id__in=ids_avec_formations)
        .order_by('created_at')[:limite_etablissements]
    )

    traites = 0
    creees = 0

    for universite in a_traiter:
        if universite.site_web_officiel:
            url = universite.site_web_officiel
        else:
            resultats = []
            try:
                resultats = recherche_web.rechercher(
                    f'{universite.nom} filières formations licence master admission', nb_resultats=3
                )
            except recherche_web.RechercheWebIndisponibleError as exc:
                logger.warning('Recherche formations "%s" indisponible : %s', universite.nom, exc)
                continue
            url = resultats[0]['lien'] if resultats else None

        texte = recherche_web.extraire_texte_page(url) if url else ''
        traites += 1
        if not texte:
            continue

        try:
            reponse = llm_gateway.generer_reponse_sync(
                construire_messages_formations(universite.nom, texte), temperature=0.1, max_tokens=800,
            )
        except llm_gateway.LLMIndisponibleError as exc:
            logger.warning('Extraction formations indisponible pour %s : %s', universite.nom, exc)
            continue

        match = re.search(r'\[.*\]', reponse or '', re.DOTALL)
        if not match:
            continue
        try:
            filieres = json.loads(match.group(0))
        except (json.JSONDecodeError, ValueError):
            continue
        if not isinstance(filieres, list):
            continue

        for filiere in filieres:
            if not isinstance(filiere, dict):
                continue
            intitule = (filiere.get('intitule') or '').strip()
            niveau = (filiere.get('niveau') or '').strip().lower()
            if not intitule or len(intitule) > 200 or niveau not in _NIVEAUX_VALIDES:
                continue
            series = filiere.get('series_acceptees')
            if not isinstance(series, list) or not series:
                series = None
            debouches = (filiere.get('debouches') or '').strip() or None

            # universite_id (colonne brute) et non universite=... : Formation.universite
            # pointe vers recommandations.models.Universite, une classe Django distincte
            # de l'instance veille.models.Universite qu'on a ici (voir commentaire plus haut).
            _, cree = Formation.objects.get_or_create(
                universite_id=universite.id,
                intitule=intitule[:255],
                defaults={
                    'id': nouvel_uuid(),
                    'niveau': niveau,
                    'domaine': (filiere.get('domaine') or None),
                    'series_acceptees': series,
                    'debouches': debouches,
                },
            )
            if cree:
                creees += 1

    logger.info(
        'Veille formations : %s établissement(s) traité(s), %s formation(s) créée(s).', traites, creees
    )
    return traites, creees


def _generer_code_unique(nom, codes_deja_pris):
    """Construit un code court à partir des initiales des mots significatifs du nom
    (ex: 'Institut Supérieur de Management' -> 'ISM'), unique parmi `codes_deja_pris`."""
    mots = [m for m in _normaliser_nom(nom).split() if m not in _MOTS_VIDES_NOM and len(m) > 1]
    base = ''.join(m[0] for m in mots).upper() or 'ETAB'
    base = base[:20]

    code = base
    suffixe = 2
    while code in codes_deja_pris:
        code = f'{base}{suffixe}'
        suffixe += 1
    return code


def charger_seed_universites():
    """Charge le socle fiable d'établissements connus avec certitude (voir
    veille/seed_universites.py). Idempotent : n'insère que les établissements absents
    (par code_unique). Retourne le nombre de fiches créées."""
    from .seed_universites import SEED_UNIVERSITES

    total_creees = 0
    codes_connus = set(Universite.objects.values_list('code_unique', flat=True))
    for fiche in SEED_UNIVERSITES:
        if fiche['code_unique'] in codes_connus:
            continue
        Universite.objects.create(
            statut_actif=True,
            source='Socle de référence (établissement majeur connu avec certitude)',
            date_verification=timezone.now().date(),
            **fiche,
        )
        codes_connus.add(fiche['code_unique'])
        total_creees += 1

    logger.info('Seed universités : %s fiche(s) créée(s).', total_creees)
    return total_creees


def veiller_universites():
    """Découvre des établissements d'enseignement supérieur sénégalais sur le web,
    filtre/classe via le LLM et crée les fiches inédites dans `universites`. Retourne le
    nombre de fiches créées."""
    total_creees = 0

    noms_connus = {_normaliser_nom(n) for n in Universite.objects.values_list('nom', flat=True)}
    codes_connus = set(Universite.objects.values_list('code_unique', flat=True))

    for requete in REQUETES_UNIVERSITES:
        try:
            resultats = recherche_web.rechercher(requete, nb_resultats=10)
        except recherche_web.RechercheWebIndisponibleError as exc:
            logger.warning('Recherche "%s" indisponible : %s', requete, exc)
            continue

        if not resultats:
            continue

        for lot in _en_lots(resultats, TAILLE_LOT):
            fiches = _classer(construire_messages_universites(lot), len(lot))
            for resultat, fiche in zip(lot, fiches):
                if not fiche or not fiche.get('pertinent') or not fiche.get('nom'):
                    continue

                nom = fiche['nom'].strip()[:255]
                if not _nom_semble_valide(nom):
                    continue  # ressemble à une page-annuaire/nom de site, pas à un établissement
                nom_normalise = _normaliser_nom(nom)
                if not nom_normalise or nom_normalise in noms_connus:
                    continue  # déjà en base (ou déjà créé plus tôt dans cette même passe)

                type_etab = fiche.get('type')
                code_unique = _generer_code_unique(nom, codes_connus)

                # On ne garde le lien du résultat comme site_web_officiel QUE si le LLM
                # confirme que c'est bien le domaine propre de l'établissement (pas un
                # article/annuaire tiers qui en parle) — sinon on le laisse vide plutôt
                # que de stocker une URL trompeuse.
                site_officiel = (
                    resultat['lien'][:255]
                    if fiche.get('lien_est_site_officiel') and resultat.get('lien')
                    else None
                )

                Universite.objects.create(
                    nom=nom,
                    code_unique=code_unique,
                    region=fiche.get('region') or None,
                    commune=fiche.get('commune') or None,
                    type=type_etab if type_etab in ('public', 'prive') else 'public',
                    site_web_officiel=site_officiel,
                    source=f'Recherche web (DuckDuckGo), requête "{requete}"',
                    date_verification=timezone.now().date(),
                    description=fiche.get('description') or resultat['extrait'] or None,
                    statut_actif=True,
                )

                noms_connus.add(nom_normalise)
                codes_connus.add(code_unique)
                total_creees += 1

    logger.info('Veille universités : %s fiche(s) créée(s).', total_creees)
    return total_creees


def backfiller_logos_universites():
    """Va chercher le vrai logo (balise og:image) du site officiel de chaque université
    active qui n'en a pas encore. Ne génère/n'invente jamais d'image : celles sans site
    officiel ou dont le site ne publie pas cette balise restent sans image_url — l'app
    affiche alors le nom de l'établissement sur fond de couleur plutôt qu'une photo
    générique trompeuse (voir shared/widgets/name_placeholder.dart côté Flutter).
    Retourne le nombre de logos effectivement trouvés."""
    trouves = 0
    a_traiter = list(
        Universite.objects.filter(statut_actif=True, image_url__isnull=True)
        .exclude(site_web_officiel__isnull=True)
        .exclude(site_web_officiel='')
    )

    for universite in a_traiter:
        logo = recherche_web.extraire_logo(universite.site_web_officiel)
        if logo:
            universite.image_url = logo[:255]
            universite.save(update_fields=['image_url'])
            trouves += 1

    logger.info('Backfill logos universités : %s/%s trouvé(s).', trouves, len(a_traiter))
    return trouves


def dedupliquer_actualites_similaires():
    """Comparaison par recouvrement de tokens significatifs (même logique que
    dedupliquer_universites_similaires) : détecte les quasi-doublons qui couvrent le même
    fait avec un titre légèrement différent (ex: deux articles sur le calendrier UCAD trouvés
    via des requêtes différentes). Archive (statut='archive', jamais de suppression) les
    moins informatifs en gardant celui qui a une vraie image, puis le contenu le plus riche.
    Retourne le nombre de fiches archivées."""
    publiees = list(Actualite.objects.filter(statut='publie').order_by('created_at'))
    archivees = 0
    traites = set()

    for i, a1 in enumerate(publiees):
        if a1.id in traites:
            continue
        tokens1 = _tokens_significatifs(a1.titre)
        if not tokens1:
            continue
        groupe = [a1]
        for a2 in publiees[i + 1:]:
            if a2.id in traites:
                continue
            tokens2 = _tokens_significatifs(a2.titre)
            if not tokens2:
                continue
            chevauchement = len(tokens1 & tokens2) / max(1, min(len(tokens1), len(tokens2)))
            if tokens1 <= tokens2 or tokens2 <= tokens1 or chevauchement >= 0.7:
                groupe.append(a2)

        if len(groupe) < 2:
            continue

        def _score(a):
            return (bool(a.image_url), len(a.contenu or ''), a.date_publication or timezone.now())

        meilleure = max(groupe, key=_score)
        for a in groupe:
            traites.add(a.id)
            if a.id != meilleure.id:
                a.statut = 'archive'
                a.save(update_fields=['statut'])
                archivees += 1

    logger.info('Déduplication actualités : %s doublon(s) archivé(s).', archivees)
    return archivees


def backfiller_metadonnees_actualites():
    """Va chercher la vraie image et la vraie date/heure de publication des actualités
    déjà en base qui n'en ont pas encore (indexées avant l'ajout de cette extraction).
    Retourne le nombre de fiches effectivement enrichies (image et/ou date trouvée)."""
    enrichies = 0
    a_traiter = list(
        Actualite.objects.filter(image_url__isnull=True).exclude(source_url__isnull=True).exclude(source_url='')
    )

    for actualite in a_traiter:
        meta = recherche_web.extraire_metadonnees_article(actualite.source_url)
        image_locale = recherche_web.telecharger_image_locale(meta['image']) if meta['image'] else None
        if not image_locale and not meta['date_publication']:
            continue
        if image_locale:
            actualite.image_url = image_locale[:255]
        if meta['date_publication']:
            actualite.date_publication = meta['date_publication']
        actualite.save(update_fields=['image_url', 'date_publication'])
        enrichies += 1

    logger.info('Backfill métadonnées actualités : %s/%s enrichie(s).', enrichies, len(a_traiter))
    return enrichies
