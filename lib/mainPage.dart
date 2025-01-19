
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      storageLoad();
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
                                    builder: (context) => Yummy(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Image.asset('assets/card05.png', fit: BoxFit.contain),
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
                                child: Image.asset('assets/card06.png', fit: BoxFit.contain),
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
                          const url = 'https://smartstore.naver.com/friendly_store';
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

    int randomNumber = Random().nextInt(10) + 1;
    targetData = filteredList.firstWhere(
            (element) => element['number'] == randomNumber,
        orElse: () => null);

    if (targetData != null) {
      if(mounted) {
        setState(() {
          recommendCooking = [targetData['image']];
        });
      }
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
          builder: (context) => DetailPage(infoList: infoList[foundIndex!], showYummyButton: false,),
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