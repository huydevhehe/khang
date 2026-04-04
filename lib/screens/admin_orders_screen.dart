import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/order_item.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<OrderItem> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final orders = await ApiService.getAllOrdersAdmin();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDeposit(int orderId) async {
    try {
      await ApiService.confirmDeposit(orderId);
      _fetchOrders();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Đã xác nhận khách thanh toán cọc!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _releasePayout(int orderId) async {
    try {
      await ApiService.releasePayout(orderId);
      _fetchOrders();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('💰 Đã giải ngân tiền cho Seller thành công!'), backgroundColor: Colors.blue));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(title: const Text('Admin: Quản lý Escrow (Cọc)'), backgroundColor: Colors.orange),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _orders.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (ctx, i) {
              final order = _orders[i];
              final isBank = order.paymentMethod.toUpperCase() == 'BANK';
              
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    // Header Đơn hàng
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Đơn hàng #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          _buildStatusBadge(order.status),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Khách hàng: ${order.username}', style: const TextStyle(fontSize: 13)),
                          Text('PTTT: ${order.paymentMethod}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          const SizedBox(height: 4),
                          Text('Tổng giá trị: ${currencyFormat.format(order.totalPrice)} đ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                          
                          const Divider(height: 30),

                          if (isBank) ...[
                            // KHU VỰC DÀNH CHO THANH TOÁN CHUYỂN KHOẢN (CỌC 20%)
                            const Text('TIỀN CỌC ESCROW (ADMIN GIỮ)', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Số tiền cọc (20%): ${currencyFormat.format(order.depositAmount)} đ', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: order.isDepositPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    order.isDepositPaid ? 'ĐÃ NHẬN TIỀN' : 'CHỜ KHÁCH CỌC',
                                    style: TextStyle(color: order.isDepositPaid ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),

                            // NÚT DUYỆT CỌC (CHỈ HIỆN KHI CHƯA CỌC)
                            if (!order.isDepositPaid)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _confirmDeposit(order.id),
                                  icon: const Icon(Icons.check_circle, color: Colors.white),
                                  label: const Text('XÁC NHẬN ĐÃ NHẬN CỌC (20%)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                ),
                              ),

                            const Divider(height: 30),

                            const Text('GIẢI NGÂN CHO NGƯỜI BÁN (SELLER)', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(order.isSellerPaid ? 'Trạng thái: ĐÃ TRẢ TIỀN' : 'Trạng thái: CHƯA THANH TOÁN', 
                                     style: TextStyle(color: order.isSellerPaid ? Colors.green : Colors.orange, fontSize: 13, fontWeight: FontWeight.bold)),
                                if (order.status == 'RECEIVED' && !order.isSellerPaid && order.isDepositPaid)
                                  ElevatedButton(
                                    onPressed: () => _releasePayout(order.id),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                    child: const Text('DUYỆT GIẢI NGÂN', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                              ],
                            ),
                            if (order.status != 'RECEIVED')
                              const Text('* Chỉ giải ngân sau khi Khách đã nhận hàng (RECEIVED)', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey)),
                          ] else ...[
                            // KHU VỰC PICKUP (KHÔNG CỌC)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('Hình thức Lấy hàng trực tiếp: Không qua Escrow/Cọc.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
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
}
