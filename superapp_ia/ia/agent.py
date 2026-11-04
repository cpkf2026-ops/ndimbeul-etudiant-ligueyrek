"""
Chatbot à outils : Gemini comprend la question, choisit lui-même où chercher (base Ndimbeul,
sites officiels), puis rédige une réponse claire à partir de ce qu'il a trouvé.

Pourquoi : avec le petit modèle local, chaque nouvelle façon de poser une question demandait
une règle écrite à la main (« merci » en fin de phrase, « emploie » mal orthographié, ville prise
pour un métier…). Un grand modèle comprend ces variantes de lui-même.

Fiabilité (mêmes exigences qu'avant) :
  - Gemini ne connaît que ce que renvoient les outils : consigne de ne rien affirmer d'autre ;
  - après génération, un chiffre ou un mois absent des résultats d'outils -> réponse refusée,
    le chatbot local répond à la place (services.texte.chiffres_inventes) ;
  - les liens absents des résultats d'outils sont retirés ;
  - pas d'information fiable -> on le dit et on donne le site / les contacts de l'établissement.

Si Gemini est indisponible (pas de clé, quota gratuit atteint, panne), `repondre` retourne None
et ia/chatbot.py utilise le chatbot local.
"""
import json
import logging
import re
import time
from datetime import date

from django.conf import settings
from django.db import DatabaseError
from django.db.models import Q

from services import cache, gemini_service, sources as sources_confiance, tavily_service, texte

from . import etablissements_chat

logger = logging.getLogger(__name__)

NB_MAX_RESULTATS = 15
NB_SOURCES_AFFICHEES = 6

INSTRUCTION = """Tu es l'assistant de Ndimbeul Étudiant, une application d'orientation pour les élèves \
et étudiants au Sénégal (bac, universités, instituts, formations, bourses, concours, stages, emplois).
Nous sommes le {date}.

Règles impératives :
1. Réponds EXACTEMENT à la question posée, en tenant compte de la conversation (« cette université », \
« et à Thiès ? » renvoient aux messages précédents).
2. Pour toute information factuelle (établissements, formations, frais, dates, conditions, offres, bourses, \
actualités), utilise d'abord les outils. N'affirme RIEN qui ne figure pas dans leurs résultats : jamais de \
montant, de date, de moyenne, de nombre ou de lien inventé ou « habituel ».
3. Si les outils de la base ne suffisent pas, utilise recherche_web (sites officiels). Si rien de fiable \
n'est trouvé, dis-le honnêtement et donne le site officiel et les contacts de l'établissement \
(outil fiche_etablissement), ou Campusen (https://campusen.sn) et le ministère (https://mesrisenegal.sn).
4. Quand un chiffre vient d'une page précise (ex. frais d'UNE formation), précise à quoi il s'applique, \
et rappelle que montants et dates peuvent changer : vérifier sur le site officiel avant toute démarche. \
Ne généralise jamais un chiffre (pas de « généralement », « en général », « habituellement » devant un \
montant, une date ou une moyenne) : dis d'où il vient.
5. Pour une liste (établissements, offres, formations), donne TOUS les résultats pertinents des outils, \
pas seulement deux ou trois grands noms.
6. Écris en français simple, en tutoyant, de façon claire et courte (listes à puces si utile). \
Pas de titre Markdown, pas de tableau.
7. Remerciements, salutations, remarques sur tes réponses : réponds naturellement et brièvement, sans outil. \
Question sans rapport avec les études, l'orientation ou l'emploi : explique poliment ton rôle.
{profil}"""

