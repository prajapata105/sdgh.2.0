import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp/whatsapp.dart';
import '../../utils/constent.dart';
class MobileNumbers extends StatefulWidget {
  final String id;
  final String cate;
  const MobileNumbers({Key? key, required this.id, required this.cate})
    : super(key: key);

  @override
  State<MobileNumbers> createState() => _MobileNumbersState();
}

class _MobileNumbersState extends State<MobileNumbers> {
  List<String> bannerslist = [];
  List<Map<String, dynamic>> mobilenumberdatas = [];
  final ScrollController _controller = ScrollController();
  double h = 0, w = 0;

  final mobilecontroller = TextEditingController();
  final onamecontroller = TextEditingController();
  final bnamecontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([fetchBanners(), fetchBusinesses()]);
    setState(() {});
  }

  Future<void> fetchBanners() async {
    final url = Uri.parse(
      'https://sridungargarhone.com/wp-json/wp/v2/business-category/${widget.id}?acf_format=standard',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final raw = jsonBody['acf']?['banners'] ?? "";
      final List<String> list =
          raw
              .toString()
              .split(RegExp(r'[\r\n]+'))
              .where((url) => url.trim().isNotEmpty)
              .toList();
      bannerslist = list;
    }
  }

  Future<void> fetchBusinesses() async {
    final url = Uri.parse(
      'https://sridungargarhone.com/wp-json/wp/v2/business?business-category=${widget.id}&acf_format=standard',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      mobilenumberdatas =
          data.map((item) {
            final List acf = item['ams_acf'] ?? [];
            return {
              "bname": item['title']['rendered'] ?? '',
              "oname": getACFValue(acf, 'owner_name'),
              "mobile": getACFValue(acf, 'phone_number'),
              "bimage": getACFValue(acf, 'business_logo') ?? '',
            };
          }).toList();
    }
  }

  String getACFValue(List acfList, String key) {
    final match = acfList.firstWhere(
      (e) => e['key'] == key,
      orElse: () => null,
    );
    if (match == null) return '';
    return match['value']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    h = MediaQuery.of(context).size.height;
    w = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: kWhiteColor,
          label: const Text(
            'अपना मोबाइल नंबर जोड़ें',
            style: TextStyle(color: kPrimaryColor),
          ),
          onPressed: showAddDialog,
        ),
        appBar: AppBar(
          backgroundColor: kWhiteColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios, color: kTitleColor),
          ),
          title: Text(
            widget.cate,
            style:  GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: kBlackColor,
              fontSize: 22,
            ),
          ),
        ),
        backgroundColor: kBackgroundColor,
        body: SingleChildScrollView(
          controller: _controller,
          child: Column(
            children: [
              CarouselSlider.builder(
                itemCount: bannerslist.length,
                itemBuilder:
                    (_, index, __) => Container(
                      margin: const EdgeInsets.all(5),
                      width: w * 0.8,
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: kWhiteColor.withOpacity(0.20),
                            spreadRadius: 2,
                            blurRadius: 4,
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(bannerslist[index]),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                options: CarouselOptions(
                  height: bannerslist.isNotEmpty ? h * 0.2 : 0,
                ),
              ),
              ListView.builder(
                itemCount: mobilenumberdatas.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, index) {
                  final data = mobilenumberdatas[index];
                  return mobilenumberdatas.isEmpty
                      ? const CircularProgressIndicator()
                      : Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Circular Gradient Avatar
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xffe85df7),
                                    Color(0xff79c3ff),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child:
                                  data['bimage'].toString().isNotEmpty
                                      ? ClipOval(
                                        child: Image.network(
                                          data['bimage'],
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : const Icon(
                                        Icons.store,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                            ),
                            const SizedBox(width: 12),

                            // Name, Owner and Buttons
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['bname'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: kblue,

                                      fontSize: 18,
                                    ),
                                    maxLines: 1,
                                    softWrap: true,
                                  ),
                                  SizedBox(height: h * 0.001),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        data['oname'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      // Call Button
                                      OutlinedButton.icon(
                                        onPressed:
                                            () =>
                                                FlutterPhoneDirectCaller.callNumber(
                                                  data['mobile'],
                                                ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                            color: Colors.black54,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                        ),
                                        icon: const Icon(Icons.call),
                                        label: const Text("Call"),
                                      ),

                                      const SizedBox(width: 10),

                                      // WhatsApp Button
                                      InkWell(
                                        onTap: () async {
                                          var url = Uri.parse("https://wa.me/$data['mobile']");

                                          if (await canLaunchUrl(url)) {
                                            launchUrl(url);
                                          } else {
                                            Get.snackbar("Error", "WhatsApp नहीं खुल पाया");
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              19,
                                            ),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xff07c8f9),
                                                Color(0xff0d41e1),
                                              ],
                                            ),
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 20),
                                              SizedBox(width: 6),
                                              Text(
                                                'WhatsApp',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                },
              ),
              SizedBox(height: h * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  void showAddDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('अपने व्यापार का विवरण जोड़ें'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bnamecontroller,
                  decoration: const InputDecoration(
                    labelText: 'व्यापार का नाम',
                  ),
                ),
                TextField(
                  controller: onamecontroller,
                  decoration: const InputDecoration(labelText: 'मालिक का नाम'),
                ),
                TextField(
                  controller: mobilecontroller,
                  decoration: const InputDecoration(labelText: 'मोबाइल नंबर'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'आपकी जानकारी 24 घंटे में जोड़ी जाएगी',
                  );
                  bnamecontroller.clear();
                  onamecontroller.clear();
                  mobilecontroller.clear();
                },
                child: const Text('Submit'),
              ),
            ],
          ),
    );
  }
}
