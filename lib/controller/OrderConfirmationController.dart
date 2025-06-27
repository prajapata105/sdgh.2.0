
import 'package:get/get.dart';

class OrderConfirmationController extends GetxController {
  // इन वेरिएबल्स को Rx बनाने की जरूरत नहीं है क्योंकि वे एक बार सेट होते हैं
  int? orderId;
  Map<String, dynamic>? orderData;

  // CheckoutController इस मेथड को कॉल करके डेटा सेट करेगा
  void setupOrderConfirmationDetails({
    required int? receivedOrderId,
    required Map<String, dynamic>? receivedOrderData,
  }) {
    orderId = receivedOrderId;
    orderData = receivedOrderData;
    print("OrderConfirmationController: Data setup for Order ID: $orderId");
    // UI को अपडेट करने की जरूरत नहीं है क्योंकि स्क्रीन इसे सीधे पढ़ेगी
  }
}