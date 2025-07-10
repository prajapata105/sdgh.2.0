// lib/screens/news_list_screen.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/controller/news_controller.dart';
import 'package:ssda/models/news_article_model.dart';
import 'package:intl/intl.dart';

import 'news_detail_screen.dart';

// <<<--- बदलाव: इसे StatefulWidget बनाया गया है ---<<<
class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final NewsController controller = Get.put(NewsController());
  // स्क्रॉल को सुनने के लिए एक कंट्रोलर
  final ScrollController _scrollController = ScrollController();

  final List<String> _defaultImages = const [
    "https://sridungargarhone.com/wp-content/uploads/2025/07/Black.jpg",
    "https://sridungargarhone.com/wp-content/uploads/2025/07/Blue.jpg",
    "https://sridungargarhone.com/wp-content/uploads/2025/07/Red.jpg",
  ];

  String _getFallbackImageUrl(int index) {
    return _defaultImages[index % _defaultImages.length];
  }

  @override
  void initState() {
    super.initState();
    // स्क्रॉल लिस्नर को जोड़ें
    _scrollController.addListener(() {
      // जब यूज़र स्क्रॉल करके लगभग अंत तक पहुँच जाए
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        controller.loadMoreNews();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("News & Updates"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allArticles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.allArticles.isEmpty) {
          return const Center(child: Text("No news found."));
        }
        // <<<--- बदलाव: खींचकर रिफ्रेश करने के लिए RefreshIndicator ---<<<
        return RefreshIndicator(
          onRefresh: () => controller.fetchNews(),
          child: CustomScrollView(
            controller: _scrollController, // स्क्रॉल कंट्रोलर को जोड़ें
            slivers: [
              _buildTopBannerSlider(controller.topBannerArticles),
              _buildOtherNewsList(controller.otherArticles),

              // <<<--- बदलाव: नीचे लोडिंग इंडिकेटर दिखाने के लिए ---<<<
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isMoreLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTopBannerSlider(List<NewsArticle> articles) {
    if (articles.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: CarouselSlider.builder(
        itemCount: articles.length,
        itemBuilder: (context, index, realIndex) {
          final article = articles[index];
          final imageUrl = (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              ? article.imageUrl!
              : _getFallbackImageUrl(index);

          return GestureDetector(
            onTap: () => Get.to(() => NewsDetailScreen(article: article)),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Image.network(
                        _getFallbackImageUrl(index),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    left: 15,
                    right: 15,
                    child: Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: 220,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.9,
        ),
      ),
    );
  }

  Widget _buildOtherNewsList(List<NewsArticle> articles) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final article = articles[index];
          final imageUrl = (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              ? article.imageUrl!
              : _getFallbackImageUrl(index + 5); // इंडेक्स को अलग रखने के लिए +5

          return InkWell(
            onTap: () => Get.to(() => NewsDetailScreen(article: article)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Get.theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('d MMMM, yyyy').format(article.date),
                          style: Get.theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 100,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Image.network(
                        _getFallbackImageUrl(index + 5),
                        width: 100,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: articles.length,
      ),
    );
  }
}
