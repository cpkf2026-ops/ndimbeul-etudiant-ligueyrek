"""
Recherche dans NOS données réelles (établissements, offres d'emploi/stage/bourse)
pour ancrer les réponses du chat sur l'application plutôt que sur le seul savoir
général du LLM (Tâche 3 du cahier des charges : "le chat répond à partir de NOTRE
base grâce à une recherche avant génération").

Recherche par mots-clés (pas d'embeddings) : rapide, sans coût CPU supplémentaire
sur un serveur déjà contraint (sans GPU) — la précision sémantique n'est pas
critique ici, le LLM reste capable de faire le lien avec une formulation différente
tant que les bons enregistrements sont dans le CONTEXTE.
"""
import re

from django.db.models import Q

from veille.models import OffreEmploi, Universite

_MOTS_VIDES = {
    'le', 'la', 'les', 'de', 'des', 'du', 'un', 'une', 'et', 'ou', 'est', 'pour',
    'sur', 'dans', 'avec', 'que', 'qui', 'quoi', 'comment', 'quel', 'quelle',
    'quels', 'quelles', 'au', 'aux', 'en', 'ce', 'cette', 'ces', 'mon', 'ma', 'mes',
    'je', 'tu', 'il', 'elle', 'nous', 'vous', 'ils', 'elles', 'sont', 'être', 'avoir',
}


def _mots_cles(question, max_mots=6):
    mots = re.findall(r"[a-zàâäéèêëïîôöùûüçA-ZÀÂÄÉÈÊËÏÎÔÖÙÛÜÇ]{3,}", question.lower())
    return [m for m in mots if m not in _MOTS_VIDES][:max_mots]


def rechercher_etablissements(question, limite=2):
    """Établissements dont le nom/la description/la région matchent un mot-clé de la
    question. Retourne le même format que rag_pipeline.rechercher() pour être
    mélangeable dans le même CONTEXTE."""
    mots = _mots_cles(question)
    if not mots:
        return []

    condition = Q()
    for mot in mots:
        condition |= Q(nom__icontains=mot) | Q(description__icontains=mot) | Q(region__icontains=mot)

    resultats = Universite.objects.filter(statut_actif=True).filter(condition)[:limite]
    return [
        {
            'titre': u.nom,
            'texte': (
                f"{u.nom} — établissement {u.type}, {u.region or 'région non précisée'}"
                f"{f', {u.commune}' if u.commune else ''}. "
                f"{(u.description or '')[:150]}"
            ).strip(),
            'categorie': 'etablissement',
            'document_id': str(u.id),
            'url': u.site_web_officiel or None,
            'score': 1.0,
        }
        for u in resultats
    ]


def rechercher_offres(question, limite=2):
    """Offres d'emploi/stage/bourse actives correspondant à un mot-clé de la question."""
    mots = _mots_cles(question)
    if not mots:
        return []

    condition = Q()
    for mot in mots:
        condition |= Q(intitule__icontains=mot) | Q(domaine__icontains=mot) | Q(description__icontains=mot)

    resultats = OffreEmploi.objects.filter(statut='active').filter(condition)[:limite]
    return [
        {
            'titre': o.intitule,
            'texte': (
                f"{o.intitule} — {o.entreprise or 'entreprise non précisée'} "
                f"({o.type}, {o.region or 'région non précisée'}). {(o.description or '')[:150]}"
            ).strip(),
            'categorie': 'offre',
            'document_id': str(o.id),
            'url': o.source_url or None,
            'score': 1.0,
        }
        for o in resultats
    ]


def rechercher(question, limite_par_categorie=2):
    """Combine établissements + offres pertinents pour la question."""
    return rechercher_etablissements(question, limite_par_categorie) + rechercher_offres(question, limite_par_categorie)
