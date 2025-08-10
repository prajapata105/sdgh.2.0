// Path: lib/UI/Widgets/common/product_screen_shimmer.dart
// WHAT TO DO: Replace the entire content of this file with the code below.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProductScreenShimmer extends StatelessWidget {
  const ProductScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    // --- YEH EK NAKLI PRODUCT CARD BANANE KA HELPER WIDGET HAI ---
    Widget _buildPlaceholderCard() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Text line 1 placeholder
            Container(
              height: 14,
              width: Get.width * 0.3,
              color: baseColor,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            const SizedBox(height: 6),
            // Text line 2 placeholder
            Container(
              height: 12,
              width: Get.width * 0.2,
              color: baseColor,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BAI OR CATEGORY LIST WALA HISSA ---
          Container(
            width: Get.width * 0.25,
            color: Colors.white, // Background color dena zaroori hai
            child: ListView.builder(
              itemCount: 8, // Nakli category items
              itemBuilder: (context, index) => Container(
                height: 50,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),

          // --- DAI OR PRODUCTS WALA HISSA (FIXED) ---
          // Humne Expanded ke andar GridView ko ek Column se badal diya hai
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Get.width * 0.03),
              child: Wrap(
                spacing: Get.width * 0.03, // Horizontal space
                runSpacing: Get.width * 0.03, // Vertical space
                children: List.generate(6, (index) {
                  // Har card ki width set kar rahe hain
                  return SizedBox(
                    width: (Get.width * 0.75 - (Get.width * 0.09)) / 2, // (Right side width - paddings) / 2
                    child: _buildPlaceholderCard(),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
