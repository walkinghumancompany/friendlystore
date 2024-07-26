import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'head.dart';
import 'detailPage.dart';

class SeasonalFood extends StatefulWidget {
  const SeasonalFood({Key? key}) : super(key: key);

  @override
  State<SeasonalFood> createState() => _SeasonalFoodState();
}

class _SeasonalFoodState extends State<SeasonalFood> {

  ScrollController _scrollController = ScrollController();
  late int currentImageIndex;

  int _fruitsLength = 0;
  int _vegetableLength = 0;
  int _seafoodLength = 0;

  final List _loadFruit = [];
  final List _loadVegetable = [];
  final List _loadSeafood = [];

  String get month => (currentImageIndex + 1).toString().padLeft(2, '0');

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    currentImageIndex = now.month - 1;
    loadData();
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
                            currentImageIndex = (currentImageIndex - 1 + 13) % 13;
                            _loadFruit.clear();
                            _loadVegetable.clear();
                            _loadSeafood.clear();
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
                            currentImageIndex = (currentImageIndex + 1) % 13;
                            _loadFruit.clear();
                            _loadVegetable.clear();
                            _loadSeafood.clear();
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
      return
        Stack(
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
              builder: (context) => DetailPage(infoList: _loadFruit[index]),
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
              )
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset('assets/beforeLikebutton.png',
              fit: BoxFit.contain,),
            )
          ],
       );
     }
    );
  }

  vegetableContainer(int count) {
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
                builder: (context) => DetailPage(infoList: _loadVegetable[index]),
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
          ));
    });
  }

  seafoodContainer(int count) {
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
                builder: (context) => DetailPage(infoList: _loadSeafood[index]),
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
          ));
    });
  }
}
