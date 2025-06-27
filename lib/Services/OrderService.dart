// lib/services/OrderService.dart

import 'dart:convert';
import 'package:ssda/Infrastructure/HttpMethods/requesting_methods.dart';
import 'package:ssda/Services/WooUserMapper.dart';
import 'package:ssda/Services/Exceptions/api_exception.dart';

class OrderService {
  static const String _baseUrl = WooUserMapper.baseUrl + '/wp-json/wc/v3/';
  static const String _consumerKey = WooUserMapper.consumerKey;
  static const String _consumerSecret = WooUserMapper.consumerSecret;

  // createOrder और fetchOrderByIdFromApi मेथड्स में कोई बदलाव नहीं...
  Future<Map<String, dynamic>?> createOrder(Map<String, dynamic> orderData) async {
    final String url = '${_baseUrl}orders?consumer_key=$_consumerKey&consumer_secret=$_consumerSecret';
    try {
      final responseData = await ApiService.requestMethods(
        methodType: "POST",
        url: url,
        body: orderData,
      );
      if (responseData is Map<String, dynamic> && responseData.containsKey('id')) {
        return responseData;
      } else {
        return null;
      }
    } catch (e) {
      print("OrderService Error (createOrder): $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchOrderByIdFromApi(int orderId) async {
    final String url = '${_baseUrl}orders/$orderId?consumer_key=$_consumerKey&consumer_secret=$_consumerSecret';
    try {
      final responseData = await ApiService.requestMethods(
        methodType: "GET",
        url: url,
      );
      if (responseData is Map<String, dynamic> && responseData.containsKey('id')) {
        return responseData;
      } else {
        return null;
      }
    } catch (e) {
      print("OrderService Error (fetchOrderByIdFromApi): $e");
      return null;
    }
  }

  // ***** 👇 केवल इस फंक्शन में एक छोटा सा बदलाव है 👇 *****
  Future<List<Map<String, dynamic>>?> fetchOrdersByCustomerId(int customerId) async {
    // सर्वर कैश को बायपास करने के लिए एक यूनिक पैरामीटर (कैश-बस्टर) बनाएं
    final String cacheBuster = '&_cb=${DateTime.now().millisecondsSinceEpoch}';

    // &status=any यह सुनिश्चित करता है कि सभी स्टेटस के ऑर्डर आएं
    // &cacheBuster यह सुनिश्चित करता है कि सर्वर से हमेशा ताजा डेटा आए
    final String url = '${_baseUrl}orders?customer=$customerId&consumer_key=$_consumerKey&consumer_secret=$_consumerSecret&orderby=date&order=desc&per_page=30&status=any$cacheBuster';

    print("Fetching orders with URL: $url"); // डीबगिंग के लिए

    try {
      final responseData = await ApiService.requestMethods(
        methodType: "GET",
        url: url,
      );
      if (responseData is List) {
        print("OrderService: Fetched ${responseData.length} orders for customer ID: $customerId");
        return responseData.cast<Map<String, dynamic>>();
      } else {
        print("OrderService: Fetched orders data is not a list for customer ID $customerId: $responseData");
        return [];
      }
    } on ApiException catch (e) {
      print("OrderService: API Error fetching orders by customer: Status ${e.statusCode}, Message: ${e.message}");
      return null;
    } catch (e) {
      print("OrderService: Generic Error fetching orders by customer: $e");
      return null;
    }
  }
}