import 'package:flutter/material.dart';
import 'package:ssda/models/product_model.dart';
import 'package:ssda/screens/products_screen.dart';
import 'package:get/get.dart';
import '../Atoms/home_product_card.dart'; // हमारे नए कार्ड को इम्पोर्ट करें

class CatgorywithProducts extends StatelessWidget {
  final String title;
  final List<Product> products;
  final int? categoryId;
  final String? categoryName;

  const CatgorywithProducts({
    super.key,
    required this.title,
    required this.products,
    this.categoryId,
    this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                // अगर categoryId है, तभी "View All" बटन दिखाएं
                if (categoryId != null)
                  TextButton(
                    onPressed: () {
                      Get.to(() => ProductsScreen(
                        categoryId: categoryId!,
                        categoryName: categoryName ?? title,
                      ));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("View All", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                        Icon(Icons.chevron_right, color: Colors.green.shade700, size: 20),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 245, // ऊंचाई को नए कार्ड के हिसाब से एडजस्ट किया
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: products.length > 8 ? 8 : products.length,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  // अब नए HomeProductCard का उपयोग करें
                  child: HomeProductCard(product: products[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
