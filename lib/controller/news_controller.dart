// lib/controller/news_controller.dart

import 'package:get/get.dart';
import 'package:ssda/models/news_article_model.dart';
import 'package:ssda/services/news_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/parser.dart';

class NewsController extends GetxController {
  var isLoading = true.obs;
  var allArticles = <NewsArticle>[].obs;

  // UI के लिए नई RxLists
  var topBannerArticles = <NewsArticle>[].obs;
  var otherArticles = <NewsArticle>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNews();
  }

  void fetchNews() async {
    try {
      isLoading(true);
      allArticles.value = await NewsService.getNewsArticles();

      // खबरों को दो हिस्सों में बांटें
      if (allArticles.length >= 5) {
        topBannerArticles.value = allArticles.sublist(0, 5); // पहली 5 खबरें
        otherArticles.value = allArticles.sublist(5);      // बाकी की खबरें
      } else {
        // अगर 5 से कम खबरें हैं, तो सभी को बैनर में दिखाएं
        topBannerArticles.value = allArticles;
        otherArticles.clear();
      }
    } finally {
      isLoading(false);
    }
  }
}

// यह कंट्रोलर वैसा ही रहेगा
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