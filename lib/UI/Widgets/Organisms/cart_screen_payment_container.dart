import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/controller/CheckoutController.dart';
import '../../../app_colors.dart';

class CartScreenPaymentContainer extends StatelessWidget {
  const CartScreenPaymentContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.put() की जगह Get.find() का उपयोग करना बेहतर है अगर कंट्रोलर पहले से मौजूद है
    final checkoutCtrl = Get.find<CheckoutController>();
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.04, vertical: Get.height * 0.01),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xfff0f0f0)))
      ),
      width: Get.width,
      height: 70,
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // <<<--- बदलाव यहाँ: इस हिस्से को Expanded में लपेटा गया ---<<<
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.payment, color: Colors.orangeAccent),
                SizedBox(width: Get.width * 0.04),
                // <<<--- बदलाव यहाँ: Column को Flexible में लपेटा गया ---<<<
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Payment Method",
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        checkoutCtrl.selectedPaymentMethod.value == 'cod'
                            ? "Cash on Delivery"
                            : "Pay Online",
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          SizedBox(width: Get.width * 0.03),

          // <<<--- बदलाव यहाँ: बटन या लोडर ---<<<
          checkoutCtrl.isLoading.value
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : ElevatedButton(
            onPressed: checkoutCtrl.placeOrderFlow,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreenColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )
            ),
            child: const Text("Place Order"),
          )
        ],
      )),
    );
  }
}