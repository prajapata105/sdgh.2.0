import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ssda/controller/HomeController.dart';
import 'package:ssda/service/mobilenumber.dart';
import 'package:ssda/utils/constent.dart';
import '../intro-screen/homenav.dart';
import 'package:ssda/ui/widgets/organisms/home_screen_category_builder.dart';
import 'package:ssda/UI/Widgets/Organisms/category_with_products.dart';


class FirstPage extends StatefulWidget {
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final auth = FirebaseAuth.instance;
  final CarouselSliderController _carouselController = CarouselSliderController();
  final HomeController homeController = Get.find<HomeController>();

  // State Variables
  List<String> _banners = [];
  List<dynamic> allBusinessCategories = [];
  List<dynamic> visibleBusinessCategories = [];
  bool _isBusinessListExpanded = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    getFcmToken();
  }

  Future<void> fetchData() async {
    await Future.wait([fetchBannerImages(), fetchBusinessCategories()]);
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> getFcmToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      String? token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
    } catch(e) {
      print('FCM Token error: $e');
    }
  }

  Future<void> fetchBannerImages() async {
    try {
      final url = Uri.parse("https://sridungargarhone.com/wp-json/wp/v2/pages/12?acf_format=standard");
      final response = await http.get(url);
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        final raw = data['acf']?['home_banners'] ?? "";
        setState(() {
          _banners = raw.toString().split(RegExp(r'[\r\n]+')).where((url) => url.trim().isNotEmpty).toList();
        });
      }
    } catch(e) {
      print('Error fetching banners: $e');
    }
  }

  Future<void> fetchBusinessCategories() async {
    try {
      final url = Uri.parse("https://sridungargarhone.com/wp-json/wp/v2/business-category?acf_format=standard&per_page=100");
      final response = await http.get(url);
      if (response.statusCode == 200 && mounted) {
        setState(() {
          allBusinessCategories = json.decode(response.body);
          visibleBusinessCategories = allBusinessCategories.take(8).toList();
        });
      }
    } catch (e) {
      print('Error fetching business categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        title: Text(
          'श्रीडूँगरगढ़ One',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: kblue,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              decoration: BoxDecoration(
                border: Border.all(width: 1.5, color: kblue),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.person, color: Theme.of(context).iconTheme.color),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
      // 👇 बॉडी को CustomScrollView से बनाया गया है
          : CustomScrollView(
        slivers: [
          // 👇 हर सामान्य विजेट को SliverToBoxAdapter में रैप किया गया है

          // 1. Banner Slider
          if (_banners.isNotEmpty)
            SliverToBoxAdapter(
              child: CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: _banners.length,
                itemBuilder: (context, index, _) => Container(
                  margin: EdgeInsets.all(5),
                  width: w * 0.9,
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(_banners[index]),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                options: CarouselOptions(
                  height: h * 0.23,
                  viewportFraction: 1,
                  autoPlay: _banners.length > 1,
                  autoPlayInterval: Duration(seconds: 25),
                ),
              ),
            ),

          // 2. Business Directory (Mobile Numbers) Section
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(8, 16, 8, 0),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('व्यावसायिक निर्देशिका',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  SizedBox(height: 10),
                  GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: visibleBusinessCategories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final cat = visibleBusinessCategories[index];
                      final name = cat['name'];
                      final logo = cat['acf']?['logo']?['url'] ?? '';
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MobileNumbers(
                                id: cat['id'].toString(),
                                cate: cat['name'],
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: h * 0.085,
                              width: w * 0.177,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [Color(0xffe3ffe7), Color(0xffd9e7ff)],
                                ),
                              ),
                              child: Image.network(logo, fit: BoxFit.contain, errorBuilder: (_,__,___) => Icon(Icons.business)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: h * 0.018,
                                  fontWeight: FontWeight.bold,
                                  color: ksubprime.withOpacity(0.8)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isBusinessListExpanded = !_isBusinessListExpanded;
                        visibleBusinessCategories = _isBusinessListExpanded
                            ? allBusinessCategories
                            : allBusinessCategories.take(8).toList();
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 12),
                      height: h * 0.05,
                      width: w,
                      decoration: BoxDecoration(
                        border: Border.all(color: kGreyColor),
                        gradient: LinearGradient(colors: [Color(0xffe3ffe7), Color(0xffd9e7ff)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isBusinessListExpanded ? "बंद करें" : 'और देखें',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ksubprime),
                          ),
                          Icon(_isBusinessListExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Product Categories Section
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              margin:  EdgeInsets.all(6.0),

              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(30)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'उत्पाद श्रेणियाँ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ksubprime),
                    ),
                  ),
                  SizedBox(height: 10),
                  HomeScreenCateogoryWidget(),
                ],
              ),
            ),
          ),

          // 4. Dynamic Sections from HomeController
          // 👇 यहाँ Obx को सीधे स्लाइवर लिस्ट में इस्तेमाल किया गया है
          Obx(() {
            // क्योंकि homeController.homeSections एक लिस्ट है, हमें इसे एक-एक करके देखना होगा
            // लेकिन यहाँ हम मान रहे हैं कि यह एक ही सेक्शन दिखाएगा या फिर हमें लूप करना होगा
            if (homeController.homeSections.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            // हम सिर्फ एक उदाहरण ले रहे हैं, आपको शायद यहाँ लूप लगाना पड़े
            final section = homeController.homeSections.first; // Example for one section

            if (section.isLoading.value) {
              return SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )),
              );
            }
            if (section.products.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            // CatgorywithProducts अब सीधे यहाँ इस्तेमाल किया जा सकता है क्योंकि यह एक Sliver है
            // और हम CustomScrollView के अंदर हैं।
            return CatgorywithProducts(
              title: section.title,
              products: section.products,
              categoryId: section.type == 'category' ? int.tryParse(section.value) : null,
              categoryName: section.title,
            );
          }),


          // 5. Bottom Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.to(() => HomeNav(index: 1)),
                      child: Container(
                        height: h * 0.08,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Color(0xffD16BA5), Color(0xff86A8E7), Color(0xff5FFBF1)],
                          ),
                        ),
                        child: Center(
                          child: Text('ताज़ा ख़बर देखे',
                              style: TextStyle(
                                  color: kWhiteColor,
                                  fontSize: h * 0.03,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.to(() => HomeNav(index: 3)),
                      child: Container(
                        height: h * 0.08,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Color(0xffD16BA5), Color(0xff86A8E7), Color(0xff5FFBF1)],
                          ),
                        ),
                        child: Center(
                          child: Text('आज का मंडी भाव',
                              style: TextStyle(
                                  color: kWhiteColor,
                                  fontSize: h * 0.03,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}