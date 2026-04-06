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
                                const Text('Trạng thái cọc (khách trả): ', style: TextStyle(fontSize: 12)),
                                Text(
                                  order.isDepositPaid ? 'ĐÃ CỌC' : 'CHỜ CỌC',
                                  style: TextStyle(color: order.isDepositPaid ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Text('Tiền cọc (Admin trả Seller): ', style: TextStyle(fontSize: 12)),
                                Text(
                                  order.isSellerPaid ? 'ĐÃ NHẬN ✅' : 'CHỜ GIẢI NGÂN ⏳',
                                  style: TextStyle(color: order.isSellerPaid ? Colors.blue : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                          
                          const Divider(),
                          const Text('CẬP NHẬT TRẠNG THÁI GIAO HÀNG:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 5),
                          
                          // Thông báo cho Seller nếu chưa cọc
                          if (order.paymentMethod == 'BANK' && !order.isDepositPaid && order.status == 'PENDING')
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('ℹ️ Vui lòng chờ Admin xác nhận nhận tiền cọc của khách để bắt đầu xử lý.', 
                                         style: TextStyle(fontSize: 11, color: Colors.orange, fontStyle: FontStyle.italic)),
                            ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Chỉ hiện "Chuẩn bị hàng" nếu đang PENDING và ĐÃ CỌC (hoặc không phải BANK)
                              if (order.status == 'PENDING' && (order.paymentMethod != 'BANK' || order.isDepositPaid))
                                _statusAction('PREPARING', 'Chuẩn bị hàng', Colors.orange, order.id),
                              
                              // Chỉ hiện "Đang giao" nếu đang ở bước PREPARING
                              if (order.status == 'PREPARING') ...[
                                _statusAction('SHIPPING', 'Đang giao', Colors.blue, order.id),
                              ],
                              
                              // Chỉ cho phép hủy nếu chưa được giải ngân tiền
                              if (!order.isSellerPaid && order.status != 'RECEIVED' && order.status != 'CANCELLED') ...[
                                const SizedBox(width: 8),
                                _statusAction('CANCELLED', 'Hủy đơn', Colors.red, order.id),
                              ],
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
    String label = status;
    if (status == 'PREPARING') { color = Colors.orange; label = 'CHUẨN BỊ'; }
    if (status == 'SHIPPING') { color = Colors.blue; label = 'ĐANG GIAO'; }
    if (status == 'RECEIVED') { color = Colors.green; label = 'HOÀN TẤT'; }
    if (status == 'CANCELLED') { color = Colors.red; label = 'ĐÃ HỦY'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
