import 'package:movie_tickets/core/utils/multi_devices.dart';
import 'package:movie_tickets/core/utils/validators.dart';
import 'package:movie_tickets/features/movies/presentation/pages/home_page.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/auth_bloc/bloc.dart';
import 'package:movie_tickets/injection.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/authentication/presentation/widgets/widget_btn_social.dart';

import '../bloc/login_bloc/bloc.dart';

class WidgetLoginForm extends StatefulWidget {
  @override
  _WidgetLoginFormState createState() => _WidgetLoginFormState();
}

class _WidgetLoginFormState extends State<WidgetLoginForm> {
  late AuthenticationBloc _authenticationBloc;
  late LoginBloc _loginBloc;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _authenticationBloc = sl<AuthenticationBloc>();
    _loginBloc = sl<LoginBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      
      builder: (context, state) {
        print("Current state: $state");
        if (state is LoginSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/home');
          });
        }
    
        if (state is LoginFailed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Đăng nhập thất bại.\n${state.message}'),
                    const Icon(Icons.error, color: Colors.red),
                  ],
                ),
                backgroundColor: AppColor.WHITE,
              ),
            );
          });
          
        }
        if (state is LoginLoading) {
          return Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          );
      }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            color: AppColor.WHITE,
          ),
          child: Form(
            key: _formKey, // Assign the form key
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Login to your account',
                      style: AppFont.MEDIUM_DEFAULT_16),
                ),
                const SizedBox(height: 20),
                _buildTextFieldUsername(),
                const SizedBox(height: 14),
                _buildTextFieldPassword(),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot password ?',
                    style: AppFont.REGULAR_GRAY4_12,
                  ),
                ),
                const SizedBox(height: 20),
                _buildButtonLogin(state),
                const SizedBox(height: 30),
                _buildTextOr(),
                const SizedBox(height: 20),
                _buildSocialLogin(),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildSocialLogin() {
    return const SizedBox(
      height: 40,
      child: Row(
        children: <Widget>[
          WidgetBtnSocial(
              btnColor: AppColor.GOOGLE_BTN,
              borderColor: AppColor.GOOGLE_BORDER_BTN,
              socialIcon: 'assets/icons/ic_google.svg',
              socialName: 'Google'),
          SizedBox(width: 20),
          WidgetBtnSocial(
              btnColor: AppColor.FACEBOOK_BTN,
              borderColor: AppColor.FACEBOOK_BORDER_BTN,
              socialIcon: 'assets/icons/ic_facebook.svg',
              socialName: 'Facebook'),
        ],
      ),
    );
  }

  _buildTextOr() {
    return Stack(
      children: <Widget>[
        const Align(
          alignment: Alignment.center,
          child: Divider(
            color: AppColor.BLACK_30,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            color: AppColor.WHITE,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Text(
                'Or',
                style: AppFont.REGULAR_GRAY5_10,
              ),
            ),
          ),
        )
      ],
    );
  }

  _buildButtonLogin(LoginState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: MultiDevices.getValueByScale(10)),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            context.read<LoginBloc>().add(LoginSubmitEmailPasswordEvent(
              emailPhone: _emailController.text,
              password: _passwordController.text,
            ));
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: AppColor.DEFAULT
        ),
        child: Text(
          'Login'.toUpperCase(),
          style: AppFont.SEMIBOLD_WHITE_18,
        ),
      ),
    );
  }

  _buildTextFieldPassword() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        color: AppColor.GRAY3,
      ),
      child: Center(
        child: TextFormField(
          controller: _passwordController,
          validator: _passwordValidate,
          style: AppFont.REGULAR_GRAY1_12,
          maxLines: 1,
          keyboardType: TextInputType.text,
          obscureText: true,
          textAlign: TextAlign.left,
          decoration: const InputDecoration.collapsed(
            hintText: 'Mật khẩu',
          ),
        ),
      ),
    );
  }

  String? _passwordValidate(password) {
    if (password == null || password.isEmpty) {
      return 'Vui lòng nhập mật khẩu.';
    }
    return null;
  }

  _buildTextFieldUsername() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        color: AppColor.GRAY3,
      ),
      child: Center(
        child: TextFormField(
          controller: _emailController,
          validator: _emailAndPhoneValidate,
          style: AppFont.REGULAR_GRAY1_12,
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          textAlign: TextAlign.left,
          decoration: const InputDecoration.collapsed(
            hintText: 'Email hoặc số điện thoại',
          ),
        ),
      ),
    );
  }

  String? _emailAndPhoneValidate(emailOrPhone) {
    if (emailOrPhone == null || emailOrPhone.isEmpty) {
      return "Vui lòng nhập email hoặc số điện thoại.";
    }
    if (!Validators.isValidEmail(emailOrPhone) &&
        !Validators.isValidPhoneNumber(emailOrPhone)) {
      return "Email hoặc số điện thoại không hợp lệ.";
    }
    return null;
  }
}
