// lib/screens/deep_link_handler_screen.dart - पूरा अंतिम कोड

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/Services/Providers/custom_auth_provider.dart';
import 'package:ssda/models/news_article_model.dart';
import 'package:ssda/models/product_model.dart';
import 'package:ssda/screens/intro-screen/homenav.dart';
import 'package:ssda/screens/news_detail_screen.dart';
import 'package:ssda/services/news_service.dart';
import 'package:ssda/services/product_service.dart';
import 'package:ssda/ui/widgets/organisms/product_description_modal_opener.dart';

class DeepLinkHandlerScreen extends StatefulWidget {
  final String path;
  const DeepLinkHandlerScreen({super.key, required this.path});

  @override
  State<DeepLinkHandlerScreen> createState() => _DeepLinkHandlerScreenState();
}

class _DeepLinkHandlerScreenState extends State<DeepLinkHandlerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDeepLink();
    });
  }

  Future<void> _handleDeepLink() async {
    final uri = Uri.parse(widget.path);
    final authProvider = Get.find<AppAuthProvider>();
    final bool isLoggedIn = authProvider.isUserLoggedIn;

    // --- न्यूज़ लिंक हैंडलिंग ---
    String? newsIdString = uri.queryParameters['p'] ?? uri.queryParameters['id'];
    if (newsIdString != null) {
      final articleId = int.tryParse(newsIdString);
      if (articleId != null) {
        final NewsArticle? article = await NewsService.getArticleById(articleId);
        if (mounted && article != null) {
          // आवश्यकता 2: लॉगिन स्थिति के अनुसार बैक-स्टैक बनाएं
          if (isLoggedIn) {
            Get.offAllNamed('/homenav');
          } else {
            Get.offAllNamed('/login-mobile-number');
          }
          Get.to(() => NewsDetailScreen(article: article));
          return;
        }
      }
    }

    // --- प्रोडक्ट लिंक हैंडलिंग ---
    String? productIdString = uri.queryParameters['product_id'];
    if (productIdString != null) {
      final productId = int.tryParse(productIdString);
      if (productId != null) {

        if (isLoggedIn) {
          final Product? product = await ProductService.getProductById(productId);
          if (mounted && product != null) {
            await Get.offAllNamed('/homenav');
            await Future.delayed(const Duration(milliseconds: 100));
            if (Get.context != null) openProductDescription(Get.context!, product);
            return;
          }
        }
        else {
          // अगर लॉग इन नहीं है, तो लॉगिन स्क्रीन दिखाएं
          Get.offAllNamed('/login-mobile-number');
          return;
        }
      }
    }


    // अगर लिंक अमान्य है, तो सुरक्षित रूप से होम पर भेजें
    if (mounted) {
      Get.offAllNamed('/homenav');
    }
  }

  @override
  Widget build(BuildContext context) {
    // जब तक डेटा लोड हो रहा है, एक लोडिंग इंडिकेटर दिखाएं।
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}