import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectionService {
  String? lastRoute;

  void initialize() {
    Connectivity().onConnectivityChanged.listen((connectivityResult) {
      if (connectivityResult.contains(ConnectivityResult.none)) {
        lastRoute = Get.currentRoute;
        Get.offAllNamed('/no-connection');
      } else if (lastRoute != null) {
        Get.offAndToNamed(lastRoute!);
        lastRoute = null;
      }
    });
  }
}
