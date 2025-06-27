// lib/UI/Widgets/Atoms/add_to_cart_button.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:ssda/app_colors.dart';
import 'package:ssda/models/product_model.dart';
import 'package:ssda/models/cart_item_model.dart';
import 'package:ssda/services/cart_service.dart';

Widget buildAddToCartButton(Product product) {
  return InkWell(
    onTap: () {
      final cart = Get.find<CartService>();

      // <<<--- बदलाव यहाँ: कीमत को String से double में सुरक्षित रूप से पार्स करें ---<<<
      final double priceAsDouble = double.tryParse(product.price) ?? 0.0;

      final cartItem = CartItem(
        id: product.id,
        title: product.name,
        imageUrl: product.image,
        price: priceAsDouble, // पार्स की हुई वैल्यू का उपयोग करें
        quantity: 1,
      );
      cart.addToCart(cartItem);
      Fluttertoast.showToast(
        msg: 'Product Added To Cart',
        backgroundColor: Colors.white,
        textColor: Colors.black,
        gravity: ToastGravity.BOTTOM,
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryGreenColor.withOpacity(0.1),
        border: Border.all(color: AppColors.primaryGreenColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "Add",
        style: TextStyle(
          fontSize: 15,
          color: AppColors.primaryGreenColor,
        ),
      ),
    ),
  );
}