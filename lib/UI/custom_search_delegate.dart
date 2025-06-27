// lib/UI/custom_search_delegate.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// SearchController को एक उपनाम (alias) दें ताकि Flutter के SearchController से कनफ्लिक्ट न हो
import 'package:ssda/controller/SearchController.dart' as app_search;
import 'package:ssda/UI/Widgets/Atoms/card_product_list.dart'; // आपका प्रोडक्ट कार्ड विजेट
import 'package:ssda/models/product_model.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  // Get.put() सुनिश्चित करता है कि सर्च UI के लिए एक नया कंट्रोलर इंस्टेंस बने
  final app_search.SearchController searchController = Get.put(app_search.SearchController());

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

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // जब यूजर कीबोर्ड पर एंटर दबाता है तो तुरंत सर्च करें
    if (query.trim().length > 2) {
      searchController.performSearch(query);
    }
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // हर बार टाइप करने पर सर्च करें (debouncing के साथ)
    searchController.onSearchChanged(query);
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (searchController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (query.length <= 2) {
        return const Center(
          child: Text(
            'Search for products, brands and more...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }
      if (searchController.searchResults.isEmpty) {
        return Center(
          child: Text(
            'No products found for "$query"',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }
      return ListView.builder(
        itemCount: searchController.searchResults.length,
        itemBuilder: (context, index) {
          final Product product = searchController.searchResults[index];
          // आपके मौजूदा प्रोडक्ट कार्ड का पुनः उपयोग करें
          return ProductCardForList(product: product);
        },
      );
    });
  }
}