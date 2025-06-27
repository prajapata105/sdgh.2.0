import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:ssda/models/category_model.dart' as app_category;

class Product {
  final int id;
  final String name;
  final String description;
  final String image;
  final String price;
  final String regularPrice;
  final String salePrice; // यह पहले से था, जो अच्छी बात है
  final bool onSale;
  final List<Attribute> attributes;
  final List<app_category.Category> categories;

  // <<<--- नए फील्ड्स यहाँ जोड़े गए हैं ---<<<
  final String? weight;          // वजन
  final String? averageRating;   // औसत रेटिंग
  final int? ratingCount;       // कितने लोगों ने रेटिंग दी
  final double discount;        // छूट (यह हम कैलकुलेट करेंगे)

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.regularPrice,
    required this.salePrice,
    required this.onSale,
    required this.attributes,
    required this.categories,
    // नए फील्ड्स को कंस्ट्रक्टर में जोड़ा गया
    this.weight,
    this.averageRating,
    this.ratingCount,
    required this.discount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {

    // --- डिस्काउंट कैलकुलेट करने का लॉजिक ---
    final double regular = double.tryParse(json['regular_price']?.toString() ?? '0.0') ?? 0.0;
    final double sale = double.tryParse(json['sale_price']?.toString() ?? '0.0') ?? 0.0;
    double calculatedDiscount = 0.0;
    if (regular > 0 && sale < regular) {
      calculatedDiscount = ((regular - sale) / regular) * 100;
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] != null
          ? Bidi.stripHtmlIfNeeded(json['description'])
          : '',
      image: (json['images'] as List?)?.isNotEmpty ?? false
          ? json['images'][0]['src']
          : '',
      price: json['price']?.toString() ?? '0.0',
      regularPrice: json['regular_price']?.toString() ?? '0.0',
      salePrice: json['sale_price']?.toString() ?? (json['price']?.toString() ?? '0.0'),
      onSale: json['on_sale'] ?? false,
      attributes: (json['attributes'] as List?)
          ?.map((attr) => Attribute.fromJson(attr))
          .toList() ??
          [],
      categories: (json['categories'] as List?)
          ?.map((cat) => app_category.Category.fromJson(cat))
          .toList() ??
          [],

      // <<<--- JSON से नए फील्ड्स को पार्स करने का लॉजिक ---<<<
      weight: json['weight']?.toString(), // API से 'weight' फील्ड
      averageRating: json['average_rating']?.toString(), // API से 'average_rating' फील्ड
      ratingCount: json['rating_count'] as int?, // API से 'rating_count' फील्ड
      discount: calculatedDiscount, // ऊपर कैलकुलेट किया हुआ डिस्काउंट
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
      option: (json['options'] as List?)?.isNotEmpty ?? false
          ? json['options'][0]
          : '',
    );
  }
}