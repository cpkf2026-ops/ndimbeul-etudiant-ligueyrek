# Crédits images — Ndimbeul-Etudiant

Toutes les photos Unsplash listées ci-dessous sont utilisées sous la [licence Unsplash](https://unsplash.com/license) (usage libre, y compris commercial, sans attribution obligatoire). Aucune photo `plus.unsplash.com` (Unsplash+/payant) n'est utilisée. Les photos Wikimedia Commons sont sous licence **CC BY-SA** (voir la page de chaque fichier pour l'auteur exact) — attribution requise en cas de réutilisation hors de l'app.

## Vraies photos de bâtiments (Wikimedia Commons)

Recherche dédiée (Wikipédia + Wikimedia Commons MediaSearch) pour trouver une photo **authentique et identifiable** du campus de chaque établissement plutôt qu'une photo générique. Résultat par établissement :

| Établissement | Photo | Fichier Wikimedia Commons | Constante |
|---|---|---|---|
| UCAD (Dakar) | Entrée du campus de l'Université Cheikh Anta Diop | https://commons.wikimedia.org/wiki/File:UCAD-Dakar.jpg | `AppImages.campusUcadReal` |
| UGB (Saint-Louis) | La Tour UGB, vue sud-ouest — bâtiment emblématique du campus | https://commons.wikimedia.org/wiki/File:LaTourUGBVueSudOuest.jpg | `AppImages.campusUgbReal` |
| ESP Dakar | Bâtiment de l'École Supérieure Polytechnique de Dakar | https://commons.wikimedia.org/wiki/File:ESPDakar.jpg | `AppImages.campusEspReal` |
| CESAG (Dakar) | Bâtiment principal du CESAG — auteur *Royalkhaimo*, CC BY-SA 4.0 (ajout Prompt 5) | https://commons.wikimedia.org/wiki/File:CESAG.jpg | `AppImages.campusCesagReal` |
| EPT (École Polytechnique de Thiès) | Allées et bâtiments du campus (« Case des polytechniciens ») — auteur *Tchernodawda*, CC BY-SA 4.0 — fichier embarqué `assets/images/etablissements/ept_thies.webp` | https://commons.wikimedia.org/wiki/File:Case_des_polytechniciens_de_l%27%C3%A9cole_polytechnique_de_Thies.jpg | `AppImages.eptThiesReal` |
| ENSA (École Nat. Sup. d'Agriculture, Thiès) | Élèves de l'ENSA (tenue eaux-et-forêts) au défilé de Thiès — photo réelle et spécifique à l'établissement (pas de photo de bâtiment trouvée) — auteur *Kikanakana*, CC BY-SA 4.0 — fichier embarqué `assets/images/etablissements/ensa_thies.webp` | https://commons.wikimedia.org/wiki/File:Ecole_Nationale_Sup%C3%A9rieure_d%27Agriculture_(ENSA)_de_Thi%C3%A8s.jpg | `AppImages.ensaThiesReal` |

**Note technique** : les constantes pointent vers l'URL `upload.wikimedia.org/.../thumb/...` directe (résolue une fois via `curl -L`), pas vers le raccourci `commons.wikimedia.org/wiki/Special:FilePath/...`. Les redirections intermédiaires de ce raccourci ne renvoient pas d'en-tête CORS, ce que `curl` suit sans broncher mais que le renderer CanvasKit de Flutter web refuse (`fetch()` échoue en mode CORS) — les photos s'affichaient cassées dans l'app malgré une vérification `curl` positive. Toujours valider un nouvel URL Wikimedia par un vrai `fetch()` navigateur (CORS), pas seulement par `curl`, avant de l'intégrer.

**Établissements sans photo de bâtiment trouvée** (recherche Wikipédia FR/EN + Wikimedia Commons MediaSearch infructueuse — page sans photo, ou pas de page dédiée) : ISEP, ISM, UADB (Bambey), UASZ (Ziguinchor). Conservent leur photo générique Unsplash déjà en place ci-dessous. UVS/UNCHK (université 100% numérique, sans campus physique) conserve délibérément une photo d'apprentissage numérique plutôt qu'une photo de bâtiment inexistant.

## ISEP Thiès (section "Universités d'Excellence" du tableau de bord) — fichier embarqué

Aucune photo de bâtiment trouvée pour ISEP Thiès (aucune page Wikipédia/Commons dédiée). Repli sur une photo réelle et spécifique tout de même — pas une photo générique sans rapport — tirée du site officiel de l'établissement.

| Photo | Détails | Source | Constante |
|---|---|---|---|
| `assets/images/isep_thies_atelier.jpg` | Deux étudiants en atelier (équipement de protection, mesure sur pièces industrielles) | Slider d'accueil de [isep-thies.sn](https://www.isep-thies.sn/) | `'assets/images/isep_thies_atelier.jpg'` (fichier embarqué — le site ne renvoie pas d'en-tête CORS, voir note technique ci-dessus) |

⚠️ Licence non confirmée (photo institutionnelle sans mention de licence explicite) — même réserve que la photo du splash ci-dessous.

## Photos génériques par université (établissements sans photo réelle trouvée)

| Établissement | Photo | Photographe | Source |
|---|---|---|---|
| ISEP (Diamniadio) | Bibliothèque / espace d'étude (`AppImages.bibliotheque`, remplace `campusIsep` dont l'URL Unsplash retournait 404) | — | déjà intégrée avant ce chantier |
| ISM (Dakar) | Bureau moderne / cadre professionnel (`AppImages.bureau1`) | — | déjà intégrée avant ce chantier |
| UNCHK / UVS (université 100% numérique) | Travail sur ordinateur portable — collection "black stock images" | Benjamin Dada | https://unsplash.com/photos/EDZTb2SQ6j0 |

