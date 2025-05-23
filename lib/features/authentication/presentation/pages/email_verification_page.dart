import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
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

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with TickerProviderStateMixin {
  final _pinController = TextEditingController();
  
  Timer? _timer;
  int _resendTimer = 60;
  bool _canResend = false;
  bool _isResending = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startResendTimer();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendCode() async {
    if (!_canResend || _isResending) return;
    
    setState(() {
      _isResending = true;
    });
    
    try {
      sl<AuthenticationBloc>().add(SendEmailAuthRequest(widget.email));
      
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        
        _startResendTimer();
        _showSuccessSnackBar('auth.emailVerification.codeSentSuccess'.i18n());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        _showErrorSnackBar('auth.emailVerification.resendFailed'.i18n());
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'auth.emailVerification.title'.i18n(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is EmailVerificateFailed) {
            _showErrorSnackBar('auth.emailVerification.invalidCode'.i18n());
            _pinController.clear();
          }
          
          if (state is EmailVerificatedSuccessfully) {
            _showSuccessSnackBar('auth.emailVerification.verifiedSuccess'.i18n());
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/change-password');
              }
            });
          }
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Email icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColor.DEFAULT.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    size: 40,
                    color: AppColor.DEFAULT,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'auth.emailVerification.checkEmail'.i18n(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Description
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: '${'auth.emailVerification.codeSentTo'.i18n()}\n'),
                      TextSpan(
                        text: widget.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColor.DEFAULT,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // PIN Input
                Pinput(
                  controller: _pinController,
                  length: 6,
                  showCursor: true,
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  defaultPinTheme: PinTheme(
                    width: 56,
                    height: 64,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      color: Colors.white,
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 56,
                    height: 64,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.DEFAULT, width: 2),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.DEFAULT.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 56,
                    height: 64,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.DEFAULT),
                      color: AppColor.DEFAULT.withOpacity(0.1),
                    ),
                  ),
                  errorPinTheme: PinTheme(
                    width: 56,
                    height: 64,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                      color: Colors.red.withOpacity(0.1),
                    ),
                  ),
                  onCompleted: (value) {
                    log('PIN completed: $value');
                    sl<AuthenticationBloc>().add(
                      VerifyCodeRequest(widget.email, value),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Resend button
                _buildResendSection(),
                
                const SizedBox(height: 32),
                
                // Help text
                Text(
                  'auth.emailVerification.didntReceive'.i18n(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendSection() {
    if (_canResend) {
      return TextButton.icon(
        onPressed: _isResending ? null : _resendCode,
        icon: _isResending
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.refresh),
        label: Text(_isResending 
          ? 'auth.emailVerification.sending'.i18n()
          : 'auth.emailVerification.resendCode'.i18n()
        ),
        style: TextButton.styleFrom(
          foregroundColor: AppColor.DEFAULT,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              '${'auth.emailVerification.resendIn'.i18n()} ${_resendTimer}s',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }
}