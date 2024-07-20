import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:friendlystore/providers/userProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'head.dart';
import 'dialog.dart';

class MentPage extends StatefulWidget {
  const MentPage({Key? key}) : super(key: key);

  @override
  State<MentPage> createState() => _MentPageState();
}


class _MentPageState extends State<MentPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  userProvider _userProvider = userProvider();
  bool writeLoad = false;
  bool isMyComments = false;
  TextEditingController writeController = TextEditingController();
  TextEditingController reCommentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _reformKey = GlobalKey<FormState>();
  late String? userName;
  late int? likeCount = 0;
  int? clickedCommentIndex;
  int? clickedLikeIndex;
  List<Map<String, dynamic>> allComments = [];
  String? clickedCommentId; // 현재 클릭된 댓글의 ID를 저장
  final ScrollController _scrollController = ScrollController();
  bool hasShownPopup = false;


  @override
  void initState() {
    super.initState();
    _loadComments();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !hasShownPopup) {
        // 스크롤이 최하단에 도달하고 팝업이 아직 표시되지 않았을 때
        hasShownPopup = true;
        showEndOfCommentsPopup(context);
      }
    });
  }

  @override
  TextFormField _comment() {
    return TextFormField(
      controller: writeController,
      maxLines: 9,
      keyboardType: TextInputType.text,
      maxLength: 200,
      validator: ((String? value) {
        if (value?.isEmpty ?? true) {
          return "클릭하여 글을 입력해주세요.";
        }
        if (value != null && value.length > 150) {
          return '글자 수는 200자를 넘을 수 없습니다.';
        }
        return null;
      }),
      decoration: InputDecoration(
        labelText: "Comment",
        hintText: "욕설, 비방, 허용되지 않은 광고등은 어플리케이션 강제 퇴장 조치됩니다.",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
  @override
  TextFormField _reComment() {
    return TextFormField(
      controller: reCommentController,
      maxLines: 5,
      keyboardType: TextInputType.text,
      maxLength: 100,
      validator: ((String? value) {
        if (value?.isEmpty ?? true) {
          return "클릭하여 글을 입력해주세요.";
        }
        if (value != null && value.length > 150) {
          return '글자 수는 100자를 넘을 수 없습니다.';
        }
        return null;
      }),
      decoration: InputDecoration(
        labelText: "ReComment",
        hintText: "욕설, 비방, 허용되지 않은 광고등은 어플리케이션 강제 퇴장 조치됩니다.",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = Provider.of<userProvider>(context, listen: true);
    double tapWidth = MediaQuery.of(context).size.width * 0.95;

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
            title: Head(context, 'assets/Comment.png', isKaKao: false),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Color(0xffF1EEDE),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          Container(
            width: tapWidth,
            height: 82,
            child: Row(
              children: [
                Container(
                  width: tapWidth * 0.6,
                  height: 72,
                  alignment: Alignment.centerLeft,
                  child: Image.asset('assets/CommentPageInfo.png', fit: BoxFit.contain, height: 62,),
                ),
                // 내 글 보기 버튼
                Container(
                    width: tapWidth * 0.195,
                    height: 72,
                    alignment: Alignment.bottomCenter,
                    child:
                    SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () async {
                                setState(() {
                                  isMyComments = !isMyComments;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.bottomCenter,
                              ),
                              child: Image.asset(isMyComments ? 'assets/allCommentsView.png': 'assets/checkMentIcon.png', fit: BoxFit.contain,
                                width: tapWidth * 0.195,),
                            )
                          ],
                        )
                    )
                ),
                Container(
                  width: tapWidth * 0.01,
                  height: 72,
                ),
                // 글쓰기 활성화 버튼
                Container(
                    width: tapWidth * 0.195,
                    height: 72,
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.zero,
                    child:
                    SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: (){
                                setState(() {
                                  writeLoad = !writeLoad;  // 현재 값의 반대로 변경
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.bottomCenter,
                              ),
                              child: Image.asset(writeLoad ? 'assets/closeFormIcon.png' : 'assets/writeIcon.png', fit: BoxFit.contain,
                                width: tapWidth * 0.195,),
                            )
                          ],
                        )
                    )
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          // 글쓰기 텍스트폼필드
          writeLoad ?
          Column(
            children: [
              Container(
                width: tapWidth,
                child: Form(
                  key: _formKey,
                  child: _comment(),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              // 글쓰기 등록 버튼
              Container(
                width: tapWidth,
                height: 25,
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () async {
                    await _updateComments(userName: _userProvider.user.name, commentText: writeController.text);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.bottomCenter,
                  ),
                  child: Image.asset('assets/writeUpdateIcon.png', fit: BoxFit.contain,),
                ),
              ),
              const SizedBox(
                height: 25,
              )
            ],
          )
              :
          Container(),
          Expanded(
            // 내 글보기 시작
              child: isMyComments
                  ?   StreamBuilder<List<Map<String, dynamic>>>(
                stream: myCommentsStream(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // 로딩 표시
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
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Container(
                            width: tapWidth,
                            alignment: Alignment.center,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center, // 점과 텍스트가 정렬되도록
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    // 라이크 버튼
                                    Container(
                                      width: tapWidth * 0.1,
                                      height: 24,
                                      alignment: Alignment.center,
                                      child: TextButton(
                                          onPressed: () async {
                                            await toggleLike(comments[index]['commentId'], _userProvider.user.name);
                                          },
                                          style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero
                                          ),
                                          child: Image.asset('assets/likeCount.png', fit: BoxFit.contain,)
                                      ),
                                    ),
                                    // 라이크 카운트
                                    Container(
                                      width: tapWidth * 0.1,
                                      height: 12,
                                      alignment: Alignment.center,
                                      child: Text("${comments[index]['likeCount'].toString()}",
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xffFF6836)
                                        ),),
                                    ),
                                  ],
                                ),
                                // 멘트 출력
                                Expanded(
                                    child: Text("${comments[index]['text']}",
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black
                                      ),)
                                ),
                              ],
                            ),
                          ),
                          // 대댓글 출력 및 입력
                          (clickedCommentIndex == index && clickedCommentIndex != -1) ?
                          Column(
                            children: [
                              // 글쓴이
                              Container(
                                  width: tapWidth,
                                  height: 18,
                                  alignment: Alignment.bottomRight,
                                  child:Text(
                                    "-${comments[index]['userName']}-",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,),
                                  )
                              ),
                              // 기존에 달린 댓글 출력
                              Container(
                                width: tapWidth * 0.9,
                                child: StreamBuilder<List<Map<String, dynamic>>>(
                                  stream: _getReCommentsOfClickedComment(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container();  // 로딩 중
                                    }
                                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return const Text('댓글이 없습니다.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,));  // 댓글이 없는 경우
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, reCommentIndex) {
                                        final reComment = snapshot.data!;
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('-${reComment[reCommentIndex]['reUserName']}-',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey,)),
                                                ),
                                                (reComment[reCommentIndex]['reUserName'] == _userProvider.user.name) ?
                                                Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      await deleteMyReComment(reComment[reCommentIndex]['reCommentId'], comments[index]['commentId']);
                                                      setState(() {});
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
                                                    : Container(),
                                              ],
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(reComment[reCommentIndex]['reCommentText'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,)),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: tapWidth * 0.9,
                                child: Form(
                                    key: _reformKey,
                                    child: _reComment()),
                              ),
                              // 댓글등록 버튼
                              Row(
                                children: [
                                  // 댓글 창 닫기
                                  Container(
                                    width: tapWidth * 0.79,
                                    height: 23,
                                    alignment: Alignment.topRight,
                                    child: TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          clickedCommentIndex = -1;
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.bottomCenter,
                                      ),
                                      child: Image.asset('assets/closeFormIcon.png', fit: BoxFit.contain,),
                                    ),
                                  ),
                                  Container(
                                    width: tapWidth * 0.01,
                                    height: 23,
                                  ),
                                  // 댓글 등록 버튼
                                  Container(
                                    width: tapWidth * 0.2,
                                    height: 23,
                                    alignment: Alignment.topRight,
                                    child: TextButton(
                                      onPressed: () async {
                                        if (!_reformKey.currentState!.validate()) {
                                          return;
                                        }
                                        await _updateRecomment(reUserName: _userProvider.user.name,
                                            reCommentText: reCommentController.text, reCommentId: comments[index]['commentId']);
                                        await _countReComment(reCommentId: comments[index]['commentId']);

                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.bottomCenter,
                                      ),
                                      child: Image.asset('assets/writeUpdateIcon.png', fit: BoxFit.contain,),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              )
                            ],
                          )
                              :
                          // 글쓴이, 댓글, 댓글카운트 출력
                          Container(
                              width: tapWidth,
                              height: 18,
                              alignment: Alignment.bottomRight,
                              child:Text(
                                "-${comments[index]['userName']}-",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,),
                              )
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                              width: tapWidth,
                              height: 15,
                              child:
                              Row(
                                  children:[
                                    Container(
                                        width: tapWidth * 0.8,
                                        height: 15,
                                        alignment: Alignment.topRight,
                                        child: TextButton(
                                          onPressed: ()  {
                                            setState(() async {
                                              await deleteMyComment(comments[index]['commentId']);
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            alignment: Alignment.centerRight,
                                          ),
                                          child: const Text('delete',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.red
                                            ),),
                                        )
                                    ),
                                    Container(
                                        width: tapWidth * 0.12,
                                        alignment: Alignment.centerRight,
                                        // decoration: BoxDecoration(border: Border.all(width: 1)),
                                        child:
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              clickedCommentIndex = index;
                                              clickedCommentId = comments[index]['commentId'];
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            alignment: Alignment.centerRight,
                                          ),
                                          child: const Row(  // '댓글' 앞에 아이콘을 추가하기 위해 Row 위젯 사용
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Icon(Icons.add_circle_outline, color: Colors.grey, size: 11,),  // 아이콘 추가
                                              Text('댓글',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                    ),
                                    Container(
                                      width: tapWidth * 0.08,
                                      alignment: Alignment.bottomLeft,
                                      child: Text(comments[index]['reCommentCount'].toString(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xffFF6836),),),
                                    ),
                                  ]
                              )
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    },
                  );
                },
              )
              // 내글보기 끝----
              // 전체글보기 시작--->
                  :
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: getCommentsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Container()); // 데이터가 아직 없는 경우 로딩 인디케이터를 표시
                  }
                  final comments = snapshot.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Container(
                            width: tapWidth,
                            alignment: Alignment.center,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center, // 점과 텍스트가 정렬되도록
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    // 라이크 버튼
                                    Container(
                                      width: tapWidth * 0.1,
                                      height: 24,
                                      alignment: Alignment.center,
                                      child: TextButton(
                                          onPressed: () async {
                                            await toggleLike(comments[index]['commentId'], _userProvider.user.name);
                                          },
                                          style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero
                                          ),
                                          child: Image.asset('assets/likeCount.png', fit: BoxFit.contain,)
                                      ),
                                    ),
                                    // 라이크 카운트
                                    Container(
                                      width: tapWidth * 0.1,
                                      height: 12,
                                      alignment: Alignment.center,
                                      child: Text("${comments[index]['likeCount'].toString()}",
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xffFF6836)
                                        ),),
                                    ),
                                  ],
                                ),
                                // 멘트 출력
                                Expanded(
                                    child: Text("${comments[index]['text']}",
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black
                                      ),)
                                ),
                              ],
                            ),
                          ),
                          // 댓글 출력 및 입력
                          (clickedCommentIndex == index && clickedCommentIndex != -1) ?
                          Column(
                            children: [
                              // 글쓴이
                              Container(
                                  width: tapWidth,
                                  height: 18,
                                  alignment: Alignment.bottomRight,
                                  child:Text(
                                    "-${comments[index]['userName']}-",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,),
                                  )
                              ),
                              // 기존에 달린 댓글 출력
                              Container(
                                width: tapWidth * 0.9,
                                child: StreamBuilder<List<Map<String, dynamic>>>(
                                  stream: _getReCommentsOfClickedComment(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container();  // 로딩 중
                                    }
                                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                      return const Text('댓글이 없습니다.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,));  // 댓글이 없는 경우
                                    }
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, reCommentIndex) {
                                        final reComment = snapshot.data!;
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('-${reComment[reCommentIndex]['reUserName']}-',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey,)),
                                                ),
                                                (reComment[reCommentIndex]['reUserName'] == _userProvider.user.name) ?
                                                Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      await deleteMyReComment(reComment[reCommentIndex]['reCommentId'], comments[index]['commentId']);
                                                      setState(() {});
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
                                                    : Container(),
                                              ],
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(reComment[reCommentIndex]['reCommentText'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,)),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: tapWidth * 0.9,
                                child: Form(
                                    key: _reformKey,
                                    child: _reComment()),
                              ),
                              // 댓글등록 버튼
                              Row(
                                children: [
                                  // 댓글 창 닫기
                                  Container(
                                    width: tapWidth * 0.79,
                                    height: 23,
                                    alignment: Alignment.topRight,
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          clickedCommentIndex = -1;
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.bottomCenter,
                                      ),
                                      child: Image.asset('assets/closeFormIcon.png', fit: BoxFit.contain,),
                                    ),
                                  ),
                                  Container(
                                    width: tapWidth * 0.01,
                                    height: 23,
                                  ),
                                  // 댓글 등록 버튼
                                  Container(
                                    width: tapWidth * 0.2,
                                    height: 23,
                                    alignment: Alignment.topRight,
                                    child: TextButton(
                                      onPressed: () async {
                                        if (!_reformKey.currentState!.validate()) {
                                          return;
                                        }
                                        await _updateRecomment(reUserName: _userProvider.user.name,
                                            reCommentText: reCommentController.text, reCommentId: comments[index]['commentId']);
                                        await _countReComment(reCommentId: comments[index]['commentId']);

                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.bottomCenter,
                                      ),
                                      child: Image.asset('assets/writeUpdateIcon.png', fit: BoxFit.contain,),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              )
                            ],
                          )
                              :
                          // 글쓴이, 댓글, 댓글카운트 출력
                          Container(
                              width: tapWidth,
                              height: 18,
                              alignment: Alignment.bottomRight,
                              child:Text(
                                "-${comments[index]['userName']}-",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,),
                              )
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                              width: tapWidth,
                              height: 15,
                              child:
                              Row(
                                  children:[
                                    Container(
                                      width: tapWidth * 0.7,
                                    ),
                                    Container(
                                        width: tapWidth * 0.1,
                                        alignment: Alignment.topRight,
                                        child:
                                        (comments[index]['userName'] == _userProvider.user.name) ?
                                        TextButton(
                                          onPressed: () async {
                                            await deleteMyComment(comments[index]['commentId']);
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            alignment: Alignment.centerRight,
                                          ),
                                          child: const Text('delete',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.red
                                            ),),
                                        )
                                            :Container()
                                    ),
                                    Container(
                                        width: tapWidth * 0.12,
                                        alignment: Alignment.centerRight,
                                        // decoration: BoxDecoration(border: Border.all(width: 1)),
                                        child:
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              clickedCommentIndex = index;
                                              clickedCommentId = comments[index]['commentId'];
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            alignment: Alignment.centerRight,
                                          ),
                                          child: const Row(  // '댓글' 앞에 아이콘을 추가하기 위해 Row 위젯 사용
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Icon(Icons.add_circle_outline, color: Colors.grey, size: 11,),  // 아이콘 추가
                                              Text('댓글',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                    ),
                                    Container(
                                      width: tapWidth * 0.08,
                                      alignment: Alignment.bottomLeft,
                                      child: Text(comments[index]['reCommentCount'].toString(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xffFF6836),),),
                                    ),
                                  ]
                              )
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    },
                  );
                },
              )
          )
        ],
      ),
    );
  }


  Stream<List<Map<String, dynamic>>> getCommentsStream() {
    return FirebaseFirestore.instance.collection('comments').limit(100)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      int currentCount = snapshot.docs.length;

      return snapshot.docs.map((doc) {
        return {
          ...doc.data() as Map<String, dynamic>,
          'commentId': doc.id,
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> myCommentsStream(BuildContext context) {
    final String currentUserName = _userProvider.user.name;

    return FirebaseFirestore.instance.collection('comments')
        .orderBy('timestamp', descending: true) // 최신 글이 상단에 오도록 내림차순 정렬
        .where('userName', isEqualTo: currentUserName) // userName 필드의 값과 currentUserName이 일치하는 문서만 선택
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          ...doc.data() as Map<String, dynamic>,
          'commentId': doc.id, // commentId 추가
        };
      }).toList();
    });
  }


  Stream<List<Map<String, dynamic>>> getReCommentsStream(String commentsId) {
    return FirebaseFirestore.instance
        .collection('comments')
        .doc(commentsId)
        .collection('reComments')
        .orderBy('reTimestamp', descending: false)
        .snapshots()
        .handleError((error) {
      print("Error fetching reComments: $error");
    })
        .map((querySnapshot) {
      var dataList = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      return dataList;
    });
  }

  Stream<List<Map<String, dynamic>>> _getReCommentsOfClickedComment() {
    if (clickedCommentId != null) {
      return getReCommentsStream(clickedCommentId!);
    }
    return Stream.value([]); // 아무 댓글도 선택되지 않았다면 빈 스트림을 반환합니다.
  }


  Future<void> _countReComment({required reCommentId}) async {
    final commentRef = FirebaseFirestore.instance.collection('comments').doc(reCommentId);
    final reCommentRef = commentRef.collection('reComments');
    final QuerySnapshot reCommentSnapshot = await reCommentRef.get();
    int countRecomment = reCommentSnapshot.docs.length;
    await commentRef.update({'reCommentCount': countRecomment});
  }

  Future<void> toggleLike(String commentId, String userId) async {
    final commentRef = FirebaseFirestore.instance.collection('comments').doc(commentId);
    final likesRef = commentRef.collection('likes').doc(userId);

    final likeDoc = await likesRef.get();

    if (likeDoc.exists) {
      // 이미 좋아요가 눌려져 있으면 삭제합니다.
      await likesRef.delete();
    } else {
      // 아직 좋아요가 눌려져 있지 않으면 추가합니다.
      await likesRef.set({'likedAt': Timestamp.now()});
    }

    final likesCollectionRef = commentRef.collection('likes');

// likes 컬렉션에 있는 모든 문서(사용자)를 가져옵니다.
    final QuerySnapshot likesSnapshot = await likesCollectionRef.get();

// likesSnapshot.docs는 문서의 리스트를 반환하므로, 그 길이는 좋아요의 수를 나타냅니다.
    int countLike = likesSnapshot.docs.length;

// commentId에 해당하는 문서에 likeCount 필드를 추가/업데이트합니다.
    await commentRef.update({'likeCount': countLike});

  }

  Future<void> _updateRecomment({required String reUserName,
    required String reCommentText,
    required String reCommentId}) async {
    if (_reformKey.currentState == null || !_reformKey.currentState!.validate()) {
      return;
    }
    final String CommentId = DateTime.now().toIso8601String();
    final Map<String, dynamic> reCommentData = {
      'reCommentText': reCommentText,
      'reUserName': reUserName,
      'reTimestamp':FieldValue.serverTimestamp(),
      'reCommentId': CommentId,
    };
    CollectionReference comments = FirebaseFirestore.instance.collection('comments');

    // 주어진 ID에 해당하는 문서의 참조를 얻습니다.
    DocumentReference commentDoc = comments.doc(reCommentId);

    // 그 문서 내의 'reComments' 컬렉션에 데이터를 추가합니다.
    await commentDoc.collection('reComments').add(reCommentData);


    reCommentController.clear();
  }

  Future<void> _updateComments({
    required String userName,
    required String commentText,
  }) async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    // 고유한 commentId 생성
    final String commentId = DateTime.now().toIso8601String();

    // Firestore에 저장될 데이터 구조
    final Map<String, dynamic> commentData = {
      'userName': userName,
      'text': commentText,
      'timestamp': FieldValue.serverTimestamp(), // 서버 시간 기반 타임스탬프
      'commentId': commentId,
      'likeCount': 0,
      'reCommentCount':0,
    };

    // Firestore에 데이터 저장
    await _firestore.collection('comments').doc(commentId).set(commentData);

    setState(() {
      writeLoad = false;
    });
    writeController.clear();
  }

  Future<void> _loadComments() async {
    // 파이어스토어의 comments 컬렉션에서 데이터를 가져옵니다.
    final commentsQuery = FirebaseFirestore.instance.collection('comments')
        .orderBy('timestamp', descending: true)
        .limit(100);

    final querySnapshot = await commentsQuery.get();

    List<Map<String, dynamic>> newLoadedComments = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> commentData = doc.data() as Map<String, dynamic>;
      commentData['id'] = doc.id; // 댓글의 ID도 저장
      newLoadedComments.add(commentData);
    }

    setState(() {
      allComments = newLoadedComments;
    });
  }

  Future<void> deleteMyComment(commentId) async {
    final DocumentReference deleteRef = _firestore.collection('comments').doc(commentId);
    await deleteRef.delete();
  }

  Future<void> deleteMyReComment(String reCommentId, String commentId) async {
    // 1. 'comments' 컬렉션에서 특정 commentId에 대한 참조를 가져옵니다.
    final commentDocRef = _firestore.collection('comments').doc(commentId);

    // 2. 'reComments' 서브컬렉션에서 reCommentId가 일치하는 문서를 검색하고 삭제합니다.
    final reCommentsCollection = commentDocRef.collection('reComments');
    final reCommentsSnapshot = await reCommentsCollection.where('reCommentId', isEqualTo: reCommentId).get();
    for (var reCommentDoc in reCommentsSnapshot.docs) {
      await reCommentDoc.reference.delete();
      // reCommentId가 고유하므로 일치하는 문서를 찾았으면 loop을 종료합니다.
      break;
    }

    // 3. commentId에 해당하는 문서의 reCommentCount 필드값을 -1 감소시킵니다.
    // (단, 0보다 작아지면 업데이트하지 않습니다.)
    final commentDocSnapshot = await commentDocRef.get();
    if (commentDocSnapshot.exists) {
      int currentReCommentCount = commentDocSnapshot.data()?['reCommentCount'] ?? 0;
      if (currentReCommentCount > 0) {
        await commentDocRef.update({'reCommentCount': currentReCommentCount - 1});
      }
    }
  }


  @override
  void dispose() {
    _scrollController.dispose();
    reCommentController.dispose();
    _userProvider;
    writeController.dispose();
    super.dispose();
  }
}

