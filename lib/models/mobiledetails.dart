class BusinessModel {
  final String title;
  final String ownerName;
  final String phoneNumber;
  final String whatsappNumber;
  final String businessLogo;
  final String link;

  BusinessModel({
    required this.title,
    required this.ownerName,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.businessLogo,
    required this.link,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    // AMS ACF से value निकालना
    String getACFValue(String key) {
      final acf = json['ams_acf'] as List;
      final match = acf.firstWhere(
            (item) => item['key'] == key,
        orElse: () => {'value': ''},
      );
      return match['value']?.toString() ?? '';
    }

    return BusinessModel(
      title: json['title']['rendered'] ?? '',
      ownerName: getACFValue('owner_name'),
      phoneNumber: getACFValue('phone_number'),
      whatsappNumber: getACFValue('whatsapp_number'),
      businessLogo: getACFValue('business_logo'),
      link: json['link'] ?? '',
    );
  }
}
