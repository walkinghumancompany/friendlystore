import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:friendlystore/providers/userProvider.dart';
import 'package:provider/provider.dart';

import 'detailPage.dart';
import 'head.dart';
import 'loading.dart';

class Yummy extends StatefulWidget {
  const Yummy({Key? key}) : super(key: key);

  @override
  State<Yummy> createState() => _YummyState();
}

class _YummyState extends State<Yummy> {

  bool isLoading = true;
  late userProvider _userProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List _data = [];
  int? _length = 0;
  bool isSeasonalMonth = false;

  Future<void> loadData() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    List<dynamic> infoList = jsonData['Info'];

    final userProvider _userProvider = Provider.of<userProvider>(context, listen: false);
    String? code = _userProvider.user.code;

    final _userCode = _firestore.collection('users');
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await _userCode.where(
        'code', isEqualTo: code).get();

    if (userSnapshot.docs.isNotEmpty) {
      DocumentReference userDocRef = userSnapshot.docs.first.reference;
      QuerySnapshot<Map<String, dynamic>> yummySnapshot = await userDocRef
          .collection('yummy').get();

      _data.clear();

      for (var doc in yummySnapshot.docs) {
        if (doc.data().containsKey('index') && doc.data().containsKey('date')) {
          var idxValue = int.tryParse(doc.data()['index'].toString());
          var dateString = doc.data()['date'] as String;
          var timestamp = doc.data()['timestamp'] as Timestamp;

          if (idxValue != null) {
            for (var infoItem in infoList) {
              int infoIdxValue = int.tryParse(infoItem['idx'].toString()) ?? 0;
              if (infoIdxValue == idxValue) {
                var dateParts = dateString.split('/');
                if (dateParts.length == 3) {
                  var formattedDate = '${dateParts[0]}년 ${dateParts[1].padLeft(2, '0')}월 ${dateParts[2].padLeft(2, '0')}일';
                  var clickMonth = dateParts[1].padLeft(2, '0');

                  var itemWithDate = Map<String, dynamic>.from(infoItem);
                  itemWithDate['formattedDate'] = formattedDate;
                  itemWithDate['timestamp'] = timestamp;

                  bool isSeasonalMonth = false;
                  if (itemWithDate.containsKey('seefood')) {
                    isSeasonalMonth = itemWithDate['seefood'][clickMonth] == true;
                  } else if (itemWithDate.containsKey('vegetable')) {
                    isSeasonalMonth = itemWithDate['vegetable'][clickMonth] == true;
                  } else if (itemWithDate.containsKey('fruit')) {
                    isSeasonalMonth = itemWithDate['fruit'][clickMonth] == true;
                  } else if (itemWithDate.containsKey('season')) {
                    isSeasonalMonth = itemWithDate['season'][clickMonth] == true;
                  }
                  itemWithDate['isSeasonalMonth'] = isSeasonalMonth;
                  _data.add(itemWithDate);
                  break;
                }
              }
            }
          }
        }
      }
      _data.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      _length = _data.length;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteYummyItem(int index) async {
    try {
      final userProvider _userProvider = Provider.of<userProvider>(context, listen: false);
      String? code = _userProvider.user.code;

      final _userCode = _firestore.collection('users');
      QuerySnapshot<Map<String, dynamic>> userSnapshot = await _userCode.where('code', isEqualTo: code).get();

      if (userSnapshot.docs.isNotEmpty) {
        DocumentReference userDocRef = userSnapshot.docs.first.reference;

        // yummy 컬렉션에서 해당 문서 찾기
        QuerySnapshot yearYummySnapshot = await userDocRef.collection('yearYummy')
            .where('index', isEqualTo: _data[index]['idx'])
            .limit(1)
            .get();

        QuerySnapshot yummySnapshot = await userDocRef.collection('yummy')
            .where('index', isEqualTo: _data[index]['idx'])
            .limit(1)
            .get();

        if (yummySnapshot.docs.isNotEmpty && yearYummySnapshot.docs.isNotEmpty) {
          // 문서 삭제
          await yummySnapshot.docs.first.reference.delete();
          await yearYummySnapshot.docs.first.reference.delete();

          // 상태 업데이트
          setState(() {
            _data.removeAt(index);
            _length = _data.length;
          });

          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Center(
                child: Text(
                  '항목이 삭제되었습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'AppleSDGothicNeo',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
            ),
          );
        }
      }
    } catch (e) {
      print('Error deleting yummy item: $e');
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('항목 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<userProvider>(context);
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: Colors.transparent,
            // 투명 배경
            centerTitle: true,
            elevation: 0,
            title: Head(context, 'assets/Yummy.png', isKaKao: false),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Color(0xffF1EEDE),
              ),
            ),
          ),
        ),
      ),
      body:
      Column(
        children: [
          const SizedBox(
            height: 21,
          ),
          Expanded(
            child:
            isLoading ? Loading(context)
            :
            (_data.length > 0
                ? GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 1 / 0.35,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                padding: EdgeInsets.zero,
                children: YummyContainer(_length!))
                : Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 150,
                  ),
                  const Text(
                    "'DICTIONARY' 페이지에서,\n",
                    maxLines: 1,
                    style: TextStyle(
                        color: Color(0xff555555), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Image.asset(
                    'assets/yummyButton.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "클릭하여 'YUMMY' 페이지에 추가해 주세요.",
                    maxLines: 1,
                    style: TextStyle(
                        color: Color(0xff555555), fontWeight: FontWeight.bold),
                  )
                ],
              ),
             )
            ),
          )
        ],
      ),
    );
  }

  YummyContainer(int count) {
    return List.generate(count, (index) {
      bool isSeasonalMonth = _data[index]['isSeasonalMonth'] ?? false;
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 21),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 102,
                  child: Image.asset(_data[index]['image'], fit: BoxFit.contain),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 102,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Container(
                        height: 25,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _data[index]['formattedDate'],
                          style: const TextStyle(
                              fontFamily: 'AppleSDGothicNeo',
                              fontWeight: FontWeight.w600,
                              fontSize: 13.7,
                              color: Colors.grey
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 45,
                        child: Row(
                          children: [
                            if (isSeasonalMonth)
                              Container(
                                alignment: Alignment.topLeft,
                                child: const Text(
                                  '제철',
                                  style: TextStyle(
                                    fontFamily: 'AppleSDGothicNeo',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.7,
                                    color: Color(0xffFF6836),
                                  ),
                                ),
                              ),
                            if (isSeasonalMonth)
                              const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: RichText(
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: this._data[index]['name'],
                                            style: const TextStyle(
                                              fontFamily: 'AppleSDGothicNeo',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15.7,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: ' YUMMY !',
                                            style: TextStyle(
                                              fontFamily: 'AppleSDGothicNeo',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15.7,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                              onTap: () {
                                deleteYummyItem(index);
                              },
                              child:
                            const Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: Text('delete',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            )
                        )
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      );
    });
  }
}
