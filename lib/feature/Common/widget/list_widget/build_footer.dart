import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommonFooter extends StatelessWidget {
  const CommonFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy lại code từ _buildFooter (bao gồm cả Padding)
    return Center(
      child: Text(
        'Copyright © 2025 NETPOOL STATION BOOKING. All rights reserved.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        textAlign: TextAlign.center, // Thêm căn giữa cho an toàn
      ),
    );
  }
}