OUTILS = [
    {
        'name': 'chercher_etablissements',
        'description': "Universités, instituts et écoles du Sénégal présents dans la base, filtrés par nom, "
                       "ville/région, domaine d'études et statut. À utiliser pour « où étudier X », "
                       "« écoles privées à Thiès », « universités publiques »…",
        'parameters': {'type': 'object', 'properties': {
            'nom': {'type': 'string', 'description': 'Nom ou sigle (ex. UCAD, ISEP, Bambey)'},
            'ville': {'type': 'string', 'description': 'Ville ou région (ex. Thiès, Saint-Louis)'},
            'domaine': {'type': 'string', 'description': "Domaine d'études (ex. informatique, droit, santé)"},
            'statut': {'type': 'string', 'enum': ['public', 'prive']},
        }},
    },
    {
        'name': 'fiche_etablissement',
        'description': "Fiche complète d'UN établissement : statut, adresse, site officiel, téléphone, e-mail, "
                       "domaines, diplômes, conditions d'admission, pièces à fournir, formations et frais connus.",
        'parameters': {'type': 'object', 'properties': {
            'nom': {'type': 'string', 'description': "Nom ou sigle de l'établissement"},
        }, 'required': ['nom']},
    },
    {
        'name': 'chercher_formations',
        'description': "Formations (licence, master, BTS…) de la base, avec l'établissement, la ville, les séries "
                       "de bac acceptées et la moyenne minimale quand elles sont connues.",
        'parameters': {'type': 'object', 'properties': {
            'mot_cle': {'type': 'string', 'description': 'Filière ou domaine (ex. informatique, comptabilité)'},
            'ville': {'type': 'string'},
            'niveau': {'type': 'string', 'description': 'licence, master, bts, doctorat…'},
            'serie_bac': {'type': 'string', 'description': 'Série du bac (ex. S2, L1, G)'},
        }},
    },
    {
        'name': 'chercher_offres',
        'description': "Offres ACTIVES et vérifiées : emplois, stages, alternances, formations, bourses, concours "
                       "(mises à jour toutes les 2 h par la veille).",
        'parameters': {'type': 'object', 'properties': {
            'type': {'type': 'string', 'enum': ['emploi', 'stage', 'alternance', 'formation', 'bourse', 'concours']},
            'ville': {'type': 'string'},
            'mot_cle': {'type': 'string', 'description': 'Métier ou domaine (ex. comptable, informatique)'},
        }},
    },
    {
        'name': 'chercher_actualites',
        'description': "Actualités récentes et vérifiées de l'enseignement supérieur au Sénégal "
                       "(bac, Campusen, bourses, concours, événements universitaires).",
        'parameters': {'type': 'object', 'properties': {
            'mot_cle': {'type': 'string'},
            'categorie': {'type': 'string', 'enum': ['bourse', 'concours', 'evenement', 'formation', 'general']},
        }},
    },
    {
        'name': 'chercher_bourses',
        'description': 'Bourses connues dans la base (nationales ou liées à un établissement).',
        'parameters': {'type': 'object', 'properties': {'mot_cle': {'type': 'string'}}},
    },
    {
        'name': 'recherche_web',
        'description': "Recherche sur Internet, limitée aux sites officiels et à la presse reconnue (ou au site "
                       "d'un établissement précis). À utiliser quand la base ne suffit pas : frais, dates, "
                       "calendrier, procédure d'inscription, actualité très récente.",
        'parameters': {'type': 'object', 'properties': {
            'requete': {'type': 'string', 'description': 'Recherche précise en français'},
            'etablissement': {'type': 'string', 'description': "Si la question porte sur UN établissement : "
                                                               "son nom, pour chercher sur son site officiel"},
        }, 'required': ['requete']},
    },
]


# --- Outils ------------------------------------------------------------------------------

def _norm(valeur):
    return cache.normaliser_texte(valeur or '')


def _filtre_lieu(ville, champ_region='region', champ_commune='commune'):
    if not ville:
        return Q()
    from veille import lieux
    v = lieux.ville_dans(ville)
    noms = {ville.strip()} | ({v[0], v[1]} if v else set())
    condition = Q()
    for n in noms:
        condition |= Q(**{f'{champ_region}__icontains': n}) | Q(**{f'{champ_commune}__icontains': n})
    return condition


def _etablissement(nom):
    from veille.models import Universite
    u = etablissements_chat.trouver(nom or '')
    if u:
        return Universite.objects.filter(id=u['id']).first()
    return (Universite.objects.filter(statut_actif=True, deleted_at__isnull=True)
            .filter(Q(nom__icontains=nom) | Q(code_unique__iexact=nom)).first())


