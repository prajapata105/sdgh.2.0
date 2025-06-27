import 'dart:convert';
import 'package:ssda/Infrastructure/HttpMethods/requesting_methods.dart';
import 'package:ssda/Services/WooUserMapper.dart';
import 'package:ssda/models/category_model.dart';

class CategoryService {
  // <<<--- बदलाव यहाँ: इन वेरिएबल्स को static बनाया गया ---<<<
  static const String _baseUrl = WooUserMapper.baseUrl + "/wp-json/wc/v3/";
  static const String _consumerKey = WooUserMapper.consumerKey;
  static const String _consumerSecret = WooUserMapper.consumerSecret;

  // <<<--- बदलाव यहाँ: इस मेथड को static बनाया गया ---<<<
  static Future<List<Category>> getAllCategories() async {
    final url =
        "${_baseUrl}products/categories?per_page=100&consumer_key=$_consumerKey&consumer_secret=$_consumerSecret";

    try {
      final response = await ApiService.requestMethods(
        methodType: "GET",
        url: url,
      );
      if (response != null && response is List) {
        return response.map((e) => Category.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching all categories: $e");
      return [];
    }
  }

  // <<<--- बदलाव यहाँ: इस मेथड को static बनाया गया ---<<<
  static Future<List<Category>> getMainCategories() async {
    final url =
        "${_baseUrl}products/categories?parent=0&per_page=100&consumer_key=$_consumerKey&consumer_secret=$_consumerSecret";

    try {
      final response = await ApiService.requestMethods(
        methodType: "GET",
        url: url,
      );
      if (response != null && response is List) {
        return response.map((e) => Category.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching main categories: $e");
      return [];
    }
  }


  // <<<--- बदलाव यहाँ: इस मेथड को static बनाया गया ---<<<
  static Future<List<Category>> getSubCategories(int parentId) async {
    final url =
        "${_baseUrl}products/categories?parent=$parentId&consumer_key=$_consumerKey&consumer_secret=$_consumerSecret";

    try {
      final response = await ApiService.requestMethods(
        methodType: "GET",
        url: url,
      );
      if (response != null && response is List) {
        return response.map((e) => Category.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching sub categories: $e");
      return [];
    }
  }

}
