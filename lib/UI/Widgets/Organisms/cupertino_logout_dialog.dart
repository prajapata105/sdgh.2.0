import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/Services/Providers/custom_auth_provider.dart'; // आपका AuthProvider
import '../../../app_colors.dart';

/// यह फंक्शन डायलॉग को दिखाता है और लॉगआउट का पूरा फ्लो हैंडल करता है।
Future<void> showCupertinoLogoutDialog(BuildContext context) {
  // GetX की मदद से अपने AuthProvider को खोजें
  final authProvider = Get.find<AppAuthProvider>();

  return showCupertinoDialog(
    context: context,
    builder: (BuildContext dialogContext) { // <<<--- context का नाम बदला ताकि कन्फ्यूजन न हो
      // नीचे बनाई गई प्राइवेट विजेट को यहाँ कॉल करें
      return _CupertinoLogoutDialog(
        // <<<--- लॉगआउट का असली काम अब यहाँ से हो रहा है ---<<<
        onLogoutConfirmed: () async {
          try {
            // सबसे पहले डायलॉग को बंद करें
            Navigator.of(dialogContext).pop();

            // अब AuthProvider से लॉगआउट का लॉजिक चलाएं
            await authProvider.logout();

            // लॉगआउट सफल होने पर यूजर को स्प्लैश स्क्रीन ('/') पर भेजें
            // और पुरानी सभी स्क्रीन्स को हटा दें
            Get.offAllNamed('/');

          } catch (e) {
            // अगर लॉगआउट में कोई एरर आता है, तो यूजर को मैसेज दिखाएं
            Get.snackbar(
              'Logout Failed',
              'An error occurred. Please try again.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      );
    },
  );
}

/// यह एक प्राइवेट विजेट है जिसका काम सिर्फ UI दिखाना है।
class _CupertinoLogoutDialog extends StatelessWidget {
  final VoidCallback onLogoutConfirmed;

  const _CupertinoLogoutDialog({required this.onLogoutConfirmed});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Logout'),
      content: const Text(
        '\nAre you sure you want to logout?',
        style: TextStyle(color: Colors.black54, fontSize: 14),
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('Cancel', style: TextStyle(color: AppColors.primaryGreenColor)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: onLogoutConfirmed,
          child: const Text('Logout'),
        ),
      ],
    );
  }
}