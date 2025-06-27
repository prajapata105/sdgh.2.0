import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/controller/news_controller.dart';
import 'package:ssda/models/news_article_model.dart';
import 'package:intl/intl.dart';

import 'news_detail_screen.dart';

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // न्यूज़ कंट्रोलर को इनिशियलाइज़ करें
    final NewsController controller = Get.put(NewsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("News & Updates"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.articles.isEmpty) {
          return const Center(child: Text("No news found."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.articles.length,
          itemBuilder: (context, index) {
            final article = controller.articles[index];
            return _buildNewsCard(article);
          },
        );
      }),
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.to(() => NewsDetailScreen(article: article)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              Image.network(
                article.imageUrl!,
                height: Get.height * 0.22,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Get.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.excerpt,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Get.theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('d MMMM, yyyy').format(article.date),
                    style: Get.theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
