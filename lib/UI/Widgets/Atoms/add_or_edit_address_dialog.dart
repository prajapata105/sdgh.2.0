import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/models/address_model.dart';

class AddressEditScreen extends StatefulWidget {
  final Address? existingAddress;

  AddressEditScreen({this.existingAddress});

  @override
  _AddressEditScreenState createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends State<AddressEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // हर फील्ड के लिए अलग-अलग कंट्रोलर
  late TextEditingController officeBuildingCtrl, floorCtrl, towerCtrl, landmarkCtrl;
  late TextEditingController receiverNameCtrl, receiverPhoneCtrl;
  late TextEditingController cityCtrl, pincodeCtrl, stateCtrl;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAddress;

    // पुराने एड्रेस को नए फील्ड्स में मैप करना
    officeBuildingCtrl = TextEditingController(text: a?.house ?? "");
    floorCtrl = TextEditingController(text: a?.area ?? "");
    towerCtrl = TextEditingController(); // यह नया फील्ड है
    landmarkCtrl = TextEditingController(); // यह नया फील्ड है

    receiverNameCtrl = TextEditingController(text: a?.name ?? "");
    receiverPhoneCtrl = TextEditingController(text: a?.phone ?? "");

    cityCtrl = TextEditingController(text: a?.city ?? "");
    pincodeCtrl = TextEditingController(text: a?.pincode ?? "");
    stateCtrl = TextEditingController(text: a?.state ?? "");
  }

  @override
  void dispose() {
    // सभी कंट्रोलर्स को Dispose करना जरूरी है
    officeBuildingCtrl.dispose();
    floorCtrl.dispose();
    towerCtrl.dispose();
    landmarkCtrl.dispose();
    receiverNameCtrl.dispose();
    receiverPhoneCtrl.dispose();
    cityCtrl.dispose();
    pincodeCtrl.dispose();
    stateCtrl.dispose();
    super.dispose();
  }

  // सेव बटन का लॉजिक
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // नए फील्ड्स से Address ऑब्जेक्ट बनाना
      final updatedAddress = Address(
        id: widget.existingAddress?.id ?? "shipping",
        name: receiverNameCtrl.text,
        phone: receiverPhoneCtrl.text,
        house: officeBuildingCtrl.text,
        // Tower और Landmark को Area फील्ड में जोड़ना
        area: "${floorCtrl.text}, ${towerCtrl.text}, ${landmarkCtrl.text}",
        city: cityCtrl.text,
        pincode: pincodeCtrl.text,
        state: stateCtrl.text,
        googleMapLink: widget.existingAddress?.googleMapLink,
      );
      Get.back(result: updatedAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text("Edit address details", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      // नीचे एक हमेशा दिखने वाला Save बटन
      bottomNavigationBar: _buildSaveButton(),
      body: Form(
        key: _formKey,
        // कीबोर्ड ओवरफ्लो से बचने के लिए SingleChildScrollView
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBanner(),
              const SizedBox(height: 24),

              // बिल्डिंग, फ्लोर आदि के लिए फील्ड्स
              _buildTextField(label: "Office / Building name *", controller: officeBuildingCtrl),
              _buildTextField(label: "Floor *", controller: floorCtrl),
              _buildTextField(label: "Tower / Wing (optional)", controller: towerCtrl, isOptional: true),
              _buildTextField(label: "Nearby landmark (optional)", controller: landmarkCtrl, isOptional: true),

              // City, State, Pincode - ये जरूरी हैं
              _buildTextField(label: "City *", controller: cityCtrl),
              _buildTextField(label: "Pincode *", controller: pincodeCtrl, keyboardType: TextInputType.number),
              _buildTextField(label: "State *", controller: stateCtrl),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              const Text(
                "Add Receiver's Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // रिसीवर के नाम और फोन के लिए फील्ड्स
              _buildTextField(label: "Receiver's name *", controller: receiverNameCtrl),
              _buildTextField(label: "Receiver's phone *", controller: receiverPhoneCtrl, keyboardType: TextInputType.phone),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // कस्टम टेक्स्ट फील्ड बनाने के लिए एक Helper विजेट
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: () {
              controller.clear();
              setState(() {});
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
        onChanged: (value) {
          setState(() {}); // Clear बटन दिखाने/छिपाने के लिए UI अपडेट करें
        },
      ),
    );
  }

  // टॉप पर दिखने वाला इन्फो बैनर
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Please check address details for a hassle free delivery experience",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // नीचे वाला सेव बटन
  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _onSave,
        child: const Text(
          "Save address",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}