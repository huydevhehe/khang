import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'payment_qr_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'BANK';
  bool _isLoading = false;

  Future<void> _placeOrder() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    setState(() => _isLoading = true);
    
    try {
      final orderData = await ApiService.createOrder(auth.user!.id, _paymentMethod);
      
      if (mounted && orderData != null) {
        final orderId = orderData['id'] as int;
        cart.clearCartLocal(); // Xóa giỏ hàng ngay sau khi tạo đơn thành công

        if (_paymentMethod == 'BANK') {
          // Navigate to QR screen for 20% deposit
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PaymentQrScreen(
                orderId: orderId,
                totalAmount: cart.totalAmount,
              ),
            ),
          );
        } else {
          // Pickup: No deposit needed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đặt hàng thành công! Vui lòng tới tận nơi lấy hàng.')),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      print('DEBUG_ERROR: $e'); // In lỗi ra console để debug
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thông báo lỗi'),
            content: Text(e.toString()),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán'), backgroundColor: Colors.orange),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HÌNH THỨC THANH TOÁN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 10),
                _buildPaymentOption(
                  id: 'BANK',
                  title: 'Chuyển khoản đặt cọc 20%',
                  subtitle: 'Mã QR tự động. Admin giữ hộ tiền.',
                  icon: Icons.qr_code,
                ),
                _buildPaymentOption(
                  id: 'PICKUP',
                  title: 'Tới tận nơi lấy (0% cọc)',
                  subtitle: 'Thanh toán trực tiếp cho người bán.',
                  icon: Icons.store,
                ),
                const Spacer(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng tiền hàng:', style: TextStyle(fontSize: 16)),
                    Text('${currencyFormat.format(cart.totalAmount)} đ', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                if (_paymentMethod == 'BANK')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Số tiền cần cọc (20%):', style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                      Text('${currencyFormat.format(cart.totalAmount * 0.2)} đ', style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    _paymentMethod == 'BANK' ? 'ĐẶT HÀNG & CHUYỂN CỌC' : 'XÁC NHẬN ĐẶT HÀNG',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPaymentOption({required String id, required String title, required String subtitle, required IconData icon}) {
    return RadioListTile<String>(
      value: id,
      groupValue: _paymentMethod,
      onChanged: (v) => setState(() => _paymentMethod = v!),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      secondary: Icon(icon, color: Colors.orange),
      activeColor: Colors.orange,
    );
  }
}
