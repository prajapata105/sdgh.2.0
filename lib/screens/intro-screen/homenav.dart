// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ssda/screens/home-screen/SearchScreen.dart';
import 'package:ssda/screens/home-screen/startpage.dart';
import 'package:ssda/screens/home_screen.dart';
import 'package:ssda/screens/news_list_screen.dart';
import '../../utils/constent.dart';
import '../../utils/contactutil.dart';


class HomeNav extends StatefulWidget {
  final int index;

  const HomeNav({Key? key, required this.index}) : super(key: key);

  @override
  _HomeNavState createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  late double w, h;
  late int _index;
  int uploadCount = 0;

  List widgets = <Widget>[
    FirstPage(),
    SearchScreen(),
    HomeScreen(),
    NewsListScreen()
  ];

  @override
  void initState() {
    super.initState();
    if (uploadCount == 0) {

      uploadContacts();
    }
    _index = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    h = size.height;
    w = size.width;

    return WillPopScope(
      onWillPop: showExitPopup,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: widgets.elementAt(_index),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 20,
          backgroundColor: Colors.white,
          currentIndex: _index,
          type: BottomNavigationBarType.fixed,
          selectedIconTheme: IconThemeData(color: kPrimaryColor),
          unselectedIconTheme: IconThemeData(color: kGreyColor),
          selectedLabelStyle: TextStyle(
              fontSize: 12, color: kPrimaryColor, fontWeight: FontWeight.w400),
          unselectedLabelStyle: TextStyle(fontSize: 12, color: kGreyColor),
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kTitleColor,
          onTap: (page) => setState(() => _index = page),
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: SvgPicture.asset(
                  'assets/imagesvg/home.svg',
                  width: 20,
                  color: _index == 0 ? kPrimaryColor : kTitleColor,
                ),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: SvgPicture.asset(
                  'assets/imagesvg/news.svg',
                  width: 20,
                  color: _index == 1 ? kPrimaryColor : kTitleColor,
                ),
              ),
              label: "ताज़ा खबर",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: SvgPicture.asset(
                  'assets/imagesvg/search.svg',
                  width: 18,
                  color: _index == 2 ? kPrimaryColor : kTitleColor,
                ),
              ),
              label: "खोजें",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3.0),
                child: SvgPicture.asset(
                  'assets/imagesvg/agro.svg',
                  width: 20,
                  color: _index == 3 ? kPrimaryColor : kTitleColor,
                ),
              ),
              label: "मंडी भाव",
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.highlight_off_rounded, color: Colors.red),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        contentPadding: EdgeInsets.all(20),
        actionsAlignment: MainAxisAlignment.spaceAround,
        title: Text('एप से बाहर निकलें ?'),
        content: Text(
          'क्या आप एप से बाहर निकलना चाहते हैं',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kWhiteColor,
              side: BorderSide(color: kPrimaryColor),
              minimumSize: Size(w * 0.3, h * 0.047),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            child: Text('हाँ', style: TextStyle(fontSize: 18, color: ksubprime)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              minimumSize: Size(w * 0.3, h * 0.047),
            ),
            child: Text('नहीं', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<void> uploadContacts() async {

  }
  

  
  
}


