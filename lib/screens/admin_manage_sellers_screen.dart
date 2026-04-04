import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AdminManageSellersScreen extends StatefulWidget {
  const AdminManageSellersScreen({super.key});

  @override
  State<AdminManageSellersScreen> createState() => _AdminManageSellersScreenState();
}

class _AdminManageSellersScreenState extends State<AdminManageSellersScreen> {
  List<User> _pendingSellers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSellers();
  }

  Future<void> _fetchSellers() async {
    final sellers = await ApiService.getPendingShops();
    if (mounted) {
      setState(() {
        _pendingSellers = sellers;
        _isLoading = false;
      });
    }
  }

  Future<void> _approve(int userId) async {
    final updated = await ApiService.approveShop(userId);
    if (updated != null) {
      _fetchSellers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt Shop thành công!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Duyệt mở Shop'), backgroundColor: Colors.orange),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _pendingSellers.isEmpty
            ? const Center(child: Text('Không có yêu cầu nào đang chờ.'))
            : ListView.builder(
                itemCount: _pendingSellers.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (ctx, i) {
                  final seller = _pendingSellers[i];
                  return Card(
                    child: ListTile(
                      title: Text(seller.shopName ?? 'Chưa rõ tên shop', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chủ shop: ${seller.fullName}'),
                          Text('Địa chỉ: ${seller.shopAddress}'),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _approve(seller.id),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('DUYỆT', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