def chercher_etablissements(nom=None, ville=None, domaine=None, statut=None):
    from recommandations import domaines as thesaurus
    from recommandations.models import Formation
    from veille.models import Universite

    qs = Universite.objects.filter(statut_actif=True, deleted_at__isnull=True)
    if nom:
        u = etablissements_chat.trouver(nom)
        qs = qs.filter(id=u['id']) if u else qs.filter(Q(nom__icontains=nom) | Q(code_unique__icontains=nom))
    if ville:
        qs = qs.filter(_filtre_lieu(ville))
    if statut:
        qs = qs.filter(type=statut)
    etabs = list(qs)
    if domaine:
        demandes = thesaurus.domaines_du_texte(domaine)
        racine = _norm(domaine)[:6]
        ids_formations = set(
            Formation.objects.filter(deleted_at__isnull=True, universite_id__in=[e.id for e in etabs])
            .filter(Q(intitule__icontains=racine) | Q(domaine__icontains=racine)).values_list('universite_id', flat=True))
        gardes = []
        for e in etabs:
            texte_e = f"{e.nom} {json.dumps(e.domaines or [], ensure_ascii=False)} {e.description or ''}"
            if e.id in ids_formations or (demandes and thesaurus.domaines_du_texte(texte_e) & demandes) \
                    or racine in _norm(texte_e):
                gardes.append(e)
        etabs = gardes
    total = len(etabs)
    etabs.sort(key=lambda e: (_norm(e.region) != 'dakar', e.nom))
    return {
        'total': total,
        'etablissements': [{
            'nom': e.nom, 'statut': e.type or 'non précisé', 'ville': e.commune, 'region': e.region,
            'site_officiel': e.site_web_officiel, 'domaines': e.domaines,
        } for e in etabs[:40]],
    }


def fiche_etablissement(nom):
    from recommandations.models import Formation, FraisScolarite
    e = _etablissement(nom)
    if e is None:
        return {'erreur': f"Aucun établissement « {nom} » dans la base."}
    formations = list(Formation.objects.filter(universite_id=e.id, deleted_at__isnull=True)
                      .values('id', 'intitule', 'niveau', 'domaine', 'series_acceptees', 'moyenne_minimale')[:60])
    frais = {f['formation_id']: f['montant'] for f in
             FraisScolarite.objects.filter(universite_id=e.id).values('formation_id', 'montant')}
    return {
        'nom': e.nom, 'statut': e.type or 'non précisé', 'ville': e.commune, 'region': e.region,
        'adresse': e.adresse, 'site_officiel': e.site_web_officiel, 'telephone': e.telephone_contact,
        'email': e.email_contact, 'description': e.description, 'domaines': e.domaines,
        'diplomes': e.diplomes, 'admission': e.admission, 'niveau_requis': e.niveau_requis,
        'pieces_a_fournir': e.pieces_a_fournir, 'source_des_infos': e.source_infos,
        'frais_generaux_connus': str(frais[None]) + ' FCFA' if frais.get(None) else None,
        'formations': [{
            'intitule': f['intitule'], 'niveau': f['niveau'], 'domaine': f['domaine'],
            'series_bac': f['series_acceptees'],
            'moyenne_minimale': str(f['moyenne_minimale']) if f['moyenne_minimale'] else None,
            'frais': str(frais[f['id']]) + ' FCFA' if frais.get(f['id']) else None,
        } for f in formations],
        '_source': {'titre': e.nom, 'url': e.site_web_officiel},
    }


def chercher_formations(mot_cle=None, ville=None, niveau=None, serie_bac=None):
    from recommandations.models import Formation
    qs = Formation.objects.select_related('universite').filter(
        deleted_at__isnull=True, universite__statut_actif=True)
    if mot_cle:
        racine = _norm(mot_cle)[:6] if len(_norm(mot_cle)) > 6 else _norm(mot_cle)
        qs = qs.filter(Q(intitule__icontains=racine) | Q(domaine__icontains=racine) | Q(debouches__icontains=racine))
    if niveau:
        qs = qs.filter(niveau__icontains=niveau)
    if ville:
        qs = qs.filter(_filtre_lieu(ville, 'universite__region', 'universite__commune'))
    resultats = []
    for f in qs[:200]:
        if serie_bac and f.series_acceptees and serie_bac.upper() not in [str(s).upper() for s in f.series_acceptees]:
            continue
        resultats.append({
            'intitule': f.intitule, 'niveau': f.niveau, 'etablissement': f.universite.nom,
            'ville': f.universite.commune or f.universite.region, 'statut': f.universite.type,
            'series_bac': f.series_acceptees,
            'moyenne_minimale': str(f.moyenne_minimale) if f.moyenne_minimale else None,
        })
    return {'total': len(resultats), 'formations': resultats[:40]}


