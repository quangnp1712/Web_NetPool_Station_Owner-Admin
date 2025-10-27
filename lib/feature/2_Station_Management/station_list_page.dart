import 'package:flutter/material.dart';

class StationListPage extends StatefulWidget {
  const StationListPage({super.key});

  @override
  State<StationListPage> createState() => _StationListPageState();
}

class _StationListPageState extends State<StationListPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Station",
          style: TextStyle(
              fontSize: 25, color: Colors.white, fontFamily: 'SegoeUI Bold')),
    );
  }
}
