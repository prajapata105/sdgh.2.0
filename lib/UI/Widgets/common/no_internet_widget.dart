import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/controller/network_controller.dart'; // नेटवर्क कंट्रोलर इम्पोर्ट करें

class NoInternetWidget extends StatelessWidget {
  // <<<--- अब हमें onRetry की ज़रूरत नहीं, यह खुद काम करेगा ---<<<
  const NoInternetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // <<<--- कंट्रोलर को यहाँ एक्सेस करें ---<<<
    final NetworkController networkController = Get.find();

    return Scaffold( // इसे Scaffold में डालें ताकि यह पूरी स्क्रीन कवर करे
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // अपनी इमेज का सही पाथ यहाँ दें
            Image.asset(
              'assets/imagesvg/5363928.jpg', // <<<--- अपनी इमेज यहाँ डालें
              width: Get.width * 0.5,
            ),
            SizedBox(height: Get.height * 0.03),
            const Text(
              'No internet connection',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: Get.height * 0.01),
            const Text(
              'Please check your network',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: Get.height * 0.04),
            TextButton(
              // <<<--- बटन दबाने पर अब यह कंट्रोलर का मेथड कॉल करेगा ---<<<
              onPressed: () => networkController.checkConnection(),
              child: const Text(
                'Try again',
                style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}