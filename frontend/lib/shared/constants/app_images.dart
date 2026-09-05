/// Banque d'images réelles (Unsplash, libres de droit) utilisées pour les
/// données mockées : campus, logements, entreprises, vie étudiante.
/// Remplacer par les vraies photos des établissements une fois les visuels
/// officiels fournis par le backend (`photo_url` des fiches université).
abstract final class AppImages {
  static const String _base = 'https://images.unsplash.com';
  static String _url(String id, {int w = 900, int q = 65}) =>
      '$_base/$id?auto=format&fit=crop&w=$w&q=$q';

  /// Photos réelles de bâtiments d'établissements (Wikimedia Commons,
  /// CC BY-SA — voir CREDITS_IMAGES.md pour le détail par fichier).
  /// URLs `upload.wikimedia.org` directes (et non le raccourci
  /// `Special:FilePath`, dont les 302 intermédiaires côté
  /// `commons.wikimedia.org` n'envoient pas d'en-tête CORS — le renderer
  /// CanvasKit de Flutter web, qui charge les images via `fetch()`, échoue
  /// alors avec `net::ERR_FAILED`, constaté à l'écran via l'icône "image
  /// cassée" sur la page Universités malgré un `curl -I -L` réussi).
  static String _wikimedia(String path) => 'https://upload.wikimedia.org/$path';

  // Campus / bâtiments universitaires
  static String get campusUcad => _url('photo-1541339907198-e08756dedf3f');
  static String get campusIsep => _url('photo-1521587760476-6c12a4b040da');
  static String get campusUgb => _url('photo-1571260899304-425eee4c7efc');
  static String get campusEsp => _url('photo-1519452575417-564c1401ecc0');
  static String get campusUvs => _url('photo-1497633762265-9d179a990aa6');
  static String get campusGeneric1 => _url('photo-1523240795612-9a054b0db644');
  static String get campusGeneric2 => _url('photo-1562774053-701939374585');
  static String get campusAerial => _url('photo-1623631484725-fef26b75b402');

  /// Bannière d'accueil du dashboard — visuel de marque (ampoule/idée +
  /// icônes d'apprentissage), fichier embarqué plutôt que servi par URL.
  static const String dashboardHero = 'assets/images/dashboard_hero.jpg';
  static String get bibliotheque => _url('photo-1521587760476-6c12a4b040da');

  // Photos spécifiques par établissement (5 universités seedées, CREDITS_IMAGES.md)
  static String get campusUcadDakar => _url('photo-1621862681248-c891542db4d7');
  static String get campusUgbSaintLouis => _url('photo-1780770281153-dd29447c868d');
  static String get digitalLearning => _url('photo-1501250987900-211872d97eaa');

  // Vraies photos de campus (Wikimedia Commons) — bâtiments identifiables de
  // l'établissement réel, à privilégier sur les photos génériques ci-dessus
  // quand elles existent (voir CREDITS_IMAGES.md).
  static String get campusUcadReal =>
      _wikimedia('wikipedia/commons/thumb/5/5c/UCAD-Dakar.jpg/1280px-UCAD-Dakar.jpg');
  static String get campusUgbReal => _wikimedia(
    'wikipedia/commons/thumb/1/14/LaTourUGBVueSudOuest.jpg/1280px-LaTourUGBVueSudOuest.jpg',
  );
  static String get campusEspReal =>
      _wikimedia('wikipedia/commons/thumb/8/8d/ESPDakar.jpg/1280px-ESPDakar.jpg');
  static String get campusCesagReal =>
      _wikimedia('wikipedia/commons/e/ea/CESAG.jpg');

  /// Deux étudiants en atelier industriel — fichier embarqué, tiré du site
  /// officiel isep-thies.sn (voir CREDITS_IMAGES.md). Repli « photo réelle et
  /// spécifique » pour les ISEP, CFPT et lycées techniques.
  static const String isepThiesAtelier = 'assets/images/isep_thies_atelier.jpg';

