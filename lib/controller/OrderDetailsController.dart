// lib/controller/OrderDetailsController.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/services/OrderService.dart';
import 'package:ssda/weight/snapkbar.dart';

class OrderDetailsController extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();
  final Snakbar _snakbar = Snakbar();

  RxBool isLoading = true.obs;
  RxMap<String, dynamic> orderDetails = RxMap<String, dynamic>({});

  // जब कंट्रोलर शुरू हो, तो यह मेथड कॉल होगा
  void loadOrderDetails({
    int? orderId,
    Map<String, dynamic>? orderData,
  }) async {
    isLoading.value = true;
    print("OrderDetailsController: Loading data for Order ID: $orderId");

    if (orderData != null && orderData.isNotEmpty) {
      orderDetails.value = orderData;
      print("OrderDetailsController: Displaying order_data passed directly.");
    } else if (orderId != null) {
      print("OrderDetailsController: Fetching details from API for Order ID: $orderId");
      final Map<String, dynamic>? result = await _orderService.fetchOrderByIdFromApi(orderId);
      if (result != null) {
        orderDetails.value = result;
      } else {
        _handleDataLoadingError("Could not fetch order details from API for ID: $orderId.");
      }
    } else {
      _handleDataLoadingError("No Order ID provided to load details.");
    }
    isLoading.value = false;
  }

  void _handleDataLoadingError(String message) {
    isLoading.value = false;
    orderDetails.clear();
    print("OrderDetailsController Error: $message");

    // Snakbar को सुरक्षित रूप से कॉल करें
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isSnackbarOpen == false) {
        _snakbar.snakbarsms(message);
      }
    });
  }
}