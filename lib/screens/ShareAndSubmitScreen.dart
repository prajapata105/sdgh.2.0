import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart'; // HapticFeedback के लिए

import 'package:ssda/utils/constent.dart';
import 'package:url_launcher/url_launcher.dart'; // आपके प्रोजेक्ट के कलर्स और कांस्टेंट्स

class ShareAndSubmitScreen extends StatefulWidget {
  final Map<String, dynamic> businessData;
  const ShareAndSubmitScreen({Key? key, required this.businessData}) : super(key: key);

  @override
  _ShareAndSubmitScreenState createState() => _ShareAndSubmitScreenState();
}

class _ShareAndSubmitScreenState extends State<ShareAndSubmitScreen> with SingleTickerProviderStateMixin {
  int _shareCount = 0;
  bool _isSubmitting = false;
  bool _isSubmissionComplete = false;

  late AnimationController _shakeAnimationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _loadShareCount();

    // वाइब्रेशन/शेक एनीमेशन के लिए कंट्रोलर और एनीमेशन सेट करें
    _shakeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _shakeAnimationController,
        curve: Curves.elasticOut,
      ),
    )..addListener(() {
      setState(() {}); // एनीमेशन के हर फ्रेम पर UI को अपडेट करें
    });
  }

  @override
  void dispose() {
    _shakeAnimationController.dispose();
    super.dispose();
  }

  void _loadShareCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _shareCount = prefs.getInt('shareCount') ?? 0;
    });
  }

  void _incrementShareCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt('shareCount') ?? 0;
    prefs.setInt('shareCount', currentCount + 1);
    _loadShareCount();
  }