## Hero de l'accueil (dashboard)

| Usage | Photo | Photographe | Source |
|---|---|---|---|
| `AppImages.campusAerial` — hero dashboard | Chemin de campus universitaire (Princeton University) menant à un bâtiment | photo publiée le 14/06/2021 | https://unsplash.com/photos/JYqLCa-rv7o |

## Fond du splash — fichier embarqué (pas d'URL distante)

Le fond du splash (`assets/images/splash_graduation_afrique.webp`) est un **fichier embarqué dans l'app** (dossier `assets/images/` déclaré dans `pubspec.yaml`, chargé via `Image.asset`), pas une URL distante — un fichier embarqué évite le problème CORS du renderer CanvasKit de Flutter web (voir note technique plus haut).

**Prompt 5 — remplacement de la photo UCAD.** L'ancien fond montrait la fresque murale du Pavillon A de l'**UCAD** (`ucad_pavillon_a_mural.jpg`), ce qui laissait penser à tort que l'app est dédiée à l'UCAD. Elle a été remplacée par un visuel **générique** sur le thème du savoir (aucun établissement réel). L'ancien fichier `ucad_pavillon_a_mural.jpg` a été supprimé des assets.

| Photo | Détails | Photographe | Source |
|---|---|---|---|
| `assets/images/splash_savoir_ampoule.webp` | Ampoule à filament allumée posée sur une pile de livres anciens — concept « idée / savoir / avenir », aucun établissement ni personne identifiable | **Beth Stevenson** | [unsplash.com/photos/NtfFqT8JBI0](https://unsplash.com/photos/NtfFqT8JBI0) — [licence Unsplash](https://unsplash.com/license) (usage libre, y c. commercial, sans attribution obligatoire) |

Le concept exact demandé (toque + pile de livres + ampoule, fond turquoise) n'existe que sur des banques payantes (l'image de référence venait de **Freepik**, non libre pour cet usage et en 626×358 seulement). Cette photo Unsplash en est l'équivalent le plus proche sous licence claire.

Traitement : téléchargée en 1600×2400, **recadrée** pour retirer l'espace vide en haut (→ 1200×1410, ampoule + pile de livres cadrées serré) et convertie en WebP q≈80 via GD (PHP) → **122 Ko** (< 200 Ko exigé). Dans `splash_screen.dart` : `BoxFit.cover` + `alignment (0, 0.22)` (biais bas pour garder les livres visibles sur écran large) et voile vert **fortement allégé** (~0,28 haut / ~0,10 milieu / ~0,82 bas).

## Catalogue élargi (Prompt 5) — ~60 établissements

