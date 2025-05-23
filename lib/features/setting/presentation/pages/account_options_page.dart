import 'package:flutter/material.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/features/setting/presentation/pages/change_password_page.dart';
import 'package:movie_tickets/core/extensions/string_ext.dart';

class AccountOptionsPage extends StatelessWidget {
  const AccountOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.account'.i18n(), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'settings.manageAccount'.i18n(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'settings.updateAccountInfo'.i18n(),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildAccountOption(
              context,
              'settings.userInfo'.i18n(),
              Icons.person,
              () {
                Navigator.pushNamed(context, '/user-info');
              },
            ),
            const SizedBox(height: 16),
            _buildAccountOption(
              context,
              'Đổi mật khẩu',
              Icons.lock,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.DEFAULT.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColor.DEFAULT),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}