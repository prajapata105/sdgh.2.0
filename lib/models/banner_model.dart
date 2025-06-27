class BannerModel {
  final String imageUrl;
  final String? link; // लिंक वैकल्पिक हो सकता है

  BannerModel({required this.imageUrl, this.link});

  // यह फैक्ट्री अब उपयोग में नहीं आएगी अगर आप HomeService में मॉडल बनाते हैं,
  // लेकिन इसे रखना अच्छी प्रैक्टिस है।
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      imageUrl: json['image_url'] ?? '',
      link: json['link'],
    );
  }
}