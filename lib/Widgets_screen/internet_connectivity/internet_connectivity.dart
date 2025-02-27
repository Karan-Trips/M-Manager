import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetController extends GetxController {
  var isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    checkInternet();
  }

  void checkInternet() async {
    Connectivity().onConnectivityChanged.listen((result) {
      isConnected.value = result != ConnectivityResult.none;
    });
  }
}
