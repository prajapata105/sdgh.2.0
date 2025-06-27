import 'package:ssda/Infrastructure/HttpMethods/requesting_methods.dart';
import 'package:ssda/models/address_model.dart';

class AddressService {
  static const String baseUrl = 'https://sridungargarhone.com/wp-json/wc/v3/customers';
  static const String consumerKey = 'ck_d7ef1f4a099e201fefb6b4cf5abe3108b1ead425';
  static const String consumerSecret = 'cs_8bcc847ea3e7159f501c242d2c047002ed9d06c5';

  static Future<void> updateShippingAddress(int customerId, Map<String, dynamic> shippingData) async {
    final url = "$baseUrl/$customerId?consumer_key=$consumerKey&consumer_secret=$consumerSecret";
    final body = {"shipping": shippingData};
    await ApiService.requestMethods(methodType: "PUT", url: url, body: body);
  }

  static Future<Address?> fetchShippingAddress(int customerId) async {
    final url = "$baseUrl/$customerId?consumer_key=$consumerKey&consumer_secret=$consumerSecret";
    final response = await ApiService.requestMethods(methodType: "GET", url: url);
    final data = response['shipping'];
    if (data == null) return null;
    return Address.fromWooShipping(data);
  }
}
