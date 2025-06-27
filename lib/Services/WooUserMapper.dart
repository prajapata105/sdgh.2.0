import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:ssda/Infrastructure/HttpMethods/requesting_methods.dart';

import 'package:ssda/utils/constent.dart';

import 'Exceptions/api_exception.dart'; // <-- अपने baseUrl/keys इसी में रखें या यहां से import करें


class WooUserMapper {
  static const String baseUrl = "https://sridungargarhone.com";
  static const String consumerKey = "ck_d7ef1f4a099e201fefb6b4cf5abe3108b1ead425";
  static const String consumerSecret = "cs_8bcc847ea3e7159f501c242d2c047002ed9d06c5";

  /// Firestore/Firebase UID से Woo user id mapping (create if not exist)
  static Future<String> mapFirebaseToWooUser({
    required String phone,
    required String name,
  }) async {
    final box = GetStorage();

    // 1. पहले check करें कि local storage में id पड़ी है या नहीं
    final savedId = box.read('wooUserId');
    if (savedId != null && savedId.toString().isNotEmpty) return savedId;

    // 2. WooCommerce में customer search करो
    final searchUrl =
        "$baseUrl/wp-json/wc/v3/customers?consumer_key=$consumerKey&consumer_secret=$consumerSecret&search=$phone";
    final searchRes = await ApiService.requestMethods(
      methodType: "GET",
      url: searchUrl,
    );
    if (searchRes is List && searchRes.isNotEmpty) {
      // मिल गया!
      final id = searchRes.first['id'].toString();
      box.write('wooUserId', id);
      return id;
    }

    // 3. अगर नहीं मिला तो customer create करो
    final email = "$phone@sdghone.com"; // Woo में email required है
    final customerBody = {
      "email": email,
      "username": phone,
      "first_name": name,
      "billing": {
        "phone": phone,
        "email": email,
        "first_name": name,
      },
      "shipping": {
        "phone": phone,
        "first_name": name,
      }
    };

    final createUrl =
        "$baseUrl/wp-json/wc/v3/customers?consumer_key=$consumerKey&consumer_secret=$consumerSecret";

    try {
      final createRes = await ApiService.requestMethods(
        methodType: "POST",
        url: createUrl,
        body: jsonEncode(customerBody),
      );
      final id = createRes['id'].toString();
      box.write('wooUserId', id);
      return id;
    } catch (e) {
      throw ApiException(500, "Woo user create/search failed: $e");
    }
  }
}
