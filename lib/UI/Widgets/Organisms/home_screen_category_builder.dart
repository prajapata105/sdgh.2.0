import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/models/category_model.dart';
import 'package:ssda/services/category_service.dart';
import 'package:ssda/screens/products_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreenCateogoryWidget extends StatefulWidget {
  const HomeScreenCateogoryWidget({super.key});

  @override
  State<HomeScreenCateogoryWidget> createState() => _HomeScreenCateogoryWidgetState();
}

class _HomeScreenCateogoryWidgetState extends State<HomeScreenCateogoryWidget> {
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CategoryService.getMainCategories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerGrid();
        }
        else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No categories found."));
        }
        else {
          final categories = snapshot.data!;
          // <<<--- बदलाव यहाँ: अब यह SliverGrid की जगह GridView.builder लौटाएगा ---<<<
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 12.0,
              childAspectRatio: 0.5, // आपका पसंदीदा साइज़
            ),
            itemCount: categories.length > 8 ? 8 : categories.length,
            itemBuilder: (BuildContext context, int index) {
              return _CategoryIcon(category: categories[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 12.0,
        childAspectRatio: 0.5,
      ),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 10,
              width: Get.width * 0.15,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
      itemCount: 8,
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final Category category;
  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => ProductsScreen(
          categoryName: category.name,
          categoryId: category.id,
        ));
      },
      borderRadius: BorderRadius.circular(10),
      child: Column(
        children: [
          // <<<--- बदलाव यहाँ: इमेज कंटेनर को Expanded में लपेटा गया ---<<<
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xffF0F4F8), Color(0xffE6E9F0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.grey.shade200, width: 0.5)
              ),
              child: Image.network(
                category.imageUrl ?? '',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.category_outlined, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // <<<--- बदलाव यहाँ: टेक्स्ट को Flexible में लपेटा गया ---<<<
          Flexible(
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Get.width * 0.037, // Responsive फॉन्ट साइज
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
