import 'package:movie_tickets/core/services/local/shared_prefs_services.dart';
import 'package:movie_tickets/features/authentication/data/models/user_model.dart';


class AuthLocalDataSource {
  final SharedPrefService sharedPrefsService;
  AuthLocalDataSource(this.sharedPrefsService);
  Future<void> saveUserData(UserModel user) async {
    await sharedPrefsService.saveValue('user', user.toJson());
    await sharedPrefsService.saveValue('isLoggedIn', true);
    await sharedPrefsService.saveValue('loginSessionExpiredIn', user.refreshTokenExpiry);
    print("User data saved: ${user.toJson()}");
    print("isLoggedIn: ${sharedPrefsService.getValue('isLoggedIn', type: bool)}");
    print("loginSessionExpiredIn: ${user.refreshTokenExpiry}");
  }
  Future<UserModel?> getUserData() async {
    final userJson = sharedPrefsService.getValue('user', type: Map<String, dynamic>);
    if (userJson != null) {
      print("User data retrieved from local storage: $userJson");
      return UserModel.fromJson(userJson);
    }
    print("No user data found from local storage");
    print("isLoggedIn: ${sharedPrefsService.getValue('isLoggedIn', type: bool)}");
    return null;
  }
  Future<bool> isLoggedIn() async {
    return sharedPrefsService.getValue('isLoggedIn', type: bool) ?? false;
  }
  Future<bool> isLoginSessionExpired() async {
    final expiryTime = sharedPrefsService.getValue('loginSessionExpiredIn', type: int) ?? 0;
    return DateTime.now().millisecondsSinceEpoch > expiryTime;
  }
  Future<void> updateLoginSessionExpiry(int expiryTime) async {
    await sharedPrefsService.saveValue('loginSessionExpiredIn', expiryTime);
  }
  Future<void> logout() async {
    await sharedPrefsService.removeValue('user');
    await sharedPrefsService.removeValue('isLoggedIn');
    await sharedPrefsService.removeValue('loginSessionExpiredIn');
  }
}