def chercher_offres(type=None, ville=None, mot_cle=None):  # noqa: A002 (nom imposé par l'outil)
    from veille.models import OffreEmploi
    qs = OffreEmploi.objects.filter(statut='active')
    if type:
        qs = qs.filter(type=type)
    if ville:
        qs = qs.filter(region__icontains=ville)
    if mot_cle:
        racine = _norm(mot_cle)[:6]
        qs = qs.filter(Q(intitule__icontains=racine) | Q(domaine__icontains=racine) | Q(description__icontains=racine))
    offres = list(qs.order_by('-date_indexation')[:NB_MAX_RESULTATS])
    return {
        'total': qs.count(),
        'offres': [{
            'intitule': o.intitule, 'entreprise': o.entreprise, 'type': o.type, 'lieu': o.region,
            'date_limite': o.date_limite.isoformat() if o.date_limite else None,
            'resume': (o.resume or o.description or '')[:300], 'lien': o.source_url,
        } for o in offres],
    }


def chercher_actualites(mot_cle=None, categorie=None):
    from veille.models import Actualite
    qs = Actualite.objects.filter(statut='publie')
    if categorie:
        qs = qs.filter(categorie=categorie)
    if mot_cle:
        racine = _norm(mot_cle)[:6]
        qs = qs.filter(Q(titre__icontains=racine) | Q(contenu__icontains=racine))
    return {'actualites': [{
        'titre': a.titre, 'resume': (a.contenu or '')[:400], 'source': a.source_nom,
        'date': a.date_publication.date().isoformat() if a.date_publication else None, 'lien': a.source_url,
    } for a in qs.order_by('-date_publication')[:10]]}


def chercher_bourses(mot_cle=None):
    from recommandations.models import Bourse
    qs = Bourse.objects.all()
    if mot_cle:
        qs = qs.filter(nom__icontains=mot_cle)
    return {'bourses': [{
        'nom': b.nom, 'montant': str(b.montant) + ' FCFA' if b.montant else None,
        'date_limite': b.date_limite.isoformat() if b.date_limite else None,
    } for b in qs[:20]], 'conseil': "Voir aussi chercher_actualites(categorie='bourse') et chercher_offres(type='bourse')."}


def recherche_web(requete, etablissement=None, *, echeance=None):
    if etablissement:
        e = _etablissement(etablissement)
        if e is None or not e.site_web_officiel:
            return {'resultats': [], 'info': "Pas de site officiel connu pour cet établissement : utilise "
                                             "fiche_etablissement pour ses contacts."}
        domaines = [re.sub(r'^https?://(www\.)?', '', e.site_web_officiel).split('/')[0]]
    else:
        domaines = sources_confiance.domaines(
            sources_confiance.ORIENTATION, sources_confiance.ACTUALITES, sources_confiance.EMPLOI)
    reste = (echeance - time.monotonic() - 4) if echeance else settings.TAVILY_TIMEOUT_SECONDES
    if reste < 3:
        return {'resultats': [], 'info': 'Plus assez de temps pour une recherche web.'}
    try:
        resultats = tavily_service.rechercher(
            requete, module='chat', include_domains=domaines, max_results=5,
            timeout=min(settings.TAVILY_TIMEOUT_SECONDES, int(reste)))
    except tavily_service.TavilyIndisponibleError as exc:
        return {'resultats': [], 'info': f'Recherche web indisponible ({exc}).'}
    return {'resultats': [{
        'titre': r['titre'], 'lien': r['url'], 'extrait': (r['contenu'] or '')[:1500],
        'date': r.get('date_publication'),
    } for r in resultats]}


_FONCTIONS = {
    'chercher_etablissements': chercher_etablissements,
    'fiche_etablissement': fiche_etablissement,
    'chercher_formations': chercher_formations,
    'chercher_offres': chercher_offres,
    'chercher_actualites': chercher_actualites,
    'chercher_bourses': chercher_bourses,
    'recherche_web': recherche_web,
}


