"""
Outils partagés par la veille Tavily des modules 2 (opportunités) et 3 (actualités) :
dédoublonnage, lecture des dates Tavily, rythme d'exécution en mode réduit.
"""
import hashlib
import logging
import time
import urllib.parse
from pathlib import Path
from datetime import datetime
from email.utils import parsedate_to_datetime

from django.conf import settings
from django.utils import timezone

from services import cache, credits, llm_service

logger = logging.getLogger(__name__)

# Paramètres de suivi publicitaire : ils changent d'un partage à l'autre sans changer
# la page, et feraient passer deux fois la même offre pour deux offres différentes.
_PARAMETRES_DE_SUIVI = ('utm_', 'fbclid', 'gclid', 'xtor', 'at_')


def normaliser_url(url):
    """'https://WWW.Senjob.com/offre/12/?utm_source=x#haut' -> 'senjob.com/offre/12'."""
    morceaux = urllib.parse.urlsplit((url or '').strip())
    hote = (morceaux.hostname or '').lower().removeprefix('www.')
    parametres = [
        (cle, valeur) for cle, valeur in urllib.parse.parse_qsl(morceaux.query)
        if not cle.lower().startswith(_PARAMETRES_DE_SUIVI)
    ]
    requete = urllib.parse.urlencode(sorted(parametres))
    chemin = morceaux.path.rstrip('/')
    return f'{hote}{chemin}' + (f'?{requete}' if requete else '')


def hash_dedoublonnage(url, titre):
    """Empreinte anti-doublon (§ 3, modules 2 et 3) : SHA-256 de l'URL normalisée et du
    titre normalisé (casse, accents, ponctuation). Stockée dans une colonne à index
    unique : la base elle-même refuse un second enregistrement de la même offre."""
    brut = f'{normaliser_url(url)}|{cache.normaliser_texte(titre)}'
    return hashlib.sha256(brut.encode('utf-8')).hexdigest()


def parser_date_tavily(valeur):
    """Tavily renvoie `published_date` au format RFC 2822 ('Sat, 17 Oct 2026 10:00:00
    GMT') ou parfois ISO 8601. Retourne un datetime « aware », ou None si absente ou
    illisible : jamais de date devinée."""
    if not valeur:
        return None
    try:
        date_lue = parsedate_to_datetime(valeur)
    except (TypeError, ValueError):
        try:
            date_lue = datetime.fromisoformat(str(valeur).replace('Z', '+00:00'))
        except ValueError:
            return None
    if timezone.is_naive(date_lue):
        date_lue = timezone.make_aware(date_lue, timezone.get_current_timezone())
    return date_lue


def precharger_modele_veille():
    """Charge Mistral 7B en mémoire AVANT la première fiche : observé le 18/10/2026, son
    chargement (4,4 Go, RAM partagée avec le modèle du chat) a dépassé à lui seul les
    5 min accordées à la première offre, qui était alors perdue. Délai large : c'est une
    tâche de fond."""
    llm_service.precharger(
        llm_service.modele_veille(), keep_alive=settings.OLLAMA_VEILLE_KEEP_ALIVE, timeout=900,
    )


# --- Mémoire des rejets ----------------------------------------------------------
# Un résultat jugé non pertinent par le LLM revient souvent dans les recherches
# suivantes (fenêtre d'une semaine) : sans mémoire, on paierait ~1 min de Mistral
# à chaque passage pour le rejeter à nouveau. Les échecs TECHNIQUES (délai, Ollama
# arrêté, réseau) ne sont pas mémorisés : ils sont retentés au passage suivant.
_DUREE_MEMOIRE_REJET = 7 * 24 * 3600


def _cle_rejet(nom, empreinte):
    return f'ia:veille:{nom}:rejete:{empreinte}'


def marquer_rejete(nom, empreinte):
    cache.ecrire(_cle_rejet(nom, empreinte), 1, _DUREE_MEMOIRE_REJET)


def deja_rejete(nom, empreinte):
    return cache.lire(_cle_rejet(nom, empreinte)) is not None


# --- Rythme de la veille (§ 4) -------------------------------------------------
# Deux déclencheurs peuvent lancer la veille : Celery Beat (quand l'application tourne)
# et le Planificateur de tâches Windows (veille_planifiee.ps1, même application fermée).
# Pour qu'ils ne fassent jamais le travail deux fois (crédits Tavily doublés), chaque
# passage RÉSERVE son créneau au démarrage : un autre déclenchement est ignoré tant que le
# dernier passage date de moins de VEILLE_INTERVAL_HOURS (VEILLE_INTERVAL_REDUIT_HOURS en
# mode réduit). Tolérance de 10 min : un déclenchement arrivé un peu en avance passe.
#
# L'heure du dernier passage est écrite dans un FICHIER (et non dans Redis) : la tâche
# Windows tourne aussi quand Redis n'est pas lancé.
_TOLERANCE_SECONDES = 10 * 60


def _fichier_passage(nom):
    return Path(settings.VEILLE_ETAT_DIR) / f'dernier_passage_{nom}.txt'


def _lire_dernier_passage(nom):
    try:
        return float(_fichier_passage(nom).read_text(encoding='ascii').strip())
    except (OSError, ValueError):
        return None


def reserver_passage(nom, force=False):
    """Vrai si ce déclenchement doit travailler ; réserve alors le créneau (écrit l'heure).
    `force=True` (commande manuelle) passe toujours, mais réserve aussi le créneau."""
    intervalle = (
        settings.VEILLE_INTERVAL_REDUIT_HOURS if credits.mode_reduit() else settings.VEILLE_INTERVAL_HOURS
    ) * 3600
    dernier = _lire_dernier_passage(nom)
    if not force and dernier is not None:
        ecart = time.time() - dernier
        if ecart < intervalle - _TOLERANCE_SECONDES:
            logger.info(
                'Veille %s ignorée : dernier passage il y a %d min, prochain dans ~%d min.',
                nom, ecart // 60, (intervalle - ecart) // 60,
            )
            return False
    try:
        _fichier_passage(nom).parent.mkdir(parents=True, exist_ok=True)
        _fichier_passage(nom).write_text(str(time.time()), encoding='ascii')
    except OSError as exc:
        logger.warning('Heure du passage %s non enregistrée : %s', nom, exc)
    return True


def rotation(options):
    """Choisit un élément différent à chaque créneau de veille (sans état stocké) :
    créneau 0 -> options[0], créneau 1 -> options[1]… puis on recommence."""
    creneau = int(time.time() // (settings.VEILLE_INTERVAL_HOURS * 3600))
    return options[creneau % len(options)]
