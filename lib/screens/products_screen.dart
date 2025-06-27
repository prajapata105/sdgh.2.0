import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/UI/Widgets/common/product_screen_shimmer.dart';
import 'package:ssda/services/category_service.dart';
import 'package:ssda/ui/search/ProductSearchDelegate.dart';
import 'package:ssda/ui/widgets/organisms/bottom_cart_container.dart';
import 'package:ssda/ui/widgets/atoms/card_product_list.dart'; // आपका नया कार्ड
import 'package:ssda/app_colors.dart' show AppColors;
import 'package:ssda/models/product_model.dart';
import 'package:ssda/services/product_service.dart';
import 'package:ssda/models/category_model.dart' as app_category;

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    super.key,
    required this.categoryName,
    this.categoryId,
  });

  final String categoryName;
  final int? categoryId;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Future<List<Product>> _productsFuture;
  late Future<List<app_category.Category>> _subCategoryFuture;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _loadProductsForCategory(_selectedCategoryId);

    if (widget.categoryId != null) {
      _subCategoryFuture = CategoryService.getSubCategories(widget.categoryId!);
    } else {
      _subCategoryFuture = Future.value([]);
    }
  }

  void _loadProductsForCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _productsFuture = ProductService.getProducts(categoryId: categoryId?.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch<String>(context: context, delegate: ProductSearchDelegate()),
          ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubCategoryList(),
              const VerticalDivider(width: 1, thickness: 1),
              _buildProductList(),
            ],
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomStickyContainer(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryList() {
    return FutureBuilder<List<app_category.Category>>(
      future: _subCategoryFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        final subCategories = snapshot.data!;
        return SizedBox(
          width: Get.width * 0.20,
          child: ListView.builder(
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final cat = subCategories[index];
              final isSelected = cat.id == _selectedCategoryId;
              return GestureDetector(
                onTap: () => _loadProductsForCategory(cat.id),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: Get.height * 0.015),
                  color: isSelected ? AppColors.primaryGreenColor.withOpacity(0.1) : Colors.white,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: Get.width * 0.07,
                        backgroundColor: AppColors.greyWhiteColor,
                        backgroundImage: cat.imageUrl != null && cat.imageUrl!.isNotEmpty ? NetworkImage(cat.imageUrl!) : null,
                        child: (cat.imageUrl == null || cat.imageUrl!.isEmpty) ? const Icon(Icons.category_outlined, color: Colors.grey) : null,
                      ),
                      SizedBox(height: Get.height * 0.008),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          cat.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Get.width * 0.03,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primaryGreenColor : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // यह मेथड अब GridView का इस्तेमाल करता है
  Widget _buildProductList() {
    return Expanded(
      child: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ProductScreenShimmer();
          }
          if (snapshot.hasError) {
            return Center(child: Text('एक त्रुटि हुई: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('कोई उत्पाद नहीं मिला।'));
          }
          final products = snapshot.data!;

          return GridView.builder(
            padding: EdgeInsets.all(Get.width * 0.03),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: Get.width * 0.03,
              mainAxisSpacing: Get.width * 0.03,
              childAspectRatio: 0.60, // <<<--- इस वैल्यू को एडजस्ट करके डिजाइन परफेक्ट करें
            ),
            itemBuilder: (context, index) {
              return ProductCardForList(product: products[index]);
            },
          );
        },
      ),
    );
  }
}