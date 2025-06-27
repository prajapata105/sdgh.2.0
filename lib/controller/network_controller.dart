import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final connectionStatus = Rx<ConnectivityResult>(ConnectivityResult.none);

  bool get isConnected => connectionStatus.value != ConnectivityResult.none;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    checkConnection();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  // <<<--- मुख्य बदलाव यहाँ नए और बेहतर लॉजिक में है ---<<<
  void _updateConnectionStatus(List<ConnectivityResult> resultList) {
    print('Connectivity Result List: $resultList'); // डीबगिंग के लिए

    // अब हम सीधे चेक करेंगे कि वाई-फाई या मोबाइल डेटा मौजूद है या नहीं।
    if (resultList.contains(ConnectivityResult.wifi) || resultList.contains(ConnectivityResult.mobile)) {
      // अगर वाई-फाई है, तो उसे प्राथमिकता दें
      if (resultList.contains(ConnectivityResult.wifi)) {
        connectionStatus.value = ConnectivityResult.wifi;
      }
      // वरना मोबाइल डेटा को सेट करें
      else {
        connectionStatus.value = ConnectivityResult.mobile;
      }
    }
    // अगर दोनों में से कोई नहीं है, तो मतलब इंटरनेट नहीं है
    else {
      connectionStatus.value = ConnectivityResult.none;
    }

    print("Effective Connectivity Status: ${connectionStatus.value}");
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}