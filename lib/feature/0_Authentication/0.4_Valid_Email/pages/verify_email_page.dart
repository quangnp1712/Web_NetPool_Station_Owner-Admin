// ignore_for_file: type_literal_in_constant_pattern

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/bloc/valid_email_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/snackbar/snackbar.dart';

//! Valid Email !//
class ValidEmailPage extends StatefulWidget {
  const ValidEmailPage({super.key});

  @override
  State<ValidEmailPage> createState() => _ValidEmailPageState();
}

class _ValidEmailPageState extends State<ValidEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _formFocusNode = FocusNode();

  final ValidEmailBloc validEmailPageBloc = ValidEmailBloc();

  TextEditingController codeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  @override
  void initState() {
    validEmailPageBloc.add(ValidEmailInitialEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ValidEmailBloc, ValidEmailState>(
      bloc: validEmailPageBloc,
      listenWhen: (previous, current) => current is ValidEmailActionState,
      buildWhen: (previous, current) => current is! ValidEmailActionState,
      listener: (context, state) {
        switch (state.runtimeType) {
          case ShowSnackBarActionState:
            final snackBarState = state as ShowSnackBarActionState;
            ShowSnackBar(snackBarState.message, snackBarState.success);
            break;
        }
      },
      builder: (context, state) {
        if (state is ValidEmailInitial) {
          emailController.text = state.email ?? "";
        }
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.asset(
                'assets/images/bg.png', // 👉 thay bằng ảnh mech của bạn
                fit: BoxFit.cover,
                height: 40,
              ),
              // Overlay
              Container(
                color: Color(0xFF10011A).withOpacity(0.5),
              ),
              // Centered ValidEmail Card
              Center(
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF323236),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: KeyboardListener(
                    focusNode: _formFocusNode,
                    onKeyEvent: (KeyEvent event) {
                      // Chỉ lắng nghe sự kiện phím *nhấn*
                      if (event is KeyDownEvent) {
                        // Kiểm tra xem có phải phím Enter không
                        if (event.logicalKey == LogicalKeyboardKey.enter) {
                          // Chạy hàm login
                          _formFocusNode.requestFocus();
                          if (_formKey.currentState!.validate()) {
                            validEmailPageBloc.add(SubmitValidEmailEvent(
                              verificationCode: codeController.text,
                            ));
                          }
                        }
                      }
                    },
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo + Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(
                                fit: BoxFit
                                    .cover, // hoặc BoxFit.contain tùy bạn muốn co hay cắt
                                clipBehavior: Clip.hardEdge,
                                child: Image.asset(
                                  'assets/images/logo_no_bg.png',
                                  height: 70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),

                          //$ Email TextField $//
                          TextFormField(
                            controller: emailController,
                            readOnly: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.singleLineFormatter,
                            ],
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'SegoeUI SemiBold',
                            ),
                            decoration: InputDecoration(
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: const Color(0xFF2A2A2A),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.grey, // màu viền khi chưa focus
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color:
                                      Colors.cyanAccent, // màu viền khi focus
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          //$ Code TextField $//
                          TextFormField(
                            controller: codeController,
                            inputFormatters: [
                              FilteringTextInputFormatter.singleLineFormatter,
                              FilteringTextInputFormatter
                                  .digitsOnly, // Chỉ cho phép nhập số
                              LengthLimitingTextInputFormatter(6),
                            ],
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'SegoeUI SemiBold',
                            ),
                            decoration: InputDecoration(
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: const Color(0xFF2A2A2A),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.grey, // màu viền khi chưa focus
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color:
                                      Colors.cyanAccent, // màu viền khi focus
                                  width: 1.2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập Mã OTP';
                              }
                              return null; // Trả về null nếu không có lỗi
                            },
                          ),
                          const SizedBox(height: 30),

                          // ValidEmail Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                // navigationController
                                //     .navigateAndSyncURL(dashboardPageRoute);
                                if (_formKey.currentState!.validate()) {
                                  validEmailPageBloc.add(SubmitValidEmailEvent(
                                    verificationCode: codeController.text,
                                  ));
                                }
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00C6FF),
                                      Color(0xFFAD00FF)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Xác nhận',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontFamily: 'SegoeUI Bold',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF454549),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: () {
                                validEmailPageBloc
                                    .add(SendValidCodeEvent(email: ""));
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Color(0xFF454549),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Gửi lại mã OTP',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontFamily: 'SegoeUI Bold',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Copyright
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Đường line xám mờ
                    Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.4),
                      margin: const EdgeInsets.symmetric(horizontal: 100),
                    ),

                    const SizedBox(height: 10),

                    // ✅ Dòng Copyright
                    Text(
                      'Copyright © 2025 NETPOOL STATION BOOKING. All rights reserved.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'SegoeUI',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
