import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:web_netpool_station_owner_admin/core/utils/debug_logger.dart';
import 'package:web_netpool_station_owner_admin/feature/0_Authentication/0.1_Authentication/shared_preferences/auth_shared_preferences.dart';

abstract class IAuthenticationService {
  Future<bool> checkJwtExpired();
  Future<bool> checkPassword(String password);
}

class AuthenticationService extends IAuthenticationService {
  // kiểm tra hết hạn hay chưa
  // false là chưa hết hạn
  // true là hết hạn
  @override
  Future<bool> checkJwtExpired() async {
    try {
      String jwtToken = AuthenticationPref.getAccessToken();
      if (jwtToken.isNotEmpty) {
        var isExpired = _isExpired(jwtToken);
        if (!isExpired) {
          return false;
        } else {
          return true;
          // logout
          // return null
        }
      } else {
        DebugLogger.printLog("Failed to get jwtToken from SharedPreferences");
        return true;
      }
    } on Exception catch (e) {
      DebugLogger.printLog(e.toString());
      return true;
    }
  }

// true là hết hạn
// false là còn hạn
  bool _isExpired(String jwt) {
    final decoded = JwtDecoder.decode(jwt);
    final expiry = decoded['exp'];
    DateTime expiration = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
    final dateNow = DateTime.now();
    final check = expiration.isBefore(dateNow);
    return expiration.isBefore(dateNow);
  }

  @override
  Future<bool> checkPassword(password) async {
    try {
      String passwordPref = AuthenticationPref.getPassword();
      if (passwordPref == password) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      DebugLogger.printLog(e.toString());
      return false;
    }
  }
}
