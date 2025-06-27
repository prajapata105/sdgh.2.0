import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ssda/models/cart_item_model.dart';
import 'package:ssda/models/coupon_model.dart';

class CartService extends GetxController {
  // --- Observables ---
  final cartItems = <CartItem>[].obs;
  final Rx<Coupon?> appliedCoupon = Rx<Coupon?>(null);

  // --- Local Storage ---
  final _box = GetStorage();

  // --- Init State: Restore Cart & Coupon ---
  @override
  void onInit() {
    super.onInit();

    // Restore Cart
    final savedItems = _box.read<List>('cartItems');
    if (savedItems != null) {
      cartItems.value = savedItems
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    ever(cartItems, (_) => _saveCartToStorage());

    // Restore Coupon
    final savedCoupon = _box.read('appliedCoupon');
    if (savedCoupon != null) {
      appliedCoupon.value = Coupon.fromJson(Map<String, dynamic>.from(savedCoupon));
    }
    ever(appliedCoupon, (_) => _saveCouponToStorage());
  }

  // --- Cart Logic ---

  /// Add item to cart. If exists, increases quantity.
  void addToCart(CartItem item) {
    final index = cartItems.indexWhere(
            (e) => e.id == item.id && e.variation == item.variation);
    if (index == -1) {
      cartItems.add(item);
    } else {
      final existing = cartItems[index];
      cartItems[index] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
    }
  }

  /// Remove item from cart.
  void removeFromCart(CartItem item) {
    cartItems.removeWhere(
            (e) => e.id == item.id && e.variation == item.variation);
  }

  /// Update quantity (set absolute qty).
  void updateQuantity(CartItem item, int qty) {
    final index = cartItems.indexWhere(
            (e) => e.id == item.id && e.variation == item.variation);
    if (index != -1) {
      if (qty <= 0) {
        removeFromCart(item);
      } else {
        cartItems[index] = cartItems[index].copyWith(quantity: qty);
      }
    }
  }

  /// Clears all cart items and removes applied coupon.
  void clearCart() {
    cartItems.clear();
    removeCoupon();
  }

  // --- Coupon Logic ---
  void applyCoupon(Coupon coupon) {
    appliedCoupon.value = coupon;
  }

  void removeCoupon() {
    appliedCoupon.value = null;
  }

  // --- Calculation Getters ---

  int get totalItems => cartItems.fold(0, (a, b) => a + b.quantity);

  double get subtotal =>
      cartItems.fold(0, (a, b) => a + b.price * b.quantity);

  double get discount => appliedCoupon.value?.amount?.toDouble() ?? 0.0;

  double get deliveryCharge => subtotal < 200 && subtotal > 0 ? 1.0 : 0.0;

  double get grandTotal {
    final value = subtotal - discount + deliveryCharge;
    return value > 0 ? value : 0;
  }

  // --- Storage Sync ---
  void _saveCartToStorage() {
    _box.write('cartItems', cartItems.map((e) => e.toJson()).toList());
  }

  void _saveCouponToStorage() {
    if (appliedCoupon.value != null) {
      _box.write('appliedCoupon', appliedCoupon.value!.toJson());
    } else {
      _box.remove('appliedCoupon');
    }
  }
}
