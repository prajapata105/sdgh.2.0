import 'package:flutter/material.dart';
import 'package:ssda/models/category_model.dart';

class CategoryWidget extends StatelessWidget {
  final Category category;

  const CategoryWidget({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        category.imageUrl != null
            ? Image.network(category.imageUrl!, height: 50, width: 50)
            : const Icon(Icons.image_not_supported, size: 50),
        const SizedBox(height: 5),
        Text(
          category.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
