import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ssda/models/address_model.dart';
import 'package:ssda/services/address_service.dart';

class AddressController extends GetxController {
  // स्टेट वेरिएबल्स
  Rx<Address?> shippingAddress = Rxn<Address>();
  RxBool isLoading = false.obs;

  // स्टोरेज से ग्राहक आईडी प्राप्त करना
  int get customerId => int.tryParse(GetStorage().read('wooUserId') ?? '') ?? 0;

  // कंट्रोलर के शुरू होने पर एड्रेस लोड करें
  @override
  void onInit() {
    super.onInit();
    fetchShippingAddress();
  }

  // सर्वर से शिपिंग एड्रेस प्राप्त करने के लिए फ़ंक्शन
  Future<void> fetchShippingAddress() async {
    if (customerId == 0) {
      print("DEBUG: Invalid Customer ID, cannot fetch address.");
      return;
    }
    isLoading.value = true;
    try {
      final fetchedAddress = await AddressService.fetchShippingAddress(customerId);
      // अगर सर्वर से एड्रेस खाली आता है, तो null सेट करें
      if (fetchedAddress != null && fetchedAddress.isEmpty) {
        shippingAddress.value = null;
      } else {
        shippingAddress.value = fetchedAddress;
      }
      print("DEBUG: Fetched Address: ${shippingAddress.value}");
    } catch (e) {
      Get.snackbar("Error", "Unable to fetch address: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- 👇 यहाँ मुख्य बदलाव किया गया है ---
  // एड्रेस जोड़ने या अपडेट करने के लिए संशोधित फ़ंक्शन
  Future<void> addOrUpdateShippingAddress(Address address) async {
    if (customerId == 0) {
      Get.snackbar("Error", "Invalid Customer ID");
      return;
    }

    // 1. रोलबैक के लिए पुराने एड्रेस को सेव करें
    final oldAddress = shippingAddress.value;

    // 2. UI को तुरंत नए एड्रेस से अपडेट करें (Optimistic UI Update)
    shippingAddress.value = address;
    isLoading.value = true;

    try {
      // 3. सर्वर पर अपडेट रिक्वेस्ट भेजें
      await AddressService.updateShippingAddress(customerId, address.toShippingJson());

      // सफलता का संदेश दिखाएं, UI पहले ही अपडेट हो चुकी है
      Get.snackbar("Success", "Address updated successfully!");
      print("DEBUG: Address updated optimistically.");
      // अब सर्वर से फिर से fetch करने की जरूरत नहीं है।

    } catch (e) {
      // 4. अगर कोई त्रुटि होती है, तो UI को पुराने एड्रेस पर वापस सेट करें
      shippingAddress.value = oldAddress;
      Get.snackbar("Error", "Failed to update address: $e");
    } finally {
      isLoading.value = false;
    }
  }


  // --- 👇 इस फ़ंक्शन को भी ठीक किया गया है ---
  // एड्रेस हटाने के लिए संशोधित फ़ंक्शन
  Future<void> deleteShippingAddress() async {
    if (customerId == 0) {
      Get.snackbar("Error", "Invalid Customer ID");
      return;
    }

    // 1. रोलबैक के लिए पुराने एड्रेस को सेव करें
    final oldAddress = shippingAddress.value;

    // 2. UI से तुरंत एड्रेस हटाएं (Optimistic UI Update)
    shippingAddress.value = null;
    isLoading.value = true;

    try {
      // WooCommerce में एड्रेस हटाने के लिए, हम एक खाली एड्रेस भेजते हैं
      final emptyAddress = Address.empty();
      await AddressService.updateShippingAddress(customerId, emptyAddress.toShippingJson());

      Get.snackbar("Success", "Address deleted successfully");
      print("DEBUG: Address deleted optimistically.");

    } catch (e) {
      // 4. अगर कोई त्रुटि होती है, तो UI को पुराने एड्रेस पर वापस सेट करें
      shippingAddress.value = oldAddress;
      Get.snackbar("Error", "Failed to delete address: $e");
    } finally {
      isLoading.value = false;
    }
  }
}