"""
Client de recherche web — la "recherche internet" de l'IA (PARTIE veille).

Utilise le point d'entrée HTML de DuckDuckGo (html.duckduckgo.com/html/) plutôt
que l'API Google Custom Search : aucune clé ni compte de facturation requis,
ce qui la rend immédiatement utilisable. Contrepartie : c'est du scraping HTML
(pas une API officielle documentée), donc plus fragile si DuckDuckGo change sa
page — voir `_extraire_resultats` si la structure attendue ne matche plus rien.
"""
import hashlib
import logging
import urllib.parse
from datetime import datetime
from email.utils import parsedate_to_datetime
from xml.etree import ElementTree
import html as html_lib
from pathlib import Path

import httpx
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)

# Dossier de stockage local des images d'actualités téléchargées (partagé avec Laravel,
# qui les sert via /api/v1/media/actualites/... — voir ActualiteResource et
# MediaController). Même principe que les logos d'établissements (TelechargerLogos.php),
# côté Django cette fois car c'est ce process qui crée les fiches d'actualité.
_DOSSIER_IMAGES_ACTUALITES = Path(__file__).resolve().parent.parent.parent / 'backend' / 'storage' / 'app' / 'public' / 'actualites'

DUCKDUCKGO_HTML_URL = 'https://html.duckduckgo.com/html/'

# Un User-Agent de navigateur classique évite un blocage immédiat par certains
# sites (dont DuckDuckGo) qui filtrent les requêtes sans en-têtes "normaux".
EN_TETES = {
    'User-Agent': (
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36'
    )
}


class RechercheWebIndisponibleError(Exception):
    """Levée quand la recherche web échoue (réseau, blocage, page inattendue)."""


def _url_reelle(href):
    """DuckDuckGo renvoie des liens de redirection du type
    '//duckduckgo.com/l/?uddg=<url encodée>&rut=...' : on en extrait l'URL réelle."""
    if not href:
        return ''
    if href.startswith('//'):
        href = 'https:' + href
    if 'duckduckgo.com/l/' in href:
        params = urllib.parse.parse_qs(urllib.parse.urlparse(href).query)
        if 'uddg' in params:
            return params['uddg'][0]
    return href


def _extraire_resultats(html, nb_resultats):
    soup = BeautifulSoup(html, 'html.parser')
    resultats = []

    for bloc in soup.select('.result'):
        lien_tag = bloc.select_one('.result__a')
        if not lien_tag:
            continue
        extrait_tag = bloc.select_one('.result__snippet')

        resultats.append({
            'titre': lien_tag.get_text(strip=True),
            'lien': _url_reelle(lien_tag.get('href', '')),
            'extrait': extrait_tag.get_text(strip=True) if extrait_tag else '',
        })
        if len(resultats) >= nb_resultats:
            break

    return resultats


def rechercher(requete, nb_resultats=10, periode=None):
    """Retourne une liste de résultats {titre, lien, extrait} pour une requête donnée.
    `periode` restreint aux pages récentes : 'd' (jour), 'w' (semaine), 'm' (mois)."""
    donnees = {'q': requete}
    if periode:
        donnees['df'] = periode
    try:
        reponse = httpx.post(
            DUCKDUCKGO_HTML_URL, data=donnees, headers=EN_TETES, timeout=15,
            follow_redirects=True,
        )
        reponse.raise_for_status()
    except httpx.HTTPError as exc:
        logger.error('Recherche web indisponible pour "%s" : %s', requete, exc)
        raise RechercheWebIndisponibleError(str(exc)) from exc

    resultats = _extraire_resultats(reponse.text, nb_resultats)
    if not resultats:
        logger.warning(
            'Aucun résultat extrait pour "%s" — la page DuckDuckGo a peut-être changé '
            'de structure (voir veille/recherche_web.py:_extraire_resultats).', requete
        )
    return resultats


BING_NEWS_RSS_URL = 'https://www.bing.com/news/search'


def _url_reelle_bing(href):
    """Les liens du flux Bing News passent par 'bing.com/news/apiclick.aspx?...&url=<url
    encodée>' : on en extrait l'URL réelle de l'article."""
    params = urllib.parse.parse_qs(urllib.parse.urlparse(href or '').query)
    return params['url'][0] if 'url' in params else (href or '')


