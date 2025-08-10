// Path: lib/screens/intro-screen/login-mobile-number.dart
// WHAT TO DO: Replace the entire content of your login file with this code.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ssda/screens/Auth/PrivacyPolicyScreen.dart';
import 'package:ssda/screens/Auth/TermsAndConditionsScreen.dart';
import 'package:ssda/utils/constent.dart';
import '../../weight/snapkbar.dart';
import 'login-otp.dart';

class MobileNumber extends StatefulWidget {
  const MobileNumber({Key? key}) : super(key: key);
  static String phonenumber = '';
  @override
  State<MobileNumber> createState() => _MobileNumberState();
}

class _MobileNumberState extends State<MobileNumber> {
  final TextEditingController _mobilenumber = TextEditingController();
  final auth = FirebaseAuth.instance;
  final formGlobalKey = GlobalKey<FormState>();
  Snakbar snakbar = Snakbar();
  bool loding = false;
  bool _isChecked = false;
  var size, w, h;

  // Ab _launchURL function ki zaroorat nahi hai.

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
            padding: EdgeInsets.symmetric(vertical: h * 0.02, horizontal: w * 0.04),
            child: Form(
              key: formGlobalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Aapka image wala code waisa hi rahega...
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('loginscreen').snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.active) {
                          if (snapshot.hasData && snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                            Map<String, dynamic> bannners = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                            return SizedBox(
                              height: h * 0.2,
                              width: w * 1,
                              child: SvgPicture.network(bannners['image'].toString(), fit: BoxFit.contain),
                            );
                          } else {
                            return SizedBox(height: h * 0.2);
                          }
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      }),
                  SizedBox(height: h * 0.04),
                  Text('Phone Verification', style: Maintital),
                  SizedBox(height: h * 0.05),
                  Text('We need to register your phone number before getting started !', style: Subtital),
                  Padding(
                    padding: EdgeInsets.only(top: h * 0.05, bottom: h * 0.01),
                    child: Container(
                      height: h * 0.06,
                      decoration: BoxDecoration(border: Border.all(width: 1, color: ksubprime), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          CountryCodePicker(initialSelection: 'IN', enabled: false, padding: EdgeInsets.zero),
                          const Text("|", style: TextStyle(fontSize: 33, color: ksubprime)),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              inputFormatters: [LengthLimitingTextInputFormatter(10), FilteringTextInputFormatter.digitsOnly],
                              controller: _mobilenumber,
                              validator: (val) {
                                if (val == null || val.length != 10) {
                                  return 'Please enter a valid 10-digit number';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                MobileNumber.phonenumber = value;
                              },
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(border: InputBorder.none, hintText: "Phone Number"),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                  // <<<--- BADLAV YAHAN KIYA GAYA HAI ---<<<
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    Get.to(() => const TermsAndConditionsScreen());
                                  },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                  // <<<--- BADLAV YAHAN KIYA GAYA HAI ---<<<
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    Get.to(() => const PrivacyPolicyScreen());
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  InkWell(
                    onTap: () async {
                      if (formGlobalKey.currentState!.validate()) {
                        if (!_isChecked) {
                          snakbar.snakbarsms('Please accept the Terms and Privacy Policy.');
                          return;
                        }

                        setState(() {
                          loding = true;
                        });

                        try {
                          await auth.verifyPhoneNumber(
                            phoneNumber: "+91${_mobilenumber.text}",
                            verificationCompleted: (PhoneAuthCredential credential) {
                              if (mounted) setState(() { loding = false; });
                            },
                            verificationFailed: (FirebaseAuthException e) {
                              if (mounted) {
                                snakbar.snakbarsms('Verification Failed: ${e.message}');
                                setState(() { loding = false; });
                              }
                            },
                            codeSent: (String verification, int? token) {
                              if (mounted) {
                                setState(() { loding = false; });
                                snakbar.snakbarsms('ओटीपी भेज दिया गया है');
                                Get.off(OtpScreen(verfyid: verification));
                              }
                            },
                            codeAutoRetrievalTimeout: (String verification) {
                              if (mounted) setState(() { loding = false; });
                            },
                          );
                        } catch (e) {
                          if (mounted) {
                            snakbar.snakbarsms('An unexpected error occurred. Please try again.');
                            setState(() { loding = false; });
                          }
                        }
                      }
                    },
                    child: Center(
                      child: Container(
                        alignment: Alignment.center,
                        height: h * 0.06,
                        width: w * 1,
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: _isChecked ? kPrimaryColor : Colors.grey, blurRadius: 4)],
                          color: _isChecked ? ksubprime : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: loding
                            ? const CircularProgressIndicator(color: kPrimaryColor)
                            : const Text('Send OTP', style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
