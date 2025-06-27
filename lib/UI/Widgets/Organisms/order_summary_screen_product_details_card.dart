// lib/UI/Widgets/Organisms/order_summary_screen_product_details_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ssda/app_colors.dart';
import 'package:ssda/UI/Widgets/Atoms/card_product_order_summary.dart';

class OrderSummaryProductsDetails extends StatelessWidget {
  final List lineItems;
  final String orderStatus;
  final String dateCreated; // ISO 8601 फॉर्मेट में तारीख
  final String currencySymbol;

  const OrderSummaryProductsDetails({
    super.key,
    required this.lineItems,
    required this.orderStatus,
    required this.dateCreated,
    required this.currencySymbol,
  });

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return "N/A";
    try {
      DateTime date = DateTime.parse(dateString).toLocal();
      return DateFormat('dd MMM, yyyy \'at\' hh:mm a').format(date);
    } catch (e) {
      print("Error parsing date in OrderSummaryProductsDetails: $e");
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String formattedDate = _formatDate(dateCreated);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ${orderStatus.capitalizeFirst ?? orderStatus}',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Placed on $formattedDate',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Text(
            '${lineItems.length} item${lineItems.length == 1 ? "" : "s"}',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lineItems.length,
            itemBuilder: (context, index) {
              final item = lineItems[index] as Map<String, dynamic>;

              // meta_data से इमेज URL निकालने का लॉजिक
              String? imageUrl;
              if (item['meta_data'] is List) {
                var meta = (item['meta_data'] as List).firstWhere(
                        (m) => m is Map && m['key'] == '_product_image_url',
                    orElse: () => null);
                if (meta != null) {
                  imageUrl = meta['value'] as String?;
                }
              }

              return OrderSummaryProductCard(
                productName: item['name'] as String? ?? 'Product Name',
                quantity: item['quantity'] as int? ?? 0,
                price: double.tryParse(item['total']?.toString() ?? '0.0') ?? 0.0,
                imageUrl: imageUrl, // <<<--- इमेज URL यहाँ पास किया गया
                currencySymbol: currencySymbol,
              );
            },
          ),
        ],
      ),
    );
  }
}