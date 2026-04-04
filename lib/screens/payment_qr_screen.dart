import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class PaymentQrScreen extends StatefulWidget {
  final int orderId;
  final double totalAmount;

  const PaymentQrScreen({
    super.key, 
    required this.orderId, 
    required this.totalAmount
  });

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  User? adminInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  Future<void> _loadAdminInfo() async {
    final info = await ApiService.getAdminInfo();
    if (mounted) {
      setState(() {
        adminInfo = info;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán tiền cọc 20%
    final depositAmount = widget.totalAmount * 0.2;
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    // Nếu thông tin admin chưa load xong
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Nếu admin chưa cài đặt số tài khoản (Lỗi mày gặp ở page trước thường do bank info sai)
    final bankId = "MBBank";
    final accountNo = adminInfo?.accountNo ?? "1111111"; // Default mockup if null
    final accountName = adminInfo?.accountHolder ?? "Admin Cho Tot";
    
    // URL VietQR (Sửa format chuẩn để không bị lỗi ImageCodec)
    final qrUrl = "https://img.vietqr.io/image/$bankId-$accountNo-compact2.jpg?amount=${depositAmount.toInt()}&addInfo=Coc%2020%20don%20hang%20${widget.orderId}&accountName=${Uri.encodeComponent(accountName)}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán tiền cọc 20%'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Quét mã QR dưới đây để chuyển khoản tiền cọc 20% cho Admin Chợ Tốt.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tiền cọc sẽ được Admin giữ hộ và giải ngân cho người bán sau khi bạn nhận hàng thành công.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 30),
            
            // HIỂN THỊ MÃ QR VỚI XỬ LÝ LỖI
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.network(
                  qrUrl,
                  height: 250,
                  width: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      width: 250,
                      color: Colors.grey.shade100,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('Lỗi tạo mã QR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('Vui lòng kiểm tra lại thông tin ngân hàng của Admin trong DB.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),
            _infoRow('Số tiền cọc:', '${currencyFormat.format(depositAmount)} đ', isBold: true, color: Colors.red),
            _infoRow('Ngân hàng:', adminInfo?.bankName ?? 'MB Bank'),
            _infoRow('Số tài khoản:', accountNo),
            _infoRow('Chủ tài khoản:', accountName),
            _infoRow('Nội dung:', 'Cọc 20% đơn hàng ${widget.orderId}'),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yêu cầu đã được gửi. Vui lòng đợi Admin xác nhận cọc!')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('XÁC NHẬN ĐÃ CHUYỂN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
