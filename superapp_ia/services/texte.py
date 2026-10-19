"""
Contrôles anti-invention et mise en forme des textes générés par le LLM, partagés
par tous les modules (« le LLM ne doit jamais inventer d'information absente des
résultats ou de la base »). Ce sont des règles déterministes : elles vérifient le
texte du modèle contre le texte source, sans faire confiance au modèle lui-même.
"""
import re

from .cache import normaliser_texte


def present_dans(valeur, texte_source, seuil=0.6):
    """Vrai si l'essentiel de `valeur` (au moins 60 % de ses mots de 3 lettres et plus)
    figure dans le texte source. Tolère 'Sonatel' vs 'la Sonatel', mais rejette un
    organisme, une ville ou un métier que le modèle aurait ajouté de lui-même."""
    mots = [m for m in normaliser_texte(valeur).split() if len(m) >= 3]
    if not mots:
        return False
    texte = set(normaliser_texte(texte_source).split())
    return sum(m in texte for m in mots) / len(mots) >= seuil


def chiffres_inventes(texte_genere, texte_source):
    """Chiffres et mois (dates, montants, effectifs…) écrits par le modèle mais absents
    du texte source. Ce sont les inventions les plus fréquentes et les plus graves
    (« 3 000 bourses », « le 12 mars », « généralement en janvier ») : un seul suffit à
    refuser le texte généré."""
    def _nombres_et_mois(texte):
        # '4 200' et '4200' -> '4200' : on recolle les milliers séparés par une espace.
        colles = re.sub(r'(?<=\d)[\s\u202f\u00a0.](?=\d{3}\b)', '', texte or '')
        mots = set(normaliser_texte(texte).split())
        return set(re.findall(r'\d+', colles)) | (mots & _MOIS)
    return _nombres_et_mois(texte_genere) - _nombres_et_mois(texte_source)


_MOIS = {
    'janvier', 'fevrier', 'mars', 'avril', 'mai', 'juin', 'juillet', 'aout',
    'septembre', 'octobre', 'novembre', 'decembre',
}


def resume_court(texte, max_phrases, max_caracteres=400):
    """Limite un texte à `max_phrases` phrases (2 lignes pour une offre, 3 pour une
    actualité, selon le cahier des charges)."""
    phrases = re.split(r'(?<=[.!?])\s+', (texte or '').strip())
    resume = ' '.join(phrases[:max_phrases])
    if len(resume) > max_caracteres:
        resume = resume[:max_caracteres].rsplit(' ', 1)[0] + '…'
    return resume


def extrait_pertinent(texte_source, mots_cles, max_caracteres):
    """Garde les phrases du texte qui contiennent le plus de mots de la question, dans
    leur ordre d'origine, jusqu'à `max_caracteres`.

    Pourquoi : sur ce CPU, le modèle LIT le prompt à ~25 tokens/s. 500 tokens de
    sources coûtent ~20 s avant le premier mot de la réponse. Envoyer seulement les
    phrases utiles divise ce temps par deux sans perdre l'information recherchée."""
    texte_source = ' '.join((texte_source or '').split())
    if len(texte_source) <= max_caracteres:
        return texte_source
    phrases = [p for p in re.split(r'(?<=[.!?;])\s+', texte_source) if p]
    mots = {normaliser_texte(m) for m in mots_cles if m}

    def _score(phrase):
        return len(mots & set(normaliser_texte(phrase).split()))

    # Les meilleures phrases d'abord ; à score égal, celles du début (souvent l'essentiel).
    classement = sorted(range(len(phrases)), key=lambda i: (-_score(phrases[i]), i))
    # Si des phrases parlent du sujet, on ne complète pas avec des phrases hors sujet :
    # chaque mot envoyé au modèle coûte du temps de lecture.
    if _score(phrases[classement[0]]) > 0:
        classement = [i for i in classement if _score(phrases[i]) > 0]
    retenues, longueur = [], 0
    for i in classement:
        if longueur + len(phrases[i]) > max_caracteres:
            continue
        retenues.append(i)
        longueur += len(phrases[i]) + 1
    if not retenues:  # une seule phrase trop longue : on la coupe
        return phrases[classement[0]][:max_caracteres].rsplit(' ', 1)[0] + '…'
    return ' '.join(phrases[i] for i in sorted(retenues))


def phrases_sourcees(texte_genere, texte_source, seuil=0.5):
    """Ne garde que les phrases du texte généré dont au moins `seuil` des mots importants
    figurent dans la source. Rattrape les phrases inventées sans chiffre, que
    `chiffres_inventes` ne voit pas (ex. « Ce peut être concernant le Bac… » ajouté
    au résumé d'un article de diplomatie). Retourne '' si aucune phrase n'est sourcée."""
    phrases = re.split(r'(?<=[.!?])\s+', (texte_genere or '').strip())
    return ' '.join(p for p in phrases if present_dans(p, texte_source, seuil=seuil))


def contient_un_mot(texte, mots):
    """Vrai si le texte contient l'un des mots (comparaison sans accents ni casse ; un
    mot se terminant par « * » accepte toutes les terminaisons : 'recrut*')."""
    mots_texte = normaliser_texte(texte).split()
    for mot in mots:
        if mot.endswith('*'):
            if any(m.startswith(mot[:-1]) for m in mots_texte):
                return True
        elif mot in mots_texte:
            return True
    return False
