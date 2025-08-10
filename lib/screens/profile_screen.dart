import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ssda/UI/Widgets/Organisms/cupertino_logout_dialog.dart';
import 'package:ssda/constants.dart';
import 'package:ssda/ui/widgets/atoms/list_tile.dart';

import 'Auth/PrivacyPolicyScreen.dart';
import 'Auth/TermsAndConditionsScreen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- 👇 अकाउंट डिलीट करने के लिए यह नया फंक्शन है ---
  void _showDeleteAccountDialog(BuildContext context) {
    // उपयोगकर्ता से कन्फर्मेशन के लिए एक डायलॉग दिखाएँ
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action is permanent and cannot be undone.'),
          actions: [
            // कैंसिल बटन
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            // डिलीट बटन
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop(); // डायलॉग बंद करें
                await _deleteUserAccount(context); // डिलीट फंक्शन को कॉल करें
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // --- 👇 यह फंक्शन Firebase से यूजर को डिलीट करता है ---
  Future<void> _deleteUserAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.delete();
      // सफलतापूर्वक डिलीट होने पर लॉगिन स्क्रीन पर भेजें
      // Get.offAllNamed('/login'); // अपनी लॉगिन स्क्रीन का सही रास्ता (route) यहाँ डालें
      Get.snackbar('Success', 'Your account details will be deleted within 48 hours. Do not login again for 48 hours.',
          snackPosition: SnackPosition.BOTTOM);
    } on FirebaseAuthException catch (e) {
      // अगर यूजर को हाल ही में लॉगिन किए हुए ज़्यादा समय हो गया हो
      if (e.code == "requires-recent-login") {
        Get.snackbar('Error',
            'Please log out and log in again before deleting your account.',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        // अन्य Firebase त्रुटियाँ
        Get.snackbar('Error', 'Failed to delete account: ${e.message}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      // अन्य कोई त्रुटि
      Get.snackbar('Error', 'An error occurred while deleting the account.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfileHeader(currentUser),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            _buildMenuList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileHeader(User? user) {
    return Row(
      children: [
        CircleAvatar(
          radius: Get.width * 0.08,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, size: 40, color: Colors.grey),
        ),
        SizedBox(width: Get.width * 0.04),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.displayName ?? 'Guest User',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: Get.height * 0.005),
            Text(
              user?.phoneNumber ?? 'Login to see details',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('YOUR INFORMATION',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400)),
        customListTile(
          icon: Icons.shopping_bag_outlined,
          title: 'Your Orders',
          callback: () => Get.toNamed('/orders'),
        ),
        customListTile(
          icon: Icons.location_on_outlined,
          title: 'Address Book',
          callback: () => Get.toNamed('/user/address'),
        ),
        const SizedBox(height: 16),
        const Text('OTHERS',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400)),
        customListTile(
          icon: Icons.share,
          title: 'Share the app',
          callback: () {
            // 👇 यह नया संदेश है जिसे शेयर किया जाएगा
            final String appLink = "https://play.google.com/store/apps/details?id=com.sridungargarhone.cityapp";
            final String message = "श्रीडूंगरगढ़ की हर ज़रूरत के लिए, मैंने यह बेहतरीन ऐप खोजा है!\n\n"
                "श्रीडूंगरगढ़ One ऐप से आप शहर की खबरें, शहर के ज़रूरी नंबर (स्थानीय संपर्क सूत्र) और किराने का सामान,सब्जी, घरेलू उत्पाद ,   सब कुछ एक ही जगह पा सकते हैं।\n\n"
                "अभी डाउनलोड करें:\n$appLink";

            Share.share(message, subject: "श्रीडूंगरगढ़ One App");
          },
        ),
        customListTile(
          icon: Icons.info_outline,
          title: 'About Us',
          callback: () => Get.toNamed('/app/about'),
        ),
        customListTile(
          icon: Icons.support_agent_outlined,
          title: 'Customer Care',
          callback: () => FlutterPhoneDirectCaller.callNumber("6376258319"),
        ),
        customListTile(
          icon: Icons.policy_outlined,
          title: 'Privacy Policy',
          callback: () {
            Get.to(() => const PrivacyPolicyScreen());
          },
        ),
        customListTile(
          icon: Icons.description_outlined,
          title: 'Terms & Conditions',
          callback: () {
            Get.to(() => const TermsAndConditionsScreen());
          },
        ),
        customListTile(
          icon: Icons.logout,
          title: 'Logout',
          isColorFul: true,
          callback: () => showCupertinoLogoutDialog(context),
        ),
        // --- 👇 यह नया विजेट यहाँ जोड़ दिया गया है ---
        const Divider(),
        customListTile(
          icon: Icons.delete_forever_outlined,
          title: 'Delete Account',
          isColorFul: true, // इसे लाल रंग का दिखाने के लिए
          callback: () => _showDeleteAccountDialog(context),
        ),
      ],
    );
  }

  Widget _buildIconWithLabel(
      {required String assetName, required String title}) {
    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Image.asset(assetName,
              errorBuilder: (c, o, s) => const Icon(Icons.error)),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
        ),
      ],
    );
  }
}