def rechercher_actualites(requete, nb_resultats=15):
    """Recherche dans un moteur d'ACTUALITÉS (flux RSS Bing News) plutôt que dans le
    web général : chaque résultat est un article de presse avec sa date de publication
    RÉELLE (pubDate) et le nom du média qui l'a publié — indispensable pour garantir
    des informations récentes et attribuables.

    Retourne une liste de {titre, lien, extrait, date_publication (datetime aware),
    source_nom, image}."""
    try:
        reponse = httpx.get(
            BING_NEWS_RSS_URL,
            params={'q': requete, 'format': 'rss', 'mkt': 'fr-FR', 'setlang': 'fr'},
            headers=EN_TETES, timeout=15, follow_redirects=True,
        )
        reponse.raise_for_status()
    except httpx.HTTPError as exc:
        logger.error("Flux d'actualités indisponible pour '%s' : %s", requete, exc)
        raise RechercheWebIndisponibleError(str(exc)) from exc

    try:
        racine = ElementTree.fromstring(reponse.content)
    except ElementTree.ParseError as exc:
        logger.error("Flux d'actualités illisible pour '%s' : %s", requete, exc)
        raise RechercheWebIndisponibleError(str(exc)) from exc

    def _texte(item, balise):
        # '{*}' : ignore l'espace de noms (balises Bing 'News:Source', 'News:Image').
        noeud = item.find(balise) if ':' not in balise else None
        if noeud is None:
            noeud = item.find('{*}' + balise.split(':')[-1])
        return (noeud.text or '').strip() if noeud is not None and noeud.text else ''

    resultats = []
    for item in racine.iter('item'):
        titre = _texte(item, 'title')
        lien = _texte(item, 'link')
        if not titre or not lien:
            continue
        date_pub = None
        if _texte(item, 'pubDate'):
            try:
                date_pub = parsedate_to_datetime(_texte(item, 'pubDate'))
            except (TypeError, ValueError):
                date_pub = None
        resultats.append({
            'titre': html_lib.unescape(titre),
            'lien': _url_reelle_bing(lien),
            'extrait': html_lib.unescape(_texte(item, 'description')),
            'date_publication': date_pub,
            'source_nom': _texte(item, 'News:Source') or None,
            'image': _texte(item, 'News:Image') or None,
        })
        if len(resultats) >= nb_resultats:
            break

    if not resultats:
        logger.warning('Aucun article trouvé dans le flux pour "%s".', requete)
    return resultats


def extraire_logo(url_site):
    """Va chercher la page d'accueil du site officiel d'un établissement et tente d'en
    extraire une image représentative (logo) via la balise <meta property="og:image">,
    quasi-systématique sur les sites institutionnels modernes. Retourne None si le site
    est injoignable ou ne publie pas cette balise (pas de génération/invention d'image)."""
    if not url_site:
        return None
    try:
        reponse = httpx.get(url_site, headers=EN_TETES, timeout=10, follow_redirects=True)
        reponse.raise_for_status()
    except httpx.HTTPError as exc:
        logger.info('Logo introuvable pour %s (site injoignable) : %s', url_site, exc)
        return None

    soup = BeautifulSoup(reponse.text, 'html.parser')
    balise = soup.find('meta', attrs={'property': 'og:image'}) or soup.find(
        'meta', attrs={'name': 'og:image'}
    )
    contenu = balise.get('content') if balise else None
    if not contenu:
        return None

    url_logo = urllib.parse.urljoin(str(reponse.url), contenu)
    hote = urllib.parse.urlparse(url_logo).hostname or ''
    # Certains sites laissent une balise og:image pointant vers leur environnement de
    # développement local (bug côté site, déjà observé en pratique) — une telle URL
    # est inexploitable pour nos utilisateurs, on la rejette plutôt que de la stocker.
    if hote in ('localhost', '127.0.0.1') or hote.startswith('192.168.') or hote.startswith('10.'):
        logger.info('Logo rejeté pour %s : og:image pointe vers une adresse locale (%s)', url_site, url_logo)
        return None
    return url_logo


def telecharger_image_locale(url_image):
    """Télécharge l'image trouvée dans les métadonnées d'un article et la stocke
    localement (storage/app/public/actualites/), plutôt que de renvoyer l'URL distante
    telle quelle : un lien externe hotlinké peut disparaître, être lent, ou surtout
    échouer à s'afficher sous Flutter web (CanvasKit refuse de décoder une image
    cross-origin sans en-tête CORS, que la plupart des sites tiers n'envoient pas).
    Retourne le chemin local ("/storage/actualites/<hash>.<ext>") ou None si le
    téléchargement échoue ou que le contenu n'est pas une image exploitable — jamais
    de valeur inventée."""
    if not url_image:
        return None
    try:
        reponse = httpx.get(url_image, headers=EN_TETES, timeout=10, follow_redirects=True)
        reponse.raise_for_status()
    except httpx.HTTPError as exc:
        logger.info('Téléchargement image échoué pour %s : %s', url_image, exc)
        return None

    content_type = reponse.headers.get('content-type', '')
    if not content_type.startswith('image/'):
        logger.info('Téléchargement image rejeté pour %s : Content-Type %s', url_image, content_type)
        return None

    extension = {
        'image/png': 'png', 'image/svg+xml': 'svg', 'image/webp': 'webp',
        'image/jpeg': 'jpg', 'image/jpg': 'jpg', 'image/gif': 'gif',
    }.get(content_type.split(';')[0].strip(), 'jpg')

    nom_fichier = hashlib.sha256(url_image.encode('utf-8')).hexdigest()[:32] + '.' + extension
    try:
        _DOSSIER_IMAGES_ACTUALITES.mkdir(parents=True, exist_ok=True)
        (_DOSSIER_IMAGES_ACTUALITES / nom_fichier).write_bytes(reponse.content)
    except OSError as exc:
        logger.warning('Écriture locale échouée pour %s : %s', url_image, exc)
        return None

    return f'/storage/actualites/{nom_fichier}'


