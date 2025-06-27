import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/app_colors.dart';
import 'package:ssda/services/cart_service.dart';

class BottomStickyContainer extends StatelessWidget {
  const BottomStickyContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ GetX CartService
    final cart = Get.find<CartService>();

    return Obx(() => Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.greyWhiteColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${cart.totalItems} ITEM${cart.totalItems > 1 ? "S" : ""}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  if (cart.totalItems > 0) {
                    Get.toNamed('/cart'); // ✅ correct, if GetMaterialApp used
                  } else {
                    Get.snackbar(
                      'Cart',
                      'Please add at least one product to cart.',
                      backgroundColor: Colors.red.shade600,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  backgroundColor: AppColors.primaryGreenColor,
                  padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 5),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
