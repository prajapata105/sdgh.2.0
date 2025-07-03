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
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  // NotificationService को GetX में डालें ताकि कहीं से भी मिल सके
  final notificationService = Get.put(NotificationService(), permanent: true);
  await notificationService.initialize();

  // Controllers/services initialization
  Get.put(NetworkController(), permanent: true);
  Get.put(CartService(), permanent: true);
  Get.put(AddressController(), permanent: true);
  Get.put(OrderService(), permanent: true);
  Get.put(UserOrdersController(), permanent: true);
  Get.put(OrderDetailsController(), permanent: true);
  Get.put(AppAuthProvider(), permanent: true);
  Get.put(HomeController(), permanent: true);

  runApp(const MyApp());
}

// ▼▼▼ MyApp अब फिर से एक StatelessWidget है ▼▼▼
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
