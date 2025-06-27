// lib/controller/SearchController.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:ssda/models/product_model.dart';
import 'package:ssda/services/product_service.dart';

class SearchController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<Product> searchResults = RxList<Product>([]);
  Timer? _debounce;

  // जब यूजर टाइप करना बंद कर दे, तब API कॉल करने के लिए Debounce
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().length > 2) { // 2 से अधिक अक्षर टाइप करने पर ही सर्च करें
        performSearch(query.trim());
      } else {
        searchResults.clear();
      }
    });
  }

  // सर्च करने का मुख्य फंक्शन
  Future<void> performSearch(String query) async {
    try {
      isLoading.value = true;
      final results = await ProductService.searchProducts(query);
      searchResults.assignAll(results);
    } catch (e) {
      print("SearchController Error: $e");
      Get.snackbar("Error", "Could not perform search. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // सर्च रिजल्ट्स को साफ करने के लिए
  void clearSearch() {
    searchResults.clear();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}