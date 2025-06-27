import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';


import '../utils/constent.dart';

class Snakbar{
   snakbarsms(String error){
    Get.snackbar(
      "",
      error,
      margin: EdgeInsets.only(
          bottom: 30, left: 15, right: 15),
      borderRadius: 4,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kPrimaryColor,
      colorText: Colors.white,
      titleText: Text('Note', style: TextStyle(
          color: Colors.white, fontFamily: 'intel'),),
      messageText: Text(error,
        style: TextStyle(
            color: Colors.white, fontFamily: 'intel'),),
      duration: Duration(seconds: 3),
    );
  }
}