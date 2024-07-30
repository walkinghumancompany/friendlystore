import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:friendlystore/providers/userProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'head.dart';
import 'loading.dart';
import 'detailPage.dart';
import 'dialog.dart';

class likePage extends StatefulWidget {
  const likePage({Key? key}) : super(key: key);

  @override
  State<likePage> createState() => _likePageState();
}

class _likePageState extends State<likePage> {

  bool isLoading = true;
  late userProvider _userProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List _data = [];
  int? _length = 0;
  String? myName;

  Future<void> loadData() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    List<dynamic> infoList = jsonData['Info'];

    final userProvider _userProvider = Provider.of<userProvider>(
        context, listen: false);
    String? code = _userProvider.user.code;

    final _userCode = _firestore.collection('users');
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await _userCode.where(
        'code', isEqualTo: code).get();

    if (userSnapshot.docs.isNotEmpty) {
      DocumentReference userDocRef = userSnapshot.docs.first.reference;
      QuerySnapshot<Map<String, dynamic>> likesSnapshot = await userDocRef
          .collection('likes').get();
      // 파이어스토어 likes 컬렉션의 모든 idx 값을 추출
      List<dynamic> idxFromLikes = [];
      for (var doc in likesSnapshot.docs) {
        if (doc.data().containsKey('index')) {
          var idxValue = int.tryParse(doc.data()['index'].toString());
          if (idxValue != null) {
            idxFromLikes.add(idxValue);
          } else {
            print('idx value is not an integer in document: ${doc.id}');
          }
        } else {
          print('idx field not found in document: ${doc.id}');
        }
      }

      _data.clear();

      for (var idxValue in idxFromLikes) {
        for (var infoItem in infoList) {
          int infoIdxValue = int.tryParse(infoItem['idx'].toString()) ?? 0;
          if (infoIdxValue == idxValue) {
            _data.add(infoItem);
            break;
          }
        }
      }
    }
    _length = _data.length;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 여기에서 Provider를 통해 userProvider의 인스턴스를 가져옵니다.
    _userProvider = Provider.of<userProvider>(context);
    // Provider로부터 값을 가져와야 하는 모든 로직을 여기서 실행하세요.
    loadName();
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
              title: Head(context, 'assets/like.png', isKaKao: false),
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
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.95,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    child: Text('닉네임 : $myName  ',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black
                      ),),
                  ),
                  Container(
                    child: TextButton(
                      onPressed: () => deleteDialog(context, deleteUser),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // 패딩 제로 설정
                        minimumSize: Size.zero, // 최소 사이즈 제로 설정
                        tapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // 버튼 영역을 내용물에 맞게 축소
                      ),
                      child: const Text(
                        '탈퇴',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 42,
            ),
            Expanded(child:
            isLoading
                ? Loading(context)
                : (_data.length > 0
                ? GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 1 / 0.35,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                padding: EdgeInsets.zero,
                children: LikeContainer(_length!))
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
                    'assets/beforeLikebutton.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "클릭하여 'Likes' 페이지에 추가해 주세요.",
                    maxLines: 1,
                    style: TextStyle(
                        color: Color(0xff555555), fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
            )
            )
          ],
        )
    );
  }

  LikeContainer(int count) {
    return List.generate(count, (index) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          DetailPage(infoList: _data[index],
                            showYummyButton: false,),
                    ),
                  );
                },
                child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: Row(children: [
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.3,
                        height: 102,
                        child: Image.asset(
                          this._data[index]['image'],
                          height: 102,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.6,
                          child: Column(
                            children: [
                              Container(
                                height: 32,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                alignment: Alignment.topLeft,
                                child: Text(
                                  this._data[index]['name'],
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: Color(0xff555555),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                  height: 70,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    this._data[index]['effect']
                                        .toString()
                                        .isEmpty
                                        ? this._data[index]['recipe']
                                        : this._data[index]['effect'],
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    maxLines: 3,
                                    style: const TextStyle(
                                      color: Color(0xff555555),
                                    ),
                                  )),
                            ],
                          )),
                    ]))),
          ]);
    });
  }

  Future<void> loadName() async {
    final String currentUserName = _userProvider.user.name;
    QuerySnapshot querySnapshot = await _firestore.collection('users')
        .where('name', isEqualTo: currentUserName)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      myName = querySnapshot.docs.first.get('name');
    } else {
      print('No user found with name $currentUserName');
    }
  }

  Future<void> deleteUser() async {
    final String currentUserName = _userProvider.user.name;
    QuerySnapshot querySnapshot = await _firestore.collection('users')
        .where('name', isEqualTo: currentUserName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      String documentId = querySnapshot.docs.first.id;
      await _firestore.collection('users').doc(documentId).delete();
      print('User with name $currentUserName deleted successfully');
    } else {
      print('No user found with name $currentUserName');
    }
  }
}