import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/order_item.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<OrderItem> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user!.id;
    final orders = await ApiService.getOrders(userId);
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử đơn hàng'), backgroundColor: Colors.orange),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _orders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (ctx, i) {
              final order = _orders[i];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text('Đơn hàng #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ngày: ${order.createdAt.split('T')[0]}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _getStatusBadge(order.status),
                          const SizedBox(width: 8),
                          _getPaymentBadge(order.paymentMethod),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text('${order.totalPrice.toInt()} đ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ),
              );
            },
          ),
    );
  }

  Widget _getStatusBadge(String status) {
    Color color = Colors.grey;
    String text = status;
    if (status == 'PENDING') { color = Colors.orange; text = 'Chờ xử lý'; }
    else if (status == 'SHIPPING') { color = Colors.blue; text = 'Đang giao'; }
    else if (status == 'RECEIVED') { color = Colors.green; text = 'Đã nhận'; }
    else if (status == 'CANCELLED') { color = Colors.red; text = 'Đã hủy'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }

  Widget _getPaymentBadge(String method) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(5)),
      child: Text(method, style: const TextStyle(fontSize: 10)),
    );
  }
}
