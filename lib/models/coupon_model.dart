class Coupon {
  final int id;
  final String code;
  final String description;
  final double amount;
  final String discountType;
  final bool individualUse;
  final int usageLimit;
  final int usageCount;
  final bool freeShipping;

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.amount,
    required this.discountType,
    required this.individualUse,
    required this.usageLimit,
    required this.usageCount,
    required this.freeShipping,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      discountType: json['discount_type'] ?? '',
      individualUse: json['individual_use'] ?? false,
      usageLimit: json['usage_limit'] ?? 0,
      usageCount: json['usage_count'] ?? 0,
      freeShipping: json['free_shipping'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "description": description,
    "amount": amount.toString(),
    "discount_type": discountType,
    "individual_use": individualUse,
    "usage_limit": usageLimit,
    "usage_count": usageCount,
    "free_shipping": freeShipping,
  };
}
