import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.3_Register/bloc/register_bloc.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/snackbar/snackbar.dart';

//! Register - station owner !//
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _formFocusNode = FocusNode();

  final RegisterBloc registerPageBloc = RegisterBloc();

  bool isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController identificationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      bloc: registerPageBloc,
      listenWhen: (previous, current) => current is RegisterActionState,
      buildWhen: (previous, current) => current is! RegisterActionState,
      listener: (context, state) {
        switch (state.runtimeType) {
          case RegisterSuccessState:
            Get.toNamed(validEmailPageRoute);
            break;
          case ShowSnackBarActionState:
            final snackBarState = state as ShowSnackBarActionState;
            ShowSnackBar(snackBarState.message, snackBarState.success);
            break;
        }
      },
      builder: (context, state) {
        if (state is Register_LoadingState) {
          isLoading = state.isLoading;
        }
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.asset(
                'assets/images/bg.png', // 👉 thay bằng ảnh mech của bạn
                fit: BoxFit.cover,
              ),
              // Overlay
              Container(
                color: Color(0xFF10011A).withOpacity(0.5),
              ),

              //$ Copyright
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

              //$ Centered Login Card
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 40),
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
                                registerPageBloc.add(SubmitRegisterEvent(
                                    email: emailController.text,
                                    password: passwordController.text,
                                    identification:
                                        identificationController.text,
                                    phone: phoneController.text,
                                    username: usernameController.text));
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

                              //$ Username TextField $//
                              TextFormField(
                                controller: usernameController,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter, // Đảm bảo chỉ nhập trên một dòng
                                ],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SegoeUI SemiBold',
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Tên',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: const Color(0xFF2A2A2A),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors
                                          .grey, // màu viền khi chưa focus
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors
                                          .cyanAccent, // màu viền khi focus
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập Tên ';
                                  }
                                  return null; // Trả về null nếu không có lỗi
                                },
                              ),
                              const SizedBox(height: 15),

                              //$ Email TextField $//
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.text,
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
                                  // ✅ Viền xám bên ngoài
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors
                                          .grey, // màu viền khi chưa focus
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors
                                          .cyanAccent, // màu viền khi focus
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

                              const SizedBox(height: 15),

                              //$ Password TextField $//
                              TextFormField(
                                obscureText: true,
                                controller: passwordController,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter, // Đảm bảo chỉ nhập trên một dòng
                                ],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SegoeUI SemiBold',
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Mật khẩu',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: const Color(0xFF2A2A2A),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors
                                          .grey, // màu viền khi chưa focus
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors
                                          .cyanAccent, // màu viền khi focus
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập mật khẩu ';
                                  }

                                  return null; // Trả về null nếu không có lỗi
                                },
                              ),
                              const SizedBox(height: 15),

                              //$ Password TextField $//
                              TextFormField(
                                obscureText: true,
                                controller: confirmPasswordController,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter, // Đảm bảo chỉ nhập trên một dòng
                                ],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SegoeUI SemiBold',
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Nhập lại mật khẩu',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: const Color(0xFF2A2A2A),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors
                                          .grey, // màu viền khi chưa focus
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors
                                          .cyanAccent, // màu viền khi focus
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập mật khẩu ';
                                  }
                                  if (value != passwordController.text) {
                                    return 'Mật khẩu không khớp';
                                  }
                                  return null; // Trả về null nếu không có lỗi
                                },
                              ),
                              const SizedBox(height: 15),

                              //$ Phone TextField $//
                              TextFormField(
                                controller: phoneController,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter,
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Chỉ cho phép nhập số
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SegoeUI SemiBold',
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Số điện thoại',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: const Color(0xFF2A2A2A),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors
                                          .grey, // màu viền khi chưa focus
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors
                                          .cyanAccent, // màu viền khi focus
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập Số điện thoại';
                                  }
                                  return null; // Trả về null nếu không có lỗi
                                },
                              ),
                              const SizedBox(height: 15),

                              //$ CCCD TextField $//
                              TextFormField(
                                controller: identificationController,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .singleLineFormatter,
                                  LengthLimitingTextInputFormatter(
                                      12), // Đảm bảo chỉ nhập trên một dòng
                                ],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SegoeUI SemiBold',
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Số định danh cá nhân (CMND/CCCD)',
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: const Color(0xFF2A2A2A),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors
                                          .grey, // màu viền khi chưa focus
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors
                                          .cyanAccent, // màu viền khi focus
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập Sô định danh cá nhân ';
                                  }
                                  return null; // Trả về null nếu không có lỗi
                                },
                              ),
                              const SizedBox(height: 30),

                              //$ Register Button $//
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
                                      registerPageBloc.add(SubmitRegisterEvent(
                                          email: emailController.text,
                                          password: passwordController.text,
                                          identification:
                                              identificationController.text,
                                          phone: phoneController.text,
                                          username: usernameController.text));
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
                                        'Đăng ký',
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
                              const SizedBox(height: 16),

                              //$ FORGOT PASSWORD
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.toNamed(loginPageRoute);
                                  },
                                  child: Text(
                                    'Đã có tài khoản',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueAccent,
                                      fontFamily: 'SegoeUI',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 40,
                  )
                ],
              ),

              // --- WIDGET LOADING TRONG STACK ---
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.containerBackground.withOpacity(
                        0.8,
                      ), // Màu nền mờ
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGlow,
                        ),
                      ),
                    ),
                  ),
                ),
              // ------------------------------------
            ],
          ),
        );
      },
    );
  }
}
