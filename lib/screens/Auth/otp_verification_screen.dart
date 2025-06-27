import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssda/UI/Widgets/Atoms/custom_text_field.dart';
import 'package:ssda/app_colors.dart' show AppColors;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ssda/Services/Providers/custom_auth_provider.dart' as myAuth;
import 'package:ssda/services/Providers/custom_auth_provider.dart';

import '../../services/Providers/custom_auth_provider.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key, this.data});
  final dynamic data;

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late TextEditingController _otpController;
  int _secondsRemaining = 30;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _startTimer();
  }

  Future<void> _verifyOTP(BuildContext context, String value) async {
    try {
      String verificationId = widget.data['verificationId'];
      String smsCode = value;
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      // Firebase Auth sign in
      UserCredential cred = await FirebaseAuth.instance.signInWithCredential(credential);

      // अब alias के साथ:
      await myAuth.AppAuthProvider().onOtpVerified(cred);

      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verification Failed: ${e.toString()}")),
      );
    }
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_secondsRemaining == 1) {
          timer.cancel();
          setState(() {});
        } else {
          setState(() {
            _secondsRemaining--;
          });
        }
      },
    );
  }

  void _restartTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _secondsRemaining = 30;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP verification'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("We've sent a verification code to "),
              Text(
                "+91 ${widget.data['phoneNumber']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text("Enter the code below to verify your account"),
              const SizedBox(height: 10),
              customTextField(
                hintText: "Please enter OTP",
                isPhoneNumberField: true,
                maxLength: 6,
                textEditingController: _otpController,
                onFieldSubmitted: (value) {
                  _verifyOTP(context, value!);
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _timer.isActive
                  ? Text(
                'Resend OTP in $_secondsRemaining',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
                  : TextButton(
                onPressed: _restartTimer,
                child: const Text(
                  "Resend OTP",
                  style: TextStyle(
                    color: AppColors.primaryGreenColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
