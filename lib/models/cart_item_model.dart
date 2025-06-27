class CartItem {
  final int id;
  final String title;
  final String imageUrl;
  final double price;
  final int quantity;
  final String? variation;
  final String? sku;
  final String? brand;

  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.variation,
    this.sku,
    this.brand,
  });

  CartItem copyWith({
    int? id,
    String? title,
    String? imageUrl,
    double? price,
    int? quantity,
    String? variation,
    String? sku,
    String? brand,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      variation: variation ?? this.variation,
      sku: sku ?? this.sku,
      brand: brand ?? this.brand,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      variation: json['variation'],
      sku: json['sku'],
      brand: json['brand'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'imageUrl': imageUrl,
    'price': price,
    'quantity': quantity,
    'variation': variation,
    'sku': sku,
    'brand': brand,
  };
}
