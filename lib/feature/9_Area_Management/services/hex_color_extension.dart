import 'dart:ui';

import 'package:flutter/material.dart';

//! Extension giúp parse màu Hex an toàn, không bao giờ gây crash
extension HexColorExtension on String? {
  Color toColor({Color fallback = Colors.grey}) {
    if (this == null || this!.isEmpty) return fallback;
    try {
      var hexString = this!.toUpperCase().replaceAll("#", "");
      if (hexString.length == 6) {
        hexString = "FF$hexString"; // Thêm Alpha nếu thiếu
      }
      return Color(int.parse(hexString, radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}
