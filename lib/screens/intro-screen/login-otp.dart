import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/Services/WooUserMapper.dart';
import 'package:ssda/utils/constent.dart';
import 'package:ssda/weight/snapkbar.dart';
import 'homenav.dart';
import 'login-mobile-number.dart';
class OtpScreen extends StatefulWidget {
  final String verfyid;
  OtpScreen({super.key, required this.verfyid});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final auth = FirebaseAuth.instance;
  Snakbar snakbar = Snakbar();
  bool _loading = false;
  var size, w, h;

  Future<void> _onOtpVerified(UserCredential cred) async {
    // 👇👇👇 Woo User Mapping Logic 👇👇👇
    final user = cred.user;
    if (user != null) {
      final phone = user.phoneNumber?.replaceAll("+91", "") ?? "";
      // यहाँ आप चाहें तो नाम ले सकते हैं (अभी empty)
      final wooUserId = await WooUserMapper.mapFirebaseToWooUser(
        phone: phone,
        name: "",
      );
      // Optional: For debug
      print("WooUserId mapped: $wooUserId");
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    h = size.height;
    w = size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: w * 0.03, right: w * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h * 0.05),
                Text('Verification Code', style: Maintital),
                SizedBox(height: h * 0.001),
                Text('We have sent the verification code to', style: smalltital),
                SizedBox(height: h * 0.02),
                Row(
                  children: [
                    Text(
                      '+91${MobileNumber.phonenumber}',
                      style: const TextStyle(
                          fontSize: 15,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(width: w * 0.02),
                    InkWell(
                      onTap: () => Get.back(),
                      child: Text(
                        "Change Phone number?",
                        style: const TextStyle(
                            fontSize: 15,
                            color: kBlackColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.1),

                /// 🔁 OTP TextField
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "Enter 6-digit OTP",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: kPrimaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: kPrimaryColor),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.03),
                SizedBox(height: h * 0.14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ---- Resend Button UI ----
                    Container(
                      alignment: Alignment.center,
                      height: h * 0.062,
                      width: w * 0.40,
                      decoration: BoxDecoration(
                        color: ksubprime,
                        boxShadow: [
                          BoxShadow(color: kPrimaryColor, blurRadius: 7)
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Resend',
                        style: TextStyle(
                            color: kWhiteColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      ),
                    ),
                    // ---- Confirm Button ----
                    InkWell(
                      onTap: _loading
                          ? null
                          : () async {
                        final otp = _otpController.text.trim();
                        if (otp.length != 6) {
                          snakbar.snakbarsms('कृपया 6 अंकों का सही OTP डालें');
                          return;
                        }
                        setState(() => _loading = true);
                        try {
                          final credential = PhoneAuthProvider.credential(
                              verificationId: widget.verfyid,
                              smsCode: otp);
                          UserCredential cred =
                          await auth.signInWithCredential(credential);

                          // 👇 Woo User Mapping after OTP verified 👇
                          await _onOtpVerified(cred);

                          // Home
                          Get.offAll(() => HomeNav(index: 0));
                        } catch (e) {
                          snakbar.snakbarsms('ओटीपी गलत है या Expired हो गया');
                        } finally {
                          setState(() => _loading = false);
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: h * 0.062,
                        width: w * 0.40,
                        decoration: BoxDecoration(
                          boxShadow: [
                            const BoxShadow(
                                color: kPrimaryColor, blurRadius: 7)
                          ],
                          color: ksubprime,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _loading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Confirm',
                          style: TextStyle(
                              color: kWhiteColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// TODO Implement this library.