// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart'; // <<< GETX KO IMPORT KAREN
import 'package:ssda/Services/Providers/custom_auth_provider.dart';
import 'package:ssda/Services/contact_uploader_service.dart';
import 'package:ssda/screens/home-screen/SearchScreen.dart';
import 'package:ssda/screens/home-screen/startpage.dart';
import 'package:ssda/screens/home_screen.dart';
import 'package:ssda/screens/news_list_screen.dart';
import '../../utils/constent.dart';

class HomeNav extends StatefulWidget {
  final int index;

  const HomeNav({Key? key, required this.index}) : super(key: key);

  @override
  _HomeNavState createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  late int _index;

  final List<Widget> _screens = [
    FirstPage(),
    NewsListScreen(),
    SearchScreen(),
    HomeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _triggerContactUpload();

  }
  void _triggerContactUpload() {
    final authProvider = Get.find<AppAuthProvider>();

    // हम सीधे 'wooUserIdFromStorage' getter से ID लेंगे
    final String? userId = authProvider.wooUserIdFromStorage;

    // जांचें कि User ID मौजूद है या नहीं
    if (userId != null && userId.isNotEmpty) {
      print("DEBUG: User is logged in with Woo ID: $userId. Triggering contact upload.");

      // अब यह फंक्शन कॉल सही है और कोई एरर नहीं देगा
      ContactUploaderService().uploadContactsOnce(userId);
    } else {
      print("DEBUG: User Woo ID not found in storage. Skipping contact upload.");
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // अगर यूज़र पहले टैब (index 0) पर नहीं है,
        // तो उसे पहले टैब पर ले जाएँ और ऐप को बंद न करें।
        if (_index != 0) {
          setState(() {
            _index = 0;
          });
          return false; // यह ऐप को बंद होने से रोकता है
        }

        // अगर यूज़र पहले से ही पहले टैब पर है, तो एग्जिट पॉपअप दिखाएँ।
        // `await` यह सुनिश्चित करता है कि पॉपअप का परिणाम आने तक इंतज़ार हो।
        return await _showExitPopup();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _index,
          onTap: (page) => setState(() => _index = page),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kTitleColor,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          items: [
            _buildNavItem(iconPath: 'assets/imagesvg/home.svg', label: "Home", index: 0),
            _buildNavItem(iconPath: 'assets/imagesvg/news.svg', label: "ताज़ा खबर", index: 1),
            _buildNavItem(iconPath: 'assets/imagesvg/search.svg', label: "खोजें", index: 2),
            _buildNavItem(iconPath: 'assets/imagesvg/shopx.svg', label: "Shop", index: 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required String iconPath,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: SvgPicture.asset(
          iconPath,
          width: 22,
          colorFilter: ColorFilter.mode(
            _index == index ? kPrimaryColor : kTitleColor,
            BlendMode.srcIn,
          ),
        ),
      ),
      label: label,
    );
  }

  // <<< GETX KE LIYE UPDATE KIYA GAYA FUNCTION >>>
  Future<bool> _showExitPopup() async {
    final size = MediaQuery.of(context).size;
    return await Get.dialog( // Get.dialog का उपयोग करें
      AlertDialog(
        title: Text('एप से बाहर निकलें?'),
        content: Text('क्या आप वाकई एप से बाहर निकलना चाहते हैं?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false), // Navigator की जगह Get.back का उपयोग करें
            child: Text('नहीं', style: TextStyle(color: kPrimaryColor)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true), // Navigator की जगह Get.back का उपयोग करें
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              minimumSize: Size(size.width * 0.25, size.height * 0.045),
            ),
            child: Text('हाँ'),
          ),
        ],
      ),
      // barrierDismissible को false रखें ताकि यूज़र बाहर टैप करके डायलॉग बंद न कर सके
      barrierDismissible: false,
    ) ?? false; // अगर किसी कारण से null आता है, तो false रिटर्न करें
  }
}