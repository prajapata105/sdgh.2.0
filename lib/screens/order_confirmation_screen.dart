// lib/screens/order_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ssda/app_colors.dart';
import 'package:ssda/controller/OrderDetailsController.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // OrderDetailsController का इंस्टेंस प्राप्त करें जो main.dart में डाला गया है
    final OrderDetailsController detailsController = Get.find<OrderDetailsController>();
    final theme = Theme.of(context);

    // कंट्रोलर से सीधे डेटा पढ़ें
    final int? orderId = detailsController.orderDetails['id'] as int?;
    final Map<String, dynamic>? orderData = detailsController.orderDetails;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'Assets/cart_packing.json',
                height: 250,
                width: 250,
                repeat: false,
              ),
              const SizedBox(height: 20),
              Text('Order Placed Successfully!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              if (orderId != null)
                Text("Your Order ID: #$orderId", style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Text('Thank you for your purchase!', style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 30),
              if (orderData != null && orderData.isNotEmpty && orderId != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreenColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: () {
                    // अब हमें आर्गुमेंट्स भेजने की जरूरत नहीं है, क्योंकि OrderDetailsController में डेटा पहले से ही है
                    Get.toNamed('/order');
                  },
                  child: const Text('View Order Details'),
                ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Get.offAllNamed('/home'),
                child: const Text('Continue Shopping', style: TextStyle(color: AppColors.primaryGreenColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}