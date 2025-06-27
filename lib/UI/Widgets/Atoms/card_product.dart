// lib/UI/Widgets/Atoms/card_product.dart

import 'package:flutter/material.dart';
import 'package:ssda/models/product_model.dart';
import '../../../app_colors.dart';
import 'add_to_cart_button.dart';
import '../Organisms/product_description_modal_opener.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // कीमत को double में पार्स करें
    final double priceAsDouble = double.tryParse(product.price) ?? 0.0;

    return GestureDetector(
      onTap: () => openProductDescription(context, product),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1.0)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded( // इमेज को उपलब्ध जगह लेने दें
              child: Center(
                child: product.image.isNotEmpty
                    ? Image.network(product.image, fit: BoxFit.contain)
                    : const Placeholder(),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              product.name,
              maxLines: 2, // 2 लाइन्स
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.2),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // <<<--- बदलाव यहाँ: toStringAsFixed का उपयोग करें ---<<<
                Text("₹ ${priceAsDouble.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                buildAddToCartButton(product),
              ],
            ),
          ],
        ),
      ),
    );
  }
}