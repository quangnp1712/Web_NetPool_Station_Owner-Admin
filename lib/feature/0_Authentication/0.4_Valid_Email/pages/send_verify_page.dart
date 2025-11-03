// ignore_for_file: type_literal_in_constant_pattern

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.4_Valid_Email/bloc/valid_email_bloc.dart';

//! Send Valid !//
class SendValidPage extends StatefulWidget {
  const SendValidPage({super.key});

  @override
  State<SendValidPage> createState() => _SendValidPageState();
}

class _SendValidPageState extends State<SendValidPage> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _formFocusNode = FocusNode();

  final ValidEmailBloc validEmailBloc = ValidEmailBloc();

  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ValidEmailBloc, ValidEmailState>(
      bloc: validEmailBloc,
      listenWhen: (previous, current) => current is ValidEmailActionState,
      buildWhen: (previous, current) => current is! ValidEmailActionState,
      listener: (context, state) {
        switch (state.runtimeType) {
          case ValidEmailSuccessState:
            Get.toNamed(rootRoute);
            // Get.offAllNamed(rootRoute);
            break;
        }
      },
      builder: (context, state) {
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
                            validEmailBloc.add(ShowVerifyEmailEvent(
                              email: emailController.text,
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
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .singleLineFormatter, // Đảm bảo chỉ nhập trên một dòng

                              FilteringTextInputFormatter.deny(
                                  RegExp(r'[^a-zA-Z0-9@._-]')),
                            ],
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'SegoeUI SemiBold',
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
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
                                return "Vui lòng nhập email";
                              }
                              final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return "Email không hợp lệ";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),

                          // send valid email Button
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
                                if (_formKey.currentState!.validate()) {
                                  validEmailBloc.add(ShowVerifyEmailEvent(
                                    email: emailController.text,
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
