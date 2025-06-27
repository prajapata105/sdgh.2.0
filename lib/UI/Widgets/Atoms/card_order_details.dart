// lib/UI/Widgets/Atoms/card_order_details.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // तारीख फॉर्मेटिंग के लिए
import 'package:ssda/models/address_model.dart'; // AddressModel इम्पोर्ट करें

class OrderDetailsCard extends StatelessWidget {
  final String orderId;
  final String paymentMethod;
  final String dateCreated; // ISO 8601 फॉर्मेट में तारीख
  final Address shippingAddress;
  final String currencySymbol; // यह पैरामीटर अब आवश्यक नहीं है, पर संगतता के लिए रखा है

  const OrderDetailsCard({
    super.key,
    required this.orderId,
    required this.paymentMethod,
    required this.dateCreated,
    required this.shippingAddress,
    required this.currencySymbol, // यह उपयोग नहीं हो रहा है, पर हटाया नहीं गया
  });

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return "N/A";
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(date.toLocal());
    } catch (e) {
      print("Error parsing date in OrderDetailsCard: $e");
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String formattedDate = _formatDate(dateCreated);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order & Payment Info', // शीर्षक बदला गया
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildDetailItem(theme, "Order ID", "#$orderId"),
          _buildDetailItem(theme, "Payment Method", paymentMethod),
          _buildDetailItem(theme, "Order Placed On", formattedDate),
          const SizedBox(height: 12),
          Text(
            'Shipping Address',
            style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            shippingAddress.name,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            "${shippingAddress.house}${shippingAddress.area.isNotEmpty ? ', ${shippingAddress.area}' : ''}",
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            "${shippingAddress.city}, ${shippingAddress.state} - ${shippingAddress.pincode}",
            style: theme.textTheme.bodyMedium,
          ),
          if(shippingAddress.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "Phone: ${shippingAddress.phone}",
              style: theme.textTheme.bodyMedium,
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailItem(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}