import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  Future<void> fetchCart(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await ApiService.getCart(userId);
    } catch (e) {
      debugPrint('Error fetching cart: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(int userId, Product product, int quantity) async {
    try {
      await ApiService.addToCart(userId, product.id, quantity);
      await fetchCart(userId); // Refresh cart
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  Future<void> removeItem(int userId, int cartId) async {
    try {
      await ApiService.removeFromCart(cartId);
      await fetchCart(userId); // Refresh cart
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }
  
  Future<void> removeFromCart(int cartId) async {
    await ApiService.removeFromCart(cartId);
    _items.removeWhere((item) => item.id == cartId);
    notifyListeners();
  }

  void clearCartLocal() {
    _items.clear();
    notifyListeners();
  }

  Future<void> clear(int userId) async {
    _items = [];
    notifyListeners();
  }
}
