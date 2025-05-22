// lib/core/utils/authentication_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/auth_bloc/bloc.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/login_page.dart';

class AuthenticationHelper {
  /// Kiểm tra và yêu cầu xác thực nếu cần thiết
  /// Trả về true nếu người dùng đã được xác thực
  /// Trả về false nếu người dùng từ chối đăng nhập hoặc có lỗi
  static Future<bool> requireAuthentication(BuildContext context) async {
    final authBloc = context.read<AuthenticationBloc>();
    final currentState = authBloc.state;
    
    // Nếu đã xác thực, return true
    if (currentState is Authenticated) {
      return true;
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
    return newState is Authenticated && (result == true);
  }
  
  /// Kiểm tra nhanh trạng thái xác thực hiện tại
  /// Không thực hiện navigation
  static bool isAuthenticated(BuildContext context) {
    final authBloc = context.read<AuthenticationBloc>();
    return authBloc.state is Authenticated;
  }
  
  /// Lấy thông tin người dùng hiện tại (nếu đã đăng nhập)
  static String? getCurrentUserName(BuildContext context) {
    final authBloc = context.read<AuthenticationBloc>();
    final state = authBloc.state;
    
    if (state is Authenticated) {
      return state.displayName;
    }
    return null;
  }
  
  /// Đăng xuất người dùng
  static void logout(BuildContext context) {
    final authBloc = context.read<AuthenticationBloc>();
    authBloc.add(LoggedOut());
  }
}