  /// Photos réelles d'établissements embarquées (Wikimedia Commons, CC BY-SA 4.0
  /// — auteurs dans CREDITS_IMAGES.md). Embarquées plutôt que servies par URL
  /// pour éviter l'aléa CORS du renderer CanvasKit sur les vignettes/thumbs.
  static const String eptThiesReal = 'assets/images/etablissements/ept_thies.webp';
  static const String ensaThiesReal = 'assets/images/etablissements/ensa_thies.webp';

  /// Groupe de quatre étudiant·e·s ouest-africain·e·s avec ordinateurs
  /// portables dans un cadre urbain (Iwaria Inc., licence Unsplash) — repli
  /// « contexte authentiquement africain » pour les établissements sans
  /// photo de bâtiment (voir CREDITS_IMAGES.md).
  static String get etudiantsDakar => _url('photo-1655720348590-c739c860beed');

  // Vie étudiante / actualités
  static String get etudiantsGroupe => _url('photo-1523580494863-6f3031224c94');
  static String get etudiantEtude => _url('photo-1554415707-6e8cfc93fe23');
  static String get remiseDiplome => _url('photo-1523240795612-9a054b0db644');
  static String get amphi => _url('photo-1524178232363-1fb2b075b655');
  static String get boursesEtude => _url('photo-1554224155-6726b3ff858f');

  // Logements
  static String get logement1 => _url('photo-1560448204-e02f11c3d0e2');
  static String get logement2 => _url('photo-1502672260266-1c1ef2d93688');
  static String get logement3 => _url('photo-1580582932707-520aed937b7b');
  static String get logement4 => _url('photo-1522708323590-d24dbb6b0267');

  // Entreprises / emploi
  static String get entreprise1 => _url('photo-1497366216548-37526070297c');
  static String get entreprise2 => _url('photo-1497366811353-6870744d04b2');
  static String get bureau1 => _url('photo-1521737604893-d14cc237f11d');
  static String get bureau2 => _url('photo-1497215728101-856f4ea42174');

  // Avatars par défaut (portraits neutres, pour aperçus profil)
  static String get avatarHomme =>
      _url('photo-1500648767791-00dcc994a43e', w: 300);
  static String get avatarFemme =>
      _url('photo-1494790108377-be9c29b29330', w: 300);

  static const List<String> universityGallery = [
    'photo-1541339907198-e08756dedf3f',
    'photo-1562774053-701939374585',
    'photo-1571260899304-425eee4c7efc',
    'photo-1519452575417-564c1401ecc0',
    'photo-1497633762265-9d179a990aa6',
    'photo-1523240795612-9a054b0db644',
  ];

  static String universityById(int index) =>
      _url(universityGallery[index % universityGallery.length]);

  /// Sentinelle volontaire : aucune photo réelle et vérifiée n'a été trouvée
  /// pour cet établissement (site officiel absent/inaccessible ou sans
  /// image exploitable). Domaine invalide par construction — déclenche le
  /// repli visuel "image indisponible" de `EntityCard`/`_UniversityVignette`
  /// plutôt que d'afficher une photo générique trompeuse. Voir le rapport
  /// de recherche du catalogue pour la liste des établissements concernés.
  static const String aucunePhoto = 'https://no-image-available.invalid/none.jpg';

