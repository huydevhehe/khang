class OrderItem {
  final int id;
  final String username; // Thêm lại trường này để Admin biết ai mua
  final double totalPrice;
  final String status;
  final String paymentMethod;
  final double depositAmount;
  final bool isDepositPaid;
  final bool isSellerPaid;
  final String createdAt;

  OrderItem({
    required this.id,
    required this.username,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    required this.depositAmount,
    required this.isDepositPaid,
    required this.isSellerPaid,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      // Lấy username từ đối tượng user bên trong order
      username: json['user']?['username'] ?? 'Khách ẩn danh',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? 'COD',
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
      isDepositPaid: json['isDepositPaid'] ?? false,
      isSellerPaid: json['isSellerPaid'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
