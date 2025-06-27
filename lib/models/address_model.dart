class Address {
  final String id;
  final String name;
  final String phone;
  final String house;
  final String area;
  final String city;
  final String pincode;
  final String state;
  final String? googleMapLink;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.house,
    required this.area,
    required this.city,
    required this.pincode,
    required this.state,
    this.googleMapLink,
  });

  factory Address.fromWooShipping(Map<String, dynamic> json) => Address(
    id: "shipping",
    name: "${json['first_name'] ?? ""} ${json['last_name'] ?? ""}".trim(),
    phone: json['phone'] ?? '',
    house: json['address_1'] ?? '',
    area: json['address_2'] ?? '',
    city: json['city'] ?? '',
    pincode: json['postcode'] ?? '',
    state: json['state'] ?? '',
    googleMapLink: json['google_map_link'] ?? '',
  );

  Map<String, dynamic> toShippingJson() => {
    "first_name": name.split(" ").first,
    "last_name": name.split(" ").length > 1 ? name.split(" ").sublist(1).join(" ") : "",
    "address_1": house,
    "address_2": area,
    "city": city,
    "state": state,
    "postcode": pincode,
    if (googleMapLink != null && googleMapLink!.isNotEmpty) "google_map_link": googleMapLink,
    if (phone.isNotEmpty) "phone": phone,
  };

  bool get isEmpty => name.isEmpty && house.isEmpty && city.isEmpty;

  static Address empty() => Address(
    id: "shipping", name: "", phone: "", house: "", area: "", city: "", pincode: "", state: "", googleMapLink: "",
  );
}
