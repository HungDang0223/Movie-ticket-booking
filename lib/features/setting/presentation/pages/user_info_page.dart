import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:movie_tickets/core/services/networking/upload_services.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/email_verification_page.dart';

import '../../../../core/constants/my_const.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final TextEditingController _nameController = TextEditingController(text: 'Nguyễn Văn A');
  final TextEditingController _phoneController = TextEditingController(text: '0912345678');
  final TextEditingController _emailController = TextEditingController();
  
  DateTime _selectedDate = DateTime(1990, 1, 1);
  String? _gender = 'Nam';
  String email = 'nguyenvana@gmail.com';
  File? _imageFile;
  String? _avatarUrl;
  bool _isSaving = false;
  final bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    // Giả lập dữ liệu người dùng
    _emailController.text = email.replaceRange(3, email.indexOf('@'), '****');
    _avatarUrl = 'https://hjpcomvusdrclccarcwt.supabase.co/storage/v1/object/sign/user-image/uploads/1747451172437?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InN0b3JhZ2UtdXJsLXNpZ25pbmcta2V5XzQxZWFmYzYxLWYxMTMtNDdjNi1hZGQxLTQ1N2ZhNWIyYjZlNiJ9.eyJ1cmwiOiJ1c2VyLWltYWdlL3VwbG9hZHMvMTc0NzQ1MTE3MjQzNyIsImlhdCI6MTc0NzQ1MjQzNywiZXhwIjoxNzUwMDQ0NDM3fQ.-bsVu9kYFOcBhiGdHrpzedZ8C3FD7jqDYuhqM9SZVLQ';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn nguồn ảnh'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Thư viện ảnh'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
                const Divider(),
                GestureDetector(
                  child: const ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Camera'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    // Nếu người dùng đã chọn nguồn
    if (source != null) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80, // Giảm chất lượng để tối ưu bộ nhớ
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    }
  }
  

  Future<void> _uploadImage() async {
    if (_imageFile == null) return ;

    try {
      // Sử dụng isolate để xử lý việc upload ảnh
      final result = await UploadService.uploadImage(_imageFile!);
      
      if (result['success']) {
        // Cập nhật URL ảnh nếu upload thành công
        setState(() {
          _avatarUrl = result['url'];
        });
      } else {
        // Xử lý lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi tải ảnh lên: ${result['error']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải ảnh lên: $e')),
        );
      }
    }
  }

  void _saveUserInfo() async {
    setState(() {
      _isSaving = true;
    });

    // Upload image if selected
    if (_imageFile != null) {
      await _uploadImage();
    }

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSaving = false;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thông tin đã được cập nhật thành công'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('vi','VN'), // Sửa lỗi: thêm từ khóa const
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.DEFAULT,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showChangeEmailDialog() {
    final TextEditingController newEmailController = TextEditingController(); // Sửa lỗi: bỏ dấu gạch dưới
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thay đổi Email'),
        content: TextField(
          controller: newEmailController,
          decoration: const InputDecoration(
            labelText: 'Email mới',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmailVerificationPage(
                    email: newEmailController.text,
                  ),
                ),
              );
            },
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _selectImage,
                    child: Stack(
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                            image: _imageFile != null
                                ? DecorationImage(
                                    image: FileImage(_imageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : _avatarUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(_avatarUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: _avatarUrl == null && _imageFile == null
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColor.DEFAULT,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chạm để thay đổi ảnh đại diện',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Thông tin cơ bản',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _nameController,
              label: 'Họ và tên',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _phoneController,
              label: 'Số điện thoại',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height:10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintStyle: const TextStyle(fontSize: 14), // Sửa lỗi: thêm từ khóa const
                      prefixIcon: const Icon(Icons.email_outlined),
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isEmailVerified)
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmailVerificationPage(
                                      email: email, // Sửa lỗi: sử dụng biến email thay vì _emailController.text
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Xác thực'),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColor.DEFAULT),
                            onPressed: _showChangeEmailDialog,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.calendar_month_outlined, color: Colors.grey),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Center(
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down)
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: _gender,
                          underline: const SizedBox(),
                          items: <String>['Nam', 'Nữ', 'Khác']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _gender = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveUserInfo,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColor.DEFAULT,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, color: AppColor.DEFAULT),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColor.DEFAULT),
        prefixIcon: Icon(prefixIcon),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColor.GRAY5)), // Sửa lỗi: bỏ const thừa
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColor.DEFAULT, width: 1.5))
      ),
    );
  }
}