def extraire_texte_page(url, max_chars=6000):
    """Récupère le texte visible (hors scripts/styles/menus) d'une page — utilisé pour
    que le LLM extraie les filières réellement listées sur le site d'un établissement,
    plutôt que d'inventer des formations plausibles. Retourne '' si la page est
    injoignable."""
    if not url:
        return ''
    try:
        reponse = httpx.get(url, headers=EN_TETES, timeout=10, follow_redirects=True)
        reponse.raise_for_status()
    except httpx.HTTPError as exc:
        logger.info('Page injoignable pour %s : %s', url, exc)
        return ''

    soup = BeautifulSoup(reponse.text, 'html.parser')
    for balise in soup(['script', 'style', 'nav', 'footer', 'header']):
        balise.decompose()
    texte = ' '.join(soup.get_text(separator=' ').split())
    return texte[:max_chars]


def _parser_date_meta(valeur):
    """Les balises de date publiées par les sites sont rarement strictement ISO 8601
    (espace au lieu de 'T', décalage horaire absent...) — on tente plusieurs formats
    plutôt que d'abandonner sur le premier échec."""
    if not valeur:
        return None
    valeur = valeur.strip()
    for candidat in (valeur, valeur.replace('Z', '+00:00'), valeur.replace(' ', 'T', 1)):
        try:
            return datetime.fromisoformat(candidat)
        except ValueError:
            continue
    return None


def extraire_metadonnees_article(url):
    """Va chercher la page d'un article et en extrait l'image et la date de publication
    RÉELLES, quand le site les publie dans ses métadonnées (balises standard reprises par
    la quasi-totalité des sites d'actualité modernes : Open Graph, Twitter Card,
    schema.org). Retourne {'image': str|None, 'date_publication': datetime|None} — jamais
    de valeur inventée : un champ absent des métadonnées reste `None`."""
    resultat = {'image': None, 'date_publication': None, 'accessible': False}
    if not url:
        return resultat
    try:
        reponse = httpx.get(url, headers=EN_TETES, timeout=10, follow_redirects=True)
        reponse.raise_for_status()
    except httpx.HTTPStatusError as exc:
        # 401/403/429 : la page existe mais le site bloque les robots (protection
        # anti-bot fréquente chez les journaux) — l'article est réel, seules ses
        # métadonnées restent inaccessibles. 404/410/5xx : lien mort, rejeté.
        resultat['accessible'] = exc.response.status_code in (401, 403, 429)
        logger.info('Métadonnées introuvables pour %s (HTTP %s)', url, exc.response.status_code)
        return resultat
    except httpx.HTTPError as exc:
        # Pas de réponse HTTP du tout (DNS, coupure, délai) : c'est NOTRE connexion
        # ou le site qui est momentanément injoignable — on ne peut pas conclure que
        # le lien est mort. L'article sera retenté au prochain passage.
        resultat['erreur_reseau'] = True
        logger.info('Métadonnées introuvables pour %s (page injoignable) : %s', url, exc)
        return resultat
    # Lien vivant : sert de contrôle de fiabilité (un article supprimé ou une
    # URL cassée n'est jamais publié).
    resultat['accessible'] = True

    soup = BeautifulSoup(reponse.text, 'html.parser')

    balise_image = (
        soup.find('meta', attrs={'property': 'og:image'})
        or soup.find('meta', attrs={'name': 'twitter:image'})
    )
    if balise_image and balise_image.get('content'):
        url_image = urllib.parse.urljoin(str(reponse.url), balise_image['content'])
        hote = urllib.parse.urlparse(url_image).hostname or ''
        if hote not in ('localhost', '127.0.0.1') and not hote.startswith(('192.168.', '10.')):
            resultat['image'] = url_image

    balise_date = (
        soup.find('meta', attrs={'property': 'article:published_time'})
        or soup.find('meta', attrs={'name': 'publish-date'})
        or soup.find('meta', attrs={'name': 'date'})
        or soup.find('time', attrs={'datetime': True})
    )
    if balise_date:
        brut = balise_date.get('content') or balise_date.get('datetime')
        resultat['date_publication'] = _parser_date_meta(brut)

    return resultat
