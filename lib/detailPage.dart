import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:friendlystore/providers/userProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'head.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.infoList}) : super(key: key);
  final Map<String, dynamic> infoList;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addToLikes(String code, int index) async {

    final _userCode = _firestore.collection('users');
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await _userCode.where('code', isEqualTo: code).get();

    if (userSnapshot.docs.isEmpty) {
      print('No user found with code: $code');
      return;
    }

    DocumentReference userDocRef = userSnapshot.docs.first.reference;
    CollectionReference likesCollection = userDocRef.collection('likes');

    // 현재 인덱스가 'likes' 컬렉션에 있는지 확인
    QuerySnapshot<Object?> likesSnapshot = await likesCollection.where('index', isEqualTo: index).get();

    if (likesSnapshot.docs.isNotEmpty) {
      // 해당 인덱스가 이미 'likes' 컬렉션에 있으면 제거합니다.
      await likesSnapshot.docs.first.reference.delete();
      setState(() {
        isLiked = false;
      });
    } else {
      // 해당 인덱스가 'likes' 컬렉션에 없으면 추가합니다.
      await likesCollection.add({'index': index});
      setState(() {
        isLiked = true;
      });
    }
  }

  Future<void> _checkIfLiked(String code, int index) async {
    final _userCode = _firestore.collection('users');
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await _userCode.where('code', isEqualTo: code).get();

    if (userSnapshot.docs.isEmpty) {
      print('No user found with code: $code');
      return;
    }
    DocumentReference userDocRef = userSnapshot.docs.first.reference;
    QuerySnapshot<Map<String, dynamic>> likesSnapshot = await userDocRef.collection('likes').where('index', isEqualTo: index).get();

    setState(() {
      isLiked = !likesSnapshot.docs.isEmpty; // likes 컬렉션에 idx가 있는지 여부에 따라 상태 설정
    });
  }

  bool isLiked = false;

  Future<void> _setYummy(BuildContext context, String code, int index) async {
    final _userCode = _firestore.collection('users');
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await _userCode.where('code', isEqualTo: code).get();

    if (userSnapshot.docs.isEmpty) {
      print('No user found with code: $code');
      return;
    }

    DocumentReference userDocRef = userSnapshot.docs.first.reference;

    // yummy 컬렉션 문서 수 확인
    QuerySnapshot yummySnapshot = await userDocRef.collection('yummy').get();
    if (yummySnapshot.size >= 300) {
      // 300개 초과시 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Center(
            child: Text(
              '최대 300개의 항목까지 저장이 됩니다.\n 기존의 항목을 삭제해 주세요.',
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
      return;
    }

    // yearYummy 컬렉션 문서 수 확인
    QuerySnapshot yearYummySnapshot = await userDocRef.collection('yearYummy').get();
    if (yearYummySnapshot.size >= 300) {
      // 300개 초과시 메시지 출력
      SnackBar(
        content: const Center(
          child: Text(
            '최대 300개의 항목까지 저장이 됩니다.\n 기존의 항목을 삭제해 주세요.',
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
      );
      return;
    }

    // 현재 날짜 가져오기
    DateTime now = DateTime.now();
    String formattedDate = "${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";

    // 새 문서 추가
    await userDocRef.collection('yummy').add({
      'date': formattedDate,
      'index': index,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await userDocRef.collection('yearYummy').add({
      'index': index,
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Center(
            child: Text(
              '야미야미 저장되었습니다!',
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
        )
    );

    print('Yummy added for user $code with index $index on $formattedDate');
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider _userProvider = Provider.of<userProvider>(context, listen: false);
      final index = widget.infoList['idx'] as int;
      _checkIfLiked(_userProvider.user.code, index);
    });
  }

  @override
  Widget build(BuildContext context) {

    final userProvider _userProvider = Provider.of<userProvider>(context);

    double infoWidth = MediaQuery.of(context).size.width * 0.9;

    final infoList = widget.infoList;
    int? index = infoList['idx'] as int;
    String? imageUrl = infoList['image'] as String?;
    String? textName = infoList['name'] as String?;
    String? textSeason = infoList['seasonal'] as String?;
    String? textInfo = infoList['info'] as String?;
    String? textEffect = infoList['effect'] as String;
    String? textKeep = infoList['keep'] as String;
    String? textTip = infoList['tip'] as String;
    String? textIngredient = infoList['ingredient'] as String;
    String? textRecipe = infoList['recipe'] as String;


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
            title: Head(context, 'assets/Dictionary.png', isKaKao: false),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Color(0xffF1EEDE),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            // 이미지
            imageUrl == null ? Container()
                : Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 220,
              padding: EdgeInsets.zero,
              child: Image.asset(imageUrl!,
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 220,
                  fit: BoxFit.contain),
            ),
            const SizedBox(
              height: 20,
            ),
            // 이름 , 라이크버튼
            Container(
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 62,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 62,
                    alignment: Alignment.center,
                    child: Text(textName!,
                      textAlign: TextAlign.center,
                      style:
                      const TextStyle(color: Color(0xff111111), fontSize: 21.5),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await _addToLikes(_userProvider.user.code, index!);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.13,
                      height: 62,
                      alignment: Alignment.center,
                      child: Image.asset(isLiked ? 'assets/afterLikebutton.png' : 'assets/beforeLikebutton.png',
                        fit: BoxFit.contain, height: 52,),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  GestureDetector(
                    onTap: () async {
                      await _setYummy(context, _userProvider.user.code!, index);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.13,
                      height: 52,
                      alignment: Alignment.center,
                      child: Image.asset('assets/yummyButton.png',
                        fit: BoxFit.contain, height: 52,),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 52,
            ),
            // 제철
            textSeason != null && textSeason.isNotEmpty ?
            Column(
              children: [
                Container(
                  width: infoWidth,
                  alignment: Alignment.topCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: infoWidth * 0.3,
                        alignment: Alignment.topCenter,
                        child: Image.asset('assets/seasonalIcon.png', fit: BoxFit.contain, alignment: Alignment.topCenter,),
                      ),
                      SizedBox(
                        width: infoWidth * 0.1,
                      ),
                      Container(
                        width: infoWidth * 0.6,
                        alignment: Alignment.bottomLeft,
                        child: Text(textSeason ?? '',
                            maxLines: 50,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Color(0xff111111), fontSize: 15)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            )
                :
            Container(),
            //주요영양성분
            textInfo != null && textInfo.isNotEmpty ?
            Column(
              children: [
                Container(
                  width: infoWidth,
                  alignment: Alignment.topCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: infoWidth * 0.3,
                        alignment: Alignment.topCenter,
                        child: Image.asset('assets/infoIcon.png', fit: BoxFit.contain, alignment: Alignment.topCenter,),
                      ),
                      SizedBox(
                        width: infoWidth * 0.1,
                      ),
                      Container(
                        width: infoWidth * 0.6,
                        child: Text(textInfo ?? '',
                            maxLines: 50,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Color(0xff111111), fontSize: 15)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            )
                :
            Container(),
            // 효능효과
            textEffect != null && textEffect.isNotEmpty ?
            Container(
              width: infoWidth,
              alignment: Alignment.topCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: infoWidth * 0.3,
                    alignment: Alignment.topCenter,
                    child: Image.asset('assets/effectIcon.png', fit: BoxFit.contain, alignment: Alignment.topCenter,),
                  ),
                  SizedBox(
                    width: infoWidth * 0.1,
                  ),
                  Container(
                    width: infoWidth * 0.6,
                    child: Text(textEffect ?? '',
                      maxLines: 50,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Color(0xff111111), fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
                : Container(),
            const SizedBox(
              height: 20,
            ),
            // 보관방법
            textKeep != null && textKeep.isNotEmpty ?
            Column(
              children: [
                Container(
                  width: infoWidth,
                  alignment: Alignment.topCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: infoWidth * 0.3,
                        alignment: Alignment.topCenter,
                        child: Image.asset('assets/keepIcon.png', fit: BoxFit.contain, alignment: Alignment.topCenter,),
                      ),
                      SizedBox(
                        width: infoWidth * 0.1,
                      ),
                      Container(
                        width: infoWidth * 0.6,
                        child: Text(textKeep ?? '',
                            maxLines: 50,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Color(0xff111111), fontSize: 15)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            )

                : Container(),
            // 팁
            textTip != null && textTip.isNotEmpty ?
            Column(
              children: [
                Container(
                  width: infoWidth,
                  alignment: Alignment.topCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: infoWidth * 0.3,
                        alignment: Alignment.topCenter,
                        child: Image.asset('assets/tipIcon.png', fit: BoxFit.contain, alignment: Alignment.topCenter,),
                      ),
                      SizedBox(
                        width: infoWidth * 0.1,
                      ),
                      Container(
                        width: infoWidth * 0.6,
                        child: Text(textTip ?? '',
                            maxLines: 50,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Color(0xff111111), fontSize: 15)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            )
                : Container(),
            // 재료
            textIngredient != null && textIngredient.isNotEmpty ?
            Column(
              children: [
                Container(
                  width: infoWidth,
                  alignment: Alignment.topCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: infoWidth * 0.3,
                        alignment: Alignment.topCenter,
                        child: Image.asset('assets/ingredientIcon.png', fit: BoxFit.contain, alignment: Alignment.topCenter,),
                      ),
                      SizedBox(
                        width: infoWidth * 0.1,
                      ),
                      Container(
                        width: infoWidth * 0.6,
                        child: Text(textIngredient ?? '',
                            maxLines: 50,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Color(0xff111111), fontSize: 15)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            )
                : Container(),
            //레시피
            textRecipe != null && textRecipe.isNotEmpty ?
            Column(
              children: [
                Container(
                  width: infoWidth,
                  alignment: Alignment.topCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: infoWidth * 0.3,
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          'assets/recipeIcon.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      SizedBox(
                        width: infoWidth * 0.1,
                      ),
                      Container(
                        width: infoWidth * 0.6,
                        child: Text(
                          textRecipe ?? '',
                          maxLines: 50,
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Color(0xff111111), fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}