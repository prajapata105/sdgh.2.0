// lib/controller/UserOrdersController.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ssda/services/OrderService.dart';
import 'package:ssda/weight/snapkbar.dart';

class UserOrdersController extends GetxController {
  // main.dart में डाले गए इंस्टेंस का उपयोग करें
  final OrderService _orderService = Get.find<OrderService>();
  final GetStorage _box = GetStorage();
  final Snakbar _snakbar = Snakbar();

  RxBool isLoading = false.obs; // डिफॉल्ट false रखें
  RxList<Map<String, dynamic>> orders = RxList<Map<String, dynamic>>([]);

  @override
  void onInit() {
    super.onInit();
    // पहली बार ऑर्डर्स लाने के लिए कॉल करें
    fetchUserOrders();
  }

  // इस मेथड को पुल-टू-रीफ्रेश और CheckoutController से कॉल किया जाएगा
  Future<void> fetchUserOrders({bool isPullToRefresh = false}) async {
    // यदि पहले से ही लोडिंग हो रही है, तो दोबारा कॉल न करें
    if (isLoading.value && !isPullToRefresh) return;

    // यदि यह पुल-टू-रीफ्रेश नहीं है, तो लोडर दिखाएं
    if (!isPullToRefresh) {
      isLoading.value = true;
    }

    try {
      final wooUserIdFromStorage = _box.read<String>('wooUserId');
      int? customerId = (wooUserIdFromStorage != null && wooUserIdFromStorage.isNotEmpty)
          ? int.tryParse(wooUserIdFromStorage) : null;

      if (customerId != null && customerId > 0) {
        final List<Map<String, dynamic>>? fetchedOrders =
        await _orderService.fetchOrdersByCustomerId(customerId);
        if (fetchedOrders != null) {
          orders.value = fetchedOrders;
        } else {
          if (!isPullToRefresh) _snakbar.snakbarsms("Could not fetch your orders at this time.");
        }
      } else {
        // यूजर लॉग-इन नहीं है, ऑर्डर्स लिस्ट खाली करें
        orders.clear();
        if (!isPullToRefresh) _snakbar.snakbarsms("Please log in to view your orders.");
      }
    } catch (e) {
      print("Error fetching user orders: $e");
      if (!isPullToRefresh) _snakbar.snakbarsms("Failed to load orders. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }
}