import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:web_netpool_station_owner_admin/core/router/routes.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';
// Import SharedPref của bạn để check token
// import 'package:your_project/shared/authentication_pref.dart';
// Hoặc import SharedPreferencesHelper

// -----------------------------------------------------------------------------
// HÀM CHUNG: Kiểm tra token có hợp lệ không (Có thể tách ra file utils riêng)
// Trả về TRUE nếu token ngon (không rỗng, chưa hết hạn)
// Trả về FALSE nếu token hỏng (rỗng, hết hạn, sai format)
// -----------------------------------------------------------------------------
bool _hasValidAccessToken() {
  try {
    String jwtToken = AuthenticationPref.getAccessToken();

    // 1. Check rỗng
    if (jwtToken.isEmpty) {
      DebugLogger.printLog("Middleware: Token is Empty");
      return false;
    }

    // 2. Check hết hạn (Dùng hàm có sẵn của thư viện jwt_decoder)
    // Hàm này tự động decode và so sánh với thời gian hiện tại
    bool isExpired = JwtDecoder.isExpired(jwtToken);

    if (isExpired) {
      DebugLogger.printLog("Middleware: Token hêt hạn");
      // Optional: Nên xóa token cũ đi nếu nó đã hết hạn để sạch bộ nhớ
      // AuthenticationPref.clearToken();
      return false;
    }

    // 3. Token OK
    return true;
  } catch (e) {
    // Trường hợp token bị lỗi format (không decode được) hoặc lỗi khác
    DebugLogger.printLog("Middleware Error checking token: $e");
    return false;
  }
}

// =============================================================================
// 1. EnsureAuthMiddleware
// Dùng cho: Dashboard, Home, Profile... (Các trang CẦN đăng nhập)
// Logic: Không có token xịn thì đuổi về Login
// =============================================================================
class EnsureAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    bool isValid = _hasValidAccessToken();

    // Nếu token KHÔNG hợp lệ -> Chuyển hướng về Login
    if (!isValid) {
      DebugLogger.printLog(
          "AuthMiddleware: Access Denied -> Redirect to Login");
      return const RouteSettings(name: loginPageRoute);
    }

    // Nếu hợp lệ -> Cho đi tiếp vào trang đích
    return null;
  }
}

// =============================================================================
// 2. EnsureNotAuthMiddleware
// Dùng cho: LoginPage, RegisterPage... (Các trang PUBLIC)
// Logic: Đã có token xịn rồi thì KHÔNG cho vào Login nữa, đá vào Dashboard
// =============================================================================
class EnsureNotAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    bool isValid = _hasValidAccessToken();

    // Nếu token HỢP LỆ (đã đăng nhập rồi) -> Chuyển hướng vào trong (Dashboard)
    if (isValid) {
      DebugLogger.printLog(
          "NotAuthMiddleware: Already Logged In -> Redirect to Dashboard");
      return const RouteSettings(name: rootRoute);
    }

    // Nếu chưa đăng nhập (hoặc token lỗi) -> Cho phép ở lại trang Login
    return null;
  }
}
