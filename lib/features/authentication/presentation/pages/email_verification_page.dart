import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/injection.dart';
import 'package:pinput/pinput.dart';

import '../bloc/auth_bloc/bloc.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {

  final _pinController = TextEditingController();
  bool isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  void _resendCode() {
    if (!_canResend) return;
    
    setState(() {
      _isResending = true;
    });
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isResending = false;
      });
      
      _startResendTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã xác thực đã được gửi lại'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực Email', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is EmailVerificateFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Mã xác thực sai.\nVui lòng thử lại."))
              );
              setState(() {
                isLoading = false;
              });
          }
          if (state is EmailVerificatedSuccessfully) {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Mã xác thực đã gửi thành công.",), duration: Duration(microseconds: 500),)
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamed(context, '/change-password');
              });
          }
          if (state is EmailVerificationInitial) {
            setState(() {
              isLoading = true;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Nhập mã xác thực',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Chúng tôi đã gửi mã xác thực đến ${widget.email}',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              Pinput(
                length: 6,
                showCursor: true,
                defaultPinTheme: PinTheme(
                  width: 50,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor.DEFAULT)
                  ),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  )
                ),
                // onSubmitted: (value) {
                //   log(value);
                // },
                onCompleted:(value) async {
                  log(value);
                  sl<AuthenticationBloc>().add(VerifyCodeRequest(widget.email, value));
                }
              ),
              const SizedBox(height: 20),
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: _isResending ? null : _resendCode,
                        child: _isResending
                            ? const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : InkWell(onTap:() {
                              sl<AuthenticationBloc>().add(SendEmailAuthRequest(widget.email));
                            }, child: const Text('Gửi lại mã')),
                      )
                    : Text(
                        'Gửi lại mã sau $_resendTimer giây',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}