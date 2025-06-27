import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/app_colors.dart';
import 'package:ssda/models/cart_item_model.dart';
import 'package:ssda/services/cart_service.dart';

class CartProductCard extends StatelessWidget {
  final CartItem cartItem;
  const CartProductCard({Key? key, required this.cartItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GetX से थीम और कार्ट सर्विस को एक बार कॉल करें
    final CartService cart = Get.find<CartService>();
    final theme = Get.theme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Get.width * 0.02,
        vertical: Get.height * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // <<<--- सेक्शन 1: इमेज ---<<<
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              cartItem.imageUrl,
              height: Get.width * 0.18, // Responsive साइज
              width: Get.width * 0.18,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: Get.width * 0.18,
                width: Get.width * 0.18,
                color: Colors.grey.shade100,
                child: Icon(Icons.broken_image, size: 40, color: Colors.grey.shade400),
              ),
            ),
          ),
          SizedBox(width: Get.width * 0.03),

          // <<<--- सेक्शन 2: प्रोडक्ट डिटेल्स (यह बची हुई जगह ले लेगा) ---<<<
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                if (cartItem.variation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${cartItem.variation!}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '₹ ${cartItem.price.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(width: Get.width * 0.02),

          // <<<--- सेक्शन 3: क्वांटिटी कंट्रोलर (इसका साइज़ फिक्स्ड और responsive है) ---<<<
          _buildQuantityControls(cart),
        ],
      ),
    );
  }

  // क्वांटिटी कंट्रोलर बनाने के लिए एक अलग मेथड
  Widget _buildQuantityControls(CartService cart) {
    return Container(
      height: 34,
      width: Get.width * 0.25, // Responsive चौड़ाई
      decoration: BoxDecoration(
          color: AppColors.primaryGreenColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreenColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // माइनस बटन
          Expanded(
            child: IconButton(
              onPressed: () {
                if (cartItem.quantity > 1) {
                  cart.updateQuantity(cartItem, cartItem.quantity - 1);
                } else {
                  // कार्ट से हटाने के लिए कन्फर्मेशन दिखाएं (बेहतर UX के लिए)
                  Get.defaultDialog(
                    title: "Remove Item",
                    middleText: "Are you sure you want to remove this item?",
                    textConfirm: "Remove",
                    textCancel: "Cancel",
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      cart.removeFromCart(cartItem);
                      Get.back();
                    },
                  );
                }
              },
              icon: Icon(
                  cartItem.quantity > 1 ? Icons.remove : Icons.delete_outline,
                  color: Colors.white,
                  size: 16
              ),
              splashRadius: 16,
            ),
          ),
          // क्वांटिटी टेक्स्ट
          Text(
            "${cartItem.quantity}",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          // प्लस बटन
          Expanded(
            child: IconButton(
              onPressed: () {
                cart.updateQuantity(cartItem, cartItem.quantity + 1);
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 16),
              splashRadius: 16,
            ),
          ),
        ],
      ),
    );
  }
}