def _executer(nom, arguments, echeance):
    fonction = _FONCTIONS.get(nom)
    if fonction is None:
        return {'erreur': f'outil inconnu : {nom}'}
    arguments = {k: v for k, v in (arguments or {}).items() if v not in (None, '')}
    try:
        if nom == 'recherche_web':
            return fonction(**arguments, echeance=echeance)
        return fonction(**arguments)
    except TypeError as exc:
        return {'erreur': f'paramètres invalides : {exc}'}
    except DatabaseError as exc:
        logger.warning('Agent : outil %s, base indisponible : %s', nom, exc)
        return {'erreur': 'base de données indisponible'}


def _sources_du_resultat(resultat):
    """(titre, url) des éléments renvoyés par un outil, pour les afficher sous la réponse."""
    trouvees = []
    if not isinstance(resultat, dict):
        return trouvees
    if resultat.get('_source', {}).get('url'):
        trouvees.append(resultat['_source'])
    for cle in ('offres', 'actualites', 'resultats'):
        for element in resultat.get(cle) or []:
            if element.get('lien'):
                trouvees.append({'titre': element.get('intitule') or element.get('titre'), 'url': element['lien'],
                                 'web': cle == 'resultats'})
    for e in resultat.get('etablissements') or []:
        if e.get('site_officiel'):
            trouvees.append({'titre': e['nom'], 'url': e['site_officiel']})
    return trouvees


# --- Conversation ------------------------------------------------------------------------

def _profil_texte(profil):
    if not profil:
        return ''
    utiles = {k: v for k, v in profil.items() if v not in (None, '', [], {}) and k in (
        'serie_bac', 'moyenne', 'region', 'niveau_etudes', 'passions', 'matieres_preferees',
        'projet_professionnel', 'metier_vise', 'statut_prefere', 'statut')}
    return ('\nProfil de l\'élève (pour personnaliser, sans le répéter) : '
            + json.dumps(utiles, ensure_ascii=False)) if utiles else ''


def _historique_gemini(historique):
    contenus = []
    for tour in historique or []:
        contenu = str(tour.get('contenu') or tour.get('content') or '').strip()
        if not contenu:
            continue
        role = 'model' if tour.get('role') == 'assistant' else 'user'
        if contenus and contenus[-1]['role'] == role:
            contenus[-1]['parts'][0]['text'] += '\n' + contenu[:3000]
        else:
            contenus.append({'role': role, 'parts': [{'text': contenu[:3000]}]})
    while contenus and contenus[0]['role'] != 'user':
        contenus.pop(0)
    return contenus


_MOIS = ('janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre',
         'octobre', 'novembre', 'décembre')


def _dates_lisibles(texte_outils):
    """Les outils donnent les dates au format ISO (2026-10-31) ; Gemini écrit « 31 octobre 2026 ».
    On ajoute ces écritures au texte autorisé pour que le contrôle des chiffres ne les refuse pas."""
    formes = []
    for annee, mois, jour in re.findall(r'\b(20\d\d)-(\d\d)-(\d\d)\b', texte_outils):
        nom_mois = _MOIS[int(mois) - 1]
        formes.append(f'{int(jour)} {nom_mois} {annee} {jour}/{mois}/{annee} {jour}/{mois} {nom_mois}')
    return ' '.join(formes)


def _retirer_liens_inventes(reponse, texte_autorise):
    def garder(m):
        url = m.group(0).rstrip('.,;:)')
        return m.group(0) if url in texte_autorise or url.split('//')[-1].split('/')[0] in texte_autorise else ''
    return re.sub(r'https?://[^\s)\]]+', garder, reponse)


