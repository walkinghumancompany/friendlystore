import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Column(
      children: [
        Container(
          alignment: Alignment.center,
          color: const Color(0xffF1EEDE),
          child: const Text('ⓒ다정한상점\nfirendlystore.korea@gmail.com',
            style: TextStyle(
              fontFamily: 'AppleSDGothicNeo',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}
