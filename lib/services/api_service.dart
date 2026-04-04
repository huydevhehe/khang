import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; 
import 'package:path/path.dart' as path;
import '../models/user.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order_item.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    } else {
      return 'http://10.0.2.2:8080/api';
    }
  }

  // --- SHOP / SELLER REGISTRATION ---
  static Future<User?> requestShop(int userId, String shopName, String shopAddress) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/request-shop'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'shopName': shopName,
        'shopAddress': shopAddress,
      }),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<User?> approveShop(int userId) async {
    final response = await http.put(Uri.parse('$baseUrl/users/$userId/approve-shop'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<List<User>> getPendingShops() async {
    final response = await http.get(Uri.parse('$baseUrl/users/pending-shops'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    return [];
  }

  // --- ORDERS / ESCROW ---
  static Future<Map<String, dynamic>?> createOrder(int userId, String paymentMethod) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'paymentMethod': paymentMethod,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Ném lỗi kèm theo nội dung từ Server (ví dụ: "Giỏ hàng rỗng")
      throw response.body; 
    }
  }

  static Future<void> confirmDeposit(int orderId) async {
    await http.put(Uri.parse('$baseUrl/orders/$orderId/confirm-deposit'));
  }

  static Future<void> releasePayout(int orderId) async {
    await http.put(Uri.parse('$baseUrl/orders/$orderId/release-payout'));
  }

  static Future<List<OrderItem>> getOrders(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/orders/user/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => OrderItem.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<OrderItem>> getSellerOrders(int sellerId) async {
    final response = await http.get(Uri.parse('$baseUrl/orders/seller/$sellerId'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => OrderItem.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<OrderItem>> getAllOrdersAdmin() async {
    final response = await http.get(Uri.parse('$baseUrl/orders/admin/all'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => OrderItem.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> updateOrderStatus(int orderId, String status) async {
    await http.put(
      Uri.parse('$baseUrl/orders/$orderId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
  }

  // --- AUTH ---
  static Future<User?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<User?> register(String username, String password, String fullName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'fullName': fullName,
      }),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // --- USERS ---
  static Future<User?> updateProfile(int userId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<User?> getUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<User?> getAdminInfo() async {
    final response = await http.get(Uri.parse('$baseUrl/users/admin-info'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // --- PRODUCTS ---
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<Product>> getMyProducts(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/products/owner/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<Product>> searchProducts(String keyword) async {
    final response = await http.get(Uri.parse('$baseUrl/products/search?keyword=$keyword'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> deleteProduct(int productId) async {
    await http.delete(Uri.parse('$baseUrl/products/$productId'));
  }

  static Future<bool> uploadProduct({
    required String title,
    required double price,
    required String description,
    required String category,
    required int ownerId,
    XFile? imageFile,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products/add-with-image'));
    request.fields['title'] = title;
    request.fields['price'] = price.toString();
    request.fields['description'] = description;
    request.fields['category'] = category;
    request.fields['ownerId'] = ownerId.toString();

    if (imageFile != null) {
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          await imageFile.readAsBytes(),
          filename: imageFile.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: path.basename(imageFile.path),
        ));
      }
    }

    var response = await request.send();
    return response.statusCode == 200;
  }

  // --- CART ---
  static Future<List<CartItem>> getCart(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/cart/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CartItem.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> addToCart(int userId, int productId, int quantity) async {
    await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': {'id': userId},
        'product': {'id': productId},
        'quantity': quantity,
      }),
    );
  }

  static Future<void> removeFromCart(int cartId) async {
    await http.delete(Uri.parse('$baseUrl/cart/$cartId'));
  }
}
