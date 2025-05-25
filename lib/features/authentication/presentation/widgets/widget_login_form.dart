import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/utils/validators.dart';
import 'package:movie_tickets/features/authentication/presentation/pages/input_email_page.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:movie_tickets/features/authentication/presentation/widgets/widget_btn_social.dart';
import '../bloc/login_bloc/bloc.dart';

class WidgetLoginForm extends StatefulWidget {
  const WidgetLoginForm({super.key});

  @override
  State<WidgetLoginForm> createState() => _WidgetLoginFormState();
}

class _WidgetLoginFormState extends State<WidgetLoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        
        if (state is LoginFailed) {
          _showErrorSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColor.WHITE,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: AppFont.MEDIUM_DEFAULT_12.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: AppFont.REGULAR_GRAY4_12,
                ),
                const SizedBox(height: 32),
                
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    _buildRememberMeCheckbox(),
                    const Spacer(),
                    _buildForgotPasswordButton(),
                  ],
                ),
                
                const SizedBox(height: 32),
                _buildLoginButton(state),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email or Phone',
          style: AppFont.REGULAR_BLACK2_14.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          validator: _emailAndPhoneValidate,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Enter your email or phone',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.GRAY3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.DEFAULT, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: AppColor.GRAY3.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: AppFont.REGULAR_BLACK2_14.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          validator: _passwordValidate,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.GRAY3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.DEFAULT, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: AppColor.GRAY3.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) {
              setState(() {
                _rememberMe = value ?? false;
              });
            },
            activeColor: AppColor.DEFAULT,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Remember me',
          style: AppFont.REGULAR_GRAY1_12,
        ),
      ],
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InputEmailPage(),
          ),
        );
      },
      child: Text(
        'Forgot Password?',
        style: AppFont.REGULAR_DEFAULT_12.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoginButton(LoginState state) {
    final isLoading = state is LoginLoading;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.DEFAULT,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColor.DEFAULT.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'SIGN IN',
                style: AppFont.SEMIBOLD_WHITE_16,
              ),
      ),
    );
  }

  Widget _buildDividerWithText() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColor.GRAY3)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: AppFont.REGULAR_GRAY1_12,
          ),
        ),
        const Expanded(child: Divider(color: AppColor.GRAY3)),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return const Row(
      children: [
        Expanded(
          child: WidgetBtnSocial(
            btnColor: AppColor.GOOGLE_BTN,
            borderColor: AppColor.GOOGLE_BORDER_BTN,
            socialIcon: 'assets/icons/ic_google.svg',
            socialName: 'Google',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: WidgetBtnSocial(
            btnColor: AppColor.FACEBOOK_BTN,
            borderColor: AppColor.FACEBOOK_BORDER_BTN,
            socialIcon: 'assets/icons/ic_facebook.svg',
            socialName: 'Facebook',
          ),
        ),
      ],
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<LoginBloc>().add(
        LoginSubmitEmailPasswordEvent(
          emailPhone: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  String? _emailAndPhoneValidate(String? emailOrPhone) {
    if (emailOrPhone == null || emailOrPhone.trim().isEmpty) {
      return "Please enter email or phone number";
    }
    final trimmed = emailOrPhone.trim();
    if (!Validators.isValidEmail(trimmed) && !Validators.isValidPhoneNumber(trimmed)) {
      return "Please enter a valid email or phone number";
    }
    return null;
  }

  String? _passwordValidate(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}