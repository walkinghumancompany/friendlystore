import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dialog.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({Key? key}) : super(key: key);

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {

  bool isUser = false;
  bool isMent = false;
  bool isRement = false;

  int countUser = 0;
  late TextEditingController userController;
  late TextEditingController mentController;
  late TextEditingController rementController;
  late TextEditingController messageController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? code;
  String? name;
  String? phone;
  final _userKey = GlobalKey<FormState>();
  final _mentKey = GlobalKey<FormState>();
  final _rementKey = GlobalKey<FormState>();
  final _messege = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userController = TextEditingController();
    mentController = TextEditingController();
    rementController = TextEditingController();
    messageController = TextEditingController();
    loadTotaluser();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xffF1EEDE),
        body:
        SingleChildScrollView(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 50,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                alignment: Alignment.topLeft,
                child: Text('가입자수${countUser.toString()}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xffFF6836)
                  ),),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                alignment: Alignment.center,
                child: const Text('가입자확인',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey
                  ),),
              ),
              const SizedBox(
                height: 20,
              ),
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
                        child: searchUser(context),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: 68,
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () async {
                            await loadUser();
                            setState((){
                              isUser = !isUser;
                            });
                          },
                          child : Image.asset('assets/searchIcon.png',
                            fit : BoxFit.contain,
                            height: 68,),
                        ),
                      ),
                    ],
                  )
              ),
              isUser ?
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(code??'데이터없음',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(name??'데이터없음',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(phone??'데이터없음',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => deleteDialog(context, deleteUser),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // 패딩 제로 설정
                        minimumSize: Size.zero, // 최소 사이즈 제로 설정
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 버튼 영역을 내용물에 맞게 축소
                      ),
                      child: const Text('delete',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                        ),),
                    ),
                  )
                ],
              )
                  :
              Container(),
              const SizedBox(
                height: 30,
              ),
              Container(
                alignment: Alignment.center,
                child: const Text('멘트확인',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey
                  ),),
              ),
              const SizedBox(
                height: 20,
              ),
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
                        child: searchMent(context),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: 68,
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () async {
                            setState(() {
                              isMent = !isMent;
                            });
                          },
                          child : Image.asset('assets/searchIcon.png',
                            fit : BoxFit.contain,
                            height: 68,),
                        ),
                      ),
                    ],
                  )
              ),
              Flexible(child:
              isMent ?
              StreamBuilder<List<Map<String, dynamic>>>(
                  stream: getCommentsStream(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator()); // 로딩 표시
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Container(
                            child: const Text('등록된 글이 없습니다.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xffFF6836)
                              ),
                            ),
                          )
                      );
                    }
                    final comments = snapshot.data!;
                    print('코멘트데이터로드확인');
                    print(comments[0]['text']);
                    return
                      ListView.builder(
                          itemCount: comments.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder:(context, index){
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    width:MediaQuery.of(context).size.width * 0.9,
                                    alignment: Alignment.center,
                                    child: Text("${comments[index]['text']}",
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black
                                      ),)
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  alignment: Alignment.bottomRight,
                                  child: TextButton(
                                    onPressed: () async {
                                      await deleteMent(comments[index]['commentId']);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero, // 패딩 제로 설정
                                      minimumSize: Size.zero, // 최소 사이즈 제로 설정
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 버튼 영역을 내용물에 맞게 축소
                                    ),
                                    child: const Text('delete',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.red
                                      ),),
                                  ),
                                )
                              ],
                            );
                          });
                  }
              )
                  : Container(
                height: 30,
              )
              ),
              Container(
                alignment: Alignment.center,
                child: const Text('댓글확인',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey
                  ),),
              ),
              const SizedBox(
                height: 20,
              ),
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
                        child: searchRement(context),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: 68,
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () async {
                            setState(() {
                              isRement = !isRement;
                            });
                          },
                          child : Image.asset('assets/searchIcon.png',
                            fit : BoxFit.contain,
                            height: 68,),
                        ),
                      ),
                    ],
                  )
              ),
              Flexible(child:
              isRement ?
              StreamBuilder<List<Map<String, dynamic>>>(
                  stream: getReCommentsStream(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator()); // 로딩 표시
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Container(
                            child: const Text('등록된 글이 없습니다.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xffFF6836)
                              ),
                            ),
                          )
                      );
                    }
                    final comments = snapshot.data!;
                    print('Re코멘트데이터로드확인');
                    print(comments[0]['reCommentText']);
                    return
                      ListView.builder(
                          itemCount: comments.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder:(context, index){
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    width:MediaQuery.of(context).size.width * 0.9,
                                    alignment: Alignment.center,
                                    child:
                                    Text("${comments[index]['reCommentText']}",
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black
                                      ),)
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  alignment: Alignment.bottomRight,
                                  child: TextButton(
                                    onPressed: () async {
                                      await deleteRement(comments[index]['reCommentId']);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero, // 패딩 제로 설정
                                      minimumSize: Size.zero, // 최소 사이즈 제로 설정
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 버튼 영역을 내용물에 맞게 축소
                                    ),
                                    child: const Text('delete',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.red
                                      ),),
                                  ),
                                )
                              ],
                            );
                          });
                  }
              )
                  : Container()
              ),
              const SizedBox(
                height: 35,
              ),
              Form(
                key: _messege,
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.9,
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
                  child: updateMessege(),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                alignment: Alignment.centerRight,
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextButton(
                    onPressed: () async {
                      await message();
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white), // Text Color
                      backgroundColor: MaterialStateProperty.all(Colors.grey[100]), // Background Color
                      padding: MaterialStateProperty.all(EdgeInsets.all(0)), // Padding
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Colors.white, // Border Color
                            width: 0.9, // Border Width
                          ),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(5), // Elevation for Shadow
                    ),
                    child: const Text('등록',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.black
                      ),)
                ),
              )
            ],
          ),
        )
    );
  }

  TextFormField updateMessege() {
    return TextFormField(
      controller: messageController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
    );
  }

  Future<void> message() async {

    final String messageId = DateTime.now().toIso8601String();

    final Map<String, dynamic> messageData = {
      'messageId': messageId,
      'message': messageController.text
    };
    await _firestore.collection('message').doc(messageId).set(messageData);
    messageController.clear();
  }

  Widget searchUser(BuildContext context) {
    return TextFormField(
        key: _userKey,
        controller: userController,
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
  Widget searchMent(BuildContext context) {
    return TextFormField(
        key: _mentKey,
        controller: mentController,
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
  Widget searchRement(BuildContext context) {
    return TextFormField(
        key: _rementKey,
        controller: rementController,
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

  Future<void> loadTotaluser() async {
    final userCollection = _firestore.collection('users');

    try {
      QuerySnapshot userSnapshot = await userCollection.get();
      countUser = userSnapshot.docs.length; // Get the count of documents

      // For debugging purposes, you can print the count
      print("Total number of users: $countUser");

      setState(() {}); // Update the UI if necessary
    } catch (e) {
      print("Error fetching user count: $e");
      // Handle any errors here
    }
  }

  Future<void> loadUser() async {
    final userName = _firestore.collection('users');
    QuerySnapshot<Map<String, dynamic>> userSnapshot = await userName.where('name', isEqualTo: userController.text ).get();
    if (userSnapshot.docs.isNotEmpty) {
      // Assuming 'name' is unique and you want the first match
      var userDoc = userSnapshot.docs.first;
      Map<String, dynamic> userData = userDoc.data();
      code = userData['code'] as String;
      name = userData['name'] as String;
      phone = userData['phone'] as String;

      // For debugging purposes, you can print the userName
      print("Loaded user name: $name");
      print(code.toString());
      print(phone.toString());
    } else {
      // Handle the case where no users are found
      print("No user found with the name: ${userController.text}");
      code = null;
      name = null;
      phone = null;// Reset the global variable or handle as necessary
    }
  }

  Stream<List<Map<String, dynamic>>> getCommentsStream(BuildContext context) {
    return FirebaseFirestore.instance
        .collection('comments')
        .where('userName', isEqualTo: mentController.text) // Added filter
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        print('스트림확인');
        return {
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    });
  }
  Stream<List<Map<String, dynamic>>> getReCommentsStream(BuildContext context) {
    StreamController<List<Map<String, dynamic>>> controller = StreamController();

    void fetchReComments() async {
      var comments = await FirebaseFirestore.instance.collection('comments').get();
      List<Map<String, dynamic>> allReComments = [];

      for (var comment in comments.docs) {
        var reComments = await FirebaseFirestore.instance
            .collection('comments')
            .doc(comment.id)
            .collection('reComments')
            .where('reUserName', isEqualTo: rementController.text)
            .get();

        for (var reComment in reComments.docs) {
          allReComments.add(reComment.data() as Map<String, dynamic>);
        }
      }

      controller.add(allReComments); // Emit the compiled list of reComments
    }

    fetchReComments(); // Initiate the data fetching

    return controller.stream; // Return the stream for use in a StreamBuilder
  }
  // Stream<List<Map<String, dynamic>>> getReCommentsStream(BuildContext context) {
  //   return FirebaseFirestore.instance
  //       .collection('comments')
  //       .doc()
  //       .collection('reUserName')
  //       .where('reUserName', isEqualTo: rementController.text) // Added filter
  //       .snapshots()
  //       .map((snapshot) {
  //     return snapshot.docs.map((doc) {
  //       print('스트림확인');
  //       return {
  //         ...doc.data() as Map<String, dynamic>,
  //       };
  //     }).toList();
  //   });
  // }


  Future<void> deleteUser() async {
    QuerySnapshot querySnapshot = await _firestore.collection('users')
        .where('name', isEqualTo: userController.text)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      String documentId = querySnapshot.docs.first.id;
      await _firestore.collection('users').doc(documentId).delete();
      print('User with name deleted successfully');
    } else {
      print('No user found with name');
    }
  }

  Future<void> deleteMent(commentId) async {
    final DocumentReference deleteRef = _firestore.collection('comments').doc(commentId);
    await deleteRef.delete();
  }

  Future<void> deleteRement(String reCommentId) async {
    var comments = await FirebaseFirestore.instance.collection('comments').get();

    for (var comment in comments.docs) {
      var reCommentsSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .doc(comment.id)
          .collection('reComments')
          .where('reCommentId', isEqualTo: reCommentId)
          .get();

      for (var reComment in reCommentsSnapshot.docs) {
        // Delete the matching reComment
        await FirebaseFirestore.instance
            .collection('comments')
            .doc(comment.id)
            .collection('reComments')
            .doc(reComment.id)
            .delete();

        // Update the reCommentCount in the parent comment document
        await FirebaseFirestore.instance
            .collection('comments')
            .doc(comment.id)
            .update({'reCommentCount': FieldValue.increment(-1)});

        break; // Break after handling the first matching reComment
      }
    }
  }

  @override
  void dispose() {
    userController.dispose();
    mentController.dispose();
    rementController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
