import 'package:connectivity_plus/connectivity_plus.dart';

/// Wrapper connectivity_plus — permet d'afficher la bannière "mode
/// hors-ligne" et d'éviter des appels réseau inutiles sur connexion 3G.
class NetworkInfo {
  NetworkInfo({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Stream<bool> get onConnectivityChanged => _connectivity
      .onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none));
}
