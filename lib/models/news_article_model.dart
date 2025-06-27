class NewsArticle {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String excerpt;
  final DateTime date;

  NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.date,
    this.imageUrl,
  });

  // WordPress API से मिले JSON को Dart ऑब्जेक्ट में बदलने के लिए
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    String rawExcerpt = json['excerpt']['rendered'] ?? '';
    // <p> टैग्स हटाने के लिए
    String cleanedExcerpt = rawExcerpt.replaceAll(RegExp(r'<p>|<\/p>|\n'), '').trim();

    return NewsArticle(
      id: json['id'],
      title: json['title']['rendered'],
      content: json['content']['rendered'],
      excerpt: cleanedExcerpt,
      date: DateTime.parse(json['date_gmt']),
      // _embed करने पर यह फील्ड मिलता है
      imageUrl: json['_embedded']?['wp:featuredmedia']?[0]?['source_url'],
    );
  }
}