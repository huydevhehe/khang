import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _price = 0;
  String _description = '';
  String _category = 'Đồ điện tử';
  XFile? _imageFile;
  Uint8List? _webImage;
  bool _isLoading = false;

  final List<String> _categories = ['Đồ điện tử', 'Xe cộ', 'Bất động sản', 'Thời trang', 'Đồ gia dụng'];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageFile = image;
          _webImage = bytes;
        });
      } else {
        setState(() {
          _imageFile = image;
        });
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) return;

    setState(() => _isLoading = true);
    
    bool success = await ApiService.uploadProduct(
      title: _title,
      price: _price,
      description: _description,
      category: _category,
      ownerId: auth.user!.id,
      imageFile: _imageFile,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng tin thành công!')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng tin thất bại!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    // Security check: Only seller or admin can see this screen (though the button should be hidden anyway)
    if (user == null || (user.role != 'admin' && user.role != 'seller')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi quyền truy cập')),
        body: const Center(child: Text('Chỉ người bán hoặc Admin mới được quyền đăng tin.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng tin mới'), backgroundColor: Colors.orange),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                      child: _imageFile == null 
                        ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                        : (kIsWeb ? Image.memory(_webImage!, fit: BoxFit.cover) : Image.network(_imageFile!.path, fit: BoxFit.cover)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Tiêu đề tin đăng'),
                    validator: (v) => v!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                    onSaved: (v) => _title = v!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Giá bán (VND)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Vui lòng nhập giá' : null,
                    onSaved: (v) => _price = double.parse(v!),
                  ),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(labelText: 'Danh mục'),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Vui lòng nhập mô tả' : null,
                    onSaved: (v) => _description = v!,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('ĐĂNG TIN NGAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
