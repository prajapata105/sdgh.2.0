import 'package:flutter/foundation.dart';
import 'package:ssda/Infrastructure/HttpMethods/requesting_methods.dart';
import 'package:ssda/Services/WooUserMapper.dart';
import 'package:ssda/models/product_model.dart';
import 'package:ssda/Services/Exceptions/api_exception.dart';

class ProductService {
  static const String _baseUrl = WooUserMapper.baseUrl + '/wp-json/wc/v3/';
  static const String _consumerKey = WooUserMapper.consumerKey;
  static const String _consumerSecret = WooUserMapper.consumerSecret;

  static Future<List<Product>> getProducts({
    int page = 1,
    int perPage = 10,
    String? categoryId,
    String? orderBy, // 'popularity' (Best Sellers) या 'date' (New Arrivals) के लिए
  }) async {
    String url = '${_baseUrl}products?consumer_key=$_consumerKey&consumer_secret=$_consumerSecret';
    url += '&page=$page&per_page=$perPage&status=publish';

    if (categoryId != null && categoryId.isNotEmpty) {
      url += '&category=$categoryId';
    }
    if (orderBy != null && orderBy.isNotEmpty) {
      url += '&orderby=$orderBy';
    }

    try {
      final response = await ApiService.requestMethods(url: url, methodType: "GET");
      if (response != null && response is List) {
        return response.map((data) => Product.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("ProductService Error (getProducts): $e");
      return [];
    }
  }

  static Future<List<Product>> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    final String url = '${_baseUrl}products?search=$query&consumer_key=$_consumerKey&consumer_secret=$_consumerSecret&status=publish';
    try {
      final response = await ApiService.requestMethods(url: url, methodType: "GET");
      if (response != null && response is List) {
        return response.map((data) => Product.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("ProductService Error (searchProducts): $e");
      return [];
    }
  }

  static Future<Product?> getProductById(int productId) async {
    final String url = '${_baseUrl}products/$productId?consumer_key=$_consumerKey&consumer_secret=$_consumerSecret';
    try {
      final response = await ApiService.requestMethods(methodType: "GET", url: url);
      if (response != null) {
        return Product.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching product by ID $productId: $e");
      return null;
    }
  }
}
