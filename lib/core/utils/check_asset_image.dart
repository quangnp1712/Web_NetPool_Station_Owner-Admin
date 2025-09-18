import 'package:flutter/services.dart' show rootBundle;

class CheckIfAssetImageExists {
  static Future<bool> checkIfAssetImageExists(String assetPath) async {
    try {
      // Thử tải file từ assets
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      // Nếu có lỗi xảy ra, file không tồn tại
      return false;
    }
  }
}
