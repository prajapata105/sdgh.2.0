import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService().showNotificationFromData(message.data);
}

class NotificationService extends GetxService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isLocalNotificationsInitialized = false;

  Future<void> initialize() async {
    await _ensureLocalNotificationsInitialized();
    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.subscribeToTopic('all_updates');
    _setupMessageHandlers();
  }



  Future<String?> getPathFromLaunchNotification() async {
    final NotificationAppLaunchDetails? launchDetails =
    await _localNotifications.getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final String? payload = launchDetails!.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        try {
          final Map<String, dynamic> data = jsonDecode(payload);
          final String? path = data['click_action'];
          print("--- App launched from terminated state via local notification. Path: $path ---");
          return path;
        } catch (e) {
          print('Error decoding notification payload: $e');
          return null;
        }
      }
    }
    return null;
  }

  Future<void> _ensureLocalNotificationsInitialized() async {
    if (_isLocalNotificationsInitialized) return;
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/ic_stat_notification');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          _handleNotificationClick(jsonDecode(response.payload!));
        }
      },
    );
    _isLocalNotificationsInitialized = true;
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotificationFromData(message.data);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data);
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // ▼▼▼ यहाँ बदलाव किया गया है ▼▼▼
  // यह फंक्शन अब सिर्फ लिंक का पता लौटाएगा
  Future<String?> getInitialMessagePath() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("--- Path from terminated notification: ${initialMessage.data['click_action']} ---");
      return initialMessage.data['click_action'];
    }
    return null;
  }
  // ▲▲▲ यहाँ बदलाव किया गया है ▲▲▲

  // यह फंक्शन अब भी बैकग्राउंड/फोरग्राउंड क्लिक को हैंडल करेगा
  void _handleNotificationClick(Map<String, dynamic> data) {
    final String? path = data['click_action'];
    if (path != null && path.isNotEmpty) {
      print("Deep Link Navigation via Notification: Navigating to $path");
      Get.toNamed(path);
    }
  }

  Future<void> showNotificationFromData(Map<String, dynamic> data) async {
    // ... (यह फंक्शन वैसा ही रहेगा)
    await _ensureLocalNotificationsInitialized();
    final String? title = data['title'];
    final String? body = data['body'];
    final String? imageUrl = data['image'];
    StyleInformation? styleInformation;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final String imagePath = await _downloadAndSaveFile(imageUrl, 'notification_image.jpg');
        styleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(imagePath),
          largeIcon: FilePathAndroidBitmap(imagePath),
          contentTitle: title,
          htmlFormatContentTitle: true,
          summaryText: body,
          htmlFormatSummaryText: true,
        );
      } catch (e) { print('Error downloading image: $e'); }
    }
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', 'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max, priority: Priority.high,
      styleInformation: styleInformation,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(presentSound: true);
    final NotificationDetails platformDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.toUnsigned(31),
      title, body, platformDetails,
      payload: jsonEncode(data),
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
