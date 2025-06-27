// ===================================================================
// FILE 1: (नई फाइल बनाएं) lib/UI/Widgets/Atoms/home_product_card.dart
// ===================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/models/cart_item_model.dart';
import 'package:ssda/services/cart_service.dart';
import 'package:ssda/models/product_model.dart';
import '../Organisms/product_description_modal_opener.dart';

// यह विजेट सिर्फ होम स्क्रीन की हॉरिजॉन्टल लिस्ट के लिए है
class HomeProductCard extends StatelessWidget {
  final Product product;

  const HomeProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openProductDescription(context, product),
      child: Container(
        // कार्ड की चौड़ाई को स्क्रीन के हिसाब से सेट किया गया
        width: Get.width * 0.4,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // इमेज सेक्शन
            _buildImageSection(),
            // डिटेल्स सेक्शन
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Expanded(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Image.network(
              product.image.isNotEmpty ? product.image : 'https://i.imgur.com/sM38wD6.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
          if (product.onSale && product.discount > 0)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${product.discount.toStringAsFixed(0)}% OFF',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.2),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${product.salePrice}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  if (product.onSale && product.regularPrice.isNotEmpty)
                    Text(
                      '₹${product.regularPrice}',
                      style: const TextStyle(
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
              _buildCartControls(),
            ],
          ),
        ],
      ),
    );
  }

  // यह विजेट ADD और +/- बटन दोनों को मैनेज करेगा
  Widget _buildCartControls() {
    final CartService cartService = Get.find();
    return Obx(() {
      final cartItem = cartService.cartItems.firstWhereOrNull((item) => item.id == product.id);

      // अगर आइटम कार्ट में नहीं है, तो 'ADD' बटन दिखाएं
      if (cartItem == null) {
        return _buildAddButton(cartService);
      }
      // अगर आइटम कार्ट में है, तो '+/-' कंट्रोलर दिखाएं
      else {
        return _buildQuantitySelector(cartService, cartItem);
      }
    });
  }

  // ADD बटन
  Widget _buildAddButton(CartService cartService) {
    return InkWell(
      onTap: () {
        final newItem = CartItem(
          id: product.id, title: product.name, imageUrl: product.image,
          price: double.tryParse(product.salePrice) ?? 0.0, quantity: 1,
        );
        cartService.addToCart(newItem);
      },
      child: Container(
        height: 30,
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade700, width: 1.5),
        ),
        child: Center(child: Text('ADD', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12))),
      ),
    );
  }

  // क्वांटिटी (+/-) कंट्रोलर
  Widget _buildQuantitySelector(CartService cartService, CartItem item) {
    return Container(
      height: 30,
      width: 75,
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
              onTap: () => cartService.updateQuantity(item, item.quantity - 1),
              child: const Icon(Icons.remove, color: Colors.white, size: 16)
          ),
          Text(
              '${item.quantity}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
          ),
          InkWell(
              onTap: () => cartService.updateQuantity(item, item.quantity + 1),
              child: const Icon(Icons.add, color: Colors.white, size: 16)
          ),
        ],
      ),
    );
  }
}



