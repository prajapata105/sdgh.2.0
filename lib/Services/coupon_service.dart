import 'package:ssda/Infrastructure/HttpMethods/requesting_methods.dart';
import 'package:ssda/models/coupon_model.dart';

class CouponService {
  // सभी coupons fetch करना (WooCommerce से)

  static Future<List<Coupon>> fetchCoupons() async {
    final response = await ApiService.requestMethods(
      methodType: "GET",
      url: "https://sridungargarhone.com/wp-json/wc/v3/coupons?consumer_key=ck_d7ef1f4a099e201fefb6b4cf5abe3108b1ead425&consumer_secret=cs_8bcc847ea3e7159f501c242d2c047002ed9d06c5",
    );
    if (response is List) {
      return response.map((e) => Coupon.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  // एक coupon code से details fetch करना
  static Future<Coupon?> fetchCouponByCode(String code) async {
    final response = await ApiService.requestMethods(
      methodType: "GET",
      url: "https://sridungargarhone.com/wp-json/wc/v3/coupons?code=$code&consumer_key=ck_d7ef1f4a099e201fefb6b4cf5abe3108b1ead425&consumer_secret=cs_8bcc847ea3e7159f501c242d2c047002ed9d06c5",
    );
    if (response is List && response.isNotEmpty) {
      return Coupon.fromJson(response[0]);
    } else {
      return null;
    }
  }
}
