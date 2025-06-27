// lib/screens/user_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ssda/app_colors.dart';
import 'package:ssda/constants.dart';
import 'package:ssda/controller/OrderDetailsController.dart';
import 'package:ssda/controller/UserOrdersController.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

// <<<--- WidgetsBindingObserver जोड़ें ताकि ऐप की lifecycle को सुन सकें ---<<<
class _OrdersScreenState extends State<OrdersScreen> with WidgetsBindingObserver {
  // Get.find() का उपयोग करें क्योंकि कंट्रोलर main.dart में स्थाई रूप से डाला गया है
  final UserOrdersController userOrdersController = Get.find<UserOrdersController>();
  final OrderDetailsController orderDetailsController = Get.find<OrderDetailsController>();

  @override
  void initState() {
    super.initState();
    // Observer को रजिस्टर करें
    WidgetsBinding.instance.addObserver(this);
    // जब भी यह स्क्रीन बने, ऑर्डर्स को रीफ्रेश करें
    userOrdersController.fetchUserOrders();
  }

  @override
  void dispose() {
    // Observer को हटाना न भूलें
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // <<<--- यह नया मेथड है ---<<<
  // यह तब कॉल होता है जब ऐप की स्थिति बदलती है (जैसे background से foreground में आना)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // जब ऐप वापस foreground में आती है (जैसे पेमेंट के बाद), तो ऑर्डर्स रीफ्रेश करें
    if (state == AppLifecycleState.resumed) {
      print("OrdersScreen is back in focus. Refreshing orders...");
      userOrdersController.fetchUserOrders();
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "N/A";
    try {
      DateTime date = DateTime.parse(dateString).toLocal();
      return DateFormat('dd MMM, hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.greyWhiteColor ,
      appBar: AppBar(
        title: const Text("Your Orders"),
        elevation: 1,
      ),
      body: Obx(() {
        if (userOrdersController.isLoading.value && userOrdersController.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreenColor));
        }
        if (!userOrdersController.isLoading.value && userOrdersController.orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 100, color: Colors.grey[350]),
                  const SizedBox(height: 20),
                  Text("No Orders Yet!", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    "Looks like you haven't placed any orders. \nWhen you do, they'll show up here.",
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    label: const Text("Start Shopping", style: TextStyle(color: Colors.white, fontSize: 16)),
                    onPressed: () => Get.offAllNamed('/home'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreenColor,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: userOrdersController.fetchUserOrders, // <<<--- अब यह सही काम करेगा
          color: AppColors.primaryGreenColor,
          child: ListView.builder(
            itemCount: userOrdersController.orders.length,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.all(10.0),
            itemBuilder: (BuildContext context, int index) {
              final order = userOrdersController.orders[index];
              final List lineItems = order['line_items'] as List? ?? [];
              final String currencySymbol = order['currency_symbol'] as String? ?? appCurrencySybmbol;
              final String status = order['status']?.toString().capitalizeFirst ?? 'Unknown';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.0),
                  onTap: () {
                    orderDetailsController.loadOrderDetails(
                      orderId: order['id'] as int?,
                      orderData: order,
                    );
                    Get.toNamed('/order');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Order #${order['id']}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryGreenColor)),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Status: $status",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: status == 'Completed' ? Colors.green.shade700 :
                                      status == 'Processing' ? Colors.blue.shade700 :
                                      status.contains('pending') || status == 'On-hold' ? Colors.orange.shade800 :
                                      status == 'Cancelled' || status == 'Failed' ? Colors.red.shade700 :
                                      Colors.grey.shade800,
                                    ),
                                  ),
                                  Text(
                                    "Placed: ${_formatDate(order['date_created'] as String?)}",
                                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[700]),
                          ],
                        ),
                        const Divider(height: 20),
                        if (lineItems.isNotEmpty)
                          SizedBox(
                            height: 65,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(top: 8),
                              itemBuilder: (BuildContext context, int itemIndex) {
                                final item = lineItems[itemIndex] as Map<String, dynamic>;
                                String? imageUrl;
                                if (item['meta_data'] is List) {
                                  var meta = (item['meta_data'] as List).firstWhere(
                                          (m) => m is Map && m['key'] == '_product_image_url',
                                      orElse: () => null);
                                  if (meta != null) imageUrl = meta['value'] as String?;
                                }

                                return Container(
                                  width: 60, height: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(width: 0.5, color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(8.0)),
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Tooltip(
                                    message: (item['name'] as String? ?? 'Product') + " (Qty: ${item['quantity']})",
                                    child: imageUrl != null && imageUrl.isNotEmpty
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(7.5),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 24),
                                        loadingBuilder: (_, child, progress) => progress == null ? child : Center(child: CircularProgressIndicator(strokeWidth: 1.5, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreenColor))),
                                      ),
                                    )
                                        : const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 24),
                                  ),
                                );
                              },
                              itemCount: lineItems.length,
                            ),
                          ),
                        if (lineItems.isNotEmpty) const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order Total:",
                              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[800]),
                            ),
                            Text(
                              "$currencySymbol${order['total'] ?? '0.00'}",
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryGreenColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}