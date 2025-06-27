import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderGiftCard extends StatelessWidget {
  const OrderGiftCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/cart/gift"),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0)
        ),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard, color: Colors.orangeAccent),
            SizedBox(width: Get.width * 0.03),
            // <<<--- बदलाव यहाँ: इस हिस्से को Expanded में लपेटा गया ---<<<
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordering For Someone else?',
                    style: Get.theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Add a message to be sent as an SMS with your gift.',
                    style: Get.theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey)
          ],
        ),
      ),
    );
  }
}
