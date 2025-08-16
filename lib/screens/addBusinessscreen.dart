import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/constent.dart';
import 'ShareAndSubmitScreen.dart'; // मान लिया गया कि यह फाइल मौजूद है

// --- पहला चरण: व्यवसाय विवरण भरें ---
class AddBusinessDetailsScreen extends StatefulWidget {
  final String initialCategoryId;
  final String phoneNumber; // लॉगिन से मिला नंबर
  const AddBusinessDetailsScreen({Key? key, required this.initialCategoryId, required this.phoneNumber}) : super(key: key);

  @override
  _AddBusinessDetailsScreenState createState() => _AddBusinessDetailsScreenState();
}

class _AddBusinessDetailsScreenState extends State<AddBusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bnameController = TextEditingController();
  final _onameController = TextEditingController();
  final _mobileController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _selectedCategory;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _mobileController.text = widget.phoneNumber;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final url = Uri.parse('https://sridungargarhone.com/wp-json/wp/v2/business-category?per_page=100');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _categories = data.map((cat) => {'id': cat['id'], 'name': cat['name']}).toList();
        _selectedCategory = _categories.firstWhereOrNull((cat) => cat['id'].toString() == widget.initialCategoryId);
      }
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  void _navigateToShareScreen() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final businessData = {
        'business_name': _bnameController.text,
        'owner_name': _onameController.text,
        'mobile_number': _mobileController.text,
        'category_id': _selectedCategory!['id'],
      };
      Get.to(() => ShareAndSubmitScreen(businessData: businessData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: kTitleColor),
        ),
        title: Text(
          'Add Business',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kBlackColor, fontSize: 22),
        ),
      ),
      backgroundColor: kBackgroundColor,
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- इंडिकेटर (Stepper) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(0, 'विवरण'),
                  _buildStepDivider(0),
                  _buildStepIndicator(1, 'शेयर'),
                ],
              ),
              const SizedBox(height: 32),

              TextFormField(
                  controller: _bnameController,
                  decoration: const InputDecoration(labelText: 'व्यापार का नाम'),
                  validator: (v) => v!.isEmpty ? 'यह ज़रूरी है' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _onameController,
                  decoration: const InputDecoration(labelText: 'मालिक का नाम'),
                  validator: (v) => v!.isEmpty ? 'यह ज़रूरी है' : null),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'मोबाइल नंबर'),
                keyboardType: TextInputType.phone,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedCategory,
                hint: const Text('बिज़नेस कैटेगरी चुनें'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedCategory = newValue),
                validator: (v) => v == null ? 'यह ज़रूरी है' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _navigateToShareScreen,
                child: const Text('अगला'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = 0 == step;
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? kPrimaryColor : Colors.grey.shade400,
          child: Text(
            '${step + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? kPrimaryColor : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int step) {
    return Container(
      width: 60,
      height: 2,
      color: 1 > step ? kPrimaryColor : Colors.grey.shade400,
    );
  }
}