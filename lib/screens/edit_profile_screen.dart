import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _accountNoController;
  late TextEditingController _accountHolderController;
  String? _selectedBank;

  final List<String> _banks = [
    'MB Bank',
    'Vietcombank',
    'Techcombank',
    'VietinBank',
    'Agribank',
    'BIDV',
    'Momo',
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    _nameController = TextEditingController(text: user.fullName);
    _accountNoController = TextEditingController(text: user.accountNo);
    _accountHolderController = TextEditingController(text: user.accountHolder);
    _selectedBank = user.bankName;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await ApiService.updateProfile(auth.user!.id, {
      'fullName': _nameController.text,
      'bankName': _selectedBank,
      'accountNo': _accountNoController.text,
      'accountHolder': _accountHolderController.text,
    });

    if (success != null) {
      auth.setUser(success);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa thông tin'), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thông tin cơ bản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 30),
              
              if (user.role == 'admin') ...[
                const Text('Thông tin Ngân hàng (Đăng tin)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedBank,
                  decoration: const InputDecoration(labelText: 'Chọn Ngân hàng'),
                  items: _banks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (v) => setState(() => _selectedBank = v),
                  validator: (v) => v == null ? 'Vui lòng chọn ngân hàng' : null,
                ),
                TextFormField(
                  controller: _accountNoController,
                  decoration: const InputDecoration(labelText: 'Số tài khoản'),
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập STK' : null,
                ),
                TextFormField(
                  controller: _accountHolderController,
                  decoration: const InputDecoration(labelText: 'Chủ tài khoản (Viết hoa không dấu)'),
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên chủ TK' : null,
                ),
              ],
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('LƯU THÔNG TIN', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
