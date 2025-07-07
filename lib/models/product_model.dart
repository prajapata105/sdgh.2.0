// lib/models/product_model.dart

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:ssda/models/category_model.dart' as app_category;

class Product {
  final int id;
  final String name;
  final String description;
  final String image;          // यह मुख्य (पहली) इमेज के लिए है
  final List<String> images;   // <<<--- सभी इमेज के लिए नई लिस्ट
  final String price;
  final String regularPrice;
  final String salePrice;
  final bool onSale;
  final List<Attribute> attributes;
  final List<app_category.Category> categories;
  final String? weight;
  final String? averageRating;
  final int? ratingCount;
  final double discount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.images, // <<<--- कंस्ट्रक्टर में जोड़ा गया
    required this.price,
    required this.regularPrice,
    required this.salePrice,
    required this.onSale,
    required this.attributes,
    required this.categories,
    this.weight,
    this.averageRating,
    this.ratingCount,
    required this.discount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // डिस्काउंट कैलकुलेट करें
    final double regular = double.tryParse(json['regular_price']?.toString() ?? '0.0') ?? 0.0;
    final double sale = double.tryParse(json['sale_price']?.toString() ?? '0.0') ?? 0.0;
    double calculatedDiscount = 0.0;
    if (regular > 0 && sale > 0 && sale < regular) {
      calculatedDiscount = ((regular - sale) / regular) * 100;
    }

    // <<<--- सभी इमेज को लिस्ट में पार्स करने का सही तरीका ---<<<
    List<String> imagesList = [];
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      // API से आने वाली इमेज लिस्ट को map करके URLs निकालें
      imagesList = (json['images'] as List)
          .map((img) => img['src'] as String? ?? '')
          .where((src) => src.isNotEmpty) // खाली URLs को हटा दें
          .toList();
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] != null ? Bidi.stripHtmlIfNeeded(json['description']) : '',

      // पहली इमेज को मुख्य इमेज बनाएं
      image: imagesList.isNotEmpty ? imagesList[0] : '',
      // सभी इमेज की लिस्ट
      images: imagesList,

      price: json['price']?.toString() ?? '0.0',
      regularPrice: json['regular_price']?.toString() ?? '0.0',
      salePrice: json['sale_price']?.toString() ?? (json['price']?.toString() ?? '0.0'),
      onSale: json['on_sale'] ?? false,
      attributes: (json['attributes'] as List?)?.map((attr) => Attribute.fromJson(attr)).toList() ?? [],
      categories: (json['categories'] as List?)?.map((cat) => app_category.Category.fromJson(cat)).toList() ?? [],
      weight: json['weight']?.toString(),
      averageRating: json['average_rating']?.toString(),
      ratingCount: json['rating_count'] as int?,
      discount: calculatedDiscount,
    );
  }
}

class Attribute {
  final int id;
  final String name;
  final String option;

  Attribute({required this.id, required this.name, required this.option});

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      option: (json['options'] as List?)?.isNotEmpty ?? false ? json['options'][0] : '',
    );
  }
}