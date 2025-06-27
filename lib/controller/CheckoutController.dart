// lib/controller/CheckoutController.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:ssda/Infrastructure/HttpMethods/requesting_methods.dart';
import 'package:ssda/controller/AddressController.dart';
import 'package:ssda/controller/OrderDetailsController.dart';
import 'package:ssda/controller/UserOrdersController.dart';
import 'package:ssda/services/cart_service.dart';
import 'package:ssda/services/OrderService.dart';
import 'package:ssda/app_colors.dart';
import 'package:ssda/weight/snapkbar.dart';
import 'package:ssda/models/address_model.dart';
import 'package:ssda/models/cart_item_model.dart';

class CheckoutController extends GetxController {
  final AddressController addressCtrl = Get.find<AddressController>();
  final CartService cartService = Get.find<CartService>();
  final OrderService orderService = Get.find<OrderService>();
  final UserOrdersController _userOrdersController = Get.find<UserOrdersController>();
  final OrderDetailsController _orderDetailsController = Get.find<OrderDetailsController>();
  final GetStorage _box = GetStorage();
  final Snakbar _snakbar = Snakbar();
  final Razorpay _razorpay = Razorpay();

  RxString selectedPaymentMethod = 'cod'.obs;
  RxBool isLoading = false.obs;

  final String _razorpayKeyId = 'rzp_test_S68VGqBoahOMH1';
  final String _appSecretKeyForWordPress = 'YOUR_VERY_STRONG_AND_UNIQUE_SECRET_KEY_FOR_WP_API';

  @override
  void onInit() {
    super.onInit();
    _initializeRazorpayListeners();
  }

  void _initializeRazorpayListeners() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  void placeOrderFlow() {
    if (!_validatePreCheckoutConditions()) return;
    _showPaymentOptionsModal();
  }

  bool _validatePreCheckoutConditions() {
    if (cartService.cartItems.isEmpty) {
      _snakbar.snakbarsms("Your cart is empty.");
      return false;
    }
    final Address? shippingAddress = addressCtrl.shippingAddress.value;
    if (shippingAddress == null || shippingAddress.isEmpty) {
      _snakbar.snakbarsms("Please add a shipping address.");
      Get.toNamed('/user/address');
      return false;
    }
    return true;
  }

