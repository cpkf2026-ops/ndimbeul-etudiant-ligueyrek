# API du service IA — Ndimbeul Étudiant

Service Django appelé **uniquement par Laravel** (`App\Services\DjangoAiClient`).
Base : `DJANGO_IA_BASE_URL` (par défaut `http://127.0.0.1:8001`).

## Authentification

Chaque requête porte l'en-tête :

```
X-Service-Token: <DJANGO_IA_INTERNAL_KEY du backend = LARAVEL_SHARED_TOKEN du service IA>
```

Sans en-tête, ou avec une mauvaise valeur : `401 {"erreur": "non_autorise", "message": "..."}`.

## Format des erreurs

Toutes les erreurs ont la même forme, que Laravel peut afficher telle quelle :

```json
{"erreur": "llm_indisponible", "message": "Le modèle local Ollama (qwen3.5:2b) est injoignable…"}
```

| HTTP | `erreur` | Signification |
|---|---|---|
| 400 | `invalid` | Entrée invalide, détail par champ dans `details` |
| 401 | `non_autorise` | En-tête `X-Service-Token` absent ou faux |
| 429 | `quota_tavily_atteint` | Crédits Tavily du mois épuisés |
| 502 | `llm_reponse_invalide` | Le modèle n'a pas rendu le JSON attendu |
| 503 | `llm_indisponible` / `tavily_indisponible` | Ollama arrêté / Tavily injoignable |
| 504 | `llm_timeout` | Génération trop longue |

Le chatbot et l'orientation ne renvoient pas ces erreurs pour une panne d'Ollama ou
de Tavily : ils répondent quand même (réponse de secours) et le signalent dans
`avertissements`.

---

## Module 1 — `POST /api/ia/orientation/`

Requête :

```json
{
  "serie_bac": "S2",
  "moyenne": 13.5,
  "passions": ["informatique", "mathématiques"],
  "ville": "Dakar",
  "utilisateur_id": "0b602647-5882-4373-901e-c3fcc562a14a"
}
```

`ville`, `utilisateur_id`, `matieres_fortes`, `metiers_envisages` et `mobilite` sont
facultatifs. Avec `utilisateur_id`, les formations proposées sont tracées dans la
table `recommandations`.

Réponse `200` (raccourcie : 3 à 5 éléments par liste) :

```json
{
  "profil": {"serie_bac": "S2", "moyenne": 13.5, "passions": ["informatique", "mathématiques"], "ville": "Dakar"},
  "metiers": [
    {"nom": "Ingénieur logiciel", "justification": "Débouché cité pour la formation « Sciences, Ingénierie et Informatique ».",
     "score": 66, "source": "https://campusen.sn"}
  ],
  "formations": [
    {"id": "272863ac-05b0-4a89-a106-dde5bf4d2674", "nom": "Licence Informatique", "niveau": "licence",
     "domaine": "Informatique",
     "universite": {"id": "0b602647-…", "nom": "Université Cheikh Anta Diop", "type": "public"},
     "conditions": {"series_acceptees": ["S1", "S2", "S3"], "moyenne_minimale": 12.0},
     "justification": "Ouverte aux bacheliers de la série S2, ta moyenne (13.5/20) atteint le minimum demandé (12/20), située à Dakar, une bourse est disponible.",
     "score": 72, "source": "https://www.ucad.sn"}
  ],
  "universites": [
    {"id": "0b602647-…", "nom": "Université Cheikh Anta Diop", "type": "public", "region": "Dakar",
     "justification": "Établissement public qui propose 3 formations adaptées à ton profil, dont « Licence Mathématiques-Physique ».",
     "score": 83, "source": "https://www.ucad.sn"}
  ],
  "avertissements": [],
  "lien_officiel": "https://campusen.sn",
  "depuis_cache": false,
  "temps_ms": 16218
}
```

Scores : formations = moteur de score (série 35, passions 30, matières 15, région 10,
bourse 10) ; universités = meilleur score de leurs formations ; métiers = score de la
formation source, ou 50 + proximité de sens avec les passions pour un métier trouvé sur le web.

---

## Module 2 — `GET /api/ia/opportunites/?categorie=stage&page=1&par_page=20`

`categorie` (facultatif) : `emploi`, `stage`, `alternance`, `formation`, `bourse`, `concours`.
Seules les offres actives sont renvoyées.