// _submitForm() फ़ंक्शन को इससे बदलें
  Future<void> _submitForm() async {
    // अगर सबमिट हो रहा है या हो चुका है, तो दोबारा कुछ न करें
    if (_isSubmitting || _isSubmissionComplete) return;

    if (_shareCount < 10) {
      HapticFeedback.lightImpact();
      _shakeAnimationController.forward(from: 0.0);
      Get.snackbar('Alert', 'कृपया सबमिट करने से पहले 10 लोगों के साथ ऐप साझा करें।', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // लोडिंग शुरू करें
    setState(() {
      _isSubmitting = true;
    });

    try {
      final url = Uri.parse('https://sridungargarhone.com/wp-json/custom/v1/submit-business');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Secret-Key': 'aSdsfrdsaaasdsd@2025!#',
        },
        body: json.encode(widget.businessData),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('shareCount', 0);

        // ✅ सबसे ज़रूरी स्टेप: पहले UI को अपडेट करें
        // लोडिंग बंद करें और सबमिशन को 'complete' मार्क करें
        setState(() {
          _isSubmissionComplete = true;
          _isSubmitting = false;
        });

        // UI अपडेट होने के बाद नेविगेशन और स्नैकबार दिखाएं
        // addPostFrameCallback यह सुनिश्चित करता है कि यह कोड UI अपडेट के बाद ही चले
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Get.snackbar('धन्यवाद!', 'आपकी जानकारी 24 घंटे में जोड़ दी जाएगी।', snackPosition: SnackPosition.BOTTOM);

            // यूज़र को मैसेज पढ़ने का समय देने के लिए 1.5 सेकंड रुकें
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                Get.back(); // पहली स्क्रीन से वापस
                Get.back(); // दूसरी स्क्रीन से वापस
              }
            });
          }
        });

      } else {
        // अगर कोई सर्वर एरर आता है
        if (mounted) {
          setState(() => _isSubmitting = false);
          final errorData = json.decode(response.body);
          Get.snackbar('Error', errorData['message'] ?? 'Something went wrong');
        }
      }
    } catch (e) {
      // अगर कोई और एरर आता है
      if (mounted) {
        setState(() => _isSubmitting = false);
        Get.snackbar('Error', 'An error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = Get.height;
    final double screenWidth = Get.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: kTitleColor, size: screenWidth * 0.06),
        ),
        title: Text(
          'Add Business',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kBlackColor, fontSize: screenWidth * 0.055),
        ),
      ),
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepIndicator(0, 'विवरण', screenWidth, screenHeight),
                      _buildStepDivider(0, screenWidth, screenHeight),
                      _buildStepIndicator(1, 'शेयर', screenWidth, screenHeight),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: LinearProgressIndicator(
                      value: _shareCount / 10,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                      minHeight: screenHeight * 0.0050,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    "${(_shareCount * 10).round()}%",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: screenWidth * 0.044, fontWeight: FontWeight.bold, color: ksubprime),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'श्रीडूंगरगढ़ One ऐप में अपना व्यवसाय जोड़ने के लिए धन्यवाद।',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.05),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  // वाइब्रेट होने वाले टेक्स्ट को AnimatedBuilder में रैप करें
                  AnimatedBuilder(
                    animation: _shakeAnimationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: Column(
                          children: [
                            Text(
                              'आपका नंबर ऐप पर लाइव करने के लिए, कृपया एक आसान काम पूरा करें:',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            Text(
                              'इस ऐप को अपने 10 दोस्तों के साथ शेयर करें।',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: screenHeight * 0.2),
                            Text(
                              "नीचे शेयर बटन पर क्लिक करें",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _shareCount < 10 ? () async {
                    // व्हाट्सएप पर भेजा जाने वाला मैसेज
                    const String message = 'श्री डूंगरगढ़ की हर ज़रूरत के लिए, मैंने यह बेहतरीन ऐप खोजा है!\n\n'
                        'श्रीडूंगरगढ़ One ऐप से आप शहर की खबरें, शहर के ज़रूरी नंबर (स्थानीय संपर्क सूत्र) और किराने का सामान, सब्जी, घरेलू उत्पाद, सब कुछ एक ही जगह पा सकते हैं।\n\n'
                        'अभी डाउनलोड करें:\n'
                        'https://play.google.com/store/apps/details?id=com.sridungargarhone.cityapp';

                    // मैसेज को URL के लिए एन्कोड करें ताकि स्पेस और spéciales कैरेक्टर सही से काम करें
                    final String encodedMessage = Uri.encodeComponent(message);

                    // व्हाट्सएप का URL बनाएं
                    final Uri whatsappUri = Uri.parse('whatsapp://send?text=$encodedMessage');

                    try {
                      // यह जांच करेगा कि व्हाट्सएप इंस्टॉल है या नहीं और उसे लॉन्च करेगा
                      if (await canLaunchUrl(whatsappUri)) {
                        await launchUrl(whatsappUri);
                        // व्हाट्सएप सफलतापूर्वक खुलने के बाद शेयर काउंट बढ़ाएं
                        _incrementShareCount();
                      } else {
                        // अगर व्हाट्सएप इंस्टॉल नहीं है, तो एक मैसेज दिखाएं
                        Get.snackbar(
                          'Error',
                          'WhatsApp is not installed on this device.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    } catch (e) {
                      // कोई और एरर आने पर मैसेज दिखाएं
                      Get.snackbar(
                        'Error',
                        'Could not launch WhatsApp.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ksubprime,
                    foregroundColor: kWhiteColor,
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: screenHeight * 0.02),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025)),
                  ),
                  child: Text('ऐप शेयर करें ($_shareCount/10)', style: TextStyle(fontSize: screenWidth * 0.045)),
                ),
                SizedBox(height: screenHeight * 0.02),
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _isSubmissionComplete ? null : (_shareCount >= 10 ? _submitForm : () {
                    HapticFeedback.lightImpact();
                    _shakeAnimationController.forward(from: 0.0);
                    Get.snackbar('Alert', 'कृपया सबमिट करने से पहले 10 लोगों के साथ ऐप शेयर करें।', snackPosition: SnackPosition.TOP);
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSubmissionComplete ? Colors.grey.shade600 : (_shareCount >= 10 ? kPrimaryColor : Colors.grey.shade400),
                    foregroundColor: kWhiteColor,
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025)),
                  ),
                  child: Text(
                    _isSubmissionComplete ? 'Successfully Submitted' : 'सबमिट करें',
                    style: TextStyle(fontSize: screenWidth * 0.045),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, double screenWidth, double screenHeight) {
    bool isActive = 1 == step;
    return Column(
      children: [
        CircleAvatar(
          radius: screenWidth * 0.03,
          backgroundColor: isActive ? kPrimaryColor : Colors.grey.shade400,
          child: Text(
            '${step + 1}',
            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03),
          ),
        ),
        SizedBox(height: screenHeight * 0.005),
        Text(
          label,
          style: TextStyle(
            color: isActive ? kPrimaryColor : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int step, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.15,
      height: screenHeight * 0.002,
      color: 1 > step ? kPrimaryColor : Colors.grey.shade400,
    );
  }
}