import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:ssda/screens/addBusinessscreen.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _isLoading = true;

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
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchBanners() async {
    try {
      final url = Uri.parse(
        'https://sridungargarhone.com/wp-json/wp/v2/business-category/${widget.id}?acf_format=standard',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final raw = jsonBody['acf']?['banners'] ?? "";
        bannerslist = raw.toString().split(RegExp(r'[\r\n]+')).where((url) => url.trim().isNotEmpty).toList();
      }
    } catch (e) {
      print("Error fetching banners: $e");
    }
  }

  Future<void> fetchBusinesses() async {
    try {
      final url = Uri.parse(
        'https://sridungargarhone.com/wp-json/wp/v2/business?business-category=${widget.id}&acf_format=standard&per_page=100',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        mobilenumberdatas = data.map((item) {
          final List acf = item['ams_acf'] ?? [];
          return {
            "bname": item['title']['rendered'] ?? 'N/A',
            "oname": getACFValue(acf, 'owner_name'),
            "mobile": getACFValue(acf, 'phone_number'),
            "bimage": getACFValue(acf, 'business_logo') ?? '',
          };
        }).toList();
      }
    } catch (e) {
      print("Error fetching businesses: $e");
    }
  }

  String getACFValue(List acfList, String key) {
    final match = acfList.firstWhere((e) => e['key'] == key, orElse: () => null);
    return match?['value']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kWhiteColor,
        label: const Text('अपना मोबाइल नंबर जोड़ें', style: TextStyle(color: kPrimaryColor)),
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kBlackColor, fontSize: 22),
        ),
      ),
      backgroundColor: kBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          // 1. Banner Carousel (सुरक्षा जाँच के साथ)
          if (bannerslist.isNotEmpty)
            SliverToBoxAdapter(
              child: CarouselSlider.builder(
                itemCount: bannerslist.length,
                itemBuilder: (_, index, __) => Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(bannerslist[index]),
                      fit: BoxFit.fill,
                      onError: (e, s) => const Icon(Icons.error),
                    ),
                  ),
                ),
                options: CarouselOptions(
                  height: Get.height * 0.2,
                  autoPlay: bannerslist.length > 1,
                  viewportFraction: 0.9,
                ),
              ),
            ),

          // 2. Businesses List
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final data = mobilenumberdatas[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, spreadRadius: 2),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Circular Image Avatar
                      Container(
                        height: 60,
                        width: 60,
                        clipBehavior: Clip.antiAlias, // To ensure the image respects the circular shape
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [Color(0xffe85df7), Color(0xff79c3ff)]),
                        ),
                        child: (data['bimage'] != null && data['bimage'].toString().isNotEmpty)
                            ? Image.network(
                          data['bimage'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.store, color: Colors.white, size: 30),
                        )
                            : const Icon(Icons.store, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 12),

                      // Name, Owner and Buttons Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['bname'],
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: kblue, fontSize: 18),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16, color: Colors.black54),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    data['oname'] ?? 'N/A',
                                    style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // 👇 OVERFLOW FIX: Buttons अब Row में हैं और Flexible हैं
                            Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: OutlinedButton.icon(
                                    onPressed: () => FlutterPhoneDirectCaller.callNumber(data['mobile']),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      side: const BorderSide(color: Colors.black54),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    icon: const Icon(Icons.call, size: 16),
                                    label: const Text("Call", style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                                Flexible(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final whatsappUrl = Uri.parse("https://wa.me/${data['mobile']}");
                                      if (await canLaunchUrl(whatsappUrl)) {
                                        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                                      } else {
                                        Get.snackbar("Error", "WhatsApp नहीं खुल पाया।");
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      backgroundColor: const Color(0xff25D366),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    icon: const Icon(FontAwesomeIcons.whatsapp, size: 14),
                                    label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: mobilenumberdatas.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80))
        ],
      ),
    );
  }

  void showAddDialog() {
    Get.to(() => AddBusinessScreen(initialCategoryId: widget.id));
  }
}