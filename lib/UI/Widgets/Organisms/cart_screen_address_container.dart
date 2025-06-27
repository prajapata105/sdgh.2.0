import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/controller/AddressController.dart';
import 'package:ssda/models/address_model.dart';
import '../../../app_colors.dart';

class CartScreenAddressContainer extends StatelessWidget {
  const CartScreenAddressContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final addressCtrl = Get.find<AddressController>();

    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.04, vertical: Get.height * 0.01),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        width: Get.width,
        height: 70,
        child: _buildChild(context, addressCtrl),
      );
    });
  }

  Widget _buildChild(BuildContext context, AddressController addressCtrl) {
    if (addressCtrl.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final address = addressCtrl.shippingAddress.value;
    return (address == null || address.isEmpty)
        ? _buildAddAddressPrompt(context)
        : _buildAddressDetails(context, address);
  }

  Widget _buildAddressDetails(BuildContext context, Address address) {
    return Row(
      children: [
        // <<<--- बदलाव यहाँ: यह हिस्सा अब पूरी बची हुई जगह लेगा ---<<<
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.home_filled, color: Colors.orangeAccent),
              SizedBox(width: Get.width * 0.04),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Delivering to: ${address.name}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${address.house}, ${address.city}",
                      style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(width: Get.width * 0.03),
        // <<<--- बदलाव यहाँ: Change बटन ---<<<
        TextButton(
          onPressed: () => Get.toNamed('/user/address'),
          child: Text(
            "Change",
            style: TextStyle(color: AppColors.primaryGreenColor, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget _buildAddAddressPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Please add a delivery address", style: TextStyle(fontWeight: FontWeight.bold)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreenColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Get.toNamed('/user/address'),
          child: const Text("Add"),
        ),
      ],
    );
  }
}