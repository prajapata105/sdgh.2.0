import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProductScreenShimmer extends StatelessWidget {
  const ProductScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Shimmer इफ़ेक्ट के लिए बेस और हाईलाइट कलर
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // बाईं ओर, कैटेगरी का नकली लोडर
          Container(
            width: Get.width * 0.25,
            color: Colors.white, // बैकग्राउंड कलर देना ज़रूरी है
          ),
          const VerticalDivider(width: 1),
          // दाईं ओर, प्रोडक्ट्स का नकली लोडर
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(Get.width * 0.03),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: Get.width * 0.03,
                mainAxisSpacing: Get.width * 0.03,
                childAspectRatio: 0.68,
              ),
              itemCount: 6, // 6 नकली कार्ड्स दिखाएं
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}