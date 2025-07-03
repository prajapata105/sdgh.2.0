import 'dart:async';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:ssda/Services/Providers/custom_auth_provider.dart';
import 'package:ssda/Services/notification_service.dart';
// 'route_generator.dart' का इम्पोर्ट यहाँ ज़रूरी नहीं है

class SplashController extends GetxController {
  final _appLinks = AppLinks();

  @override
  void onInit() {
    super.onInit();
    _handleStartup();
  }

  // ▼▼▼ इस फंक्शन को इस फाइनल संस्करण से बदल दें ▼▼▼
  Future<void> _handleStartup() async {
    // 1. सबसे पहले जांचें कि ऐप किसी नोटिफिकेशन पर क्लिक करके लॉन्च हुआ है या नहीं (यह सही है)
    final notificationService = Get.find<NotificationService>();
    final String? notificationPath = await notificationService.getPathFromLaunchNotification();

    if (notificationPath != null && notificationPath.isNotEmpty) {
      Get.offAllNamed(notificationPath);
      return;
    }

    // 2. अगर नोटिफिकेशन लिंक नहीं है, तो वेबसाइट (यूनिवर्सल) लिंक की जांच करें
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      // URI से पूरा पाथ (जैसे "/?p=123") बनाएँ
      String path = initialUri.path;
      if (initialUri.hasQuery) {
        path += '?${initialUri.query}';
      }

      // पूरे पाथ को GetX को पास करें।
      // अब आपका AppRouter इसे पकड़ेगा और DeepLinkHandlerScreen पर भेजेगा।
      print("--- Website link found: $path. Passing to AppRouter. ---");
      Get.offAllNamed(path);
      return;
    }

    // 3. अगर कोई डीप लिंक नहीं है, तो सामान्य रूप से ऐप शुरू करें
    Timer(const Duration(seconds: 3), () {
      final authProvider = Get.find<AppAuthProvider>();
      if (authProvider.isUserLoggedIn) {
        Get.offAllNamed('/homenav');
      } else {
        Get.offAllNamed('/login-mobile-number');
      }
    });
  }
// ▲▲▲ फंक्शन यहाँ समाप्त होता है ▲▲▲
}