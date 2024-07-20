import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/widgets.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KakaoInquiryService {

  kakaoChannelInquiry(context) async {
    // 연결 페이지 URL 구하기
    Uri url = await TalkApi.instance.addChannelUrl('_quxbXxj');  // http://pf.kakao.com/뒤의 글자만 이용

    // 연결 페이지 URL을 브라우저에서 열기
    try {
      await launchBrowserTab(url);
    } catch (error) {
      debugPrint('카카오톡 채널 추가 실패 $error');
    }
  }
}

void showErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xffF1EEDE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline,  // 느낌표 아이콘
              color: Color(0xffFF6836),  // 아이콘 색상
            ),
            SizedBox(width: 10),  // 아이콘과 텍스트 사이의 간격
            Text(
              '사용중인 핀번호',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffFF6836),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.2,
          child: const Text(
            '이미 사용중인 핀번호 입니다.\n'
                '카카오 비지니스채널\n'
                '"다정한 상점" or \n'
                'friendlystore.korea@gmail.com\n'
                '으로 문의주세요.',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 위젯 간의 최대한의 간격을 확보합니다.
            children: [
              Container(
                height: 50,
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () async {
                    KakaoInquiryService().kakaoChannelInquiry(context);
                  },
                  child: Image.asset('assets/kakaoImage.png', fit: BoxFit.contain,),
                ),
              ),
              Spacer(),  // 이 부분은 중간에 최대한의 공간을 확보합니다.
              Container(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xffF1EEDE),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Color(0xffFF6836),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      );
    },
  );
}

void showNameDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xffF1EEDE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline,  // 느낌표 아이콘
              color: Color(0xffFF6836),  // 아이콘 색상
            ),
            SizedBox(width: 10),  // 아이콘과 텍스트 사이의 간격
            Text(
              '사용중인 닉네임',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffFF6836),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.2,
          child: const Text(
            '이미 사용중인 닉네임 입니다.\n'
                '다른 닉네임을 입력해주세요\n'
                '\n'
                '로그인장애 문의:카카오비지니스 채널\n'
                '"다정한상점"으로 문의해주세요.',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 위젯 간의 최대한의 간격을 확보합니다.
            children: [
              Container(
                height: 50,
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () async {
                    KakaoInquiryService().kakaoChannelInquiry(context);
                  },
                  child: Image.asset('assets/kakaoImage.png', fit: BoxFit.contain,),
                ),
              ),
              Spacer(),  // 이 부분은 중간에 최대한의 공간을 확보합니다.
              Container(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xffF1EEDE),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Color(0xffFF6836),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      );
    },
  );
}

void showPhoneDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xffF1EEDE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline,  // 느낌표 아이콘
              color: Color(0xffFF6836),  // 아이콘 색상
            ),
            SizedBox(width: 10),  // 아이콘과 텍스트 사이의 간격
            Text(
              '사용중인 전화번호',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffFF6836),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.2,
          child: const Text(
            '이미 사용중인 전화번호 입니다.\n'
                '카카오 비지니스채널\n'
                '"다정한 상점" or \n'
                'friendlystore.korea@gmail.com\n'
                '으로 문의주세요.',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 위젯 간의 최대한의 간격을 확보합니다.
            children: [
              Container(
                height: 50,
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () async {
                    KakaoInquiryService().kakaoChannelInquiry(context);
                  },
                  child: Image.asset('assets/kakaoImage.png', fit: BoxFit.contain,),
                ),
              ),
              Spacer(),  // 이 부분은 중간에 최대한의 공간을 확보합니다.
              Container(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xffF1EEDE),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Color(0xffFF6836),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      );
    },
  );
}

void showloginDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xffF1EEDE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline,  // 느낌표 아이콘
              color: Color(0xffFF6836),  // 아이콘 색상
            ),
            SizedBox(width: 10),  // 아이콘과 텍스트 사이의 간격
            Text(
              '등록안된 전화번호',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffFF6836),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.2,
          child: const Text(
            '등록되지않은 전화번호 입니다.\n'
                '카카오 비지니스채널\n'
                '"다정한 상점" or \n'
                'friendlystore.korea@gmail.com\n'
                '으로 문의주세요.',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 위젯 간의 최대한의 간격을 확보합니다.
            children: [
              Container(
                height: 50,
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () async {
                    KakaoInquiryService().kakaoChannelInquiry(context);
                  },
                  child: Image.asset('assets/kakaoImage.png', fit: BoxFit.contain,),
                ),
              ),
              Spacer(),  // 이 부분은 중간에 최대한의 공간을 확보합니다.
              Container(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xffF1EEDE),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Color(0xffFF6836),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      );
    },
  );
}

void showsearchDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xffF1EEDE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline,  // 느낌표 아이콘
              color: Color(0xffFF6836),  // 아이콘 색상
            ),
            SizedBox(width: 10),  // 아이콘과 텍스트 사이의 간격
            Text(
              'No Data',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffFF6836),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.2,
          child: const Text(
            '일치하는 데이터가 없습니다.\n'
                '카카오 비지니스채널\n'
                '"다정한 상점" or \n'
                'friendlystore.korea@gmail.com\n'
                '으로 문의주세요.',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 위젯 간의 최대한의 간격을 확보합니다.
            children: [
              Container(
                height: 50,
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () async {
                    const url = 'http://pf.kakao.com/_quxbXxj';  // 여기에 실제 카카오 비지니스 채널 URL을 입력하세요.
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Image.asset('assets/kakaoImage.png', fit: BoxFit.contain,),
                ),
              ),
              Spacer(),  // 이 부분은 중간에 최대한의 공간을 확보합니다.
              Container(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xffF1EEDE),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Color(0xffFF6836),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      );
    },
  );
}

void showEndOfCommentsPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xffF1EEDE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline,  // 느낌표 아이콘
              color: Color(0xffFF6836),  // 아이콘 색상
            ),
            SizedBox(width: 10),  // 아이콘과 텍스트 사이의 간격
            Text(
              'No Data',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffFF6836),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.2,
          child: const Text(
            '코멘트는 최신순으로 최대 \n100개까지 저장 됩니다.\n'
                '기타 문의는 "다정한상점"\n카카오채널로 해주세요 :)',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 위젯 간의 최대한의 간격을 확보합니다.
            children: [
              Container(
                height: 50,
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () async {
                    KakaoInquiryService().kakaoChannelInquiry(context);
                  },
                  child: Image.asset('assets/kakaoImage.png', fit: BoxFit.contain,),
                ),
              ),
              Spacer(),  // 이 부분은 중간에 최대한의 공간을 확보합니다.
              Container(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xffF1EEDE),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Color(0xffFF6836),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      );
    },
  );
}

void deleteDialog(BuildContext context, Function onDelete) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xffF1EEDE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Color(0xffFF6836),
            ),
            SizedBox(width: 10),
            Text(
              '회원탈퇴',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xffFF6836),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.2,
          child: const Text(
            '확인 버튼을 누르면 탈퇴됩니다.\n'
                '재가입은 새로운 달력을 구매해야 가능합니다.\n'
                '정말 탈퇴 하시겠습니까?',
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),  // 취소 버튼을 누르면 팝업 닫기
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xffF1EEDE),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      color: Color(0xffFF6836),
                    ),
                  ),
                ),
              ),
              Spacer(),
              Container(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () async {
                    await onDelete(); // deleteUser 함수 호출 및 완료까지 기다리기
                    Navigator.of(context).pushReplacementNamed('/loginPage'); // 로그인 페이지로 이동
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xffF1EEDE),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Color(0xffFF6836),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      );
    },
  );
}
