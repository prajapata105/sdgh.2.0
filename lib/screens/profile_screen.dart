import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ssda/constants.dart';
import 'package:ssda/ui/widgets/atoms/list_tile.dart';
import 'package:ssda/ui/widgets/organisms/cupertino_logout_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        const Text('YOUR INFORMATION', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400)),
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
        const Text('OTHERS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400)),
        customListTile(
          icon: Icons.share,
          title: 'Share the app',
          callback: () => Share.share('Check out this awesome grocery app!', subject: "Grocery App"),
        ),
        customListTile(
          icon: Icons.info_outline,
          title: 'About Us',
          callback: () => Get.toNamed('/app/about'),
        ),
        customListTile(
          icon: Icons.logout,
          title: 'Logout',
          isColorFul: true,
          callback: () => showCupertinoLogoutDialog(context),
        ),
      ],
    );
  }

  // <<<--- यह मिसिंग मेथड यहाँ जोड़ दिया गया है ---<<<
  Widget _buildIconWithLabel({required String assetName, required String title}) {
    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Image.asset(assetName, errorBuilder: (c, o, s) => const Icon(Icons.error)),
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