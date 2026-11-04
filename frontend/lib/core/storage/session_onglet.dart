/// Stockage de session « le temps de l'onglet » (web : sessionStorage).
///
/// Une actualisation de la page garde la session ; fermer l'onglet ou rouvrir le
/// lien repart de l'écran de connexion (comme sur le PC). Sur mobile, ces
/// fonctions ne sont jamais appelées (stockage natif sécurisé à la place).
library;

export 'session_onglet_stub.dart' if (dart.library.js_interop) 'session_onglet_web.dart';
