import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ssda/app_theme.dart';
import 'package:ssda/controller/AddressController.dart';
import 'package:ssda/controller/HomeController.dart';
import 'package:ssda/controller/OrderDetailsController.dart';
import 'package:ssda/controller/UserOrdersController.dart';
import 'package:ssda/controller/network_controller.dart';
import 'package:ssda/route_generator.dart';
import 'package:ssda/services/OrderService.dart';
import 'package:ssda/services/cart_service.dart';
import 'package:ssda/Services/Providers/custom_auth_provider.dart';
import 'package:ssda/ui/widgets/common/no_internet_widget.dart';

import 'Services/notification_service.dart';

Future<void> main() async {
  // डीबगिंग के लिए प्रिंट स्टेटमेंट्स
  print("DEBUG: main() function started.");
  WidgetsFlutterBinding.ensureInitialized();

  print("DEBUG: Firebase.initializeApp() is starting...");
  await Firebase.initializeApp();
  print("DEBUG: Firebase.initializeApp() is complete.");

  print("DEBUG: GetStorage.init() is starting...");
  await GetStorage.init();
  print("DEBUG: GetStorage.init() is complete.");

  print("DEBUG: NotificationService().initialize() is starting...");
  await NotificationService().initialize();
  print("DEBUG: NotificationService().initialize() is complete.");

  // Controllers/services initialization
  print("DEBUG: Initializing GetX controllers...");
  Get.put(NetworkController(), permanent: true);
  Get.put(CartService(), permanent: true);
  Get.put(AddressController(), permanent: true);
  Get.put(OrderService(), permanent: true);
  Get.put(UserOrdersController(), permanent: true);
  Get.put(OrderDetailsController(), permanent: true);
  Get.put(AppAuthProvider(), permanent: true);
  Get.put(HomeController(), permanent: true);
  print("DEBUG: GetX controllers initialized.");

  print("DEBUG: Running the app...");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appTHeme,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      builder: (context, child) {
        final networkController = Get.find<NetworkController>();
        return Obx(() {
          return Stack(
            children: [
              child ?? const SizedBox.shrink(),
              if (!networkController.isConnected) const NoInternetWidget(),
            ],
          );
        });
      },
    );
  }
}
