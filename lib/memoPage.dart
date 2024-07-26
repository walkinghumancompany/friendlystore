import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:friendlystore/providers/userProvider.dart';
import 'package:provider/provider.dart';
import 'head.dart';
import 'foodItemClass.dart';



class MemoPage extends StatefulWidget {
  const MemoPage({Key? key}) : super(key: key);

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> with TickerProviderStateMixin {

  bool _isMemoLoad = false;
  bool _isSetMemo = false;
  final FocusNode _focusNode = FocusNode();
  TextEditingController writeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String memo = '';
  List<String> cartItems = [];
  List<String> completedItems = [];
  List<FoodItem> allFoodItems = [];
  List<String> seasonalSuggestions = [];
  late AnimationController _controller;
  late Animation<double> _animation;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // 애니메이션 주기를 2초로 설정
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.2, // 최소 불투명도 (가장 흐릴 때)
      end: 1.0,   // 최대 불투명도 (가장 선명할 때)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // 부드러운 전환을 위한 곡선
    ));
    loadCartMemo();
    loadSeasonalSuggestions();
  }

  Future<void> loadSeasonalSuggestions() async {
    allFoodItems = await loadFoodItems();
    updateSeasonalSuggestions();
  }

  void updateSeasonalSuggestions() {
    DateTime now = DateTime.now();
    String currentMonth = now.month.toString().padLeft(2, '0');

    List<FoodItem> seasonalItems = allFoodItems
        .where((item) => item.seasons[currentMonth] == true)
        .toList();

    seasonalItems.shuffle();
    seasonalSuggestions = seasonalItems.take(3).map((item) => item.name).toList();

    setState(() {});
  }


  Future<void> loadCartMemo() async {
    final userProvider _userProvider = Provider.of<userProvider>(context, listen: false);
    String? code = _userProvider.user.code;
    final _userCode = _firestore.collection('users');

    QuerySnapshot<Map<String, dynamic>> userSnapshot = await _userCode.where('code', isEqualTo: code).get();

    if (userSnapshot.docs.isNotEmpty) {
      List<dynamic>? fetchedCartItems = userSnapshot.docs.first.data()['cartItems'] as List<dynamic>?;
      List<dynamic>? fetchedCompletedItems = userSnapshot.docs.first.data()['completedItems'] as List<dynamic>?;

      setState(() {
        if (fetchedCartItems != null) {
          cartItems = fetchedCartItems.cast<String>();
          memo = cartItems.join(' ');
          writeController.text = memo;
        } else {
          cartItems = [];
          memo = '';
          writeController.clear();
        }

        if (fetchedCompletedItems != null) {
          completedItems = fetchedCompletedItems.cast<String>();
        } else {
          completedItems = [];
        }

        _isMemoLoad = cartItems.isEmpty;
        _isSetMemo = false;
      });
    } else {
      setState(() {
        memo = '';
        writeController.clear();
        _isMemoLoad = true;
        _isSetMemo = false;
      });
    }
  }

  Future<void> setCartMemo() async {
    final userProvider _userProvider = Provider.of<userProvider>(context, listen: false);
    String? code = _userProvider.user.code;

    final Map<String, dynamic> cartItemsData = {
      'cartItems': cartItems,
      'completedItems': completedItems
    };

    final _userCode = _firestore.collection('users');
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await _userCode.where('code', isEqualTo: code).get();

    if (userSnapshot.docs.isNotEmpty) {
      DocumentReference userDocRef = userSnapshot.docs.first.reference;
      await userDocRef.update(cartItemsData);
    }

    setState(() {
      if (cartItems.isEmpty) {
        _isMemoLoad = true;
        _isSetMemo = false;
      }
    });

    updateSeasonalSuggestions();
  }

  Future<void> deleteCartMemo() async {
    final userProvider _userProvider = Provider.of<userProvider>(context, listen: false);
    String? code = _userProvider.user.code;

    final _userCode = _firestore.collection('users');
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await _userCode.where('code', isEqualTo: code).get();

    // 문서가 존재하는 경우, 첫 번째 문서에서 cartMemo를 삭제합니다.
    if (userSnapshot.docs.isNotEmpty) {
      // 문서 ID를 사용하여 문서 참조를 가져옵니다.
      DocumentReference userDocRef = userSnapshot.docs.first.reference;

      // 문서에서 cartMemo 필드를 삭제합니다.
      await userDocRef.update({'cartItems': FieldValue.delete()});
    }

    setState(() {
      writeController.clear();
    });
  }

  Future<void> deleteCompletedItems() async {
    final userProvider _userProvider = Provider.of<userProvider>(context, listen: false);
    String? code = _userProvider.user.code;

    final _userCode = _firestore.collection('users');
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await _userCode.where('code', isEqualTo: code).get();

    if (userSnapshot.docs.isNotEmpty) {
      DocumentReference userDocRef = userSnapshot.docs.first.reference;
      await userDocRef.update({'completedItems': FieldValue.delete()});
    }

    setState(() {
      completedItems.clear(); // 로컬 상태 업데이트
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            title: Head(context, 'assets/Memo.png', isKaKao: false),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Color(0xffF1EEDE),
              ),
            ),
          ),
        ),
      ),
      body:
      Stack(
        children: [
          Positioned.fill(
            child:
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 78,
                  ),
                  Container(
                    width: width,
                    height: 55,
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: width * 0.2,
                          height: 55,
                          padding: EdgeInsets.only(left: 15),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Color(0xffFF6836), // 색상 코드를 Color 객체로 지정
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          width: width * 0.8,
                          height: 55,
                          padding: EdgeInsets.all(0),
                          child: const Text('구매할 목록',
                            style: TextStyle(
                                fontFamily: 'AppleSDGothicNeo',
                                fontWeight: FontWeight.w500,
                                fontSize: 14.7,
                                color: Colors.grey
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  if (_isMemoLoad)
                    Column(
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                _isSetMemo = true;
                                _isMemoLoad = false;
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                FocusScope.of(context).requestFocus(_focusNode);
                              });
                            },
                            child:
                            Container(
                              alignment: Alignment.center,
                              width: width * 0.88,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Color(0xffF1EEDE), // 배경색
                                borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5), // 그림자 색
                                    spreadRadius: 1, // 그림자 범위
                                    blurRadius: 3, // 흐림 정도
                                    offset: Offset(0, 3), // 그림자 위치
                                  ),
                                ],
                              ),
                              child: const Text('장볼 리스트를 여기에 메모해보세요.\n클릭하시면 메모가 가능 합니다.',
                                style: TextStyle(
                                    fontFamily: 'AppleSDGothicNeo',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.7,
                                    color: Colors.grey
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                        ),
                        SizedBox(height: 25),
                        Container(
                          width: width,
                          height: 55,
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: width * 0.2,
                                height: 55,
                                padding: EdgeInsets.only(left: 15),
                                child: const Icon(
                                  Icons.shopping_cart_checkout,
                                  color: Colors.green,
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                width: width * 0.8,
                                height: 55,
                                padding: EdgeInsets.all(0),
                                child: const Text('구매완료 목록',
                                  style: TextStyle(
                                      fontFamily: 'AppleSDGothicNeo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.7,
                                      color: Colors.grey
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          width: width * 0.9,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: completedItems.map((item) => GestureDetector(
                              onTap: () {
                                null;
                              },
                              child: Chip(
                                label: Text(item),
                                backgroundColor: Colors.green.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: Colors.green),
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if(completedItems.isNotEmpty)
                          Container(
                            width: width * 0.9,
                            height: 25,
                            alignment: Alignment.centerRight, // 이 줄을 추가합니다
                            child: GestureDetector(
                              onTap: () async {
                                await deleteCompletedItems();
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Image.asset(
                                  'assets/resetIcon.png',
                                  height: 25,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          )
                        else Container()
                      ],
                    )
                  else if (!_isSetMemo)
                    cartItems.isEmpty
                        ? TextButton(
                        onPressed: () {
                          setState(() {
                            _isSetMemo = true;
                            _isMemoLoad = false;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            FocusScope.of(context).requestFocus(_focusNode);
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: width * 0.88,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Color(0xffF1EEDE),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            '장볼 리스트를 여기에 메모해보세요.\n클릭하시면 메모가 가능 합니다.',
                            style: TextStyle(
                                fontFamily: 'AppleSDGothicNeo',
                                fontWeight: FontWeight.w400,
                                fontSize: 12.7,
                                color: Colors.grey
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                    )
                        :
                    Column(
                      children: [
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSetMemo = true;
                                writeController.text = cartItems.join(' ');
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: Color(0xffF1EEDE),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: cartItems.map((item) => GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      cartItems.remove(item);
                                      completedItems.add(item);
                                    });
                                    await setCartMemo();
                                    if (cartItems.isEmpty) {
                                      setState(() {
                                        _isMemoLoad = true;
                                        _isSetMemo = false;
                                      });
                                    }
                                  },
                                  child: Chip(
                                    label: Text(item),
                                    backgroundColor: Color(0xffF1EEDE),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                )).toList(),
                              ),
                            )
                        ),
                        SizedBox(height: 25),
                        Container(
                          width: width,
                          height: 55,
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: width * 0.2,
                                height: 55,
                                padding: EdgeInsets.only(left: 15),
                                child: const Icon(
                                  Icons.shopping_cart_checkout,
                                  color: Colors.green,
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                width: width * 0.8,
                                height: 55,
                                padding: EdgeInsets.all(0),
                                child: const Text('구매완료 목록',
                                  style: TextStyle(
                                      fontFamily: 'AppleSDGothicNeo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.7,
                                      color: Colors.grey
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          width: width * 0.9,
                          decoration: BoxDecoration(
                            color: Color(0xffF1EEDE), // 배경색
                            borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // 그림자 색
                                spreadRadius: 1, // 그림자 범위
                                blurRadius: 3, // 흐림 정도
                                offset: Offset(0, 3), // 그림자 위치
                              ),
                            ],
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: completedItems.map((item) => GestureDetector(
                              onTap: () {
                                null;
                              },
                              child: Chip(
                                label: Text(item),
                                backgroundColor: Colors.green.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: Colors.green),
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if(completedItems.isNotEmpty)
                          Container(
                            width: width * 0.9,
                            height: 25,
                            alignment: Alignment.centerRight, // 이 줄을 추가합니다
                            child: GestureDetector(
                              onTap: () async {
                                await deleteCompletedItems();
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Image.asset(
                                  'assets/resetIcon.png',
                                  height: 25,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          )
                        else Container()
                      ],
                    ),
                  if (_isSetMemo)
                    Column(
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color(0xffF1EEDE), // 배경색
                              borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), // 그림자 색
                                  spreadRadius: 1, // 그림자 범위
                                  blurRadius: 3, // 흐림 정도
                                  offset: Offset(0, 3), // 그림자 위치
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: _Memo(),
                            )
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: width,
                          height: 25,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 15.2),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isSetMemo = false;
                                      _isMemoLoad = memo.isEmpty; // 메모가 비어있으면 _isMemoLoad를 true로 설정
                                      writeController.text = memo; // 현재 메모 내용으로 컨트롤러 초기화
                                    });
                                    loadCartMemo();
                                  },
                                  child: Image.asset('assets/closeFormIcon.png', fit: BoxFit.contain),
                                ),
                              ),
                              Spacer(), // 왼쪽과 중앙 사이의 공간을 채웁니다
                              Container(
                                child: GestureDetector(
                                  onTap: () async {
                                    await deleteCartMemo();
                                  },
                                  child: Image.asset('assets/resetIcon.png', fit: BoxFit.contain),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                padding: EdgeInsets.only(right: 15.2),
                                child: GestureDetector(
                                  onTap: () async {
                                    List<String> newItems = writeController.text.split(' ').where((item) => item.isNotEmpty).toList();
                                    setState(() {
                                      cartItems = newItems;
                                      memo = writeController.text;
                                    });
                                    await setCartMemo();
                                    setState(() {
                                      _isSetMemo = false;
                                    });
                                  },
                                  child: Image.asset('assets/writeUpdateIcon.png', fit: BoxFit.contain),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 25),
                        Container(
                          width: width,
                          height: 55,
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: width * 0.2,
                                height: 55,
                                padding: EdgeInsets.only(left: 15),
                                child: const Icon(
                                  Icons.shopping_cart_checkout,
                                  color: Colors.green,
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                width: width * 0.8,
                                height: 55,
                                padding: EdgeInsets.all(0),
                                child: const Text('구매완료 목록',
                                  style: TextStyle(
                                      fontFamily: 'AppleSDGothicNeo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.7,
                                      color: Colors.grey
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          width: width * 0.9,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: completedItems.map((item) => GestureDetector(
                              onTap: () {
                                null;
                              },
                              child: Chip(
                                label: Text(item),
                                backgroundColor: Colors.green.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: Colors.green),
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if(completedItems.isNotEmpty)
                          Container(
                            width: width * 0.9,
                            alignment: Alignment.centerRight, // 이 줄을 추가합니다
                            child: GestureDetector(
                              onTap: () async {
                                await deleteCompletedItems();
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Image.asset(
                                  'assets/resetIcon.png',
                                  height: 25,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          )
                        else Container()
                      ],
                    ),
                  const SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          ),
          if(_isSetMemo)
            Positioned(
              top: 25,
              right: 10,
              child: Container(
                width: 180,
                padding: EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _animation.value,
                          child: Container(
                            alignment: Alignment.topCenter,
                            width: 40,
                            child: Image.asset(
                              'assets/SeasonMemo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      child: Column(
                        children:
                          seasonalSuggestions.map((item) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  String currentText = writeController.text;
                                  if (currentText.isNotEmpty && !currentText.endsWith(' ')) {
                                    currentText += ' ';
                                  }
                                  writeController.text = currentText + item;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF8B00).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Text(
                                  item,
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.right,  // 변경: center에서 right로
                                ),
                              ),
                            ),
                          )).toList(),
                      )
                    ),
                  ],
                ),
              ),
            )
          else Container(),
        ],
      ),
    );
  }
  TextFormField _Memo() {
    return TextFormField(
      controller: writeController,
      focusNode: _focusNode,
      maxLines: 10,
      keyboardType: TextInputType.text,
      maxLength: 300,
      autofocus: true,
      decoration: InputDecoration(
        labelText: "CartMemo",
        hintText: "예) 시금치, 삼겹살, 딸기, 과자, 치약......\n띄어쓰기를 꼭 해주세요!\n띄어쓰기시 자동으로 리스트가 되어\n구매완료 목록으로 이동이 가능합니다.",
        fillColor: Color(0xffF1EEDE), // 배경색 설정
        filled: true, // fill color를 사용하기 위해 true로 설정
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
        // 그림자 효과 추가
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      style: const TextStyle(fontSize: 14, color: Colors.black),
    );
  }
}
