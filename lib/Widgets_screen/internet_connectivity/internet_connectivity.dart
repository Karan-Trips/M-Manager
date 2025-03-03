import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetController extends GetxController {
  var isConnected =
      false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection(); 
    _listenToConnectionChanges();
  }

  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    isConnected.value = result != ConnectivityResult.none;
  }

  void _listenToConnectionChanges() {
    Connectivity().onConnectivityChanged.listen((result) {
      isConnected.value = result != ConnectivityResult.none;
    });
  }
}
