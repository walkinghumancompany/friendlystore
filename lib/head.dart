import 'package:flutter/material.dart';
import 'package:friendlystore/user.dart';
import 'package:friendlystore/providers/userProvider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'likePage.dart';

@override

Widget Head(BuildContext context, String imagePath, {bool isKaKao = false}){

  userProvider _userProvider = userProvider();
  double headWidth = MediaQuery.of(context).size.width;

  return
    Container(
      width: headWidth,
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 가로축 기준으로 중앙 정렬
        crossAxisAlignment: CrossAxisAlignment.end, // 세로축 기준으로 하단 정렬
        children: [
          Container(width: headWidth * 0.01,),
          Container(
              width: headWidth * 0.1,
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.all(0),
              child: isKaKao ? TextButton(
                onPressed: () async {
                  const url = 'http://pf.kakao.com/_quxbXxj';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Image.asset(
                  'assets/kakaoIcon.png',
                  fit: BoxFit.contain,
                  height: 42,
                  alignment: Alignment.center,
                ),
              )
                  : TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Image.asset(
                  'assets/backIcon.png',
                  fit: BoxFit.contain,
                  height: 52,
                  alignment: Alignment.center,
                ),
              )
          ),
          Container(
            width: headWidth * 0.09,
          ),
          Container(
            width: headWidth * 0.6,
            alignment: Alignment.bottomCenter,
            child: Image.asset(
                imagePath,
                height: 42.5,
                fit : BoxFit.contain,
                alignment: Alignment.center),
          ),
          Container(
            width: headWidth * 0.1,
            height: 56,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                User user = User(
                  code: _userProvider.user.code,
                  name: _userProvider.user.name,
                  phone: _userProvider.user.phone,
                );
                Navigator.pushReplacementNamed(context, '/mainPage', arguments: user);
              },
              child: Image.asset(
                'assets/HomeIcon.png',
                fit: BoxFit.cover,
                width: headWidth * 0.08,  // 컨테이너 너비의 80%
                height: 45,  // 명시적 높이 지정
              ),
            ),
          ),
          Container(
            width: headWidth * 0.1,
            height: 56,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => likePage()),
                );
              },
              child: Image.asset(
                'assets/likeIcon.png',
                fit: BoxFit.cover,
                width: headWidth * 0.08,  // 컨테이너 너비의 80%
                height: 45,  // 명시적 높이 지정
              ),
            ),
          )
        ],
      ),
    );
}