def repondre(message, profil, historique, echeance):
    """Réponse de Gemini avec outils, ou None (indisponible, délai, contrôle de fiabilité
    échoué) : l'appelant utilise alors le chatbot local."""
    if not gemini_service.disponible():
        return None
    instruction = INSTRUCTION.format(date=date.today().strftime('%d/%m/%Y'), profil=_profil_texte(profil))
    contenus = _historique_gemini(historique) + [{'role': 'user', 'parts': [{'text': message}]}]
    resultats_outils, sources, outils_appeles = [], [], []

    def boucle():
        """Appels successifs à Gemini (et à ses outils) jusqu'à une réponse en texte."""
        for _ in range(settings.GEMINI_MAX_ETAPES + 1):
            reste = echeance - time.monotonic()
            if reste < 3:
                logger.warning('Agent : délai dépassé après %s', outils_appeles)
                return None
            avec_outils = len(outils_appeles) < settings.GEMINI_MAX_ETAPES
            contenu = gemini_service.generer(contenus, instruction_systeme=instruction,
                                             outils=OUTILS if avec_outils else None, timeout=min(15, reste - 1))
            appels = [p['functionCall'] for p in contenu.get('parts', []) if p.get('functionCall')]
            if not appels:
                contenus.append(contenu)
                return ''.join(p.get('text', '') for p in contenu.get('parts', []) if not p.get('thought')).strip()
            contenus.append(contenu)
            reponses_outils = []
            for appel in appels:
                resultat = _executer(appel.get('name'), appel.get('args'), echeance)
                outils_appeles.append(appel.get('name'))
                resultats_outils.append(json.dumps(resultat, ensure_ascii=False, default=str))
                sources.extend(_sources_du_resultat(resultat))
                reponse_outil = {k: v for k, v in resultat.items() if k != '_source'} if isinstance(resultat, dict) else resultat
                reponses_outils.append({'functionResponse': {'name': appel.get('name'),
                                                             'response': {'resultat': reponse_outil}}})
            contenus.append({'role': 'user', 'parts': reponses_outils})
        return None

    def verifier(brute):
        """(réponse nettoyée, chiffres inventés) : liens inventés retirés, chiffres contrôlés."""
        texte_autorise = ' '.join(
            [message, json.dumps(profil or {}, ensure_ascii=False, default=str), *resultats_outils]
            + [str(t.get('contenu') or t.get('content') or '') for t in historique or []])
        # Dates ISO écrites en toutes lettres, date du jour, et barème « /20 » des moyennes.
        texte_autorise += f" {_dates_lisibles(texte_autorise)} {date.today().strftime('%d/%m/%Y')} sur 20 /20"
        propre = _retirer_liens_inventes(brute, texte_autorise)
        propre = re.sub(r'^#+\s*', '', propre, flags=re.M).replace('**', '')
        # Numéros de liste (« 1. », « 2) ») : de la mise en forme, pas des informations.
        a_controler = re.sub(r'^\s*\d{1,2}[.)]\s', '', propre, flags=re.M)
        return propre, texte.chiffres_inventes(a_controler, texte_autorise)

    try:
        reponse = boucle()
        if not reponse:
            return None
        reponse, inventes = verifier(reponse)
        if inventes and echeance - time.monotonic() > 5:
            # Une seconde chance : on signale à Gemini les chiffres qu'il n'a pas trouvés dans les
            # outils (souvent tirés de sa mémoire, donc non vérifiés), il réécrit sans eux.
            logger.warning('Agent : chiffres absents des outils %s, réécriture demandée', inventes)
            contenus.append({'role': 'user', 'parts': [{'text': (
                f"Contrôle de fiabilité : ces chiffres ne figurent dans aucun résultat d'outil : "
                f"{', '.join(sorted(inventes))}. Réécris ta réponse SANS eux. Si l'information manque, "
                "dis-le et renvoie vers le site officiel ou les contacts de l'établissement.")}]})
            reponse = boucle()
            if not reponse:
                return None
            reponse, inventes = verifier(reponse)
    except gemini_service.GeminiIndisponibleError as exc:
        logger.warning('Agent : Gemini indisponible, repli sur le chatbot local (%s)', exc)
        return None
    if inventes:
        logger.warning('Agent : réponse refusée, chiffres absents des outils %s : %s', inventes, reponse[:200])
        return None
    # Sources affichées : les pages lues sur le web (base de la réponse) et les éléments de la
    # base cités dans la réponse (offre, actualité, établissement nommé).
    vues, uniques = set(), []
    for s in sources:
        lue_sur_le_web = s.get('web')
        citee = s['url'] in reponse or (s.get('titre') and _norm(s['titre'])[:25] in _norm(reponse))
        if s.get('url') and s['url'] not in vues and (lue_sur_le_web or citee):
            vues.add(s['url'])
            uniques.append({'titre': s.get('titre') or s['url'], 'url': s['url']})
    logger.info('Agent : réponse avec outils %s', outils_appeles or 'aucun')
    return {
        'reponse': reponse,
        'sources': uniques[:NB_SOURCES_AFFICHEES],
        'recherche_web': 'recherche_web' in outils_appeles,
        'avertissements': [],
        'moteur': 'gemini',
    }
