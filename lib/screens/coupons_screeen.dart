import 'package:flutter/material.dart';
import 'package:ssda/UI/Widgets/Atoms/custom_text_field.dart' show customTextField;
import 'package:ssda/app_colors.dart' show AppColors;
import 'package:get/get.dart';
import 'package:ssda/services/cart_service.dart';
import 'package:ssda/services/coupon_service.dart';
import 'package:ssda/models/coupon_model.dart';

class CouponsSelectionScreen extends StatefulWidget {
  const CouponsSelectionScreen({super.key});

  @override
  State<CouponsSelectionScreen> createState() => _CouponsSelectionScreenState();
}

class _CouponsSelectionScreenState extends State<CouponsSelectionScreen> {
  final TextEditingController _couponController = TextEditingController();
  late Future<List<Coupon>> _futureCoupons;
  Coupon? _appliedCoupon;

  @override
  void initState() {
    super.initState();
    _futureCoupons = CouponService.fetchCoupons();
  }

  void _applyCoupon(Coupon coupon) {
    setState(() {
      _appliedCoupon = coupon;
    });
    Get.find<CartService>().applyCoupon(coupon);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Coupon ${coupon.code} applied!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyWhiteColor,
      appBar: AppBar(
        leadingWidth: 25,
        automaticallyImplyLeading: true,
        title: const Text("Coupons"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customTextField(
              textEditingController: _couponController,
              hintText: "Type your coupon code here",
              isPhoneNumberField: false,
              suffixIcon: TextButton(
                onPressed: () async {
                  final code = _couponController.text.trim();
                  if (code.isEmpty) return;
                  final coupon = await CouponService.fetchCouponByCode(code);
                  if (coupon != null) {
                    _applyCoupon(coupon);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid coupon code.")),
                    );
                  }
                },
                child: const Text("Apply"),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Best Coupons for you",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Expanded(
              child: FutureBuilder<List<Coupon>>(
                future: _futureCoupons,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Failed to load coupons.'));
                  }
                  final coupons = snapshot.data ?? [];
                  if (coupons.isEmpty) {
                    return const Center(child: Text("No coupons available."));
                  }
                  return ListView.builder(
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = coupons[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 15),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  coupon.description,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                InkWell(
                                  splashColor: AppColors.primaryGreenColor,
                                  onTap: () {
                                    _applyCoupon(coupon);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreenColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        width: 1,
                                        color: AppColors.primaryGreenColor,
                                      ),
                                    ),
                                    child: const Text(
                                      "Apply",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: AppColors.primaryGreenColor,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Text(
                              "Use Code: ${coupon.code}",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (coupon.amount != null)
                              Text(
                                "Discount: ₹${coupon.amount} (${coupon.discountType})",
                                style: const TextStyle(
                                    color: Colors.green, fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
