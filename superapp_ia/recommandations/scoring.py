"""
Moteur de recommandation (PARTIE 8) — deux étapes bien séparées, comme demandé :

  1) FILTRAGE PAR RÈGLES (éliminatoire) : une formation dont la série de bac du
     profil n'est pas dans `series_acceptees` est retirée AVANT tout scoring —
     on ne recommande JAMAIS une filière incompatible avec la série du bac, quel
     que soit son score sur les autres critères.

  2) CLASSEMENT PAR SCORE des formations survivantes, sur 100 points :
       - Compatibilité série bac (déjà garantie par le filtrage, toujours pleine
         note pour les survivantes — affichée pour la transparence) .... 35 pts
       - Matching domaine/passions (similarité sémantique) .............. 30 pts
       - Matières fortes (similarité sémantique avec le domaine/intitulé) 15 pts
       - Région cible correspondante ..................................... 10 pts
       - Bourse disponible ................................................ 10 pts

Le champ budget a été volontairement retiré (voir migration
2026_09_23_000002_drop_budget_add_matieres_fortes_to_profils_lyceens_table) : son poids (15 pts)
a été redistribué vers le nouveau critère "matières fortes".
"""
from datetime import date

import numpy as np
from django.db.models import Q

from ia.embeddings import encoder_texte, encoder_textes, similarite_cosinus

from .models import Bourse, Formation

POIDS_SERIE_BAC = 35.0
POIDS_DOMAINE_PASSIONS = 30.0
POIDS_MATIERES_FORTES = 15.0
POIDS_REGION = 10.0
POIDS_BOURSE = 10.0


def _est_compatible_serie(formation, serie_bac):
    """Règle éliminatoire : pas de restriction renseignée => ouverte à toutes les séries."""
    if not serie_bac or not formation.series_acceptees:
        return True
    return serie_bac in formation.series_acceptees


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
    region_universite = getattr(formation.universite, 'region', None)
    if not region_cible or not region_universite:
        return 0.0
    return POIDS_REGION if region_universite.strip().lower() == region_cible.strip().lower() else 0.0


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
    return np.array([_CACHE_EMBEDDINGS_FORMATION[f.id] for f in formations])


def _texte_profil(profil):
    morceaux = list(profil.get('passions') or []) + list(profil.get('metiers_envisages') or [])
    return ' '.join(morceaux)


def _texte_matieres_fortes(profil):
    return ' '.join(profil.get('matieres_fortes') or [])


def generer_recommandations(profil, limite=10):
    """Retourne les `limite` meilleures formations COMPATIBLES avec la série de bac,
    triées par score décroissant.

    Chaque élément : {'formation': Formation, 'score': float, 'details': {...sous-scores}}.
    """
    serie_bac = profil.get('serie_bac')

    formations_candidates = list(
        Formation.objects.select_related('universite').filter(
            deleted_at__isnull=True, universite__statut_actif=True
        )
    )
    # 1) FILTRAGE ÉLIMINATOIRE — jamais de filière incompatible avec la série du bac.
    formations = [f for f in formations_candidates if _est_compatible_serie(f, serie_bac)]
    if not formations:
        return []

    texte_profil = _texte_profil(profil)
    embedding_profil = encoder_texte(texte_profil) if texte_profil.strip() else None

    texte_matieres = _texte_matieres_fortes(profil)
    embedding_matieres = encoder_texte(texte_matieres) if texte_matieres.strip() else None

    besoin_embeddings_formations = embedding_profil is not None or embedding_matieres is not None
    embeddings_formations = _encoder_formations_avec_cache(formations) if besoin_embeddings_formations else None

    universites_avec_bourse_active = _precharger_universites_avec_bourse_active()

    region_cible = profil.get('region_cible')
    mobilite = bool(profil.get('mobilite'))

    # 2) CLASSEMENT PAR SCORE des formations restantes.
    resultats = []
    for i, formation in enumerate(formations):
        embedding_formation = embeddings_formations[i] if embeddings_formations is not None else None

        details = {
            'serie_bac': POIDS_SERIE_BAC,  # garanti par le filtrage ci-dessus
            'domaine_passions': _score_domaine_passions(embedding_profil, embedding_formation),
            'matieres_fortes': _score_matieres_fortes(embedding_matieres, embedding_formation),
            'region': _score_region(formation, region_cible, mobilite),
            'bourse': _score_bourse(formation, universites_avec_bourse_active),
        }
        score_total = round(sum(details.values()), 2)
        resultats.append({'formation': formation, 'score': score_total, 'details': details})

    resultats.sort(key=lambda r: r['score'], reverse=True)
    return resultats[:limite]
