import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/home_page.dart';
import 'package:web_netpool_station_owner_admin/feature/1_Account_Management/Usecase/1.1_Register/pages/register_page.dart';
import 'package:web_netpool_station_owner_admin/feature/Common/landing_page/controller/navigation_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
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
          // Centered Login Card
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

                  // Email TextField
                  TextField(
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'SegoeUI SemiBold',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      // ✅ Viền xám bên ngoài
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
                          color: Colors.cyanAccent, // màu viền khi focus
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Password TextField
                  TextField(
                    obscureText: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'SegoeUI SemiBold',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      labelStyle: const TextStyle(color: Colors.white70),
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
                          color: Colors.cyanAccent, // màu viền khi focus
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
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
                        // Get.toNamed(rootRoute);
                        navigationController
                            .navigateAndSyncURL(dashboardPageRoute);
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C6FF), Color(0xFFAD00FF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Đăng nhập',
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
                        Get.toNamed(registerPageRoute);
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Color(0xFF454549),
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

                  // FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Quên mật khẩu ?',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blueAccent,
                          fontFamily: 'SegoeUI',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
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
  }
}
