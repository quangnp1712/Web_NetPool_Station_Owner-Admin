import 'package:flutter/material.dart';

class PageNotFound extends StatelessWidget {
  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/error.png",
            width: 350,
          ),
          const SizedBox(
            height: 10,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Page not found",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'SegoeUI Bold'),
              )
            ],
          )
        ],
      ),
    );
  }
}
