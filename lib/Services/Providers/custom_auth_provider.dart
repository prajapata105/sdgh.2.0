import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // <<<--- Context के लिए इम्पोर्ट करें
import 'package:get/get.dart';         // <<<--- GetX के लिए इम्पोर्ट करें
import 'package:get_storage/get_storage.dart';
import 'package:ssda/Services/notification_service.dart';
import 'package:ssda/services/WooUserMapper.dart';

// फाइल के नाम के अनुसार क्लास का नाम CustomAuthProvider रखना बेस्ट प्रैक्टिस है
class AppAuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final box = GetStorage();
  bool get isUserLoggedIn => box.read('wooUserId') != null;
  String? wooUserId;

  /// वर्तमान में लॉग-इन फायरबेस यूजर की जानकारी देता है
  User? get currentUser => _auth.currentUser;

  /// लोकल स्टोरेज से wooUserId देता है
  String? get wooUserIdFromStorage => box.read('wooUserId');


  // --- Methods ---

  /// OTP वेरिफिकेशन के बाद Woo-commerce यूजर बनाता/मैप करता है
  Future<void> onOtpVerified(UserCredential cred) async {
    String firebaseUid = cred.user!.uid;
    String phone = cred.user!.phoneNumber!;
    wooUserId = await WooUserMapper.mapFirebaseToWooUser(phone: firebaseUid, name: phone);
    await box.write('wooUserId', wooUserId);
    await NotificationService().refreshTokenAndSendToServer();

  }

  /// <<<--- यह है अपडेट किया हुआ Logout मेथड ---<<<
  /// इसका काम सिर्फ लॉगआउट का लॉजिक चलाना है, पेज बदलना नहीं।
  Future<void> logout() async {
    try {
      // Firebase से साइन आउट करें
      await _auth.signOut();

      // लोकल स्टोरेज से यूजर का डेटा साफ़ करें
      await box.remove('wooUserId');
      wooUserId = null;
      print("User logged out and local data cleared.");

    } catch (e) {
      print("Error during logout: $e");
      // अगर कोई एरर आए तो उसे दोबारा थ्रो करें ताकि UI उसे हैंडल कर सके
      throw Exception('Logout Failed: $e');
    }
  }

  // <<<--- यह मेथड भी जोड़ें ताकि प्रोफाइल स्क्रीन में यूजर की जानकारी मिल सके ---<<<
  Future<User?> getLoggedInUser() async {
    return _auth.currentUser;
  }
}