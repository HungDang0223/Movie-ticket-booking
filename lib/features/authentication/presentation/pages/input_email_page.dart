import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/constants/app_color.dart';
import 'package:movie_tickets/core/constants/app_font.dart';
import 'package:movie_tickets/core/utils/multi_devices.dart';
import 'package:movie_tickets/core/utils/validators.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/auth_bloc/bloc.dart';
import 'package:movie_tickets/injection.dart';

class InputEmailPage extends StatefulWidget {
  const InputEmailPage({super.key});

  @override
  State<InputEmailPage> createState() => _InputEmailPageState();
}

class _InputEmailPageState extends State<InputEmailPage> {
  final TextEditingController _inputController = TextEditingController();
  late bool isSending;
  final bloc = sl<AuthenticationBloc>();
  @override
  void initState() {
    isSending = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập email', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is EmailRequestSentSuccessfully) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Mã xác thực đã gửi thành công.",), duration: Duration(microseconds: 500),)
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamed(context, '/email-verification', arguments: _inputController.text);
            });
          }
          if (state is SendEmailRequestFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Mã xác thực đã gửi thất bại.\nVui lòng thử lại hoặc sử dụng một email khác."))
            );
            setState(() {
              isSending = false;
            });
          }
          if (state is EmailVerificationInitial) {
            setState(() {
              isSending = true;
            });
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "Nhập email của bạn để lấy mã xác thực",
                      style: MultiDevices.getStyle(
                        fontSize: 20,
                        color: AppColor.DEFAULT,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const Text(
                      "Đảm bảo rằng email đã được sử dụng để đăng ký/đăng nhập ứng dụng.\n",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      color: AppColor.GRAY3,
                      border: Border.all(color: AppColor.DEFAULT)
                    ),
                    child: Center(
                      child: TextFormField(
                        controller: _inputController,
                        validator: _emailValidate,
                        style: AppFont.REGULAR_GRAY1_12,
                        maxLines: 1,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.left,
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Nhập email',
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColor.WHITE
                      ),
                      child: isSending == true
                        ? const Center(
                          child: CircularProgressIndicator(color: AppColor.DEFAULT,),
                        )
                        : InkWell(
                            onTap: () {
                              print(_inputController.text);
                              context.read<AuthenticationBloc>().add(SendEmailAuthRequest(_inputController.text));
                            },
                            child: const Row(
                              children: [
                                Text(
                                  "Lấy mã xác thực",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.DEFAULT,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Icon(Icons.arrow_forward, color: AppColor.DEFAULT, size: 16,)
                              ],
                            ),
                        ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  String? _emailValidate(email) {
    if (email == null || email.isEmpty) {
      return "Vui lòng nhập email.";
    }
    if (!Validators.isValidEmail(email)) {
      return "Email không hợp lệ.";
    }
    return null;
  }
}