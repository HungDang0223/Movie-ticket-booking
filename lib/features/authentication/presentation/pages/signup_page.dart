import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/auth_bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/injection.dart';
import 'package:movie_tickets/features/authentication/domain/repositories/auth_repository.dart';
import 'package:movie_tickets/features/authentication/presentation/widgets/widget_signup_form.dart';
import 'package:movie_tickets/features/authentication/presentation/widgets/widgets.dart';

import '../bloc/signup_bloc/bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  @override
  Widget build(BuildContext context) {
    var authRepository = sl<AuthRepository>();

    return Scaffold(
      body: BlocProvider(
        create: (context) => SignupBloc(authRepository: authRepository),
        child: Container(
          color: AppColor.DEFAULT,
          child: ListView(
            children: [
              _buildTopWelcome(),
              _buildSignupForm(),
            ],
          ),
        ),
      ),
    );
  }

  _buildTopWelcome() => const WidgetTopWelcome();
  _buildSignupForm() => const WidgetSignupForm();
}