```json
{
  "total": 21, "page": 1, "nb_pages": 2, "par_page": 20,
  "resultats": [
    {"id": "…", "titre": "Stagiaire Assistant Comptable", "organisme": "Banque Atlantique Sénégal",
     "categorie": "stage", "lieu": "Dakar Plateau", "domaine": "Finance",
     "niveau_requis": "Licence 3 Comptabilité-Finance", "date_limite": "2026-11-15",
     "resume": "Banque Atlantique Sénégal recherche un stagiaire assistant comptable pour son siège de Dakar Plateau. Durée 6 mois.",
     "url_source": "https://www.senjob.com/…", "source": "senjob.com", "fiabilite": "plateforme",
     "date_publication": null, "date_collecte": "2026-10-18T02:00:12+00:00"}
  ]
}
```

## Module 3 — `GET /api/ia/actualites/?page=1&categorie=bourse`

`categorie` (facultatif) : `bourse`, `concours`, `evenement`, `formation`, `general`.

```json
{
  "total": 145, "page": 1, "nb_pages": 8, "par_page": 20,
  "resultats": [
    {"id": "647a27a9-…", "titre": "Grève de 72 heures annoncée pour la rentrée scolaire 2026-2027 par le G7",
     "resume": "Les principaux syndicats d'enseignants (SAEMS, UDEN, CUSEMS) ont annoncé une grève de 72 heures…",
     "categorie": "evenement", "url_source": "https://www.seneweb.com/…",
     "image_url": "/storage/actualites/3f2a….jpg", "source": "seneweb.com", "fiabilite": "presse",
     "date_publication": "2026-10-16T09:12:00+00:00"}
  ]
}
```

`image_url` est un chemin servi par Laravel (`storage/app/public/actualites`), ou `null`.

---

## Module 4 — `POST /api/ia/chat/`

Requête (utilisateur connecté : la conversation est enregistrée dans `conversations_ia`) :

```json
{"message": "Quelles sont les conditions pour la licence informatique à l'UCAD ?",
 "utilisateur_id": "0b602647-…", "conversation_id": "…", "profil": {"serie_bac": "S2"}}
```

Mode visiteur (pas de compte) : pas d'`utilisateur_id`, Laravel envoie lui-même les
derniers échanges (5 au maximum sont utilisés) :

```json
{"message": "Et à l'UGB ?",
 "historique": [{"role": "user", "contenu": "Quand est la rentrée à l'UCAD ?"},
                {"role": "assistant", "contenu": "La rentrée est fixée au … [1]."}]}
```

Réponse `200` :

```json
{
  "reponse": "Pour obtenir une Licence Informatique à l'UCAD, il faut un bac S1, S2 ou S3 avec une moyenne minimale de 12.00/20 [1].",
  "sources": [{"titre": "Licence Informatique (Université Cheikh Anta Diop)", "url": "https://www.ucad.sn"}],
  "temps_ms": 23764,
  "intention": "question",
  "conversation_id": "…",
  "depuis_cache": false,
  "recherche_web": false,
  "avertissements": []
}
```

- `intention` : `salutation`, `remerciement`, `au_revoir`, `hors_sujet` (réponse immédiate,
  sans recherche) ou `question`.
- `[n]` dans `reponse` renvoie à `sources[n-1]`.
- Information introuvable : réponse honnête avec les liens officiels, `avertissements`
  contient `information_introuvable`.
- Autres `avertissements` possibles : `reponse_tronquee` (coupée à l'échéance, phrases
  complètes gardées), `llm_timeout`, `llm_indisponible`, `chiffre_non_source`,
  `recherche_web_indisponible`, `quota_tavily_atteint`.

Version streaming (texte affiché au fil de l'eau, déjà utilisée par l'application) :
`POST /api/ia/chat/stream/` (événements SSE `{"token": …}` puis `{"done": true, …}`).

---

## Santé — `GET /api/ia/sante/`

```json
{
  "statut": "ok", "base_donnees": "ok", "redis": "ok",
  "ollama": {"disponible": true,
             "modele_veille": {"nom": "mistral:7b-instruct", "installe": true},
             "modele_rapide": {"nom": "qwen3.5:2b", "installe": true}},
  "tavily": {"cle_configuree": true,
             "credits": {"mois": "2026-10", "consommes": {"veille": 24, "interactif": 3, "total": 27},
                         "limite_mensuelle": 1000, "reserve_interactif": 200, "restants": 973,
                         "mode_reduit_veille": false}}
}
```

`503` avec `"statut": "degrade"` si MySQL ou Ollama ne répond pas.

## Exemple d'appel depuis Laravel

```php
$reponse = app(\App\Services\DjangoAiClient::class)->orientation([
    'serie_bac' => $profil->serie_bac,
    'moyenne'   => $profil->moyenne_generale,
    'passions'  => $profil->passions ?? [],
    'ville'     => $profil->region_cible,
    'utilisateur_id' => $utilisateur->id,
]);

if ($reponse->failed()) {
    return response()->json(['message' => $reponse->json('message')], $reponse->status());
}
return response()->json($reponse->json());
```
