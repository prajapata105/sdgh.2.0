// lib/controller/Splesh_controller.dart - पूरा अंतिम कोड

import 'dart:async';

import 'package:get/get.dart';
import 'package:app_links/app_links.dart'; // <<<--- यह इम्पोर्ट ज़रूरी है
import 'package:ssda/Services/Providers/custom_auth_provider.dart';
import 'package:ssda/screens/intro-screen/homenav.dart';
import 'package:ssda/screens/intro-screen/login-mobile-number.dart';


class SplashController extends GetxController {
  final _appLinks = AppLinks();

  @override
  void onInit() {
    super.onInit();
    _handleStartup();
  }

  Future<void> _handleStartup() async {
    // ऐप शुरू होते ही जांचें कि क्या यह डीप लिंक से खुली है।
    final initialUri = await _appLinks.getInitialLink();

    // अगर initialUri null है, इसका मतलब है कि यह एक सामान्य स्टार्ट है।
    // तभी टाइमर वाला लॉजिक चलाएं।
    if (initialUri == null) {
      // यह एक सामान्य स्टार्ट है।
      Timer(const Duration(seconds: 3), () {
        final authProvider = Get.find<AppAuthProvider>();
        if (authProvider.isUserLoggedIn) {
          Get.offAllNamed('/homenav');
        } else {
          Get.offAllNamed('/login-mobile-number');
        }
      });
    }
    // अगर initialUri null नहीं है, तो इसका मतलब है कि AppRouter और
    // DeepLinkHandlerScreen अपना काम कर रहे हैं।
    // तो SplashController को कुछ भी करने की ज़रूरत नहीं है।
  }
}