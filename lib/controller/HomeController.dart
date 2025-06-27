import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/Services/HomeService.dart';
import 'package:ssda/Services/news_service.dart';
import 'package:ssda/models/banner_model.dart';
import 'package:ssda/models/news_article_model.dart';
import 'package:ssda/models/product_model.dart';
import 'package:ssda/screens/news_detail_screen.dart';
import 'package:ssda/services/product_service.dart';
import 'package:ssda/screens/products_screen.dart';
import 'package:ssda/screens/user_cart_screen.dart';
import 'package:ssda/screens/user_orders_screen.dart';
import 'package:ssda/ui/widgets/organisms/product_description_modal_opener.dart';

// सेक्शन के डेटा को रखने के लिए एक मॉडल
class HomeSection {
  final String title;
  final String type;
  final String value;
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = true.obs;

  HomeSection({required this.title, required this.type, required this.value});
}

class HomeController extends GetxController {
  final HomeService _homeService = HomeService();
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  var isLoading = true.obs;
  var carouselBanners = <BannerModel>[].obs;
  var homeSections = <HomeSection>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomePageData();
    setupAppLinkListener();
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }

  void setupAppLinkListener() {
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('Foreground AppLink Received: $uri');
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri deepLink) async {
    String? articleIdString = deepLink.queryParameters['p'] ?? deepLink.queryParameters['id'];
    if (articleIdString != null) {
      final articleId = int.tryParse(articleIdString);
      if (articleId != null) {
        final NewsArticle? article = await NewsService.getArticleById(articleId);
        if (article != null) {
          // यहाँ Get.to() का उपयोग करें क्योंकि यूजर पहले से ऐप में है
          Get.to(() => NewsDetailScreen(article: article));
        }
      }
    }
  }
  Future<void> fetchHomePageData() async {
    try {
      isLoading(true);
      homeSections.clear();
      final homeData = await _homeService.fetchHomePageData();

      _parseAndLoadBanners(homeData['banner_data']);
      _parseAndLoadSections(homeData['sections_data']);

    } catch (e) {
      print("HomeController में त्रुटि: $e");
    } finally {
      isLoading(false);
    }
  }

  void _parseAndLoadBanners(String? rawBannerData) {
    if (rawBannerData == null || rawBannerData.isEmpty) {
      carouselBanners.value = [];
      return;
    }
    List<BannerModel> banners = [];

    // <<<--- बदलाव यहाँ: .toList() जोड़ा गया ---<<<
    final List<String> lines = rawBannerData.split(RegExp(r'\r\n?|\n')).where((s) => s.trim().isNotEmpty).toList();

    for (var line in lines) {
      final parts = line.split(',');
      if (parts.length == 2 && Uri.tryParse(parts[0].trim())?.isAbsolute == true) {
        banners.add(BannerModel(imageUrl: parts[0].trim(), link: parts[1].trim()));
      }
    }
    carouselBanners.value = banners;
  }

  void _parseAndLoadSections(String? rawSectionsData) {
    if (rawSectionsData == null || rawSectionsData.isEmpty) {
      homeSections.value = [];
      return;
    }
    final List<String> lines = rawSectionsData.split(RegExp(r'\r\n?|\n')).where((s) => s.trim().isNotEmpty).toList();

    for (var line in lines) {
      final parts = line.split(':');
      if (parts.length == 3) {
        final section = HomeSection(
          type: parts[0].trim(),
          value: parts[1].trim(),
          title: parts[2].trim(),
        );
        homeSections.add(section);
        _fetchProductsForSection(section);
      }
    }
  }

  Future<void> _fetchProductsForSection(HomeSection section) async {
    try {
      section.isLoading(true);
      List<Product> fetchedProducts = [];
      if (section.type == 'special') {
        fetchedProducts = await ProductService.getProducts(orderBy: section.value, perPage: 8);
      } else if (section.type == 'category') {
        fetchedProducts = await ProductService.getProducts(categoryId: section.value, perPage: 8);
      }
      section.products.value = fetchedProducts;
    } catch(e) {
      print("Error fetching products for section ${section.title}: $e");
    }
    finally {
      section.isLoading(false);
    }
  }

  void handleBannerTap(BuildContext context, String? link) {
    if (link == null || link.trim().isEmpty) return;
    String sanitizedLink = link.trim();
    if (sanitizedLink.contains(':')) {
      final parts = sanitizedLink.split(':');
      final type = parts[0].trim();
      final value = parts.length > 1 ? parts[1].trim() : '';
      if (type == 'page') {
        if (value == 'orders') Get.to(() => const OrdersScreen());
        else if (value == 'cart') Get.to(() => const CartScreen());
      }
    } else {
      final id = int.tryParse(sanitizedLink);
      if (id != null) _navigateToProduct(context, id);
    }
  }

  Future<void> _navigateToProduct(BuildContext context, int productId) async {
    Get.dialog(const Center(child: CircularProgressIndicator()));
    try {
      final Product? product = await ProductService.getProductById(productId);
      Get.back();
      if (product != null) {
        openProductDescription(context, product);
      } else {
        Get.snackbar('त्रुटि', 'यह प्रोडक्ट नहीं मिला।');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('त्रुटि', 'प्रोडक्ट की जानकारी लोड नहीं हो सकी।');
    }
  }
}