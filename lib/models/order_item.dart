class OrderItem {
  final int id;
  final String username;
  final double totalPrice;
  final String status;
  final String paymentMethod;
  final double depositAmount;
  final bool isDepositPaid;
  final bool isSellerPaid;
  final String createdAt;
  
  // Seller Bank Info (for Admin payout)
  final String? sellerBankName;
  final String? sellerAccountNo;
  final String? sellerAccountHolder;

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
    this.sellerBankName,
    this.sellerAccountNo,
    this.sellerAccountHolder,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      username: json['user']?['username'] ?? 'Khách ẩn danh',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? 'COD',
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
      isDepositPaid: json['isDepositPaid'] ?? false,
      isSellerPaid: json['isSellerPaid'] ?? false,
      createdAt: json['createdAt'] ?? '',
      sellerBankName: json['sellerBankName'],
      sellerAccountNo: json['sellerAccountNo'],
      sellerAccountHolder: json['sellerAccountHolder'],
    );
  }
}
