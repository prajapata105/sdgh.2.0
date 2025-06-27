// lib/UI/Widgets/Atoms/card_product_order_summary.dart
import 'package:flutter/material.dart';

class OrderSummaryProductCard extends StatelessWidget {
  final String productName;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String currencySymbol;

  const OrderSummaryProductCard({
    super.key,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect( // इमेज को गोल किनारों के अंदर रखने के लिए
              borderRadius: BorderRadius.circular(7.0),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.shopping_bag_outlined, color: Colors.grey.shade400, size: 30),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
              )
                  : Icon(Icons.shopping_bag_outlined, color: Colors.grey.shade400, size: 30),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Qty: $quantity",
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "$currencySymbol${price.toStringAsFixed(2)}",
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}