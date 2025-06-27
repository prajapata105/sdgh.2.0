// lib/Infrastructure/AsyncAction/async_actions.dart

import "package:dio/dio.dart"; // DioException के लिए Dio को इम्पोर्ट करें
import "package:fluttertoast/fluttertoast.dart";
import "package:flutter/material.dart"; // Fluttertoast के लिए Material को इम्पोर्ट करें (वैकल्पिक, पर अच्छी प्रैक्टिस)

import "../HttpMethods/requesting_methods.dart";

class AsyncAction {
  static Future<dynamic> asynAction({ // रिटर्न टाइप को Future<dynamic> करना बेहतर है
    required String url,            // URL को required करें
    String? methodType,
    Map<String, String>? httpHeaders, // <<<--- इसे String? से Map<String, String>? में बदला गया
    dynamic body,
    String errorMessage = "An unexpected error occurred. Please try again.", // बेहतर डिफ़ॉल्ट संदेश
    bool showToast = true,
  }) async {
    try {
      var response = await ApiService.requestMethods(
        url: url, // url अब required है ApiService में
        methodType: methodType,
        body: body,
        customHeaders: httpHeaders, // <<<--- httpHeaders को customHeaders के रूप में पास किया गया
      );
      return response;
    } on DioException catch (e) {
      // DioException से अधिक विशिष्ट जानकारी लॉग करें या दिखाएं
      String apiErrorMessage = errorMessage; // डिफ़ॉल्ट संदेश
      if (e.response?.data != null && e.response!.data is Map && e.response!.data['message'] != null) {
        apiErrorMessage = e.response!.data['message'];
      } else if (e.message != null && e.message!.isNotEmpty) {
        apiErrorMessage = e.message!;
      }

      print("DioException in AsyncAction: ${e.message}, Response: ${e.response?.data}");

      if (showToast) {
        Fluttertoast.showToast(
          msg: apiErrorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      // आप यहां एक कस्टम ऑब्जेक्ट या null भी रिटर्न कर सकते हैं, बजाय इसके कि एरर को फिर से थ्रो करें,
      // यह इस पर निर्भर करता है कि आप कॉलिंग कोड में इसे कैसे हैंडल करना चाहते हैं।
      // अभी के लिए, हम null रिटर्न करते हैं ताकि कॉलर इसे हैंडल कर सके।
      return null;
    } catch (e) {
      // अन्य सामान्य त्रुटियां
      print("Generic error in AsyncAction: $e");
      if (showToast) {
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      return null;
    }
  }
}