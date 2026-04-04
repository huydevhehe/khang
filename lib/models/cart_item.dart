import 'product.dart';

class CartItem {
  final int? id;
  final Product product;
  int quantity;

  CartItem({
    this.id,
    required this.product,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson(int userId) {
    return {
      if (id != null) 'id': id,
      'user': {'id': userId},
      'product': {'id': product.id},
      'quantity': quantity,
    };
  }
}
