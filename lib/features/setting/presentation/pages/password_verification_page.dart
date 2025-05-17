import 'package:flutter/material.dart';
import 'package:movie_tickets/features/setting/presentation/pages/account_options_page.dart';

class PasswordVerificationPage extends StatefulWidget {
  const PasswordVerificationPage({super.key});

  @override
  _PasswordVerificationPageState createState() => _PasswordVerificationPageState();
}

class _PasswordVerificationPageState extends State<PasswordVerificationPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isValidating = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _verifyPassword() {
    setState(() {
      _isValidating = true;
    });

    // Simulate API call for password verification
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isValidating = false;
      });
      
      // Navigate to account options Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AccountOptionsPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Xác thực bảo mật',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Vui lòng nhập mật khẩu của bạn để tiếp tục',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValidating ? null : _verifyPassword,
                child: _isValidating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Xác nhận'),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: TextButton(
                onPressed: null, // Handle forgot password
                child: Text('Quên mật khẩu?'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}