import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/app_colors.dart';
import 'package:ssda/services/cart_service.dart';

class BottomStickyContainer extends StatelessWidget {
  const BottomStickyContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartService>();

    // Obx विजेट का इस्तेमाल करें ताकि यह कार्ट के बदलावों को सुन सके
    return Obx(() {
      // 👇====== शर्त यहाँ जोड़ी गई है ======👇
      // अगर कार्ट में कोई आइटम नहीं है, तो कुछ भी न दिखाएं।
      if (cart.totalItems < 1) {
        return const SizedBox.shrink(); // यह एक खाली विजेट है
      }

      // 👇 अगर कार्ट में आइटम हैं, तो पूरा कंटेनर दिखाएं। 👇
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12.0), // मार्जिन ताकि यह किनारों से चिपका न रहे
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          decoration: BoxDecoration(
              color: AppColors.primaryGreenColor, // कंटेनर का रंग बदला गया
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 2
                )
              ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // कीमत और आइटम की संख्या
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cart.totalItems} ITEM${cart.totalItems > 1 ? "S" : ""}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16
                    ),
                  ),
                  Text(
                    // grandTotal का इस्तेमाल
                    '₹${cart.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        fontSize: 14
                    ),
                  ),
                ],
              ),

              // NEXT बटन
              TextButton(
                onPressed: () {
                  Get.toNamed('/cart');
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
                ),
                child: Text(
                  'NEXT',
                  style: TextStyle(
                      color: AppColors.primaryGreenColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}