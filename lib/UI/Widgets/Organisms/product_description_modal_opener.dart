import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:ssda/app_colors.dart';
import 'package:ssda/constants.dart';
import 'package:ssda/models/cart_item_model.dart';
import 'package:ssda/models/product_model.dart';
import 'package:ssda/services/cart_service.dart';
import 'package:share_plus/share_plus.dart'; // <<<--- शेयर पैकेज

// यह एक हेल्पर फंक्शन है जो बॉटम शीट को खोलता है
void openProductDescription(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7, // शुरुआती ऊंचाई थोड़ी बढ़ाई गई
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) =>
          ProductDescriptionModal(product: product, scrollController: scrollController),
    ),
  );
}

class ProductDescriptionModal extends StatelessWidget {
  final Product product;
  final ScrollController scrollController;

  const ProductDescriptionModal({super.key, required this.product, required this.scrollController});

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ड्रैग हैंडल
          Container(
            height: 5,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          // स्क्रॉल होने वाला कंटेंट
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // प्रोडक्ट इमेज
                SizedBox(
                  height: Get.height * 0.25,
                  child: product.image.isNotEmpty
                      ? Image.network(product.image, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 100, color: Colors.grey),
                  )
                      : const Icon(Icons.image_not_supported_outlined, size: 100, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // <<<--- बदलाव यहाँ: टाइटल और शेयर बटन के लिए Row ---<<<
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                          product.name,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.share, color: Colors.grey.shade600),
                      onPressed: () {
                        final String productUrl = "https://sridungargarhone.com/?product_id=${product.id}";
                        Share.share(
                          'Check out this product on SSDA App: ${product.name}\n\n$productUrl',
                          subject: product.name,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // प्रोडक्ट का विवरण
                if (product.description.isNotEmpty)
                  Text(
                    _parseHtmlString(product.description),
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700], height: 1.5),
                  ),
                const SizedBox(height: 100), // नीचे के बटन के लिए जगह
              ],
            ),
          ),
          // बॉटम बार जो हमेशा दिखेगा
          _buildBottomBar(theme),
        ],
      ),
    );
  }

  // कीमत और ऐड टू कार्ट बटन के लिए बॉटम बार
  Widget _buildBottomBar(ThemeData theme) {
    final double priceAsDouble = double.tryParse(product.price) ?? 0.0;
    final double regularPriceAsDouble = double.tryParse(product.regularPrice) ?? 0.0;
    final bool onSale = product.onSale && regularPriceAsDouble > priceAsDouble;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 15, 20, Get.mediaQuery.padding.bottom + 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$appCurrencySybmbol${priceAsDouble.toStringAsFixed(2)}",
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryGreenColor),
                ),
                if (onSale)
                  Text(
                    "$appCurrencySybmbol${regularPriceAsDouble.toStringAsFixed(2)}",
                    style: theme.textTheme.titleMedium?.copyWith(decoration: TextDecoration.lineThrough, color: Colors.grey),
                  ),
              ],
            ),
          ),
          SizedBox(width: Get.width * 0.04),
          // <<<--- बदलाव यहाँ: नया कार्ट कंट्रोल विजेट ---<<<
          _buildCartControls(),
        ],
      ),
    );
  }

  // यह विजेट ADD और +/- बटन दोनों को मैनेज करेगा
  Widget _buildCartControls() {
    final CartService cartService = Get.find();
    return Obx(() {
      final cartItem = cartService.cartItems.firstWhereOrNull((item) => item.id == product.id);

      if (cartItem == null) {
        return _buildAddButton(cartService);
      } else {
        return _buildQuantitySelector(cartService, cartItem);
      }
    });
  }

  // ADD बटन
  Widget _buildAddButton(CartService cartService) {
    return ElevatedButton(
      onPressed: () {
        final newItem = CartItem(
          id: product.id, title: product.name, imageUrl: product.image,
          price: double.tryParse(product.price) ?? 0.0, quantity: 1,
        );
        cartService.addToCart(newItem);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreenColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text("ADD TO CART", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // क्वांटिटी (+/-) कंट्रोलर
  Widget _buildQuantitySelector(CartService cartService, CartItem item) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primaryGreenColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              onPressed: () => cartService.updateQuantity(item, item.quantity - 1),
              icon: const Icon(Icons.remove, color: Colors.white)
          ),
          Text(
              '${item.quantity}',
              style: Get.theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
          ),
          IconButton(
              onPressed: () => cartService.updateQuantity(item, item.quantity + 1),
              icon: const Icon(Icons.add, color: Colors.white)
          ),
        ],
      ),
    );
  }
}