  void _showPaymentOptionsModal() {
    final BuildContext context = Get.context!;
    Get.bottomSheet(
      Container(
        color: Theme.of(context).cardColor,
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: <Widget>[
            ListTile(
              title: Text('Select Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.money_outlined, color: Theme.of(context).colorScheme.secondary),
              title: const Text('Cash on Delivery'),
              onTap: () {
                selectedPaymentMethod.value = 'cod';
                Navigator.of(context).pop(); // Get.back() की जगह इसका उपयोग करें
                Future.microtask(() => _initiateOrderCreation(paymentMethod: 'cod', paymentMethodTitle: 'Cash on Delivery'));
              },
            ),
            ListTile(
              leading: Icon(Icons.payment, color: Theme.of(context).colorScheme.secondary),
              title: const Text('Pay Online (Razorpay)'),
              onTap: () {
                selectedPaymentMethod.value = 'razorpay';
                Navigator.of(context).pop();
                Future.microtask(() => _initiateRazorpayPayment());
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _initiateRazorpayPayment() async {
    isLoading.value = true;
    final int amountInPaise = (cartService.grandTotal * 100).toInt();
    final String razorpayOrderCreationUrl = 'https://sridungargarhone.com/wp-json/my-razorpay/v1/create-order';

    String userEmail = _box.read<String>('userEmail') ?? 'guest_${DateTime.now().millisecondsSinceEpoch}@sdghone.com';
    String userPhoneNumber = addressCtrl.shippingAddress.value?.phone ?? '';

    try {
      final Map<String, dynamic>? response = await ApiService.requestMethods(
        methodType: "POST",
        url: razorpayOrderCreationUrl,
        body: {'amount': amountInPaise},
        customHeaders: {'X-SDGHONE-APP-KEY': _appSecretKeyForWordPress},
      );

      if (response != null && response['order_id'] != null) {
        final String razorpayOrderId = response['order_id'];
        _openRazorpayCheckout(amountInPaise, razorpayOrderId, userEmail, userPhoneNumber);
      } else {
        _handleApiFailure("Payment server did not create an order.", response);
      }
    } catch (e) {
      _handleApiFailure("Error connecting to payment server.", e);
    }
  }

  void _openRazorpayCheckout(int amount, String orderId, String email, String contact) {
    var options = {
      'key': _razorpayKeyId,
      'amount': amount,
      'name': 'SD Ghone',
      'order_id': orderId,
      'description': 'Order Payment',
      'timeout': 120,
      'prefill': {'contact': contact, 'email': email},
      'theme': {'color': '#${AppColors.primaryGreenColor.value.toRadixString(16).substring(2)}'}
    };
    try {
      _razorpay.open(options);
    } catch(e){
      print("Error opening Razorpay checkout: $e");
      _snakbar.snakbarsms("Could not open payment window.");
      isLoading.value = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    isLoading.value = false;
    _snakbar.snakbarsms("Payment Successful! Finalizing order...");
    _initiateOrderCreation(
      paymentMethod: 'razorpay',
      paymentMethodTitle: 'Paid via Razorpay',
      setPaid: true,
      transactionId: response.paymentId ?? '',
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isLoading.value = false;
    String errorMessageToShow = "Payment failed. Please try again.";
    if (response.message != null) {
      try {
        final errorData = jsonDecode(response.message!);
        errorMessageToShow = errorData['error']?['description'] ?? errorMessageToShow;
      } catch (e) {
        if (response.message!.isNotEmpty) errorMessageToShow = response.message!;
      }
    }
    _snakbar.snakbarsms(errorMessageToShow);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isLoading.value = false;
    _snakbar.snakbarsms("Processing payment via ${response.walletName}. Awaiting confirmation...");
  }

  Future<void> _initiateOrderCreation({
    required String paymentMethod,
    required String paymentMethodTitle,
    bool setPaid = false,
    String transactionId = '',
  }) async {
    isLoading.value = true;
    try {
      final Address address = addressCtrl.shippingAddress.value!;
      final int? customerId = int.tryParse(_box.read<String>('wooUserId') ?? '');
      final String billingEmail = _box.read<String>('userEmail') ?? '${customerId ?? 'guest'}_${DateTime.now().millisecondsSinceEpoch}@sdghone.com';

      final List<Map<String, dynamic>> lineItems = cartService.cartItems.map((CartItem item) {
        return {
          'product_id': item.id,
          'quantity': item.quantity,
          'meta_data': [{'key': '_product_image_url', 'value': item.imageUrl}]
        };
      }).toList();

      final orderPayload = _buildOrderPayload(
          paymentMethod, paymentMethodTitle, setPaid, transactionId, customerId,
          billingEmail, address, lineItems, cartService.deliveryCharge
      );

      Map<String, dynamic>? createdOrder = await orderService.createOrder(orderPayload);

      if (createdOrder != null && createdOrder.containsKey('id')) {
        _handleOrderCreationSuccess(createdOrder);
      } else {
        _handleApiFailure("Order Placement Failed.", "Server did not confirm order creation.");
      }
    } catch (e) {
      _handleApiFailure("An unexpected error occurred during order creation.", e);
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _buildOrderPayload(
      String paymentMethod, String paymentMethodTitle, bool setPaid, String transactionId, int? customerId,
      String billingEmail, Address address, List<Map<String, dynamic>> lineItems, double deliveryCharge) {
    return {
      'payment_method': paymentMethod,
      'payment_method_title': paymentMethodTitle,
      'set_paid': setPaid,
      if (customerId != null && customerId > 0) 'customer_id': customerId,
      if (transactionId.isNotEmpty) 'transaction_id': transactionId,
      'billing': {
        'first_name': address.name.split(' ').first, 'last_name': address.name.split(' ').length > 1 ? address.name.split(' ').sublist(1).join(' ') : (address.name.split(' ').first),
        'address_1': address.house, 'address_2': address.area, 'city': address.city,
        'state': address.state, 'postcode': address.pincode, 'country': 'IN',
        'email': billingEmail, 'phone': address.phone,
      },
      'shipping': {
        'first_name': address.name.split(' ').first, 'last_name': address.name.split(' ').length > 1 ? address.name.split(' ').sublist(1).join(' ') : (address.name.split(' ').first),
        'address_1': address.house, 'address_2': address.area, 'city': address.city,
        'state': address.state, 'postcode': address.pincode, 'country': 'IN',
      },
      'line_items': lineItems,
      'shipping_lines': [{'method_id': 'flat_rate', 'method_title': 'Delivery Charge', 'total': deliveryCharge.toStringAsFixed(2)}]
    };
  }

  void _handleOrderCreationSuccess(Map<String, dynamic> createdOrder) async { // <<<--- इसे async बनाएं
    cartService.clearCart();
    _snakbar.snakbarsms("Order placed successfully! ID: #${createdOrder['id']}");

    // <<<--- यूजर की ऑर्डर लिस्ट को रीफ्रेश करें और इंतजार करें ---<<<
    // Get.find() यह सुनिश्चित करेगा कि यह वही इंस्टेंस है जो OrdersScreen उपयोग कर रहा है
    print("CheckoutController: Refreshing user orders list...");
    await _userOrdersController.fetchUserOrders();
    print("CheckoutController: User orders list refreshed.");

    // समर्पित कंट्रोलर का उपयोग करके डेटा पास करें
    _orderDetailsController.loadOrderDetails(
      orderId: createdOrder['id'] as int?,
      orderData: createdOrder,
    );

    // अब कन्फर्मेशन स्क्रीन पर नेविगेट करें
    Get.offAllNamed('/order/confirm');
    isLoading.value = false;
  }

  void _handleApiFailure(String userMessage, dynamic logMessage) {
    _snakbar.snakbarsms(userMessage);
    print("API Failure in CheckoutController: $logMessage");
    isLoading.value = false;
  }
}