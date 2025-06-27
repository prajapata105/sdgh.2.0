import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/controller/SearchController.dart' as app_search;
import 'package:ssda/UI/Widgets/Atoms/card_product_list.dart';

class ProductSearchDelegate extends SearchDelegate<String> {
  // GetX सर्च कंट्रोलर को initialize करें
  final app_search.SearchController searchController = Get.put(app_search.SearchController());

  // सर्च बार की थीम
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey[800]),
        titleTextStyle: theme.textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[500]),
        border: InputBorder.none,
      ),
    );
  }

  // सर्च बार के दाईं ओर के एक्शन (जैसे 'clear' बटन)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            searchController.clearSearch();
          },
        ),
    ];
  }

  // सर्च बार के बाईं ओर का विजेट (जैसे 'back' बटन)
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  // जब यूजर कीबोर्ड से 'search' दबाता है
  @override
  Widget buildResults(BuildContext context) {
    // 2 से ज्यादा अक्षर होने पर ही सर्च करें
    if (query.trim().length > 2) {
      searchController.performSearch(query);
    }
    return _buildSearchResults();
  }

  // जब यूजर सर्च बार में कुछ टाइप करता है (सुझाव दिखाने के लिए)
  @override
  Widget buildSuggestions(BuildContext context) {
    // टाइप करते समय लाइव रिजल्ट्स दिखाएं
    if (query.trim().length > 2) {
      searchController.onSearchChanged(query);
    } else {
      searchController.clearSearch(); // अगर यूजर टेक्स्ट हटाता है तो लिस्ट क्लियर करें
    }
    return _buildSearchResults();
  }

  // सर्च रिजल्ट्स को दिखाने वाला मुख्य विजेट
  Widget _buildSearchResults() {
    return Obx(() {
      // 1. अगर लोडिंग हो रही है
      if (searchController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // 2. अगर यूजर ने पर्याप्त टाइप नहीं किया है
      if (query.length <= 2) {
        return const Center(
          child: Text(
            'उत्पाद, ब्रांड और बहुत कुछ खोजें...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      // 3. अगर कोई रिजल्ट नहीं मिला
      if (searchController.searchResults.isEmpty && !searchController.isLoading.value) {
        return Center(
          child: Text(
            '"$query" के लिए कोई उत्पाद नहीं मिला',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      // 4. जब रिजल्ट्स मिल जाएं (सबसे ज़रूरी हिस्सा)
      // ListView की जगह GridView.builder का इस्तेमाल करें
      return GridView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: searchController.searchResults.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          // एक लाइन में 2 कार्ड्स
          crossAxisCount: 2,
          // कार्ड्स के बीच हॉरिजॉन्टल स्पेस
          crossAxisSpacing: 12.0,
          // कार्ड्स के बीच वर्टिकल स्पेस
          mainAxisSpacing: 12.0,
          // कार्ड की चौड़ाई और ऊंचाई का अनुपात (इसे बदलकर कार्ड का लुक एडजस्ट करें)
          childAspectRatio: 0.7, // यह वैल्यू आपके रेस्पॉन्सिव कार्ड के लिए है
        ),
        itemBuilder: (context, index) {
          final product = searchController.searchResults[index];
          // आपका रेस्पॉन्सिव कार्ड विजेट
          return ProductCardForList(product: product);
        },
      );
    });
  }
}