Le `UniversiteSeeder` (Laravel) et `MockUniversityData` (Flutter) couvrent désormais les 8 universités publiques, les grandes écoles publiques, le réseau des 6 ISEP, ~20 universités/écoles privées reconnues et ~16 centres de formation professionnelle et technique.

**Images — état de la recherche (sweep Wikimedia Commons exhaustif sur les 62 fiches).** Photos **réelles et sous licence claire** trouvées et intégrées, soit **7 établissements sur 62** :

| Établissement | Type de visuel | Constante |
|---|---|---|
| UCAD, UGB, ESP, CESAG | Bâtiment / campus (Wikimedia CC BY-SA) | `campusUcadReal`, `campusUgbReal`, `campusEspReal`, `campusCesagReal` |
| EPT (Thiès) | Campus (Wikimedia CC BY-SA, embarqué) | `eptThiesReal` |
| ENSA (Thiès) | Élèves de l'établissement (Wikimedia CC BY-SA, embarqué) | `ensaThiesReal` |
| ISEP Thiès | Atelier, site officiel (déjà en place) | `isepThiesAtelier` |

**Les 55 autres établissements n'ont aucune photo de bâtiment réutilisable.** Recherche effectuée : Wikimedia Commons (générateur `search`, ns 6) sur chaque nom d'établissement + variantes → aucun résultat pertinent au-delà des 7 ci-dessus (beaucoup de faux positifs : « UAM » = Univ. Autónoma de Madrid, « UVS » = lac de Mongolie, « ESMT » = école de Berlin, « UDB » = galerie d'art à Paris…).

Les autres pistes demandées **ne sont pas exploitables en l'état** :
- **Google Maps / Street View** : les conditions d'utilisation de Google interdisent le téléchargement/extraction des images et leur réutilisation dans une autre application. L'API Static Maps impose une clé facturée + attribution Google et interdit le stockage permanent.
- **Sites officiels & pages Facebook** : photos protégées par le droit d'auteur de l'établissement, sans licence de réutilisation ; de plus la plupart des sites `.sn` ne renvoient pas d'en-tête CORS → `Image.network` échoue dans Flutter web (voir note technique plus haut). Utilisables uniquement avec **autorisation écrite** de chaque établissement, puis dépôt manuel dans `assets/images/etablissements/`.

**En attendant**, repli sur un jeu d'images génériques à contexte africain crédible, réparties par catégorie (universités, ISEP/CFPT, écoles de commerce, numérique). Une même image peut apparaître sur plusieurs fiches d'une même catégorie. Le champ `image_url` (back-office admin d'établissement) permet de remplacer chaque visuel au cas par cas dès qu'une photo autorisée est disponible.

| Repli | Image | Photographe / source |
|---|---|---|
| Universités/écoles — vie de campus | `AppImages.etudiantsDakar` (`photo-1655720348590-c739c860beed`) | **Iwaria Inc.** — [unsplash.com/photos/vWqBjWbc_H4](https://unsplash.com/photos/vWqBjWbc_H4), licence Unsplash |
| Universités publiques régionales | `campusGeneric1/2`, `campusAerial`, `amphi`, `bibliotheque` | déjà en place (voir plus bas) |
| ISEP / CFPT / lycées techniques | `AppImages.isepThiesAtelier` (fichier embarqué), `campusGeneric1/2` | isep-thies.sn / Unsplash |
| Écoles privées de commerce/gestion | `bureau1/2`, `entreprise1/2` | déjà en place |
| Numérique / à distance (UN-CHK, ESMT, ISI…) | `digitalLearning` | Benjamin Dada — Unsplash (déjà en place) |

## Note méthodologique

Le catalogue Unsplash ne contient pas de photos officielles des campus sénégalais spécifiques (UCAD, UGB, ISEP, ISM, UNCHK) — recherche effectuée mais aucun résultat gratuit et fiable trouvé pour chaque bâtiment précis. Priorité donnée à des photos **authentiquement sénégalaises** (Dakar, Saint-Louis) plutôt qu'à des photos de campus génériques non-africaines, conformément au repli recommandé par le cahier des charges ("photo générique de la même région plutôt qu'un placeholder"). Les photos "vie étudiante" déjà en place dans `AppImages` (groupe d'étudiants, amphithéâtre, bibliothèque, bourses) ont été spot-vérifiées et conservées — elles montrent déjà des contextes crédibles et variés.
