// lib/core/utils/authentication_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/auth_bloc/bloc.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/login_page.dart';

class AuthenticationHelper {
  /// Kiểm tra và yêu cầu xác thực nếu cần thiết
  /// Trả về true nếu người dùng đã được xác thực hoặc đăng nhập thành công
  /// Trả về false nếu người dùng từ chối đăng nhập hoặc có lỗi
  static Future<bool> requireAuthentication(BuildContext context, {String? redirectMessage}) async {
    final authBloc = context.read<AuthenticationBloc>();
    final currentState = authBloc.state;
    
    // Nếu đã xác thực, return true
    if (currentState is Authenticated) {
      return true;
    }
    
    // Hiển thị dialog thông báo nếu có message
    if (redirectMessage != null) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Yêu cầu đăng nhập'),
            content: Text(redirectMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          );
        },
      );
    }
    
    // Nếu chưa xác thực, chuyển đến trang đăng nhập
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
        settings: const RouteSettings(name: '/login'),
      ),
    );
    
    // Kiểm tra lại trạng thái sau khi quay về từ trang đăng nhập
    final newState = authBloc.state;
    return newState is Authenticated;
  }
  
  /// Wrapper function để thực hiện action chỉ khi đã authenticated
  static Future<T?> executeWithAuth<T>(
    BuildContext context, 
    Future<T> Function() action, {
    String? authMessage,
  }) async {
    final isAuthenticated = await requireAuthentication(
      context, 
      redirectMessage: authMessage,
    );
    
    if (isAuthenticated) {
      return await action();
    }
    return null;
  }
  
  /// Kiểm tra nhanh trạng thái xác thực hiện tại
  /// Không thực hiện navigation
  static bool isAuthenticated(BuildContext context) {
    final authBloc = context.read<AuthenticationBloc>();
    return authBloc.state is Authenticated;
  }
  
  /// Lấy thông tin người dùng hiện tại (nếu đã đăng nhập)
  static UserModel? getCurrentUser(BuildContext context) {
    final authBloc = context.read<AuthenticationBloc>();
    final state = authBloc.state;
    
    if (state is Authenticated) {
      return state.user;
    }
    return null;
  }
  
  /// Lấy ID người dùng hiện tại (nếu đã đăng nhập)
  static String? getCurrentUserId(BuildContext context) {
    final authBloc = context.read<AuthenticationBloc>();
    final state = authBloc.state;
    
    if (state is Authenticated) {
      return state.user.userId;
    }
    return null;
  }
  
  /// Đăng xuất người dùng
  static void logout(BuildContext context) {
    final authBloc = context.read<AuthenticationBloc>();
    authBloc.add(LoggedOut());
  }
  
  /// Show snackbar khi cần authentication
  static void showAuthRequiredSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Đăng nhập',
          onPressed: () {
            requireAuthentication(context);
          },
        ),
      ),
    );
  }
}