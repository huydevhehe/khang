import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/order_item.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  List<OrderItem> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orders = await ApiService.getSellerOrders(auth.user!.id);
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(int orderId, String status) async {
    await ApiService.updateOrderStatus(orderId, status);
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của Shop'), backgroundColor: Colors.orange),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _orders.isEmpty
            ? const Center(child: Text('Chưa có đơn hàng nào.'))
            : ListView.builder(
                itemCount: _orders.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (ctx, i) {
                  final order = _orders[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Đơn hàng #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              _buildStatusBadge(order.status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Khách chọn: ${order.paymentMethod}', style: const TextStyle(fontSize: 12)),
                          Text('Tổng tiền: ${currencyFormat.format(order.totalPrice)} đ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          
                          if (order.paymentMethod == 'BANK') ...[
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Text('Trạng thái cọc (qua Admin): ', style: TextStyle(fontSize: 12)),
                                Text(
                                  order.isDepositPaid ? 'ĐÃ CỌC' : 'CHỜ CỌC',
                                  style: TextStyle(color: order.isDepositPaid ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                          
                          const Divider(),
                          const Text('CẬP NHẬT TRẠNG THÁI GIAO HÀNG:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _statusAction('SHIPPING', 'Đang giao', Colors.blue, order.id),
                              const SizedBox(width: 10),
                              _statusAction('RECEIVED', 'Đã giao xong', Colors.green, order.id),
                              const SizedBox(width: 10),
                              _statusAction('CANCELLED', 'Hủy đơn', Colors.red, order.id),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'SHIPPING') color = Colors.blue;
    if (status == 'RECEIVED') color = Colors.green;
    if (status == 'CANCELLED') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _statusAction(String status, String label, Color color, int orderId) {
    return ElevatedButton(
      onPressed: () => _updateStatus(orderId, status),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
