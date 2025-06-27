import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/controller/HomeController.dart';
import 'package:ssda/ui/widgets/organisms/bottom_cart_container.dart';
import 'package:ssda/ui/widgets/organisms/category_with_products.dart';
import 'package:ssda/ui/widgets/organisms/home_screen_app_bar.dart';
import 'package:ssda/ui/widgets/organisms/home_screen_category_builder.dart';
import 'package:ssda/ui/widgets/organisms/home_screen_search_bar.dart';
import 'package:ssda/ui/widgets/organisms/home_screen_carousel.dart';
import 'package:ssda/ui/widgets/common/product_screen_shimmer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ssda/utils/constent.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => homeController.fetchHomePageData(),
            child: Obx(() {
              if (homeController.isLoading.value) {
                return const ProductScreenShimmer();
              }
              return CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  const HomeScreenAppBar(),
                  const SliverToBoxAdapter(child: HomeScreenSearchBar()),

                  // 1. आपका बैनर कैराउज़ल (यह सुरक्षित है और पहले की तरह काम करेगा)
                  const HomeScreenCarousel(),

                  SliverToBoxAdapter(
                    child: Container(

                      padding: const EdgeInsets.all(16),
                      margin:  EdgeInsets.all(6.0),
                      decoration: const BoxDecoration(

                        color: Colors.white, // kWhiteColor को सीधे कलर से बदल दिया
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Categories',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          // अब यह यहाँ सही से काम करेगा
                          const HomeScreenCateogoryWidget(),
                        ],
                      ),
                    ),
                  ),

                  // 2. आपके डायनामिक सेक्शन्स (यह WordPress से आएंगे)
                  ...homeController.homeSections.map((section) {
                    return Obx(() {
                      if (section.isLoading.value) {
                        return SliverToBoxAdapter(child: _buildProductShimmer());
                      }
                      if (section.products.isEmpty) {
                        return const SliverToBoxAdapter(); // अगर प्रोडक्ट नहीं हैं तो कुछ न दिखाएं
                      }
                      return CatgorywithProducts(
                        title: section.title,
                        products: section.products,
                        // अगर यह एक कैटेगरी है तो "View All" के लिए ID पास करें
                        categoryId: section.type == 'category' ? int.tryParse(section.value) : null,
                        categoryName: section.title,
                      );
                    });
                  }).toList(),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            }),
          ),
          const Align(alignment: Alignment.bottomCenter, child: BottomStickyContainer()),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  Widget _buildProductShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12)
          ),
        ),
      ),
    );
  }
}
