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
}
