import 'package:ssda/Infrastructure/HttpMethods/requesting_methods.dart';
import 'package:ssda/models/news_article_model.dart';

class NewsService {
  static const String _baseUrl = "https://sridungargarhone.com/wp-json/wp/v2/";

  static Future<List<NewsArticle>> getNewsArticles() async {
    const url = "${_baseUrl}posts?_embed&per_page=20";
    try {
      final response = await ApiService.requestMethods(url: url, methodType: "GET");
      if (response != null && response is List) {
        return response.map((e) => NewsArticle.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching news: $e");
    }
    return [];
  }

  // <<<--- यह नया फंक्शन जोड़ा गया है ---<<<
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