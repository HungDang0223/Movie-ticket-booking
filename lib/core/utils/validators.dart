class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );
  static final RegExp _phoneRegExp = RegExp(
    r'^\d{10,15}$'
  );
  static final RegExp _passwordRegExp = RegExp(
    r'^.{4,8}$',
  );

  static bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    return _passwordRegExp.hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return _passwordRegExp.hasMatch(password) && password.isNotEmpty;
  }

  static isValidName(String name) {
    return name.isNotEmpty;
  }
}
