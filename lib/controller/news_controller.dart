// lib/controller/news_controller.dart

import 'package:get/get.dart';
import 'package:ssda/models/news_article_model.dart';
import 'package:ssda/services/news_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/parser.dart';

class NewsController extends GetxController {
  // <<<--- नए वेरिएबल्स जोड़े गए हैं ---<<<
  var isLoading = true.obs;
  var isMoreLoading = false.obs; // नीचे लोडिंग दिखाने के लिए
  var allArticles = <NewsArticle>[].obs;

  var topBannerArticles = <NewsArticle>[].obs;
  var otherArticles = <NewsArticle>[].obs;

  var _currentPage = 1;
  var _hasMore = true; // यह बताएगा कि और पोस्ट्स हैं या नहीं

  @override
  void onInit() {
    super.onInit();
    fetchNews();
  }

  // <<<--- यह फंक्शन अब रिफ्रेश का काम करेगा ---<<<
  Future<void> fetchNews() async {
    try {
      isLoading(true);
      _currentPage = 1;
      _hasMore = true;
      allArticles.clear();

      var newArticles = await NewsService.getNewsArticles(page: _currentPage);
      allArticles.value = newArticles;

      _splitArticles();
    } finally {
      isLoading(false);
    }
  }

  // <<<--- नया फंक्शन: और खबरें लोड करने के लिए ---<<<
  Future<void> loadMoreNews() async {
    // अगर पहले से लोड हो रहा है या सारी खबरें आ चुकी हैं, तो कुछ न करें
    if (isMoreLoading.value || !_hasMore) return;

    try {
      isMoreLoading(true);
      _currentPage++;
      var newArticles = await NewsService.getNewsArticles(page: _currentPage);

      if (newArticles.isEmpty) {
        _hasMore = false; // अब और खबरें नहीं हैं
      } else {
        allArticles.addAll(newArticles);
        _splitArticles(); // लिस्ट को फिर से बांटें
      }
    } finally {
      isMoreLoading(false);
    }
  }

  // यह फंक्शन अब allArticles लिस्ट के आधार पर काम करेगा
  void _splitArticles() {
    if (allArticles.length >= 5) {
      topBannerArticles.value = allArticles.sublist(0, 5);
      otherArticles.value = allArticles.sublist(5);
    } else {
      topBannerArticles.value = allArticles;
      otherArticles.clear();
    }
  }
}

// NewsDetailController वैसा ही रहेगा
class NewsDetailController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();
  var isPlaying = false.obs;
  final String htmlContent;

  NewsDetailController(this.htmlContent);

  @override
  void onInit() {
    super.onInit();
    _initTts();
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? '';
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage('hi-IN');
    await flutterTts.setSpeechRate(0.5);
    flutterTts.setCompletionHandler(() {
      isPlaying(false);
    });
  }

  void togglePlay() {
    if (isPlaying.value) {
      flutterTts.stop();
      isPlaying(false);
    } else {
      isPlaying(true);
      flutterTts.speak(_parseHtmlString(htmlContent));
    }
  }

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }
}
