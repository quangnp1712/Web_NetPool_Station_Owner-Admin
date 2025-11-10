import 'package:flutter/material.dart';
import 'package:web_netpool_station_owner_admin/core/theme/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          Center(child: Text("dasshborad")),
        ],
      ),
    );
  }
}
