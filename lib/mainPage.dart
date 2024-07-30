
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:friendlystore/cookingTimer.dart';
import 'package:friendlystore/memoPage.dart';
import 'package:friendlystore/seasonalCookingPage.dart';
import 'package:friendlystore/user.dart';
import 'package:friendlystore/yummyPage.dart';
import 'package:provider/provider.dart';
import 'package:friendlystore/providers/userProvider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'head.dart';
import 'detailPage.dart';
import 'mentPage.dart';
import 'dialog.dart';
import 'main.dart';
import 'seasonalFoodPage.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';



class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin {

  final storage = FlutterSecureStorage;
  late TextEditingController searchController;
  late List<dynamic> infoList = [];
  late List<dynamic> recommendCooking = [];
  late DateTime now;
  late String formattedDate;
  late Map<String, dynamic> targetData;
  String? updateCard;
  String? updateCardCompare;
  bool isUpdate = false;
  bool isLoading = true;
  String? checkPhone;

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      storageLoad();
      showRecentMessagesDialog(context);
      try {
        await Firebase.initializeApp();
        await FirebaseMessaging.instance.requestPermission();
        String? token = await FirebaseMessaging.instance.getToken();
        print('FCM Token: $token');
      } catch (e, stackTrace) {
        print('Error initializing Firebase or getting FCM token: $e');
        print('Stack trace: $stackTrace');
      }
    });
    searchController = TextEditingController();
    now = DateTime.now();
    formattedDate = "${now.month.toString().padLeft(2, '0')}";
    loadData(context);
    eventAnimation();
    updateAfterCard();
    _cardController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _cardController.reverse(); // 애니메이션을 역방향으로 재생합니다.
      } else if (status == AnimationStatus.dismissed) {
        _cardController.forward(); // 애니메이션을 다시 시작합니다.
      }
    });
    _cardController.forward(); // 초기 애니메이션 시작
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    debugPrint('메세지 ${initialMessage?.notification?.title}');

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    try {
      if (foundation.defaultTargetPlatform != foundation.TargetPlatform.iOS) {
        FirebaseMessaging.onMessage.listen((event) {showMessage(event);});
      }
    } catch(e) {
      debugPrint('onMessage try error :${e}');
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async {
    try {
      debugPrint('message.data : ${message.data}');
      Map<String, dynamic> messageData = message.data;
      String click_action = messageData['click_action'] ?? '';

      if (click_action.isNotEmpty) {
        final Uri _url = Uri.parse(click_action);
        if (!await launchUrl(_url)) {
        }
      }
    } catch(e) {
      print('error handleMessage ${e}');
    }
  }

  showMessage(RemoteMessage? message) {

    RemoteNotification? notification = message?.notification;
    AndroidNotification? android = message?.notification?.android;
    var data = message?.data;
    var androidNotiDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      importance: Importance.high,
    );

    var iOSNotiDetails = const DarwinNotificationDetails();
    var details =
    NotificationDetails(android: androidNotiDetails, iOS: iOSNotiDetails);
    if (data != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        message?.notification?.title,
        message?.notification?.body,
        details,
        payload: 'data',
      );
    }
  }

  void showRecentMessagesDialog(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool doNotShowAgain = prefs.getBool('doNotShowAgain') ?? false;
    String lastShownMessageTimestamp = prefs.getString('lastShownMessageTimestamp') ?? '';

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<String> messages = [];
    QuerySnapshot querySnapshot = await firestore.collection('message')
        .orderBy('messageId', descending: true) // 'updatedAt' 필드로 문서를 내림차순 정렬
        .limit(1) // 가장 최근 문서만 가져옴
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final mostRecentDoc = querySnapshot.docs.first;
      final data = mostRecentDoc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('message')) {
        String currentMessageTimestamp = data['messageId'];
        DateTime now = DateTime.now();
        DateTime messageDate = DateTime.parse(currentMessageTimestamp);

        if (currentMessageTimestamp != lastShownMessageTimestamp) {
          // 새로운 문서가 업데이트 되었으므로 doNotShowAgain을 false로 설정
          await prefs.setBool('doNotShowAgain', false);
          doNotShowAgain = false;
          await prefs.setString('lastShownMessageTimestamp', currentMessageTimestamp);
        }

        if (!doNotShowAgain && now.difference(messageDate).inDays < 3) {
          messages.add((data['message'] as String?) ?? '');
          // 메시지가 2분 이내에 업데이트된 경우에만 팝업 표시
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
                      Icons.volume_up,  // 확성기 아이콘
                      color: Color(0xffFF6836),  // 아이콘 색상
                    ),
                    SizedBox(width: 10),  // 아이콘과 텍스트 사이의 간격
                    Text(
                      '새로운 소식',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xffFF6836),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: messages.map((message) => Text(message)).toList(),
                  ),
                ),
                actions: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color(0xffF1EEDE)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // 원하는 모서리 둥근 정도를 설정하세요
                                side: const BorderSide(
                                  color: Colors.grey, // 원하는 보더 색상을 설정하세요
                                  width: 0.5, // 원하는 보더 두께를 설정하세요
                                ),
                              ),
                            ),
                            // 여기에 boxShadow 추가
                            shadowColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.5)),
                            elevation: MaterialStateProperty.all(3),
                          ),
                          onPressed: () async {
                            FirebaseFirestore.instance
                                .collection('link')
                                .doc('friendly') // 여기에 Firestore 문서 ID를 넣으세요
                                .get()
                                .then((doc) {
                              if (doc.exists && doc.data()!.containsKey('linkUrl')) {
                                String url = doc.data()!['linkUrl'];
                                _launchURL(url); // URL 열기
                              }
                            });
                          },
                          child: const Text('더 알아보기',
                            style: TextStyle(
                              color: Color(0xffFF6836),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: TextButton(
                              child: const Text('다시보지않기'),
                              onPressed: () async {
                                await prefs.setBool('doNotShowAgain', true);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Spacer(),
                          Container(
                            child: TextButton(
                              child: const Text('닫기'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  )
                ],
              );
            },
          );
        }
      }
    }
  }


  void _launchURL(String url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  void storageLoad() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    checkPhone = await storage.read(key: 'storagePhone');
    if (checkPhone != null) {
      final userSnapshot = await firestore.collection('users')
          .where('phone', isEqualTo: checkPhone)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        User user = User(
          name: userData['name'],
          phone: userData['phone'],
          code: userData['code'],
        );

        // 여기서 Provider로 상태를 업데이트합니다.
        Provider.of<userProvider>(context, listen: false).updateUserData(user: user);

      } else {
        storage.delete(key: 'storagePhone');
        Navigator.popAndPushNamed(context, '/loginPage');
      }
    } else {
      storage.delete(key: 'storagePhone');
      Navigator.popAndPushNamed(context, '/loginPage');
    }
  }


  @override
  Widget build(BuildContext context) {
    double menuWidth = MediaQuery.of(context).size.width * 0.9;
    final userProvider _userProvider = Provider.of<userProvider>(context);

    final width = MediaQuery.of(context).size.width;

    print('현재 날짜: $formattedDate');


    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffF1EEDE),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xffF1EEDE),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            backgroundColor: Colors.transparent, // 투명 배경
            centerTitle: true,
            elevation: 0,
            title: Head(context, 'assets/Home.png', isKaKao: true),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Color(0xffF1EEDE),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
          children: [
            SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 35,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 112,
                      child: Image.asset('assets/mainLogo.png',
                          fit: BoxFit.contain,
                          height: 112),
                    ),
                    const SizedBox(
                      height: 25,),
                    // 검색
                    Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        height: 70,
                        child : Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.1,
                              height: 68,
                              alignment: Alignment.center,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 56,
                              alignment: Alignment.center,
                              child: searchField(context),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: 68,
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () => loadData(context),
                                child : Image.asset('assets/searchIcon.png',
                                  fit : BoxFit.contain,
                                  height: 68,),
                              ),
                            ),
                          ],
                        )
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    // 오늘의추천요리
                    Container(
                      width: menuWidth,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: menuWidth * 0.5,
                            height: 60,
                            alignment: Alignment.bottomRight,
                            child: Image.asset('assets/recommendIcon.png', fit:BoxFit.contain),
                          ),
                          Container(
                            width: menuWidth * 0.5,
                            height: 120,
                            alignment: Alignment.center,
                            child: FadeTransition(
                              opacity: _animation,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPage(infoList: targetData),
                                    ),
                                  );
                                },
                                child: recommendCooking.isNotEmpty
                                    ? Image.asset(
                                  recommendCooking[0],
                                  fit: BoxFit.contain,
                                )
                                    : Placeholder(),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    //메뉴1
                    Container(
                      width: menuWidth,
                      height: 90,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: menuWidth * 0.3,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CookingTimer(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Image.asset('assets/card04.png', fit: BoxFit.contain),
                            ),
                          ),
                          SizedBox(
                            width: menuWidth * 0.05,
                          ),
                          Container(
                            width: menuWidth * 0.3,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MemoPage(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Image.asset('assets/card02.png', fit: BoxFit.contain),
                            ),
                          ),
                          SizedBox(
                            width: menuWidth * 0.05,
                          ),
                          Container(
                            width: menuWidth * 0.3,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Yummy(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                child: Image.asset('assets/card05.png', fit: BoxFit.contain),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    // 메뉴2
                    Container(
                      width: menuWidth,
                      height: 90,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: menuWidth * 0.3,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeasonalFood(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Image.asset('assets/card01.png', fit: BoxFit.contain),
                            ),
                          ),
                          SizedBox(
                            width: menuWidth * 0.05,
                          ),
                          Container(
                            width: menuWidth * 0.3,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeasonalCooking(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Image.asset('assets/card02.png', fit: BoxFit.contain),
                            ),
                          ),
                          SizedBox(
                            width: menuWidth * 0.05,
                          ),
                          Container(
                            width: menuWidth * 0.3,
                            child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MentPage(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                child:
                                isUpdate ?
                                ScaleTransition(scale: _cardAnimation,
                                  child: Image.asset('assets/card03After.png', fit: BoxFit.contain,),)
                                    :  Image.asset('assets/card03.png', fit: BoxFit.contain)
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    // 배너
                    Container(
                      alignment: Alignment.center,
                      width: width,
                      child: TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () async {
                          const url = 'https://www.friendlystore.co.kr';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        child: Image.asset('assets/banner.png', fit: BoxFit.contain,),
                      ),
                    )
                  ],
                )
            ),
          ]
      ),
    );
  }

  Widget searchField(BuildContext context) {
    return TextFormField(
        key: const ValueKey(1),
        controller: searchController,
        maxLines: 1,
        keyboardType: TextInputType.text,
        cursorHeight: 10,
        decoration: InputDecoration(
          errorStyle: const TextStyle(fontSize: 13),
          isDense: true,
          hintText: "  검색어를 입력해주세요.",
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 10.0,
          ),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xffFF6836), width: 1)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xffFF6836), width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xffFF6836), width: 1)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xffFF6836), width: 1)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xffFF6836), width: 1)),
        )
    );
  }

  Future<void> eventAnimation() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    infoList = jsonData['Info'];

    List<dynamic> filteredList = infoList.where((item) {
      if (item['season'] != null && item['season'] is Map && item['season'].containsKey(formattedDate) && item['season'][formattedDate] == true) {
        return true;
      }
      return false;
    }).toList();

    int randomNumber = Random().nextInt(6) + 1;
    targetData = filteredList.firstWhere(
            (element) => element['number'] == randomNumber,
        orElse: () => null);

    if (targetData != null) {
      setState(() {
        recommendCooking = [targetData['image']];
      });
    }

  }

  void loadData(BuildContext context) async {
    String searchText = searchController.text;
    int? foundIndex;

    String jsonString = await rootBundle.loadString('assets/data.json');
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    infoList = jsonData['Info'];

    for (int i = 0; i < infoList.length; i++) {
      if (infoList[i]['name'] == searchText) {
        foundIndex = i;
        break;
      }
    }

    if (foundIndex != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPage(infoList: infoList[foundIndex!]),
        ),
      );
    } else if (searchText.isNotEmpty) {  // <-- 추가된 조건
      showsearchDialog(context);
    }
  }
  Future<void> updateAfterCard() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('comments')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = snapshot.docs.first;
      updateCard = documentSnapshot['commentId'];
    }
    updateCardCompare = await storage.read(key: 'update');
    print(updateCard);
    print(updateCardCompare);

    // 여기에서 'mounted' 속성을 확인합니다.
    if (mounted) {
      if (updateCard != updateCardCompare) {
        setState(() {
          isUpdate = true;
        });
        updateCardCompare = updateCard;
        await storage.write(key: 'update', value: updateCardCompare);
      } else {
        setState(() {
          isUpdate = false;
        });
      }
    }
  }

  late final AnimationController _cardController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 500),
  );

  late final Animation<double> _cardAnimation = Tween<double>(
    begin: 0.95,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _cardController,
    curve: Curves.elasticOut,
  ));

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
    lowerBound: 0.4,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.bounceIn,
  );

  @override
  void dispose() {
    searchController.dispose();
    _cardController.dispose();
    _controller.dispose();
    updateAfterCard();
    super.dispose();
  }
}