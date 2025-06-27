// lib/UI/Widgets/Organisms/card_cart_prices_detail.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/services/cart_service.dart';

class CartPriceDetailWidget extends StatelessWidget {
  final Map<String, dynamic>? orderData;
  final CartService? cartServiceInstance;
  final String currencySymbol;

  const CartPriceDetailWidget({
    super.key,
    this.orderData,
    this.cartServiceInstance,
    required this.currencySymbol,
  }) : assert(orderData != null || cartServiceInstance != null,
  'Either orderData or cartServiceInstance must be provided');

  double _tryParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    late double subtotal;
    late double totalDiscount;
    late double deliveryCharge;
    late double grandTotal;

    if (cartServiceInstance != null) {
      // CartScreen के लिए
      subtotal = cartServiceInstance!.subtotal;
      totalDiscount = cartServiceInstance!.discount;
      deliveryCharge = cartServiceInstance!.deliveryCharge;
      grandTotal = cartServiceInstance!.grandTotal;
    } else if (orderData != null) {
      // OrderSummaryScreen के लिए

      // 👇 ****** सबटोटल की गणना लाइन आइटम्स से करें ****** 👇
      double calculatedSubtotal = 0.0;
      if (orderData!['line_items'] is List) {
        for (var item in (orderData!['line_items'] as List)) {
          if (item is Map<String, dynamic>) {
            // 'subtotal' का उपयोग करें, 'total' का नहीं, ताकि डिस्काउंट से पहले की कीमत मिले
            calculatedSubtotal += _tryParseDouble(item['subtotal']);
          }
        }
      }
      subtotal = calculatedSubtotal;
      // 👆 ****** यहाँ तक बदलाव ****** 👆

      totalDiscount = _tryParseDouble(orderData!['discount_total']);

      if (orderData!['shipping_lines'] != null && (orderData!['shipping_lines'] as List).isNotEmpty) {
        final shippingLine = (orderData!['shipping_lines'] as List).first as Map<String, dynamic>;
        deliveryCharge = _tryParseDouble(shippingLine['total']);
      } else {
        deliveryCharge = 0.0;
      }
      grandTotal = _tryParseDouble(orderData!['total']);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bill Details",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildPriceRow("Item Total (Subtotal)", subtotal, currencySymbol: currencySymbol, textStyle: theme.textTheme.bodyLarge),

          if (totalDiscount > 0)
            _buildPriceRow("Coupon Discount", -totalDiscount.abs(), isDiscount: true, currencySymbol: currencySymbol, textStyle: theme.textTheme.bodyLarge),

          _buildPriceRow("Delivery Charge", deliveryCharge, currencySymbol: currencySymbol, textStyle: theme.textTheme.bodyLarge),

          const Divider(thickness: 1, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Grand Total",
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "$currencySymbol${grandTotal.toStringAsFixed(2)}",
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isDiscount = false, required String currencySymbol, TextStyle? textStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle ?? const TextStyle(fontSize: 15)),
          Text(
            (isDiscount ? "- " : "") + "$currencySymbol${value.abs().toStringAsFixed(2)}",
            style: (textStyle ?? const TextStyle(fontSize: 15)).copyWith(
              color: isDiscount ? Colors.green.shade700 : (textStyle?.color ?? Colors.black87),
              fontWeight: isDiscount ? FontWeight.bold : textStyle?.fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}