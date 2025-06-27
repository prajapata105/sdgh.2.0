import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ssda/service/mobilenumber.dart';
import 'package:ssda/utils/constent.dart';
import '../intro-screen/homenav.dart';

class FirstPage extends StatefulWidget {
  static bool openlist = true;
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final auth = FirebaseAuth.instance;
  final CarouselSliderController _carouselController = CarouselSliderController();


  List<String> _banners = [];
  List<dynamic> allCategories = [];
  List<dynamic> visibleCategories = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await Future.wait([fetchBannerImages(), fetchCategories()]);
    setState(() => isLoading = false);
  }
  Future<void> getFcmToken() async {
    // (iOS के लिए notification permission लें)
    await FirebaseMessaging.instance.requestPermission();

    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
  }
  Future<void> fetchBannerImages() async {
    final url = Uri.parse("https://sridungargarhone.com/wp-json/wp/v2/pages/12?acf_format=standard");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final raw = data['acf']?['home_banners'] ?? "";
      final List<String> banners = raw
          .toString()
          .split(RegExp(r'[\r\n]+'))
          .where((url) => url.trim().isNotEmpty)
          .toList();
      _banners = banners;
    }
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse("https://sridungargarhone.com/wp-json/wp/v2/business-category?acf_format=standard&per_page=100");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      allCategories = json.decode(response.body);
      visibleCategories = allCategories.take(8).toList();
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
        title: InkWell(
          onTap: () {
          },
          child: Text(
            'श्रीडूँगरगढ़ One',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: kblue,

              fontSize: 22,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1.5,
                  color: kblue,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],

      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Banner Slider
            CarouselSlider.builder(
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
                autoPlayAnimationDuration: Duration(seconds: 2),
              ),
            ),
            SizedBox(height: h * 0.02),

            // Business Category Grid
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('श्रेणी के अनुसार खोजें',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: visibleCategories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final cat = visibleCategories[index];
                      final name = cat['name'];
                      final logo = cat['acf']?['logo']?['url'] ?? '';
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MobileNumbers(
                                id: visibleCategories[index]['id'].toString(),     // category ID
                                cate: visibleCategories[index]['name'],            // category Name
                              ),
                            ),
                          );
                          // implement navigation to MobileNumbers
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // 👈 Add this line
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
                              child: Image.network(logo, fit: BoxFit.contain),
                            ),
                            SizedBox(height: 4),
                            Text(name,
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

                  // Button: Show More / Hide
                  InkWell(
                    onTap: () {
                      setState(() {
                        FirstPage.openlist = !FirstPage.openlist;
                        visibleCategories = FirstPage.openlist
                            ? allCategories.take(8).toList()
                            : allCategories;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 12),
                      height: h * 0.05,
                      width: w * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(color: kGreyColor),
                        gradient: LinearGradient(
                            colors: [Color(0xffe3ffe7), Color(0xffd9e7ff)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            FirstPage.openlist
                                ? 'और मोबाइल नंबर देखें'
                                : "बंद करें",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ksubprime),
                          ),
                          Icon(FirstPage.openlist
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Buttons
            Padding(
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
                          child: Text('ताज़ा ख़बर देखे',
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
            )
          ],
        ),
      ),
    );
  }
}
