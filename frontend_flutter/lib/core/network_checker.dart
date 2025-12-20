import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkChecker {
  static Future<bool> hasNetwork() async {
    final connectivityResults = await Connectivity().checkConnectivity();

    // If ALL results are 'none', there is no network connection
    if (connectivityResults.contains(ConnectivityResult.none)) {
      return false;
    }

    // Double-check real internet access
    return await InternetConnectionChecker().hasConnection;
  }
}
