import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/features/authentication/presentation/bloc/auth_bloc/authentication_bloc.dart';

import '../../../../core/constants/my_const.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPassController = TextEditingController();
  final _newPassConfirmController = TextEditingController();
  bool isSending = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đặt lại mật khẩu mới"),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 17),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  color: AppColor.GRAY3,
                ),
                child: Center(
                  child: TextFormField(
                    controller: _newPassController,
                    style: AppFont.REGULAR_GRAY1_12,
                    maxLines: 1,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Nhập mã xác thực',
                    ),
                  ),
                ),
              ),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 17),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  color: AppColor.GRAY3,
                ),
                child: Center(
                  child: TextFormField(
                    controller: _newPassConfirmController,
                    style: AppFont.REGULAR_GRAY1_12,
                    maxLines: 1,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Nhập mã xác thực',
                    ),
                  ),
                ),
              ),
              Container(
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
          ],
        ),
      ),
    );
  }
}