  // ---------------------------------------------------------------------
  // Photos réelles par établissement — trouvées sur le site officiel de
  // chaque établissement (ou son infobox Wikipédia à défaut), vérifiées
  // chargeables une à une. Remplacent les replis génériques partagés
  // (campusGeneric1/2, bibliotheque, digitalLearning, isepThiesAtelier,
  // bureau1/2, entreprise1/2...) qui provoquaient des doublons trompeurs
  // entre établissements sans rapport.
  // ---------------------------------------------------------------------
  static const String cestiReal =
      'https://cesti.ucad.sn/wp-content/uploads/2026/06/cesti-entree.jpg';
  static const String ebadReal =
      'https://ebad.ucad.sn/sites/default/files/facade1_3_0.jpg';
  static const String itaReal =
      'https://ita.sn/wp-content/uploads/2025/07/IMG_E52331-scaled.jpg';
  static const String uidtReal = 'https://www.uidt.sn/campus/batiment.webp';
  static const String uaszReal =
      'https://uasz.sn/wp-content/uploads/2014/10/devant_le_rectorat.jpg';
  static const String uadbReal = 'https://upload.wikimedia.org/wikipedia/fr/3/31/UADB.jpeg';
  static const String uamReal = 'http://uam.sn/wp-content/uploads/2024/04/UAM1.png';
  static const String unchkReal =
      'https://www.unchk.sn/wp-content/uploads/2026/08/3I9A0812-scaled.jpg';
  static const String isepMatamReal =
      'https://isepmatam.sn/wp-content/uploads/2019/10/IMG_0423.jpg';
  static const String cfptSjReal =
      'https://cfptsj.sn/wp-content/uploads/2023/07/MG_0633-scaled.jpg';
  static const String uahbReal =
      'https://univ.uahb.sn/wp-content/uploads/2022/01/uahb-bg-maintenance-1024x576.jpg';
  static const String udbReal = 'http://www.udb-sn.com/images/img-2.jpg';
  static const String unisReal = 'https://www.sahel.education/assets/unis-drone.JPG';
  static const String iamReal =
      'https://groupeiam.com/wp-content/uploads/2026/06/DSC03475-Avec-accentuation-NR-copie-2-scaled.jpg';
  static const String esmtReal =
      'https://esmt.sn/sites/default/files/styles/slideshow/public/img_8855.jpg?itok=G9wVm6pD';
  static const String ipgReal =
      'https://ipg-isti.com/assets/img/photos/brochure-campus.jpg';
  static const String cedsDkrReal =
      'https://cedsdakar.org/wp-content/uploads/2025/06/IMG_4687-1.jpg';
  static const String ditReal =
      'https://dit.sn/wp-content/uploads/2023/09/IMG_5602-scaled.webp';
  static const String marmitonsReal =
      'https://ecolelesmarmitons.com/wp-content/uploads/2023/09/Z3A7390P-1024x683.jpg';
  static const String odcReal = 'https://orangedigitalcenter.sn/odc2Accueil.jpg';
  static const String ltimkReal =
      'https://www.ltimk.com/wp-content/uploads/2026/05/WhatsApp-Image-2026-05-18-at-17.16.37-11-1000x668.jpeg';
  static const String isfarReal = 'https://uadb.edu.sn/images/2025/11/04/is2.jpg';
  static const String issReal = 'https://www.issante.sn/iss-hero-1.jpg';
  static const String isiReal =
      'https://www.groupeisi.com/wp-content/uploads/2018/12/ISI-KM-2.jpg';
  static const String ejicomReal =
      'https://www.ejicom.com/wp-content/uploads/2022/08/laureats-prix-ejicom-2021-scaled.jpg';
  static const String afiUeReal =
      'https://afi-ue.sn/wp-content/uploads/2026/06/DSC05805-400x250.jpg';
  static const String cedtG15Real =
      'https://cedtleg15.com/wp-content/uploads/2026/03/WhatsApp-Image-2026-03-22-at-18.43.22-150x150.jpeg';
  static const String ucaoUudReal =
      'https://www.st-michel.sn/wp-content/uploads/2021/09/IMG_3270-2-225x300.jpg';
  static const String ukbReal =
      'https://ukb.sn/sites/default/files/slider/465732757_1090899322605218_4271003705848982174_n_0.png';
  static const String enfefsReal =
      'https://enfefs.com/wp-content/uploads/2026/06/723838433_1597033872427397_1892845812497471956_n-1024x768.jpg';
  static const String issZigReal =
      'https://univ.issante.org/wp-content/uploads/2021/06/WhatsApp-Image-2021-06-21-at-22.19.30.jpeg';
  static const String isfommReal =
      'https://assets.zyrosite.com/cdn-cgi/image/format=auto,w=1224,h=424,fit=crop/m2W8N71nMKt4gM3Q/whatsapp-image-2025-04-29-at-17.45.32-AGB2Q8xB01F66MvO.jpeg';
}
