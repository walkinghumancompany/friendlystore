import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:friendlystore/providers/userProvider.dart';
import 'package:provider/provider.dart';
import 'head.dart';
import 'detailPage.dart';

class SeasonalFood extends StatefulWidget {
  const SeasonalFood({Key? key}) : super(key: key);

  @override
  State<SeasonalFood> createState() => _SeasonalFoodState();
}

class _SeasonalFoodState extends State<SeasonalFood> {

  late userProvider _userProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ScrollController _scrollController = ScrollController();
  late int currentImageIndex;

  int _fruitsLength = 0;
  int _vegetableLength = 0;
  int _seafoodLength = 0;

  final List _loadFruit = [];
  final List _loadVegetable = [];
  final List _loadSeafood = [];

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

    _yummyIndices = yearYummyDocs.docs.where((doc) {
      // 현재 선택된 월과 문서의 월이 일치하는 항목만 필터링
      return doc.data()['month'] == currentImageIndex + 1;
    }).map((doc) {
      var index = doc.data()['index'];
      return index is int ? index : null;
    }).whereType<int>().toList();

    // 년도 변경 확인 및 yearYummy 컬렉션 삭제
    await _checkAndClearYearYummy(userDoc.docs.first.reference);
    setState(() {});
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

  Future<void> loadData() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    List<dynamic> infoList = jsonData['Info'];

    for (var item in infoList) {
      if (item.containsKey('fruit') && item['fruit'][month] == true) {
        _loadFruit.add(item);
      }
    }
    for (var item in infoList) {
      if (item.containsKey('vegetable') && item['vegetable'][month] == true) {
        _loadVegetable.add(item);
      }
    }
    for (var item in infoList) {
      if (item.containsKey('seefood') && item['seefood'][month] == true) {
        _loadSeafood.add(item);
      }
    }

    _fruitsLength = _loadFruit.length;
    _vegetableLength = _loadVegetable.length;
    _seafoodLength = _loadSeafood.length;
    setState(() {});
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
                            currentImageIndex = (currentImageIndex - 1 + 13) % 13;  // 또는 (currentImageIndex + 1) % 13
                            _loadFruit.clear();
                            _loadVegetable.clear();
                            _loadSeafood.clear();
                            loadData();
                            loadYummyData();  // 월이 변경될 때마다 yummy 데이터 다시 로드
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
                            currentImageIndex = (currentImageIndex + 1 + 13) % 13;  // 또는 (currentImageIndex + 1) % 13
                            _loadFruit.clear();
                            _loadVegetable.clear();
                            _loadSeafood.clear();
                            loadData();
                            loadYummyData();  // 월이 변경될 때마다 yummy 데이터 다시 로드
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
                      height: 30,
                    ),
                    // 과일 리스트
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 15,
                      alignment: Alignment.center,
                      child: Image.asset('assets/fruitsIcon.png', fit: BoxFit.contain,),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        mainAxisSpacing: 21,
                        crossAxisSpacing: 21,
                        padding: EdgeInsets.all(20),
                        children: fruitContainer(_fruitsLength)),
                    const SizedBox(
                      height: 12,
                    ),
                    // 채소 리스트
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 15,
                      alignment: Alignment.center,
                      child: Image.asset('assets/vegetableIcon.png', fit: BoxFit.contain,),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        mainAxisSpacing: 21,
                        crossAxisSpacing: 21,
                        padding: EdgeInsets.all(20),
                        children: vegetableContainer(_vegetableLength)),
                    const SizedBox(
                      height: 12,
                    ),
                    // 씨푸드 리스트
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 15,
                      alignment: Alignment.center,
                      child: Image.asset('assets/seafoodIcon.png', fit: BoxFit.contain,),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        mainAxisSpacing: 21,
                        crossAxisSpacing: 21,
                        padding: EdgeInsets.all(20),
                        children: seafoodContainer(_seafoodLength)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  fruitContainer(int count) {
    return List.generate(count, (index) {
      var fruitIndex = _loadFruit[index]['idx'];
      return Stack(
        children: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DetailPage(infoList: _loadFruit[index], currentMonth: currentImageIndex + 1,),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                _loadFruit[index]['image'],
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (fruitIndex != null && isYummy(fruitIndex))
            Positioned(
              right: 0,  // 오른쪽에 배치
              bottom: 0, // 하단에 배치
              width: MediaQuery.of(context).size.width * 0.25 / 3,  // 전체 너비의 25%의 1/3
              height: MediaQuery.of(context).size.width * 0.25 / 3, // 전체 너비의 25%의 1/3 (정사각형 유지)
              child: Image.asset(
                'assets/yummyCheck.png',
                fit: BoxFit.contain,
              ),
            ),
        ],
      );
    });
  }

  vegetableContainer(int count) {
    return List.generate(count, (index) {
      var vegetableIndex = _loadVegetable[index]['idx'];
      return Stack(
        children: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DetailPage(infoList: _loadVegetable[index], currentMonth: currentImageIndex + 1,),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                _loadVegetable[index]['image'],
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (vegetableIndex != null && isYummy(vegetableIndex))
            Positioned(
              right: 0,  // 오른쪽에 배치
              bottom: 0, // 하단에 배치
              width: MediaQuery.of(context).size.width * 0.25 / 3,  // 전체 너비의 25%의 1/3
              height: MediaQuery.of(context).size.width * 0.25 / 3, // 전체 너비의 25%의 1/3 (정사각형 유지)
              child: Image.asset(
                'assets/yummyCheck.png',
                fit: BoxFit.contain,
              ),
            ),
        ],
      );
    });
  }

  seafoodContainer(int count) {
    return List.generate(count, (index) {
      var seefoodIndex = _loadSeafood[index]['idx'];
      return Stack(
        children: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DetailPage(infoList: _loadSeafood[index], currentMonth: currentImageIndex + 1,),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                _loadSeafood[index]['image'],
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (seefoodIndex != null && isYummy(seefoodIndex))
            Positioned(
              right: 0,  // 오른쪽에 배치
              bottom: 0, // 하단에 배치
              width: MediaQuery.of(context).size.width * 0.25 / 3,  // 전체 너비의 25%의 1/3
              height: MediaQuery.of(context).size.width * 0.25 / 3, // 전체 너비의 25%의 1/3 (정사각형 유지)
              child: Image.asset(
                'assets/yummyCheck.png',
                fit: BoxFit.contain,
              ),
            ),
        ],
      );
    });
  }
}