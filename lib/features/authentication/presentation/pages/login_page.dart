import 'package:movie_tickets/injection.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/auth_bloc/bloc.dart';
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
    // Get the AuthenticationBloc instance
    final authBloc = context.read<AuthenticationBloc>();

    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginBloc(
          authRepository: authRepository,
          authenticationBloc: authBloc,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Container(
              color: AppColor.DEFAULT,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: Center(
                      child: _buildTopWelcome(),
                    ),
                  ),
                  Flexible(
                    flex: 5,
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
        ),
      ),
    );
  }

  _buildTopWelcome() => const WidgetTopWelcome();

  _buildLoginForm() => const WidgetLoginForm();

  _buildBottomSignUp() => const WidgetBottomSignUp();
}
