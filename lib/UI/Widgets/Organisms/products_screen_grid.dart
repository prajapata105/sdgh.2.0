import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/UI/Widgets/Atoms/card_product_list.dart';
import 'package:ssda/models/product_model.dart';

class ProductsScreenGrid extends StatelessWidget {
  final List<Product> products;

  const ProductsScreenGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    // यह तय करेगा कि स्क्रीन की चौड़ाई के हिसाब से कितने कॉलम दिखाने हैं।
    // 150px प्रति कार्ड के हिसाब से यह कैलकुलेट करेगा।
    final crossAxisCount = (Get.width * 0.75 / 150).floor().clamp(2, 4);

    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // कॉलम की संख्या डायनामिक होगी
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        // यह आपके रेस्पॉन्सिव कार्ड के लिए है
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        return ProductCardForList(product: products[index]);
      },
    );
  }
}