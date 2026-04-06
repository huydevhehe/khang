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

  Future<void> _updateStatus(int orderId, String status) async {
    try {
      await ApiService.updateOrderStatus(orderId, status);
      _fetchOrders();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Đã cập nhật trạng thái: $status'), backgroundColor: Colors.blue));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    }
  }

  String _getBankId(String? bankName) {
    if (bankName == null) return '970422'; // Default MB
    final name = bankName.toLowerCase();
    if (name.contains('vietcom')) return '970436';
    if (name.contains('techcom')) return '970407';
    if (name.contains('mb')) return '970422';
    if (name.contains('bidv')) return '970418';
    if (name.contains('vietin')) return '970415';
    if (name.contains('acb')) return '970416';
    return '970422';
  }

  void _showPayoutDialog(OrderItem order) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');
    final amountText = currencyFormat.format(order.depositAmount);
    
    // Tạo link VietQR (Admin trả lại 20% cọc cho Seller)
    final bankId = _getBankId(order.sellerBankName);
    final qrUrl = 'https://img.vietqr.io/image/$bankId-${order.sellerAccountNo}-compact.jpg?'
        'amount=${order.depositAmount.toInt()}'
        '&addInfo=Giai+ngan+don+hang+${order.id}'
        '&accountName=${Uri.encodeComponent(order.sellerAccountHolder ?? "")}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('💳 Quét mã QR giải ngân cho Seller', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: order.sellerAccountNo == null 
          ? const Text(' Seller chưa nhập thông tin ngân hàng trong Profile!')
          : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Seller: ${order.sellerAccountHolder ?? "Không rõ"}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Số tiền: $amountText đ', style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Image.network(qrUrl, height: 250, errorBuilder: (c, e, s) => const Text('Lỗi tải mã QR')),
              const SizedBox(height: 10),
              Text('STK: ${order.sellerAccountNo} - ${order.sellerBankName}', style: const TextStyle(fontSize: 12)),
              const Divider(),
              const Text('⚠️ Admin hãy quét mã phía trên để chuyển tiền cho người bán. Chỉ bấm "Xác nhận" sau khi đã chuyển khoản thành công.', 
                         style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
            ],
          ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          if (order.sellerAccountNo != null)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _confirmPayout(order.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('XÁC NHẬN ĐÃ CHUYỂN TIỀN', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmPayout(int orderId) async {
    try {
      await ApiService.releasePayout(orderId);
      _fetchOrders();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('💰 Đã cập nhật trạng thái Giải ngân thành công!'), backgroundColor: Colors.blue));
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

                            const Text('GIẢI NGÂN & GIAO HÀNG', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            
                            // NÚT XÁC NHẬN ĐÃ GIAO HÀNG (DÀNH CHO ADMIN)
                            // CHỈ HIỆN KHI ĐANG TRONG TRẠNG THÁI SHIPPING
                            if (order.status == 'SHIPPING')
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _updateStatus(order.id, 'RECEIVED'),
                                    icon: const Icon(Icons.shopping_bag_outlined),
                                    label: const Text('XÁC NHẬN ĐÃ GIAO HÀNG XONG', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green)),
                                  ),
                                ),
                              ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(order.isSellerPaid ? 'TIỀN SELLER: ĐÃ TRẢ' : 'TIỀN SELLER: CHƯA TRẢ', 
                                     style: TextStyle(color: order.isSellerPaid ? Colors.green : Colors.orange, fontSize: 13, fontWeight: FontWeight.bold)),
                                if (order.status == 'RECEIVED' && !order.isSellerPaid && order.isDepositPaid)
                                  ElevatedButton.icon(
                                    onPressed: () => _showPayoutDialog(order),
                                    icon: const Icon(Icons.qr_code, size: 16),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                    label: const Text('HIỆN QR GIẢI NGÂN', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                              ],
                            ),
                            if (order.status != 'RECEIVED')
                              const Text('* Chỉ giải ngân sau khi trạng thái là RECEIVED', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey)),
                          ] else ...[
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
    String label = status;
    if (status == 'PENDING') { color = Colors.orange; label = 'CHỜ XỬ LÝ'; }
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
}
