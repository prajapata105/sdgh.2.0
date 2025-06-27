// lib/UI/Widgets/Organisms/home_screen_search_bar.dart
import 'package:flutter/material.dart';
import 'package:ssda/UI/Search/ProductSearchDelegate.dart';
import 'package:ssda/utils/constent.dart'; // <<<--- नया सर्च डेलीगेट इम्पोर्ट करें

class HomeScreenSearchBar extends StatelessWidget {
  const HomeScreenSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Flutter का बिल्ट-इन सर्च UI दिखाएं
        showSearch(
          context: context,
          delegate: ProductSearchDelegate(),
        );
      },
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.search, color: kblue),
              const SizedBox(width: 10),
              Text(
                "Search for products...",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}