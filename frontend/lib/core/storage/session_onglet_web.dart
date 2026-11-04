import 'package:web/web.dart' as web;

String? lireSessionOnglet(String cle) => web.window.sessionStorage.getItem(cle);

void ecrireSessionOnglet(String cle, String valeur) => web.window.sessionStorage.setItem(cle, valeur);

void supprimerSessionOnglet(String cle) => web.window.sessionStorage.removeItem(cle);
