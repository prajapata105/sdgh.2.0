import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:ssda/service/mobilenumber.dart' show MobileNumbers;
import 'package:ssda/utils/constent.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> matchedCategories = [];
  List<dynamic> matchedBusinesses = [];
  bool isLoading = false;
  double h = 0, w = 0;

  void _searchData(String query) async {
    setState(() {
      isLoading = true;
    });

    await Future.wait([
      _fetchCategories(query),
      _fetchBusinesses(query),
    ]);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchCategories(String query) async {
    final url = Uri.parse(
        'https://sridungargarhone.com/wp-json/wp/v2/business-category?acf_format=standard&per_page=100&search=$query');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      matchedCategories = [];

      // First: find exact match
      final exact = data.where((item) => item['name'].toString().toLowerCase() == query.toLowerCase()).toList();

      // Then get 3 other similar matches (excluding exact if already present)
      final similar = data
          .where((item) =>
      item['name'].toString().toLowerCase().contains(query.toLowerCase()) &&
          !exact.contains(item))
          .take(3)
          .toList();

      matchedCategories = [...exact, ...similar];
    }
  }

  Future<void> _fetchBusinesses(String query) async {
    final url = Uri.parse(
        'https://sridungargarhone.com/wp-json/wp/v2/business?acf_format=standard&search=$query&per_page=100');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      matchedBusinesses = data;
    }
  }

  @override
  Widget build(BuildContext context) {
    h = MediaQuery.of(context).size.height;
    w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.02),
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (value.trim().isNotEmpty) _searchData(value.trim());
                },
                decoration: InputDecoration(
                  hintText: 'हिंदी या English में सर्च करें...',
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (matchedCategories.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('कैटेगरी:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: h * 0.023)),
                            GridView.builder(
                              itemCount: matchedCategories.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 0.7,
                                mainAxisSpacing: 8,
                              ),
                              itemBuilder: (context, index) {
                                final cat = matchedCategories[index];
                                final logo = cat['acf']?['logo']?['url'] ?? '';
                                return InkWell(
                                  onTap: () {
                                    Get.to(() => MobileNumbers(
                                      id: cat['id'].toString(),
                                      cate: cat['name'],
                                    ));
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        height: h * 0.08,
                                        width: w * 0.18,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xffe3ffe7),
                                              Color(0xffd9e7ff)
                                            ],
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: logo.isNotEmpty
                                            ? Image.network(logo)
                                            : const Icon(Icons.category),
                                      ),
                                      Text(
                                        cat['name'],
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: h * 0.017,
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      if (matchedBusinesses.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('बिज़नेस:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: h * 0.023)),
                            ListView.builder(
                              itemCount: matchedBusinesses.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final biz = matchedBusinesses[index];
                                final acf = biz['ams_acf'] ?? [];
                                final owner = _getACF(acf, 'owner_name');
                                final phone = _getACF(acf, 'phone_number');
                                final image = _getACF(acf, 'business_logo');

                                return ListTile(
                                  leading: image != null && image.toString().isNotEmpty
                                      ? CircleAvatar(
                                      backgroundImage:
                                      NetworkImage(image.toString()))
                                      : const CircleAvatar(child: Icon(Icons.store)),
                                  title: Text(biz['title']['rendered']),
                                  subtitle: Text(owner),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.call),
                                    onPressed: () {
                                      launchUrl(Uri.parse('tel:$phone'));
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      else
                        const Text('कोई बिज़नेस नहीं मिला।'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getACF(List list, String key) {
    final item =
    list.firstWhere((e) => e['key'] == key, orElse: () => null);
    if (item == null) return '';
    return item['value'] ?? '';
  }
}
