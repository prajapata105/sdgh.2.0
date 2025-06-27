import 'package:ssda/Infrastructure/HttpMethods/requesting_methods.dart';
import 'package:ssda/models/banner_model.dart';

class HomeService {
  static String get _pageApiUrl {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return "https://sridungargarhone.com/wp-json/wp/v2/pages/12?_cb=$timestamp";
  }

  Future<Map<String, dynamic>> fetchHomePageData() async {
    try {
      final response = await ApiService.requestMethods(
        methodType: "GET",
        url: _pageApiUrl,
      );

      if (response != null) {
        // एक ही कॉल में बैनर और सेक्शन, दोनों का डेटा लौटाएं
        return {
          'banner_data': response['banner_pairs_data'],
          'sections_data': response['dynamic_sections_raw'],
        };
      }
      return {};
    } catch (e) {
      print("HomeService में त्रुटि: $e");
      return {};
    }
  }
}
