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

from recommandations.models import Formation
from services.texte import extrait_pertinent
from veille.models import Actualite, OffreEmploi, Universite

from .models import DocumentRAG

_MOTS_VIDES = {
    'le', 'la', 'les', 'de', 'des', 'du', 'un', 'une', 'et', 'ou', 'est', 'pour',
    'sur', 'dans', 'avec', 'que', 'qui', 'quoi', 'comment', 'quel', 'quelle',
    'quels', 'quelles', 'au', 'aux', 'en', 'ce', 'cette', 'ces', 'mon', 'ma', 'mes',
    'je', 'tu', 'il', 'elle', 'nous', 'vous', 'ils', 'elles', 'sont', 'être', 'avoir',
    # Tournures de demande, sans contenu à chercher (« je veux savoir si… y'a… »).
    'veux', 'voudrais', 'aimerais', 'savoir', 'connaître', 'connaitre', 'dire', 'donne',
    'donner', 'peux', 'pouvez', 'faut', 'fait', 'faire', 'est-ce', 'ici', 'aussi', 'merci',
    'stp', 'svp', 'bonjour', 'salut', 'okay', 'avez', 'existe', 'existent', 'plus', 'tout',
    'quand', 'combien', 'pourquoi', 'lieu', 'cette', 'année', 'annee', 'actuellement',
}


def _sigle(universite):
    """'UCAD' -> ' (UCAD)' pour que la question « à l'UCAD » retrouve la fiche. Les
    sigles de moins de 3 lettres (générés automatiquement, ex. 'C') sont ignorés."""
    code = (universite.code_unique or '').strip()
    return f' ({code})' if len(code) >= 3 else ''


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
        condition |= (
            Q(nom__icontains=mot) | Q(code_unique__icontains=mot)
            | Q(description__icontains=mot) | Q(region__icontains=mot)
        )

    resultats = Universite.objects.filter(statut_actif=True).filter(condition)[:limite]
    return [
        {
            'titre': u.nom,
            'texte': (
                f"{u.nom}{_sigle(u)} — établissement {u.type}, {u.region or 'région non précisée'}"
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


def rechercher_formations(question, limite=3):
    """Formations (intitulé, domaine, débouchés) correspondant à un mot-clé, avec leur
    établissement et leurs conditions d'admission."""
    mots = _mots_cles(question)
    if not mots:
        return []

    condition = Q()
    for mot in mots:
        condition |= (
            Q(intitule__icontains=mot) | Q(domaine__icontains=mot) | Q(debouches__icontains=mot)
            | Q(universite__nom__icontains=mot) | Q(universite__code_unique__icontains=mot)
        )

    resultats = (
        Formation.objects.select_related('universite')
        .filter(deleted_at__isnull=True, universite__statut_actif=True).filter(condition)[:limite]
    )
    documents = []
    for f in resultats:
        conditions = []
        if f.series_acceptees:
            conditions.append(f"séries acceptées : {', '.join(f.series_acceptees)}")
        if f.moyenne_minimale:
            conditions.append(f'moyenne minimale : {f.moyenne_minimale}/20')
        documents.append({
            'titre': f'{f.intitule} ({f.universite.nom})',
            'texte': (
                f"{f.intitule} — {f.niveau}, {f.domaine or 'domaine non précisé'}, à {f.universite.nom}{_sigle(f.universite)}. "
                f"{'; '.join(conditions) + '. ' if conditions else ''}"
                f"{'Débouchés : ' + f.debouches if f.debouches else ''}"
            ).strip(),
            'categorie': 'formation',
            'document_id': str(f.id),
            'url': f.universite.site_web_officiel or None,
            'score': 1.0,
        })
    return documents


def rechercher_actualites(question, limite=2):
    """Actualités publiées par la veille (module 3) correspondant à un mot-clé."""
    mots = _mots_cles(question)
    if not mots:
        return []

    condition = Q()
    for mot in mots:
        condition |= Q(titre__icontains=mot) | Q(contenu__icontains=mot)

    resultats = Actualite.objects.filter(statut='publie').filter(condition).order_by('-date_publication')[:limite]
    return [
        {
            'titre': a.titre,
            'texte': (
                f"{a.titre} ({a.source_nom or 'source'}, "
                f"{a.date_publication.strftime('%d/%m/%Y') if a.date_publication else 'date inconnue'}). {a.contenu}"
            ),
            'categorie': 'actualite',
            'document_id': str(a.id),
            'url': a.source_url or None,
            'score': 1.0,
        }
        for a in resultats
    ]


def rechercher_documents(question, limite=3):
    """Documents importés par l'administrateur (PDF, textes : table `documents_rag`),
    retrouvés par mots-clés dans leur texte intégral déjà stocké en base.

    Remplace, pour le chat, la recherche sémantique FAISS : celle-ci chargeait torch
    (~1 Go de RAM, ~45 s au premier message) et bloquait un PC de 10 Go. Les documents
    importés restent ainsi consultables par le chat, sans ce coût."""
    mots = _mots_cles(question)
    if not mots:
        return []

    condition = Q()
    for mot in mots:
        condition |= Q(titre__icontains=mot) | Q(contenu_texte__icontains=mot)

    resultats = DocumentRAG.objects.select_related('source').filter(condition)[:limite]
    return [
        {
            'titre': d.titre or 'Document',
            'texte': extrait_pertinent(d.contenu_texte, mots, 600),
            'categorie': 'document',
            'document_id': str(d.id),
            'url': d.source.url_ou_chemin if d.source.type == 'url' else None,
            'score': 1.0,
        }
        for d in resultats
    ]


def rechercher_tout(question, limite_par_categorie=15):
    """Toute notre base (module 4) : établissements, formations, offres, actualités et
    documents importés. Ramène largement (un seul mot-clé suffit à remonter une ligne) :
    c'est le chatbot qui classe ensuite les candidats selon le nombre de mots retrouvés."""
    return (
        rechercher_etablissements(question, limite_par_categorie)
        # Catalogue de formations plus large (quelques centaines de lignes) : on en
        # remonte davantage pour que le classement trouve la plus précise.
        + rechercher_formations(question, limite_par_categorie * 4)
        + rechercher_offres(question, limite_par_categorie)
        + rechercher_actualites(question, limite_par_categorie)
        + rechercher_documents(question)
    )
