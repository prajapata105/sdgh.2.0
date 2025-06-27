import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ssda/controller/news_controller.dart';
import 'package:ssda/models/news_article_model.dart';
import 'package:intl/intl.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsArticle article;
  const NewsDetailScreen({super.key, required this.article});

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String? parsedString = document.body?.text;
    return parsedString ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final NewsDetailController detailCtrl = Get.put(NewsDetailController(_parseHtmlString(article.content)));
    final String newsUrl = "https://sridungargarhone.com/?p=${article.id}";
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // <<<--- अब हम सीधे वेबसाइट का लिंक शेयर करेंगे ---<<<
              Share.share(
                'Read this interesting news: ${article.title}\n\n$newsUrl',
                subject: article.title,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                article.title,
                style: Get.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, height: 1.3)
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('d MMMM, yyyy').format(article.date),
              style: Get.theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            if (article.imageUrl != null)
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    article.imageUrl!,
                    height: Get.height * 0.25,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: Get.height * 0.25,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: Get.height * 0.25,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image, color: Colors.grey.shade400, size: 50),
                      );
                    },
                  )
              ),
            const SizedBox(height: 16),

            _listenToNewsButton(detailCtrl),
            const SizedBox(height: 20),

            // HTML कंटेंट
            Html(
              data: article.content,
              style: {
                "p": Style(
                  fontSize: FontSize(16),
                  lineHeight: const LineHeight(1.6),
                ),
                "img": Style(
                  margin: Margins.symmetric(vertical: 10),
                ),
              },
              extensions: [
                TagExtension(
                  tagsToExtend: {"img"},
                  builder: (context) {
                    final attrs = context.attributes;
                    final src = attrs['src'] ?? '';
                    if (src.isEmpty) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          src,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 300,
                              color: Colors.grey.shade200,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: Colors.grey.shade200,
                              child: Icon(Icons.broken_image, color: Colors.grey.shade400, size: 50),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            )

          ],
        ),
      ),
    );
  }

  Widget _listenToNewsButton(NewsDetailController detailCtrl) {
    return Obx(() => InkWell(
      onTap: detailCtrl.togglePlay,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade50,
                Colors.green.shade50,
              ],
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              detailCtrl.isPlaying.value ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              color: Colors.green.shade700,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              detailCtrl.isPlaying.value ? 'Listening...' : 'Listen to this news',
              style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ));
  }
}
