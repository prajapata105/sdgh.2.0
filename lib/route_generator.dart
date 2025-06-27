import 'package:flutter/material.dart';
import 'package:ssda/screens/Auth/login_screen.dart';
import 'package:ssda/screens/Auth/otp_verification_screen.dart';
import 'package:ssda/screens/app_about_screen.dart';
import 'package:ssda/screens/cart_gift_screen.dart';
import 'package:ssda/screens/coupons_screeen.dart';
import 'package:ssda/screens/deep_link_handler_screen.dart';
import 'package:ssda/screens/error_screen.dart';
import 'package:ssda/screens/home_screen.dart';
import 'package:ssda/screens/intro-screen/homenav.dart';
import 'package:ssda/screens/intro-screen/login-mobile-number.dart'; // मान लीजिए यह आपका लॉग-इन स्क्रीन है
import 'package:ssda/screens/intro-screen/splasescreen.dart';
import 'package:ssda/screens/order_confirmation_screen.dart';
import 'package:ssda/screens/order_summary_screen.dart';
import 'package:ssda/screens/pdf_view_screen.dart';
import 'package:ssda/screens/products_screen.dart';
import 'package:ssda/screens/profile_screen.dart';
import 'package:ssda/screens/user_address_screen.dart';
import 'package:ssda/screens/user_cart_screen.dart';
import 'package:ssda/screens/user_orders_screen.dart';


class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    print("DEBUG: AppRouter को कॉल किया गया, राउट है: ${settings.name}"); // <<<--- यह लाइन जोड़ें
    if (settings.name != null && settings.name!.contains('?')) {
      return MaterialPageRoute(
        builder: (_) => DeepLinkHandlerScreen(path: settings.name!),
      );
    }

    switch (settings.name) {
      case '/':
        return ScalePageRoute(builder: (_) => const SplaseScreen());

      case '/login-mobile-number': // मान लीजिए यह आपकी लॉग-इन स्क्रीन का राउट है
        return ScalePageRoute(builder: (_) => const MobileNumber());

      case '/home':
        return ScalePageRoute(builder: (_) => const HomeScreen());

      case '/homenav':
        return ScalePageRoute(builder: (_) => const HomeNav(index: 0));

      case '/products':
      // <<<--- बदलाव यहाँ: अब यह आर्ग्यूमेंट्स को सही से हैंडल करेगा ---<<<
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return ScalePageRoute(
            builder: (_) => ProductsScreen(
              categoryId: args['categoryId'],
              categoryName: args['categoryName'],
            ),
            animationDirection: AnimationDirection.rightToLeft,
          );
        }
        // अगर आर्ग्यूमेंट्स सही नहीं हैं, तो एरर स्क्रीन दिखाएं
        return MaterialPageRoute(builder: (_) => const ErrorScreem());

      case '/coupons':
        return ScalePageRoute(
          builder: (_) => const CouponsSelectionScreen(),
          animationDirection: AnimationDirection.rightToLeft,
        );

      case "/cart/gift":
        return ScalePageRoute(builder: (_) => const CartGiftScreen());

      case "/cart":
        return ScalePageRoute(builder: (context) => const CartScreen());

      case "/orders":
        return ScalePageRoute(
          builder: (_) => const OrdersScreen(),
          animationDirection: AnimationDirection.rightToLeft,
        );

      case "/order":
        return ScalePageRoute(
          builder: (_) => const OrderSummaryScreen(),
          animationDirection: AnimationDirection.rightToLeft,
        );

      case "/order/invoice":
        return ScalePageRoute(
          builder: (_) => const ViewOrderInvoiceScreen(),
          animationDirection: AnimationDirection.rightToLeft,
        );

      case "/order/confirm":
        return ScalePageRoute(builder: (_) => const OrderConfirmationScreen());

      case '/profile':
        return ScalePageRoute(builder: (_) => const ProfileScreen());

      case '/user/address':
        return ScalePageRoute(
          builder: (_) => UserAddressScreen(),
          animationDirection: AnimationDirection.rightToLeft,
        );

      case '/app/about':
        return ScalePageRoute(
          builder: (_) => const AppAboutScreen(),
          animationDirection: AnimationDirection.rightToLeft,
        );

    // आपके बाकी के केस यहाँ आएंगे...

      default:
        return MaterialPageRoute(builder: (_) => const ErrorScreem());
    }
  }
}

enum AnimationDirection { leftToRight, rightToLeft, center }

class ScalePageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;
  final AnimationDirection animationDirection;

  ScalePageRoute({
    required this.builder,
    this.animationDirection = AnimationDirection.center,
  }) : super(
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // ... आपका ट्रांजीशन का कोड ...
      switch (animationDirection) {
        case AnimationDirection.leftToRight:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        case AnimationDirection.rightToLeft:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        case AnimationDirection.center:
        default:
          return ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: child,
          );
      }
    },
  );
}
