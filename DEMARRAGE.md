# Ndimbeul Étudiant — Installer et lancer le projet

Guide pour faire tourner l'application complète sur votre machine Windows :
**Laravel** (API), **Django** (IA), **Celery** (veille automatique toutes les 2 h)
et **Flutter** (application, dans Chrome).

---

## 1. Logiciels à installer (une seule fois)

| Logiciel | Version | Rôle |
|---|---|---|
| [Laragon](https://laragon.org/download/) (édition *Full*) | PHP 8.3, MySQL | Base de données + PHP + Redis |
| [Composer](https://getcomposer.org/download/) | 2.x | Dépendances Laravel |
| [Python](https://www.python.org/downloads/) | **3.12** | Service IA Django |
| [Flutter](https://docs.flutter.dev/get-started/install/windows) | 3.4x (stable) | Application |
| [Google Chrome](https://www.google.com/chrome/) | récente | Affichage de l'app |
| [Ollama](https://ollama.com/download) | récente | IA locale |
| [Git](https://git-scm.com/download/win) | récente | Récupérer le code |

Vérifier : `php -v`, `composer -V`, `py -3.12 --version`, `flutter --version`, `ollama --version`.

Prévoir **8 Go de RAM minimum** (l'IA locale tourne sur le processeur).

---

## 2. Installation (une seule fois)

### 2.1 Récupérer le code

```powershell
cd C:\laragon\www
git clone https://github.com/cpkf2026-ops/ndimbeul-etudiant-ligueyrek.git Ndimbeul-Edu
cd Ndimbeul-Edu
```

### 2.2 Base de données

1. Ouvrir **Laragon** → **Start All**.
2. Laragon → **Database** (HeidiSQL) → créer une base nommée **`backendpff`**
   (interclassement `utf8mb4_unicode_ci`).

### 2.3 Backend Laravel

```powershell
cd C:\laragon\www\Ndimbeul-Edu\backend
composer install
copy .env.example .env
php artisan key:generate
```

Ouvrir `backend\.env` et modifier :

```env
DB_DATABASE=backendpff
DB_USERNAME=root
DB_PASSWORD=
DJANGO_IA_BASE_URL=http://127.0.0.1:8001
DJANGO_IA_INTERNAL_KEY=une_cle_secrete_commune
```

Puis créer les tables et les données de départ :

```powershell
php artisan migrate --seed
php artisan storage:link
```

### 2.4 Service IA Django

```powershell
cd C:\laragon\www\Ndimbeul-Edu\superapp_ia
py -3.12 -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
```

Ouvrir `superapp_ia\.env` et renseigner :

```env
# La même clé que DJANGO_IA_INTERNAL_KEY dans backend\.env
LARAVEL_SHARED_TOKEN=une_cle_secrete_commune
# Clé de recherche web Tavily (gratuite, 1 000 crédits/mois) : voir § 2.7
TAVILY_API_KEY=tvly-...
```

Puis charger la liste des sites de confiance utilisés par la recherche web :

```powershell
python manage.py charger_sources
```

> La première installation (`pip install`) peut prendre 10 à 20 minutes.

### 2.5 Modèle d'IA

```powershell
ollama pull qwen3.5:2b
```

Un seul modèle léger (2,7 Go de RAM) fait tout : chatbot, orientation et veille.
Sur un PC de **16 Go ou plus**, on peut ajouter `ollama pull mistral:7b-instruct` et mettre
`OLLAMA_MODEL=mistral:7b-instruct` dans `superapp_ia\.env` (veille mieux rédigée). Sur 8-10 Go,
ne pas le faire : les deux modèles ensemble saturent la mémoire et bloquent la machine.

### 2.6 Application Flutter

```powershell
cd C:\laragon\www\Ndimbeul-Edu\frontend
flutter pub get
```

### 2.7 Clé Tavily (recherche web)

1. Créer un compte gratuit sur **https://app.tavily.com** (e-mail ou Google).
2. Dans le tableau de bord, copier la clé **API Key** (elle commence par `tvly-`).
3. La coller dans `superapp_ia\.env` : `TAVILY_API_KEY=tvly-...` (sans espace ni guillemets).
4. Redémarrer Django et la veille (`demarrer_tout.bat`), puis vérifier que
   `GET /api/ia/sante/` renvoie `"cle_configuree": true` (voir `superapp_ia\API_IA.md`).

Le plan gratuit donne 1 000 crédits par mois. Le service les compte lui-même
(table `credits_tavily`) : la veille s'arrête à 800 crédits pour garder 200 crédits
au chatbot et à l'orientation, puis passe en mode réduit (toutes les 6 h, sources
gratuites). Sans clé, tout fonctionne quand même, sans recherche web.

---

## 3. Lancer le projet (à chaque fois)

Ouvrir **Laragon → Start All** (MySQL), puis **un terminal par commande**.
Les laisser ouverts tant que vous utilisez l'application.

**Terminal 1 — Redis** (file d'attente de la veille IA)
```powershell
C:\laragon\bin\redis\redis-x64-5.0.14.1\redis-server.exe
```
> Le numéro de version dans le chemin peut varier : vérifier le dossier `C:\laragon\bin\redis\`.

**Terminal 2 — Ollama** (IA locale)
```powershell
ollama serve
```
> Message *« address already in use »* = Ollama tourne déjà : fermer ce terminal.

**Terminal 3 — API Laravel** (port 8000)
```powershell
cd C:\laragon\www\Ndimbeul-Edu\backend
php artisan serve --port=8000
```

**Terminal 4 — Service IA Django** (port 8001 : chat et recommandations)
```powershell
cd C:\laragon\www\Ndimbeul-Edu\superapp_ia
.\venv\Scripts\activate
python manage.py runserver 8001
```

**Terminal 5 — Celery worker** (exécute la veille)
```powershell
cd C:\laragon\www\Ndimbeul-Edu\superapp_ia
.\venv\Scripts\activate
$env:PYTHONIOENCODING="utf-8"
celery -A superapp_ia worker -l info --pool=solo
```

**Terminal 6 — Celery Beat** (déclenche la veille toutes les 2 h)
```powershell
cd C:\laragon\www\Ndimbeul-Edu\superapp_ia
.\venv\Scripts\activate
$env:PYTHONIOENCODING="utf-8"
celery -A superapp_ia beat -l info
```

**Terminal 7 — Application Flutter** (s'ouvre dans Chrome)
```powershell
cd C:\laragon\www\Ndimbeul-Edu\frontend
flutter run -d chrome --web-port 8090
```

L'application est sur **http://localhost:8090**.

---

## 4. Vérifier que tout fonctionne

| Où | Ce qu'on doit voir |
|---|---|
| Terminal 3 | `Server running on [http://127.0.0.1:8000]` |
| Navigateur : http://localhost:8000/api/v1/news | du texte JSON (`{"data":[...]}`) |
| Terminal 5 | `celery@... ready.` |
| Terminal 6 | `beat: Starting...` puis `Sending due task veille-...` |
| Chrome | l'accueil de l'application |

### Remplir tout de suite les actualités et les offres

La veille passe toutes les 2 h. Pour ne pas attendre, dans un **nouveau terminal** :

```powershell
cd C:\laragon\www\Ndimbeul-Edu\superapp_ia
.\venv\Scripts\activate
$env:PYTHONIOENCODING="utf-8"
python manage.py veiller --actualites      # module 3 : Tavily + Mistral
python manage.py veiller --opportunites    # module 2 : Tavily + Mistral
```

Chaque commande consomme 1 crédit Tavily et prend 5 à 15 minutes (environ 1 minute
de Mistral par nouvel élément). Sans clé Tavily, utiliser les sources gratuites :
`python manage.py veiller --actualites-gratuites` et `python manage.py veiller --offres`.

### Lancer les tests automatiques

```powershell
cd C:\laragon\www\Ndimbeul-Edu\superapp_ia
.\venv\Scripts\python manage.py test tests --settings=tests.settings_test
```

Tavily et Ollama sont simulés : les tests tournent sans Internet, sans MySQL et sans Redis.

---

## 5. Problèmes fréquents

| Problème | Solution |
|---|---|
| `Cannot connect to redis://localhost:6379` | Le terminal 1 (Redis) n'est pas lancé. |
| `SQLSTATE[HY000] [2002]` / erreur MySQL | Laragon n'est pas démarré (**Start All**). |
| L'app affiche « Impossible de charger » | Le terminal 3 (Laravel) n'est pas lancé. |
| Chat IA : erreur 401 | `DJANGO_IA_INTERNAL_KEY` (backend) ≠ `LARAVEL_SHARED_TOKEN` (superapp_ia). |
| Chat IA très lent ou erreur 503 | Ollama non lancé, ou modèle non téléchargé (`ollama pull qwen3.5:2b`). |
| Pas de recherche web (`recherche_web_indisponible`) | `TAVILY_API_KEY` vide ou invalide dans `superapp_ia\.env`. |
| Erreur 429 `quota_tavily_atteint` | Crédits Tavily du mois épuisés : le service répond depuis la base. |
| Chat plus lent pendant la veille | Normal : Mistral utilise 4 cœurs pendant la veille (`OLLAMA_VEILLE_NUM_THREAD`). |
| `Port 8090 is already in use` | Une app Flutter tourne déjà : la fermer, ou utiliser `--web-port 8091`. |
| Les nouveautés n'apparaissent pas | Vérifier les terminaux 5 et 6 ; l'app se recharge seule toutes les 15 min (ou tirer la liste vers le bas). |

**Arrêter un service :** `Ctrl + C` dans son terminal.
**Après une modification du code Flutter :** touche `r` (rechargement) ou `R` (redémarrage) dans le terminal 7.

---

## 6. Comment fonctionne le service IA (pour comprendre)

Règle du projet : **« Tavily cherche, Mistral rédige »**. Tavily ramène des
informations fraîches du web ; le LLM local les résume et les classe en français,
sans jamais inventer ce qui n'est pas dans les sources (dates, chiffres, organismes
et métiers sont revérifiés par du code dans le texte source).

La veille n'est pas une IA « entraînée » : c'est une **tâche planifiée** (Celery Beat,
toutes les 2 h) qui, pour les offres (module 2) puis les actualités (module 3) :

1. lance **une seule recherche Tavily** (1 crédit) limitée aux sites de confiance
   (table `sources_confiance`) ;
2. écarte les doublons (empreinte URL + titre) **avant** d'appeler le LLM ;
3. vérifie la page (lien vivant, date réelle, image réelle) ;
4. demande à **Mistral 7B** (Ollama) une fiche structurée, puis la contrôle ;
5. enregistre dans MySQL → l'app Flutter l'affiche via l'API Laravel.

Le chatbot (module 4) et l'orientation (module 1) cherchent d'abord dans la base,
puis sur Tavily seulement si nécessaire, et répondent en moins de 30 s.
Détail des routes et exemples JSON : `superapp_ia/API_IA.md`.

Le code est dans `superapp_ia/services/` (Tavily, Ollama, crédits, cache, sources),
`superapp_ia/veille/` (modules 2 et 3), `superapp_ia/recommandations/` (module 1)
et `superapp_ia/ia/` (module 4).

## Guide administrateur : ajouter un établissement, une actualité, un emploi / stage

Connecté avec un compte administrateur, un bouton jaune **« + Ajouter… »** apparaît en bas
des pages **Universités**, **Actualités** et **Emploi** (et trois raccourcis dans le
tableau de bord admin). Le principe est toujours le même, en 3 étapes :

1. **Donner l'information de départ**
   - établissement : taper son nom (ex. « Institut Supérieur de Santé de Kaolack ») ;
   - actualité / offre : coller le lien de la page (site officiel, presse, Senjob…).
     Pour une annonce interne sans lien : « Remplir à la main ».
2. **L'IA prépare une proposition** (20 à 40 s pour un établissement) :
   site officiel vérifié, présentation tirée des pages trouvées, quartier/ville, statut
   public/privé **seulement s'il est prouvé**, logos ; pour un lien : titre, résumé,
   date, image, organisme, date limite. Elle signale aussi ce qui **existe déjà**
   dans l'application (pour éviter les doublons).
3. **Relire, corriger, publier** : rien n'est publié sans validation. Une fois publié,
   le contenu s'affiche exactement comme ceux trouvés par la veille IA.

Bonnes pratiques :
- Statut public/privé : laisser « Non vérifié » en cas de doute (vérifier sur
  anaqsup.sn ou espaceuniversitaire.mesrisenegal.sn).
- Préférer les liens officiels (sites des écoles, mesrisenegal.sn, presse reconnue).
- Chaque recherche d'établissement consomme 1 crédit Tavily (lecture d'un lien : 0).

## Web et mobile en même temps

Le même code Flutter sert le web et Android. Le PC fait office de serveur sur le Wi-Fi :
`demarrer_tout.bat` lance l'API Laravel sur toutes les interfaces (`--host=0.0.0.0`).

**Sur le PC** : http://localhost:8090

**Sur un téléphone connecté au même Wi-Fi** :
- dans le navigateur du téléphone : `http://<IP-du-PC>:8090` (la version web appelle
  automatiquement l'API de la machine qui sert la page) ;
- ou l'application Android (APK) : `frontend\build\app\outputs\flutter-apk\app-release.apk`,
  à copier sur le téléphone et installer (autoriser « sources inconnues »).

L'APK contient l'adresse du PC. Si l'adresse change (autre Wi-Fi), reconstruire :
```
ipconfig                      (lire « Adresse IPv4 », ex. 192.168.1.27)
cd frontend
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.27:8000/api/v1
```
Quand l'API sera hébergée en ligne (HTTPS), reconstruire avec son adresse : l'application
fonctionnera alors partout, sans le PC.

iPhone : la construction iOS nécessite un Mac (impossible depuis Windows).
