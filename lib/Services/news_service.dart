// lib/services/news_service.dart

import 'package:ssda/Infrastructure/HttpMethods/requesting_methods.dart';
import 'package:ssda/models/news_article_model.dart';

class NewsService {
  static const String _baseUrl = "https://sridungargarhone.com/wp-json/wp/v2/";

  // <<<--- बदलाव यहाँ: अब यह फंक्शन पेज नंबर भी लेता है ---<<<
  static Future<List<NewsArticle>> getNewsArticles({int page = 1, int perPage = 20}) async {
    // URL में अब पेज नंबर भी भेजा जाएगा
    final url = "${_baseUrl}posts?_embed&per_page=$perPage&page=$page";

    try {
      final response = await ApiService.requestMethods(url: url, methodType: "GET");
      if (response != null && response is List) {
        // अगर लिस्ट खाली है, तो एक खाली लिस्ट लौटाएं
        if (response.isEmpty) {
          return [];
        }
        return response.map((e) => NewsArticle.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching news on page $page: $e");
    }
    return [];
  }

  // यह फंक्शन वैसा ही रहेगा
  static Future<NewsArticle?> getArticleById(int id) async {
    final url = "${_baseUrl}posts/$id?_embed";
    try {
      final response = await ApiService.requestMethods(url: url, methodType: "GET");
      if (response != null) {
        return NewsArticle.fromJson(response);
      }
    } catch (e) {
      print("Error fetching article by ID: $e");
    }
    return null;
  }
}
