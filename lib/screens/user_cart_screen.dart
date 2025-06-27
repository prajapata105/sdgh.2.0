import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/constants.dart';
import 'package:ssda/controller/CheckoutController.dart'; // <<<--- कंट्रोलर इम्पोर्ट करें
import 'package:ssda/services/cart_service.dart';
import 'package:ssda/UI/Widgets/Organisms/cart_screen_address_container.dart';
import 'package:ssda/UI/Widgets/Organisms/cart_screen_payment_container.dart';
import 'package:ssda/UI/Widgets/Organisms/card_cart_prices_detail.dart';
import 'package:ssda/UI/Widgets/Organisms/card_cart_time_total_items.dart';
import 'package:ssda/UI/Widgets/Atoms/card_gift_cart_screen.dart';
import 'package:ssda/UI/Widgets/Atoms/card_cancellation_policy.dart';
import 'package:ssda/UI/Widgets/Atoms/card_product_cart_screen.dart';
import 'package:ssda/UI/Widgets/Organisms/card_apply_coupon.dart';
import 'package:ssda/app_colors.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartService>();
    // <<<--- बदलाव यहाँ: कंट्रोलर को स्क्रीन के शुरुआत में ही बनाएं ---<<<
    final checkoutCtrl = Get.put(CheckoutController());

    return Obx(() => Scaffold(
      backgroundColor: AppColors.greyWhiteColor,
      appBar: AppBar(
        leadingWidth: 25,
        automaticallyImplyLeading: true,
        title: const Text("My Cart"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            // <<<--- बदलाव यहाँ: नीचे के हिस्से के लिए जगह छोड़ी गई ---<<<
            padding: EdgeInsets.fromLTRB(10, 5, 10, Get.height * 0.2),
            children: [
              const CartTimeandTotalItemCard(),

              // कार्ट के प्रोडक्ट्स
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: cart.cartItems.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: Text(
                      "Your cart is empty!",
                      style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cart.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.cartItems[index];
                    return CartProductCard(cartItem: cartItem);
                  },
                ),
              ),

              const ApplyCouponOnCartCard(),
              CartPriceDetailWidget(
                cartServiceInstance: cart,
                currencySymbol: appCurrencySybmbol,
              ),
              const OrderGiftCard(),
              const CancellationPolicyCard(),
            ],
          ),

          // एड्रेस और पेमेंट सेक्शन
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CartScreenAddressContainer(),
                CartScreenPaymentContainer(),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
