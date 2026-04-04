import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await ApiService.getProducts();
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchProducts(String keyword) async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await ApiService.searchProducts(keyword);
    } catch (e) {
      debugPrint('Error searching products: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
