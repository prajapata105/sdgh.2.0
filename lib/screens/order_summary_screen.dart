// lib/screens/order_summary_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/app_colors.dart' show AppColors;
import 'package:ssda/controller/OrderDetailsController.dart';
import 'package:ssda/models/address_model.dart';
import 'package:ssda/constants.dart'; // appCurrencySymbol के लिए

// अपने Organisms और Atoms विजेट्स के लिए सही पाथ इम्पोर्ट करें
import 'package:ssda/UI/Widgets/Organisms/order_summary_screen_product_details_card.dart';
import 'package:ssda/UI/Widgets/Organisms/card_cart_prices_detail.dart';
import 'package:ssda/UI/Widgets/Atoms/card_order_details.dart';
import 'package:ssda/UI/Widgets/Atoms/repeat_order_cta.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // OrderDetailsController को GetX के साथ इंजेक्ट या फाइंड करें
    final OrderDetailsController controller = Get.put(OrderDetailsController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.greyWhiteColor,
      appBar: AppBar(
        elevation: 1, // थोड़ा एलिवेशन अच्छा लगेगा
        title: Obx(() => Text(
          controller.orderDetails.containsKey('id') ? 'Order Summary #${controller.orderDetails['id']}' : 'Order Summary',
          style: theme.appBarTheme.titleTextStyle,
        ),
        ),
      ),
      body: Obx(() { // पूरी बॉडी को Obx से लपेटें
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.orderDetails.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Could not load order details. Please try again later or check your order history.",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }


        // ऑर्डर डेटा से जानकारी निकालें
        final order = controller.orderDetails;

        // सुरक्षा के लिए null चेक और डिफ़ॉल्ट वैल्यूज़
        final List lineItems = order['line_items'] as List? ?? [];
        final Map<String, dynamic> billingAddressMap = order['billing'] as Map<String, dynamic>? ?? {};
        final Address shippingAddress = Address.fromWooShipping(order['shipping'] as Map<String, dynamic>? ?? {});
        final String currencySymbol = order['currency_symbol'] as String? ?? appCurrencySybmbol;
        final String orderStatus = order['status'] as String? ?? 'N/A';
        final String paymentMethodTitle = order['payment_method_title'] as String? ?? 'N/A';
        final String dateCreated = order['date_created'] as String? ?? '';

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                // अब यह डायनामिक डेटा लेगा
                OrderSummaryProductsDetails(
                  lineItems: lineItems,
                  orderStatus: orderStatus,
                  dateCreated: dateCreated, // date_created सीधे पास करें, फॉर्मेटिंग विजेट में होगी
                  currencySymbol: currencySymbol,
                ),
                // अब यह डायनामिक डेटा लेगा
                CartPriceDetailWidget(
                  orderData: order, // पूरा ऑर्डर डेटा पास करें
                  currencySymbol: currencySymbol,
                ),
                // अब यह डायनामिक डेटा लेगा
                OrderDetailsCard(
                  orderId: order['id']?.toString() ?? 'N/A',
                  paymentMethod: paymentMethodTitle,
                  dateCreated: dateCreated, // date_created सीधे पास करें
                  shippingAddress: shippingAddress,
                  currencySymbol: currencySymbol,
                ),
                const SizedBox(height: 100), // रिपीट ऑर्डर बटन के लिए जगह
              ],
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: RepeatOrderContainer(),
            )
          ],
        );
      }),
    );
  }
}