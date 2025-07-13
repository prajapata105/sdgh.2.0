import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/constent.dart'; // आपके प्रोजेक्ट के कलर्स और कांस्टेंट्स

class AddBusinessScreen extends StatefulWidget {
  final String initialCategoryId;
  const AddBusinessScreen({Key? key, required this.initialCategoryId}) : super(key: key);

  @override
  _AddBusinessScreenState createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bnameController = TextEditingController();
  final _onameController = TextEditingController();
  final _mobileController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  Map<String, dynamic>? _selectedCategory;
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final url = Uri.parse('https://sridungargarhone.com/wp-json/wp/v2/business-category?per_page=100');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _categories = data.map((cat) => {'id': cat['id'], 'name': cat['name']}).toList();

        // --- यहाँ बदलाव किया गया है ---
        // firstWhere को firstWhereOrNull से बदला गया है ताकि एरर न आए
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() => _isSubmitting = true);
      try {
        final url = Uri.parse('https://sridungargarhone.com/wp-json/custom/v1/submit-business');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'X-Secret-Key': 'aSdsfrdsaaasdsd@2025!#', // आपकी गुप्त कुंजी
          },
          body: json.encode({
            'business_name': _bnameController.text,
            'owner_name': _onameController.text,
            'mobile_number': _mobileController.text,
            'category_id': _selectedCategory!['id'],
          }),
        );

        if (response.statusCode == 200) {
          Get.back(); // वापस पिछली स्क्रीन पर जाएँ
          Get.snackbar('धन्यवाद!', 'आपकी जानकारी 24 घंटे में जोड़ दी जाएगी।', snackPosition: SnackPosition.BOTTOM);
        } else {
          final errorData = json.decode(response.body);
          Get.snackbar('Error', errorData['message'] ?? 'Something went wrong');
        }
      } catch (e) {
        Get.snackbar('Error', 'An error occurred: $e');
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    } else if (_selectedCategory == null) {
      Get.snackbar('Error', 'Please select a category');
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
          'Add Your Business',
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
              TextFormField(controller: _bnameController, decoration: const InputDecoration(labelText: 'व्यापार का नाम'), validator: (v) => v!.isEmpty ? 'यह ज़रूरी है' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _onameController, decoration: const InputDecoration(labelText: 'मालिक का नाम'), validator: (v) => v!.isEmpty ? 'यह ज़रूरी है' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _mobileController, decoration: const InputDecoration(labelText: 'मोबाइल नंबर'), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'यह ज़रूरी है' : null),
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
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit for Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
