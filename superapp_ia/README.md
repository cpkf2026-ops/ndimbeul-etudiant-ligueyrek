# superapp_ia — Micro-service IA de Ndimbeul-Etudiant

Service Django interne qui remplace les LLM cloud (GPT-4 / Mistral API) prévus au
cahier des charges par un **LLM local servi par [Ollama](https://ollama.com)**
(`mistral:7b-instruct`), avec un pipeline RAG (FAISS + sentence-transformers) et un
moteur de recommandations de formations.

Ce service n'est **jamais exposé à Flutter**. Seul le backend Laravel l'appelle, en
HTTP interne, avec le header `X-Internal-Key` (voir `ia/middleware.py`).

## 1. Prérequis (à faire une seule fois)

1. **Ollama** : installer depuis [ollama.com/download](https://ollama.com/download),
   puis télécharger le modèle :
   ```
   ollama pull mistral:7b-instruct
   ollama run mistral:7b-instruct   # test rapide en français
   ```
   Ollama écoute par défaut sur `http://localhost:11434` et expose une API
   compatible OpenAI sur `/v1`.

2. **Python 3.11+** (le venv fourni utilise Python 3.12) et **MySQL** déjà lancé
   avec la base `backendpff` migrée par Laravel (`php artisan migrate` côté
   `backend/`) — ce service **partage** cette base, il ne crée aucune table.

3. Environnement virtuel + dépendances (déjà créés dans ce dossier) :
   ```
   venv\Scripts\activate
   pip install -r requirements.txt
   ```

## 2. Configuration (`.env`)

Le fichier `.env` à la racine de `superapp_ia/` contient :

| Variable | Rôle |
|---|---|
| `DJANGO_SECRET_KEY`, `DJANGO_DEBUG`, `DJANGO_ALLOWED_HOSTS` | Réglages Django standards |
| `INTERNAL_API_KEY` | Clé partagée avec `DJANGO_IA_INTERNAL_KEY` dans `backend/.env` (déjà synchronisée) |
| `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT` | Mêmes identifiants MySQL que `backend/.env` |
| `OLLAMA_BASE_URL`, `OLLAMA_API_KEY`, `OLLAMA_MODEL` | Connexion au LLM local |
| `EMBEDDING_MODEL_NAME`, `RAG_TOP_K` | Modèle d'embeddings et nombre de documents recherchés |
| `CACHE_REPONSE_TTL_HEURES` | Durée de vie du cache de réponses (24h par défaut) |

## 3. Lancer le service

```
venv\Scripts\activate
python manage.py runserver 8001
```

Le port **8001** est volontaire, pour ne jamais entrer en conflit avec Laravel
(généralement sur 8000).

> Aucune migration à lancer : toutes les tables utilisées (`sources_donnees`,
> `documents_rag`, `conversations_ia`, `cache_reponses`, `recommandations`,
> `formations`, `universites`, `bourses`, `frais_scolarite`) existent déjà côté
> MySQL, créées par les migrations Laravel. Les modèles Django correspondants sont
> `managed = False` : Django lit/écrit des lignes, jamais le schéma.

## 4. Documents de la base de connaissances (RAG)

Les fiches de démonstration (`ia/sample_docs/`, commande `seed_rag_demo`) ont été supprimées :
leurs chiffres (frais, moyennes, séries) n'étaient pas vérifiés. La base de connaissances se
remplit avec des documents réels, importés depuis le back-office (`/internal/documents/index`)
et par la veille automatique.

Le premier appel télécharge automatiquement le modèle d'embeddings
(`paraphrase-multilingual-MiniLM-L12-v2`, ~470 Mo, mis en cache par
`sentence-transformers` sous `%USERPROFILE%\.cache`).

## 5. Endpoints `/internal/*`

Toutes les requêtes doivent porter le header `X-Internal-Key: <INTERNAL_API_KEY>`
(401 sinon).

### `GET /internal/health`
Ping Django + MySQL + Ollama.
```
curl http://127.0.0.1:8001/internal/health -H "X-Internal-Key: <clé>"
```

### `POST /internal/chat` (streaming SSE)
```
curl -N http://127.0.0.1:8001/internal/chat ^
  -H "X-Internal-Key: <clé>" -H "Content-Type: application/json" ^
  -d "{\"utilisateur_id\":\"7302d663-2614-4465-8afc-00c2804d4af8\",\"message\":\"Quelles formations en informatique à l'UCAD ?\",\"profil\":{\"serie_bac\":\"S2\",\"budget_max\":500000,\"region_cible\":\"Dakar\",\"passions\":[\"informatique\"]}}"
```
Réponse : flux `text/event-stream`, une ligne par morceau de texte
(`data: {"token": "..."}\n\n`), terminé par
`data: {"done": true, "conversation_id": "...", "sources": [...]}\n\n`
(ou `data: {"error": "..."}\n\n` si Ollama est indisponible). Ce format est celui
attendu par le parseur SSE déjà présent côté Flutter
(`chat_remote_datasource.dart`).

### `POST /internal/documents/index`
Accepte soit un PDF (`multipart/form-data`, champ `document`, comme envoyé par
`DjangoAiClient::indexDocument` côté Laravel), soit un texte brut (`texte`) pour
les tests manuels. Champs optionnels : `source_id`, `universite_id`, `categorie`.

### `POST /internal/recommendations`
```
curl http://127.0.0.1:8001/internal/recommendations ^
  -H "X-Internal-Key: <clé>" -H "Content-Type: application/json" ^
  -d "{\"utilisateur_id\":\"7302d663-2614-4465-8afc-00c2804d4af8\",\"profil\":{\"serie_bac\":\"S2\",\"budget_max\":500000,\"mobilite\":true,\"region_cible\":\"Dakar\",\"passions\":[\"informatique\",\"entrepreneuriat\"],\"metiers_envisages\":[\"développeur\",\"data analyst\"]}}"
```
Retourne les 10 meilleures formations (scoring PARTIE 8), avec explication
générée par le LLM pour chacune, et persiste les résultats dans `recommandations`.

### `GET /internal/quality-metrics`
Nombre de documents/chunks indexés, requêtes traitées, taux de cache hit.

## 6. Intégration avec Laravel

Déjà connectée côté Laravel (`AiProxyController`, `DjangoAiClient`,
`config/services.php`) — rien à coder de ce côté. Vérifié/ajouté dans
`backend/.env` :
```
DJANGO_IA_BASE_URL=http://127.0.0.1:8001
DJANGO_IA_INTERNAL_KEY=<identique à INTERNAL_API_KEY de superapp_ia/.env>
DJANGO_IA_TIMEOUT=30
```
`AiProxyController::chat()` relaie le flux SSE de Django à Flutter sans le
bufferiser (utilisation de `response()->stream()` + `ob_flush()`), conformément à
la contrainte du CDC.

## 7. Tests de validation (PARTIE 11)

1. **Isoler Django de Laravel** : tester `/internal/chat`, `/internal/recommendations`
   directement en curl/Postman avec `X-Internal-Key`, avant de tester via Laravel.
2. **Profils différents** : utiliser au moins 2-3 `profil` différents (série,
   budget, région) sur `/internal/chat` et `/internal/recommendations`, vérifier
   que les réponses/scores changent en fonction du profil, pas seulement de la
   question.
3. **Question hors contexte** : poser une question sans rapport avec les fiches
   indexées (ex. "Quel temps fait-il à Paris ?") et vérifier que l'assistant
   répond honnêtement qu'il ne sait pas, au lieu d'inventer (le pipeline RAG
   renvoie alors 0 document pertinent, cf. `SEUIL_PERTINENCE` dans
   `ia/rag_pipeline.py`).
4. **Temps de réponse** : objectif CDC < 5 secondes (dépend fortement du CPU pour
   `mistral:7b-instruct` — sur une machine sans GPU, le premier token peut prendre
   plusieurs secondes).
5. **Hors-ligne** : couper l'accès internet, relancer une requête `/internal/chat`
   — tout doit continuer à fonctionner (Ollama + MySQL sont locaux).
6. **Recommandations** : vérifier que le classement des formations reflète bien
   la pondération (série bac 35, domaine/passions 30, budget 15, région 10,
   bourse 10 — détail renvoyé dans `details_score` de la réponse).

## 8. Choix d'implémentation à noter

- **Pas de Celery/Redis actif** : installés (`requirements.txt`) comme demandé,
  mais aucun endpoint du cahier des charges ne nécessite de tâche asynchrone
  (le crawling de sources externes n'est pas dans le périmètre livré) — brancher
  un worker Celery serait de la sur-ingénierie tant qu'aucune tâche concrète ne
  l'exige.
- **`django.contrib.auth/admin/sessions` non installés** : ce service n'a ni
  interface d'administration ni comptes utilisateurs propres ; les installer
  aurait pollué la base MySQL partagée avec des tables Django inutiles
  (`auth_user`, `django_session`...).
- **`manage.py runserver` en développement uniquement** : pour un vrai flux SSE
  en production, préférer un serveur ASGI (`daphne`/`uvicorn`) ou WSGI threadé
  (`gunicorn --worker-class gthread`) — non nécessaire pour la soutenance.
