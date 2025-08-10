import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/UI/Widgets/common/product_screen_shimmer.dart';
import 'package:ssda/services/category_service.dart';
import 'package:ssda/ui/search/ProductSearchDelegate.dart';
import 'package:ssda/ui/widgets/organisms/bottom_cart_container.dart';
import 'package:ssda/ui/widgets/atoms/card_product_list.dart';
import 'package:ssda/app_colors.dart' show AppColors;
import 'package:ssda/models/product_model.dart';
import 'package:ssda/services/product_service.dart';
import 'package:ssda/models/category_model.dart' as app_category;
import 'package:html_unescape/html_unescape.dart';

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
  // --- इनफिनिट स्क्रॉलिंग के लिए वेरिएबल्स ---
  late Future<List<app_category.Category>> _subCategoryFuture;
  int? _selectedCategoryId;
  final HtmlUnescape unescape = HtmlUnescape();

  // उत्पादों की सूची को स्टोर करने के लिए
  final List<Product> _products = [];
  // स्क्रॉल को नियंत्रित करने के लिए
  final ScrollController _scrollController = ScrollController();
  // पेज नंबर ट्रैक करने के लिए
  int _currentPage = 1;
  // यह बताएगा कि और उत्पाद लोड हो रहे हैं या नहीं
  bool _isLoadingMore = false;
  // यह बताएगा कि क्या सर्वर पर और उत्पाद हैं
  bool _hasMoreProducts = true;
  // पहली बार लोड होने की स्थिति के लिए
  bool _isFirstLoadRunning = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    // पहली बार उत्पाद लोड करें
    _loadProductsForCategory(_selectedCategoryId);

    // सब-कैटेगरी लोड करें
    if (widget.categoryId != null) {
      _subCategoryFuture = CategoryService.getSubCategories(widget.categoryId!);
    } else {
      _subCategoryFuture = Future.value([]);
    }

    // स्क्रॉल कंट्रोलर में एक லிஸ்னர் जोड़ें
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // कंट्रोलर को हटाना न भूलें
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // जब कोई नई श्रेणी चुनी जाती है तो यह फंक्शन चलता है
  void _loadProductsForCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      // सब कुछ रीसेट करें
      _products.clear();
      _currentPage = 1;
      _hasMoreProducts = true;
      _isFirstLoadRunning = true;
    });
    // पहले पेज के उत्पाद लोड करें
    _fetchProducts();
  }

  // उत्पादों को सर्वर से लाने वाला मुख्य फंक्शन
  Future<void> _fetchProducts() async {
    // अगर कोई और लोड चल रहा है या और उत्पाद नहीं हैं, तो कुछ न करें
    if (_isLoadingMore || !_hasMoreProducts) return;

    // अगर यह पहली बार लोड नहीं हो रहा है, तो लोडिंग को true सेट करें
    if (_isFirstLoadRunning == false) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      // ProductService को पेज नंबर के साथ कॉल करें
      final newProducts = await ProductService.getProducts(
        categoryId: _selectedCategoryId?.toString(),
        page: _currentPage,
        perPage: 10, // एक बार में 10 उत्पाद लोड करें
      );

      if (newProducts.isNotEmpty) {
        setState(() {
          _products.addAll(newProducts);
          _currentPage++; // अगले पेज के लिए पेज नंबर बढ़ाएँ
        });
      } else {
        // अगर कोई नया उत्पाद नहीं मिला, तो इसका मतलब है कि और उत्पाद नहीं हैं
        setState(() {
          _hasMoreProducts = false;
        });
      }
    } catch (e) {
      // कोई त्रुटि होने परจัดการ करें
      debugPrint("Something went wrong: $e");
    }

    setState(() {
      _isLoadingMore = false;
      _isFirstLoadRunning = false;
    });
  }

  // जब उपयोगकर्ता स्क्रॉल करता है तो यह फंक्शन चलता है
  void _onScroll() {
    // जब उपयोगकर्ता 95% नीचे स्क्रॉल कर ले, तो और उत्पाद लोड करें
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.95) {
      _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          unescape.convert(widget.categoryName),
        ),
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
                          unescape.convert(cat.name),
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

  Widget _buildProductList() {
    // अगर पहली बार लोड हो रहा है, तो शिमर दिखाएँ
    if (_isFirstLoadRunning) {
      return Expanded(child: const ProductScreenShimmer());
    }
    // अगर कोई उत्पाद नहीं मिला, तो संदेश दिखाएँ
    if (_products.isEmpty) {
      return Expanded(child: const Center(child: Text('इस श्रेणी में कोई उत्पाद नहीं मिला।')));
    }

    // GridView.builder का उपयोग करें
    return Expanded(
      child: GridView.builder(
        controller: _scrollController, // स्क्रॉल कंट्रोलर जोड़ें
        padding: EdgeInsets.all(Get.width * 0.03),
        // सूची की लंबाई: उत्पादों की संख्या + 1 (लोडिंग इंडिकेटर के लिए)
        itemCount: _products.length + (_hasMoreProducts ? 1 : 0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: Get.width * 0.03,
          mainAxisSpacing: Get.width * 0.03,
          childAspectRatio: 0.60,
        ),
        itemBuilder: (context, index) {
          // अगर यह सूची का आखिरी आइटम है और और उत्पाद हैं
          if (index >= _products.length) {
            // लोडिंग इंडिकेटर दिखाएँ
            return const Center(child: CircularProgressIndicator());
          }
          // उत्पाद कार्ड दिखाएँ
          return ProductCardForList(product: _products[index]);
        },
      ),
    );
  }
}