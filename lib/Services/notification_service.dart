import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ssda/Infrastructure/HttpMethods/requesting_methods.dart';
import 'package:ssda/Services/Providers/custom_auth_provider.dart';
import 'package:ssda/Services/WooUserMapper.dart';
import 'package:ssda/screens/home_screen.dart';
// import 'package:ssda/screens/news_detail_screen.dart';
// import 'package:ssda/screens/product_detail_screen.dart';

// यह फंक्शन ऐप के बाहर (बैकग्राउंड में) आए मैसेज को हैंडल करेगा
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background Message Handled: ${message.messageId}");
}

class NotificationService {
  // Singleton पैटर्न ताकि पूरी ऐप में इसका सिर्फ एक ही इंस्टैंस बने।
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // नोटिफिकेशन सेटअप का मुख्य फंक्शन
  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission();

    _setupLocalNotifications();
    _setupMessageHandlers();

    // जब भी ऐप खुले, टोकन को रिफ्रेश और सर्वर पर भेजने की कोशिश करें
    await refreshTokenAndSendToServer();
  }

  // लोकल नोटिफिकेशन को इनिशियलाइज़ करने के लिए
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // आपका ऐप आइकॉन
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          _handleNotificationClick(Map<String, dynamic>.from(data));
        }
      },
    );
  }

  // FCM से मैसेज आने पर उन्हें हैंडल करने के लिए
  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data);
    });

    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationClick(message.data);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // <<<--- यह सबसे महत्वपूर्ण नया फंक्शन है ---<<<
  // यह फंक्शन FCM टोकन को रिफ्रेश करता है और सर्वर पर भेजता है
  Future<void> refreshTokenAndSendToServer() async {
    final fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      print("FCM Token: $fcmToken");
      if (Get.isRegistered<AppAuthProvider>()) {
        final authProvider = Get.find<AppAuthProvider>();
        // <<<--- बदलाव यहाँ: अब हम नए isUserLoggedIn getter का उपयोग करेंगे ---<<<
        if (authProvider.isUserLoggedIn) {
          await _sendFcmTokenToServer(fcmToken);
        } else {
          print("User not logged in. Skipping token send.");
        }
      }
    }
  }

  // यह फंक्शन आपके सर्वर पर टोकन भेजेगा
  Future<void> _sendFcmTokenToServer(String token) async {
    try {
      final url = "${WooUserMapper.baseUrl}/wp-json/my-app/v1/save-fcm-token";

      // <<<--- बदलाव यहाँ: अब हम आपके ApiService का सही से उपयोग करेंगे ---<<<
      // यह मानकर चल रहे हैं कि is_user_logged_in के लिए कुकी-बेस्ड ऑथेंटिकेशन काम कर रहा है
      await ApiService.requestMethods(
        methodType: "POST",
        url: url,
        body: {'fcm_token': token},
      );
      print("FCM Token successfully sent to server.");
    } catch (e) {
      print("Failed to send FCM token to server: $e");
    }
  }

  // लोकल नोटिफिकेशन दिखाने का फंक्शन (Foreground के लिए)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'high_importance_channel', 'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max, priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  // नोटिफिकेशन पर क्लिक करने पर सही स्क्रीन खोलने का लॉजिक
  void _handleNotificationClick(Map<String, dynamic> data) {
    final String? type = data['type'];
    final String? idString = data['id'];

    if (type == null || idString == null) {
      Get.offAll(() => const HomeScreen());
      return;
    }

    final id = int.tryParse(idString);
    if (id == null) return;

    print("Notification tapped: type=$type, id=$id");

    if (type == 'product') {
      // Get.to(() => ProductDetailsScreen(productId: id));
      print("Product पेज पर नेविगेट करें, ID: $id");
    } else if (type == 'news') {
      // Get.to(() => NewsDetailScreen(articleId: id));
      print("News आर्टिकल पेज पर नेविगेट करें, ID: $id");
    }
  }
}
