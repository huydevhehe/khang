import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'order_history_screen.dart';
import 'edit_profile_screen.dart';
import 'admin_orders_screen.dart';
import 'shop_registration_screen.dart';
import 'admin_manage_sellers_screen.dart';
import 'seller_orders_screen.dart';
import 'seller_products_screen.dart';
import 'add_product_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isRefreshing = false;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    // Bắt đầu chế độ đồng bộ ngầm ngay từ khi vào trang (cứ mỗi 5 giây kiểm tra 1 lần)
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _refreshProfile(silent: true);
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshProfile({bool silent = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) return;

    if (!silent) {
      if (mounted) setState(() => _isRefreshing = true);
    }

    try {
      final updatedUser = await ApiService.getUser(auth.user!.id);
      if (updatedUser != null) {
        // Nếu role đổi từ user sang seller, thông báo ngay
        if (updatedUser.role.toLowerCase() != auth.user!.role.toLowerCase()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Chúc mừng! Cửa hàng của bạn đã được Admin phê duyệt!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        await auth.setUser(updatedUser);
      }
    } catch (e) {
      debugPrint('Sync profile failed: $e');
    } finally {
      if (mounted && !silent) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tài khoản'), backgroundColor: Colors.orange),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Vui lòng đăng nhập để xem thông tin'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('ĐĂNG NHẬP', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final user = auth.user!;
    final userRole = user.role.toLowerCase();

    // Dùng list động để render UI linh hoạt và dễ debug
    List<Widget> children = [];

    // 1. Header (Thông tin cá nhân)
    children.add(Container(
      padding: const EdgeInsets.all(20),
      color: Colors.orange.withOpacity(0.1),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.orange,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '@${user.username}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (userRole == 'seller') ...[
                  const SizedBox(height: 8),
                  Text('Shop: ${user.shopName ?? 'Chưa đặt tên'}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('Thu nhập: ${currencyFormat.format(user.balance)} đ', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
        ],
      ),
    ));

    // 2. Section ADMIN
    if (userRole == 'admin') {
      children.add(const _SectionHeader(title: 'QUẢN TRỊ VIÊN'));
      children.add(_buildTile(
        icon: Icons.store_mall_directory,
        title: 'Duyệt yêu cầu mở Shop',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminManageSellersScreen())),
      ));
      children.add(_buildTile(
        icon: Icons.assignment,
        title: 'Quản lý đơn hàng toàn sàn',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen())),
      ));
    }

    // 3. Section SELLER
    if (userRole == 'seller') {
      children.add(const _SectionHeader(title: 'QUẢN LÝ BÁN HÀNG (SELLER)'));
      children.add(_buildTile(
        icon: Icons.add_circle,
        title: 'Đăng sản phẩm mới',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())).then((_) => _refreshProfile()),
      ));
      children.add(_buildTile(
        icon: Icons.inventory,
        title: 'Quản lý tin đăng của tôi',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerProductsScreen())),
      ));
      children.add(_buildTile(
        icon: Icons.shopping_basket,
        title: 'Đơn hàng khách đã đặt',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerOrdersScreen())),
      ));
    }

    // 4. Đăng ký shop (Cho user thường)
    if (userRole == 'user' && (user.shopStatus == 'NONE' || user.shopStatus == null)) {
      children.add(const _SectionHeader(title: 'PHÁT TRIỂN KINH DOANH'));
      children.add(_buildTile(
        icon: Icons.add_business,
        title: 'Trở thành Người bán chuyên nghiệp',
        subtitle: 'Tạo cửa hàng và bán hàng ngay',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopRegistrationScreen())),
      ));
    }

    if (user.shopStatus == 'PENDING') {
      children.add(const _SectionHeader(title: 'TRẠNG THÁI HỒ SƠ'));
      children.add(const ListTile(
        leading: Icon(Icons.timer, color: Colors.blue),
        title: Text('Cửa hàng đang chờ Admin phê duyệt'),
        subtitle: Text('Vui lòng đợi trong giây lát...'),
      ));
    }

    // 5. Hoạt động chung
    children.add(const _SectionHeader(title: 'HOẠT ĐỘNG CỦA TÔI'));
    children.add(_buildTile(
      icon: Icons.history,
      title: 'Lịch sử mua hàng',
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen())),
    ));

    // 6. Hệ thống & Đăng xuất
    children.add(const _SectionHeader(title: 'HỆ THỐNG'));
    children.add(_buildTile(
      icon: Icons.exit_to_app,
      title: 'Đăng xuất tài khoản',
      color: Colors.red,
      onTap: () async {
        await auth.logout();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      },
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản & Quản lý (Live)'), 
        backgroundColor: Colors.orange,
        actions: [
          if (_isRefreshing) 
            const Center(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshProfile(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshProfile(),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: children,
        ),
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap, Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color == Colors.red ? Colors.red : Colors.orange),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.grey.shade100,
      child: Text(
        title, 
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }
}
