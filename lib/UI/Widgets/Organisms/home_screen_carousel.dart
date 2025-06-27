import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ssda/controller/HomeController.dart';

class HomeScreenCarousel extends StatelessWidget {
  const HomeScreenCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find();

    // Obx के बजाय GetX विजेट का उपयोग करना बेहतर है ताकि पूरा विजेट रीबिल्ड हो
    return GetX<HomeController>(
      builder: (controller) {
        if (controller.isLoading.value && controller.carouselBanners.isEmpty) {
          return SliverToBoxAdapter(child: _buildShimmerEffect());
        }

        if (controller.carouselBanners.isEmpty) {
          // अगर कोई बैनर नहीं है तो खाली Sliver लौटाएं
          return const SliverToBoxAdapter();
        }

        // CarouselSlider को SliverToBoxAdapter में लपेटा गया
        return SliverToBoxAdapter(
          child: CarouselSlider.builder(
            itemCount: controller.carouselBanners.length,
            itemBuilder: (context, index, realIndex) {
              final banner = controller.carouselBanners[index];
              return GestureDetector(
                onTap: () => controller.handleBannerTap(context, banner.link),
                child: Container(
                  width: Get.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      banner.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                      },
                    ),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: Get.height * 0.22,
              autoPlay: controller.carouselBanners.length > 1, // अगर एक से ज़्यादा बैनर है तभी ऑटोप्ले करें
              enlargeCenterPage: true,
              viewportFraction: 0.9,
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
        height: Get.height * 0.22,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}