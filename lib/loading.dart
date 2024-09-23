import 'package:flutter/material.dart';

Widget Loading(BuildContext context) {
  return Center(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: const Text(
              "Loding",
              style: TextStyle(fontSize: 15, color: Color(0xff555555)),
            ),
          ),
          const SizedBox(height: 20),  // 간격을 추가
          const CircularProgressIndicator(
              color: Color(0xffFF6836),
              semanticsValue: "Loding..",
              strokeWidth: 7.0),
        ]
    ),
  );
}
