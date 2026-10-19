"""
Localisation précise des établissements : quartier / commune trouvés dans un texte
(adresse, présentation, page contact). Utilisé par la recherche d'établissement (back-office)
et les scripts d'enrichissement. On ne devine jamais : aucun lieu cité -> None.
"""
import re

from services.cache import normaliser_texte

# Quartiers / communes de la région de Dakar : variante normalisée -> nom affiché.
QUARTIERS = [
    ('point e', 'Point E'), ('sacre coeur', 'Sacré-Cœur'), ('mermoz', 'Mermoz'), ('pyrotechnie', 'Mermoz-Pyrotechnie'),
    ('liberte 6', 'Liberté 6'), ('liberte vi', 'Liberté 6'), ('liberte 5', 'Liberté 5'), ('liberte 4', 'Liberté 4'),
    ('liberte 3', 'Liberté 3'), ('liberte 2', 'Liberté 2'), ('liberte ii', 'Liberté 2'), ('liberte 1', 'Liberté 1'),
    ('sicap liberte', 'Sicap Liberté'), ('sicap foire', 'Sicap Foire'), ('sicap amitie', 'Sicap Amitié'),
    ('sicap baobab', 'Sicap Baobab'), ('sicap', 'Sicap'), ('amitie', 'Amitié'), ('fann', 'Fann'), ('plateau', 'Plateau'),
    ('ponty', 'Plateau'), ('medina', 'Médina'), ('gueule tapee', 'Gueule Tapée'), ('fass', 'Fass'),
    ('colobane', 'Colobane'), ('hlm', 'HLM'), ('grand dakar', 'Grand Dakar'), ('biscuiterie', 'Biscuiterie'),
    ('dieuppeul', 'Dieuppeul'), ('derkle', 'Derklé'), ('castors', 'Castors'), ('zone de captage', 'Zone de Captage'),
    ('grand yoff', 'Grand Yoff'), ("patte d'oie", "Patte d'Oie"), ('parcelles assainies', 'Parcelles Assainies'),
    ('camberene', 'Cambérène'), ('ouakam', 'Ouakam'), ('ngor', 'Ngor'), ('almadies', 'Almadies'),
    ('mamelles', 'Mamelles'), ('yoff', 'Yoff'), ('nord foire', 'Nord Foire'), ('ouest foire', 'Ouest Foire'),
    ('keur gorgui', 'Keur Gorgui'), ('vdn', 'VDN'), ('diamalaye', 'Diamalaye'), ('hann', 'Hann'), ('bel air', 'Bel-Air'),
    ('front de terre', 'Front de Terre'), ('grand medine', 'Grand Médine'), ('golf sud', 'Golf Sud'),
    ('guediawaye', 'Guédiawaye'), ('pikine', 'Pikine'), ('thiaroye', 'Thiaroye'), ('keur massar', 'Keur Massar'),
    ('yeumbeul', 'Yeumbeul'), ('malika', 'Malika'), ('mbao', 'Mbao'), ('rufisque', 'Rufisque'), ('bargny', 'Bargny'),
    ('diamniadio', 'Diamniadio'), ('sebikotane', 'Sébikotane'), ('sangalkam', 'Sangalkam'), ('cite du rail', 'Cité du Rail'),
]

# Villes / régions hors Dakar (commune -> région).
VILLES = {
    'thies': ('Thiès', 'Thiès'), 'mbour': ('Mbour', 'Thiès'), 'saly': ('Saly', 'Thiès'), 'tivaouane': ('Tivaouane', 'Thiès'),
    'saint louis': ('Saint-Louis', 'Saint-Louis'), 'richard toll': ('Richard-Toll', 'Saint-Louis'),
    'ziguinchor': ('Ziguinchor', 'Ziguinchor'), 'bignona': ('Bignona', 'Ziguinchor'), 'diourbel': ('Diourbel', 'Diourbel'),
    'touba': ('Touba', 'Diourbel'), 'mbacke': ('Mbacké', 'Diourbel'), 'bambey': ('Bambey', 'Diourbel'),
    'kaolack': ('Kaolack', 'Kaolack'), 'matam': ('Matam', 'Matam'), 'tambacounda': ('Tambacounda', 'Tambacounda'),
    'kolda': ('Kolda', 'Kolda'), 'louga': ('Louga', 'Louga'), 'fatick': ('Fatick', 'Fatick'),
    'kaffrine': ('Kaffrine', 'Kaffrine'), 'kedougou': ('Kédougou', 'Kédougou'), 'sedhiou': ('Sédhiou', 'Sédhiou'),
}


def quartiers_dans(texte):
    """Quartiers de la région de Dakar cités dans le texte, dans leur ordre d'apparition."""
    t = ' ' + normaliser_texte(texte or '').replace('-', ' ') + ' '
    trouves = []
    for cle, nom in QUARTIERS:
        motif = r'\b' + re.escape(cle) + r'\b'
        if cle == 'plateau':  # « plateau technique » n'est pas un lieu
            motif = r'\b(dakar plateau|au plateau|plateau dakar|quartier du plateau)\b'
        m = re.search(motif, t)
        if m:
            trouves.append((m.start(), nom))
    vus = []
    for _, nom in sorted(trouves):
        if nom not in vus:
            vus.append(nom)
    return vus


def ville_dans(texte):
    """(commune, région) de la première ville hors Dakar citée, sinon None."""
    t = ' ' + normaliser_texte(texte or '').replace('-', ' ') + ' '
    trouves = [(m.start(), v) for cle, v in VILLES.items() for m in [re.search(r'\b' + re.escape(cle) + r'\b', t)] if m]
    return min(trouves)[1] if trouves else None


def localiser(texte):
    """(région, commune) déduits d'un texte, ou (None, None) si aucun lieu n'y est cité."""
    q = quartiers_dans(texte)
    v = ville_dans(texte)
    if q and (not v or normaliser_texte(texte).find(normaliser_texte(q[0])) <= normaliser_texte(texte).find(v[0].lower())):
        return 'Dakar', q[0]
    if v:
        return v[1], v[0]
    if re.search(r'\bdakar\b', normaliser_texte(texte or '')):
        return 'Dakar', 'Dakar'
    return None, None
