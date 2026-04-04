class User {
  final int id;
  final String username;
  final String fullName;
  final String role;
  
  // Shop Info
  final String? shopName;
  final String? shopAddress;
  final String? shopStatus; // NONE, PENDING, APPROVED
  
  // Wallet Balance
  final double balance;

  // Bank Info
  final String? bankName;
  final String? accountNo;
  final String? accountHolder;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.shopName,
    this.shopAddress,
    this.shopStatus,
    this.balance = 0.0,
    this.bankName,
    this.accountNo,
    this.accountHolder,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'user',
      shopName: json['shopName'],
      shopAddress: json['shopAddress'],
      shopStatus: json['shopStatus'] ?? 'NONE',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      bankName: json['bankName'],
      accountNo: json['accountNo'],
      accountHolder: json['accountHolder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'role': role,
      'shopName': shopName,
      'shopAddress': shopAddress,
      'shopStatus': shopStatus,
      'balance': balance,
      'bankName': bankName,
      'accountNo': accountNo,
      'accountHolder': accountHolder,
    };
  }
}
