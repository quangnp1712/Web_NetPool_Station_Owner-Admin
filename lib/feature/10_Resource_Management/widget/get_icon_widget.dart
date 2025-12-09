// --- Helpers UI ---
import 'package:flutter/material.dart';

Widget getIcon(String? iconName, {double size = 18, Color? color}) {
  IconData iconData;
  switch (iconName) {
    case 'PS5':
    case 'PS':
    case 'PLAYSTATION':
      iconData = Icons.gamepad_outlined;
      break;
    case 'PC':
    case 'NET':
      iconData = Icons.computer_outlined;
      break;
    case 'BILLIARD':
    case 'BIDA':
      iconData = Icons.sports_baseball_outlined;
      break;
    case 'SOCCER':
      iconData = Icons.sports_soccer_outlined;
      break;
    default:
      iconData = Icons.category_outlined;
  }
  return Icon(iconData, size: size, color: color ?? Colors.white);
}
