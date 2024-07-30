import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:friendlystore/providers/userProvider.dart';
import 'package:provider/provider.dart';
import 'head.dart';
import 'detailPage.dart';

class SeasonalCooking extends StatefulWidget {
  const SeasonalCooking({Key? key}) : super(key: key);

  @override
  State<SeasonalCooking> createState() => _SeasonalCookingState();
}

class _SeasonalCookingState extends State<SeasonalCooking> {

  late userProvider _userProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ScrollController _scrollController = ScrollController();
  late int currentImageIndex;

  late int _cookingLength = 0;
  List _loadCooking = [];

  String get month => (currentImageIndex + 1).toString().padLeft(2, '0');

  List<int> _yummyIndices = [];


  Future<void> loadYummyData() async {
    final userProvider _userProvider = Provider.of<userProvider>(context, listen: false);
    String? code = _userProvider.user.code;
    final userDoc = await _firestore.collection('users').where('code', isEqualTo: code).get();

    if (userDoc.docs.isEmpty) {
      print('사용자를 찾을 수 없습니다: $code');
      return;
    }

    final yearYummyDocs = await userDoc.docs.first.reference.collection('yearYummy').get();

    _yummyIndices = yearYummyDocs.docs.map((doc) {
      var index = doc.data()['index'];
      return index is int ? index : null;
    }).whereType<int>().toList();


    // 년도 변경 확인 및 yearYummy 컬렉션 삭제
    await _checkAndClearYearYummy(userDoc.docs.first.reference);
  }

  Future<void> _checkAndClearYearYummy(DocumentReference userDocRef) async {
    final now = DateTime.now();
    final lastUpdateDoc = await userDocRef.collection('lastYearYummyUpdate').doc('lastUpdate').get();

    if (!lastUpdateDoc.exists || lastUpdateDoc.data()?['year'] != now.year) {
      // yearYummy 컬렉션의 모든 문서 삭제
      final yearYummyDocs = await userDocRef.collection('yearYummy').get();
      for (var doc in yearYummyDocs.docs) {
        await doc.reference.delete();
      }

      // lastUpdate 문서 업데이트 또는 생성
      await userDocRef.collection('lastYearYummyUpdate').doc('lastUpdate').set({
        'year': now.year,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _yummyIndices.clear(); // 로컬 리스트도 비우기
    }
  }

  bool isYummy(int index) {
    return _yummyIndices.contains(index);
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<userProvider>(context);
  }


  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    currentImageIndex = now.month - 1;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await loadData();
    await loadYummyData();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadData() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    List<dynamic> infoList = jsonData['Info'];

    for (var item in infoList) {
      if (item['season'] is Map && item['season'][month] == true) {
        _loadCooking.add(item);
      }
    }
    _cookingLength = _loadCooking.length;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    double moveWidth = MediaQuery.of(context).size.width * 0.9;

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
            title: Head(context, 'assets/calendar.png', isKaKao: false),
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
          Positioned(
              top: 0,  // 상단에 위치
              left: 0,
              right: 0,
              child: Card(
                elevation: 0,
                color: Color(0xffF1EEDE),
                child: Container(
                  width: moveWidth,
                  height: 52,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 왼쪽 화살표 버튼
                      InkWell(
                        onTap: () {
                          setState(() {
                            currentImageIndex = (currentImageIndex - 1 + 12) % 12;
                            _loadCooking.clear();
                            loadData();
                          });
                          _scrollController.animateTo(
                              0.0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut
                          );
                        },
                        child: Container(
                          width: moveWidth * 0.1,
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.arrow_circle_left_outlined,
                            color: Color(0xffC0C0C0),
                          ),
                        ),
                      ),
                      // 중앙 이미지
                      Container(
                        width: moveWidth * 0.8,
                        alignment: Alignment.topCenter,
                        child: Image.asset('assets/$month.png'),
                      ),
                      // 오른쪽 화살표 버튼
                      InkWell(
                        onTap: () {
                          setState(() {
                            currentImageIndex = (currentImageIndex + 1) % 12;
                            _loadCooking.clear();
                            loadData();
                          });
                          _scrollController.animateTo(
                              0.0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut
                          );
                        },
                        child: Container(
                          width: moveWidth * 0.1,
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.arrow_circle_right_outlined,
                            color: Color(0xffC0C0C0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ),
          Padding(
            padding: EdgeInsets.only(top: 52),  // 상단에 고정된 위젯만큼의 공간을 만듭니다.
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    // 제철요리 리스트
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 25,
                      alignment: Alignment.center,
                      child: Image.asset('assets/cookings.png', fit: BoxFit.contain,),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: moveWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: moveWidth * 0.48,
                            child: GridView.count(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 1,
                                mainAxisSpacing: 7,
                                crossAxisSpacing: 7,
                                padding: EdgeInsets.all(0),
                                children: cookingImageContainer(_cookingLength)),
                          ),
                          SizedBox(
                            width: moveWidth * 0.04,
                          ),
                          Container(
                            width: moveWidth * 0.48,
                            child: GridView.count(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 1,
                                mainAxisSpacing: 7,
                                crossAxisSpacing: 7,
                                padding: EdgeInsets.all(0),
                                children: cookingTextContainer(_cookingLength)),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  cookingImageContainer(int count) {
    return List.generate(count, (index) {
      var cookingIndex = _loadCooking[index]['idx'];
      return TextButton(
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailPage(infoList: _loadCooking[index]),
            ),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 100,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  _loadCooking[index]['image'],
                  fit: BoxFit.contain,
                ),
              ),
              if (cookingIndex != null && isYummy(cookingIndex))
                Positioned(
                  right: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width * 0.25 / 3,
                  height: MediaQuery.of(context).size.width * 0.25 / 3,
                  child: Image.asset(
                    'assets/yummyCheck.png',
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
  cookingTextContainer (int count) {
    double textHeight = MediaQuery.of(context).size.width;
    return List.generate(count, (index) {
      return TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailPage(infoList: _loadCooking[index]),
              ),
            );
          },
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    height: 36,
                    child: Text(
                      _loadCooking[index]['name'],
                      style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    height: 56,
                    child: Text(
                      _loadCooking[index]['recipe'],
                      style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
          ));
    });
  }
}
