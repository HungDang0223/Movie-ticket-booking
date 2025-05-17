import 'package:movie_tickets/injection.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';
import '../widgets/widgets.dart';
import '../bloc/login_bloc/bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    var authRepository = sl<AuthRepository>();

    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginBloc(authRepository: authRepository),
        child: Container(
          color: AppColor.DEFAULT,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Center(child: _buildTopWelcome(),),
              ),
              Flexible(
                flex: 4,
                child: Column(
                  children: [
                    _buildLoginForm(),
                    _buildBottomSignUp(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildTopWelcome() => WidgetTopWelcome();

  _buildLoginForm() => WidgetLoginForm();

  _buildBottomSignUp() => WidgetBottomSignUp();
}
