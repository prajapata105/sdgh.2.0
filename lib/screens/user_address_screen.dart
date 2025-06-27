import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/UI/Widgets/Atoms/add_or_edit_address_dialog.dart'; // यह आपकी पुरानी इम्पोर्ट हो सकती है, नई स्क्रीन के लिए इसकी आवश्यकता नहीं है।
import 'package:ssda/controller/AddressController.dart';
import 'package:ssda/models/address_model.dart';


// सुनिश्चित करें कि आपकी AddressEditScreen सही से इम्पोर्टेड है
// import 'package:ssda/UI/Screens/address_edit_screen.dart'; // आपकी फाइल का सही पाथ दें

class UserAddressScreen extends StatelessWidget {
  final addressCtrl = Get.find<AddressController>();

  // पता जोड़ने या संपादित करने वाली स्क्रीन पर जाने के लिए एक Helper फंक्शन
  void _navigateToAddEditScreen(Address? address) {
    // Get.to(() => AddressEditScreen(existingAddress: address)); // आपका पुराना नेविगेशन
    Get.to(() => AddressEditScreen(existingAddress: address))?.then((result) async {
      if (result is Address) {
        await addressCtrl.addOrUpdateShippingAddress(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Address'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: _buildAddAddressButton(context),
      body: RefreshIndicator(
        onRefresh: () => addressCtrl.fetchShippingAddress(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            if (addressCtrl.isLoading.value && addressCtrl.shippingAddress.value == null) {
              return const Center(
                heightFactor: 5,
                child: CircularProgressIndicator(),
              );
            }

            final address = addressCtrl.shippingAddress.value;

            if (address == null || address.isEmpty) {
              return _buildEmptyAddressWidget(context);
            } else {
              // --- 👇 सिर्फ यह विजेट बदला गया है ---
              return _buildNewAddressCard(context, address);
            }
          }),
        ),
      ),
    );
  }

  // =======================================================================
  // --- NEW CARD UI ---
  // यह नया कार्ड विजेट है जो आपके द्वारा भेजी गई इमेज जैसा दिखता है
  // =======================================================================
  Widget _buildNewAddressCard(BuildContext context, Address address) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.group_outlined, color: Colors.amber.shade700, size: 28),
            ),
            const SizedBox(width: 16),
            // Address Details and Actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${address.house}, ${address.area}, ${address.city}, ${address.pincode}, ${address.state}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Phone number: ${address.phone}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // More Options (Edit, Delete)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _navigateToAddEditScreen(address);
                          } else if (value == 'delete') {
                            _showDeleteConfirmationDialog(context);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Edit'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete_outline, color: Colors.red),
                              title: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                        child: const Icon(Icons.more_horiz, color: Colors.grey),
                      ),

                      // Share/Select Button
                      IconButton(
                        icon: Icon(Icons.upload_outlined, color: Colors.grey.shade700),
                        onPressed: () {
                          // TODO: इस पते को चुनने या शेयर करने के लिए एक्शन जोड़ें
                          Get.snackbar("Action", "Select address feature coming soon!");
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // बाकी के Helper विजेट्स वैसे ही रहेंगे...

  Widget _buildEmptyAddressWidget(BuildContext context) {
    return Center(
      heightFactor: 2.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'कोई पता नहीं मिला',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'त्वरित डिलीवरी के लिए अपना पता जोड़ें।',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('नया पता जोड़ें'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _navigateToAddEditScreen(null),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAddressButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: const Text('नया पता जोड़ें'),
        onPressed: () => _navigateToAddEditScreen(null),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('पता हटाएं?'),
        content: const Text('क्या आप वाकई इस पते को हटाना चाहते हैं?'),
        actions: [
          TextButton(
            child: const Text('रद्द करें'),
            onPressed: () => Get.back(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('हाँ, हटाएं'),
            onPressed: () async {
              Get.back();
              await addressCtrl.deleteShippingAddress();
            },
          ),
        ],
      ),
    );
  }
}