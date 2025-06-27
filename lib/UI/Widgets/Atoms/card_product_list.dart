import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/models/cart_item_model.dart';
import 'package:ssda/services/cart_service.dart';
import 'package:ssda/models/product_model.dart';

import '../Organisms/product_description_modal_opener.dart';

/// The definitive, pixel-perfect, and error-free product card.
/// This architecture uses a Stack with Clip.none to achieve the complex
/// overlapping button design, exactly as requested.
class ProductCardForList extends StatelessWidget {
  final Product product;
  final CartService cartService = Get.find();

  ProductCardForList({super.key, required this.product});

  // यह सिर्फ एक उदाहरण है, आप अपनी फाइल से असली फंक्शन को कॉल करें


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openProductDescription(context, product),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: Get.width * 0.42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),

        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. इमेज और बटन का हिस्सा ---
            // Stack को Expanded में डाला ताकि यह flexible ऊंचाई ले सके
            Expanded(child: _buildImageAndButtonSection()),

            // --- 2. डिटेल्स का हिस्सा ---
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  /// यह विजेट इमेज और उसके ऊपर ओवरलैप होने वाले बटन को बनाता है
  Widget _buildImageAndButtonSection() {
    return Stack(
      // <<<--- यही वो जादू है जिससे बटन कंटेनर से बाहर दिखेगा ---<<<
      clipBehavior: Clip.none,
      children: [
        // इमेज को बड़ा करने के लिए ज्यादा जगह
        Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(Get.width * 0.0),
          child: Image.network(
            product.image.isNotEmpty ? product.image : 'https://i.imgur.com/sM38wD6.png',
            fit: BoxFit.contain,
          ),
        ),

        // ADD या +/- बटन (अब यह इमेज के ऊपर और आधा बाहर होगा)
        Positioned(
          // <<<--- बटन को नीचे से बाहर निकालने के लिए नेगेटिव वैल्यू ---<<<
          bottom: -Get.height * 0.02,
          right: Get.width * 0.015,
          left: Get.width * 0.015,
          child: Obx(() {
            final cartItem = cartService.cartItems.firstWhereOrNull((item) => item.id == product.id);
            return cartItem == null ? _buildAddButton() : _buildQuantitySelector(cartItem);
          }),
        ),
      ],
    );
  }

  /// यह विजेट नाम, वजन, कीमत, MRP और डिस्काउंट दिखाता है
  Widget _buildDetailsSection() {
    // डिटेल्स को दिखाने के लिए पर्याप्त जगह
    return Padding(
      padding: EdgeInsets.fromLTRB(10, Get.height * 0.03, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // वजन (अगर API से मिला है)
          if (product.weight != null && product.weight!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                product.weight!,
                style: TextStyle(fontSize: Get.width * 0.03, color: Colors.grey.shade600),
              ),
            ),

          // प्रोडक्ट का नाम
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: Get.width * 0.035, fontWeight: FontWeight.w600, height: 1.3),
          ),
          SizedBox(height: Get.height * 0.006),

          // कीमत, MRP और डिस्काउंट
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹${product.salePrice}', // अब हम salePrice का इस्तेमाल करेंगे
                style: TextStyle(fontSize: Get.width * 0.04, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: Get.width * 0.02),
              if (product.onSale && product.regularPrice.isNotEmpty)
                Text(
                  'MRP ₹${product.regularPrice}',
                  style: TextStyle(
                    fontSize: Get.width * 0.03,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          if (product.discount > 1) // 1% से ज्यादा डिस्काउंट हो तभी दिखाएं
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                '${product.discount.toStringAsFixed(0)}% OFF',
                style: TextStyle(fontSize: Get.width * 0.032, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  /// छोटा और फोटो जैसा "ADD" बटन
  Widget _buildAddButton() {
    return InkWell(
      onTap: () {
        final newItem = CartItem(
          id: product.id, title: product.name, imageUrl: product.image,
          price: double.tryParse(product.salePrice) ?? 0.0, quantity: 1,
        );
        cartService.addToCart(newItem);
      },
      child: Container(
        height: 36, // ऊंचाई
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)],
        ),
        child: const Center(child: Text('ADD', style: TextStyle(color: Color(0xff16A34A), fontWeight: FontWeight.bold, fontSize: 14))),
      ),
    );
  }

  /// छोटा और फोटो जैसा "+/-" बटन
  Widget _buildQuantitySelector(CartItem item) {
    return Container(
      height: 30, // ऊंचाई
      width: 85, // चौड़ाई
      decoration: BoxDecoration(
        color: const Color(0xff16A34A),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: InkWell(onTap: () => cartService.updateQuantity(item, item.quantity - 1), child: const Icon(Icons.remove, color: Colors.white, size: 20))),
          Text('${item.quantity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: InkWell(onTap: () => cartService.updateQuantity(item, item.quantity + 1), child: const Icon(Icons.add, color: Colors.white, size: 20))),
        ],
      ),
    );
  }
}