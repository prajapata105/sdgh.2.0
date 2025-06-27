import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/controller/Splesh_controller.dart';

class SplaseScreen extends StatelessWidget {
  const SplaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // कंट्रोलर को इनिशियलाइज़ करें, यह अपने आप अपना काम शुरू कर देगा
    Get.put(SplashController());
    final size = MediaQuery.of(context).size;
    final h = size.height;

    return Scaffold(
      backgroundColor: const Color(0xff161C29),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Center(child: Image.asset('assets/imagesvg/logoSdghone.png')),
            const Spacer(),
            const Text(
              'श्री डूंगरगढ़ हमारा शहर',
              style: TextStyle(fontSize: 19, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
            SizedBox(height: h * 0.05),
          ],
        ),
      ),
    );
  }
}