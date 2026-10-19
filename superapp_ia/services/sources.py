"""
Sources de confiance transmises à Tavily (`include_domains`), par catégorie.

La liste de référence vit dans la table `sources_confiance`, modifiable depuis le
back-office Laravel. Les valeurs ci-dessous servent :
  - à remplir cette table la première fois (`python manage.py charger_sources`) ;
  - de repli pour une catégorie qui n'a encore aucune ligne en base.

Choix éditoriaux (cohérents avec veille/fiabilite.py) :
  - emploisenegal.com est volontairement ABSENT : le site protège ses pages par un
    challenge anti-robots, les contourner irait contre ses conditions d'utilisation ;
  - réseaux sociaux, blogs et agrégateurs ne sont jamais des sources de confiance.
"""
import logging

from django.db import DatabaseError

from .models import SourceConfiance

logger = logging.getLogger(__name__)

ORIENTATION = 'orientation'
EMPLOI = 'emploi'
ACTUALITES = 'actualites'
CATEGORIES = (ORIENTATION, EMPLOI, ACTUALITES)

SOURCES_PAR_DEFAUT = {
    ORIENTATION: [
        ('campusen.sn', "Campusen — plateforme d'orientation des bacheliers"),
        ('mesrisenegal.sn', "Ministère de l'Enseignement supérieur, de la Recherche et de l'Innovation"),
        ('education.sn', "Ministère de l'Éducation nationale"),
        ('officedubac.sn', 'Office du Baccalauréat'),
        ('ucad.sn', 'Université Cheikh Anta Diop de Dakar'),
        ('ugb.sn', 'Université Gaston Berger de Saint-Louis'),
        ('uadb.edu.sn', 'Université Alioune Diop de Bambey'),
        ('uasz.sn', 'Université Assane Seck de Ziguinchor'),
        ('univ-thies.sn', 'Université Iba Der Thiam de Thiès'),
        ('uam.sn', 'Université Amadou Mahtar Mbow'),
        ('unchk.sn', 'Université numérique Cheikh Hamidou Kane'),
        ('ussein.sn', 'Université du Sine Saloum El-Hâdj Ibrahima Niass'),
        ('esp.sn', 'École supérieure polytechnique'),
        ('ept.sn', 'École polytechnique de Thiès'),
        ('isep-thies.sn', 'ISEP Thiès'),
        ('cesag.sn', 'CESAG'),
        ('campusfrance.org', 'Campus France (études à l\'étranger)'),
    ],
    EMPLOI: [
        ('senjob.com', 'Senjob — offres d\'emploi et de stage'),
        ('anpej.sn', "Agence nationale pour la promotion de l'emploi des jeunes"),
        ('fonctionpublique.gouv.sn', 'Ministère de la Fonction publique (concours)'),
        ('onfp.sn', 'Office national de formation professionnelle'),
        ('3fpt.sn', 'Fonds de financement de la formation professionnelle'),
        ('mesrisenegal.sn', 'MESRI (bourses)'),
        ('campusfrance.org', 'Campus France (bourses)'),
        ('auf.org', 'Agence universitaire de la Francophonie (bourses)'),
        ('aps.sn', 'APS (avis de recrutement relayés)'),
        ('lesoleil.sn', 'Le Soleil (avis de recrutement relayés)'),
    ],
    ACTUALITES: [
        ('aps.sn', 'APS — Agence de presse sénégalaise'),
        ('lesoleil.sn', 'Le Soleil'),
        ('seneweb.com', 'Seneweb'),
        ('dakaractu.com', 'Dakaractu'),
        ('pressafrik.com', 'PressAfrik'),
        ('lequotidien.sn', 'Le Quotidien'),
        ('emedia.sn', 'E-Media'),
        ('igfm.sn', 'IGFM'),
        ('senego.com', 'Senego'),
        ('seneplus.com', 'SenePlus'),
        ('mesrisenegal.sn', 'MESRI (communiqués)'),
        ('education.sn', 'Ministère de l\'Éducation nationale (communiqués)'),
        ('campusen.sn', 'Campusen (communiqués)'),
    ],
}


def _sans_doublons(domaines):
    vus = set()
    return [d for d in domaines if not (d in vus or vus.add(d))]


def domaines(*categories):
    """Domaines actifs des catégories demandées, sans doublon, prêts pour
    `include_domains`. Une catégorie présente en base (même entièrement désactivée
    par l'administrateur) utilise la base ; sinon les valeurs par défaut."""
    try:
        lignes = list(
            SourceConfiance.objects.filter(categorie__in=categories)
            .values_list('categorie', 'domaine', 'actif')
        )
    except DatabaseError as exc:
        logger.warning('Table sources_confiance illisible, sources par défaut utilisées : %s', exc)
        lignes = []

    categories_en_base = {categorie for categorie, _, _ in lignes}
    resultat = [domaine for categorie, domaine, actif in lignes if actif]
    for categorie in categories:
        if categorie not in categories_en_base:
            resultat += [domaine for domaine, _ in SOURCES_PAR_DEFAUT[categorie]]
    return _sans_doublons(resultat)


def charger_valeurs_par_defaut():
    """Insère les sources par défaut absentes de la table (idempotent : ne modifie
    jamais une ligne existante, donc respecte les choix faits dans le back-office).
    Retourne le nombre de lignes créées."""
    crees = 0
    for categorie, sources in SOURCES_PAR_DEFAUT.items():
        for domaine, nom in sources:
            _, cree = SourceConfiance.objects.get_or_create(
                domaine=domaine, categorie=categorie, defaults={'nom': nom},
            )
            crees += cree
    return crees
