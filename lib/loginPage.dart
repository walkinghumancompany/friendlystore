import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dialog.dart';
import 'footer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _loginformKey = GlobalKey<FormState>();
  bool _exitingUser = false;
  bool _newUser = true;
  bool _register = true;


  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController checkphoneController = TextEditingController();
  TextEditingController loginController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    codeController.dispose();
    nameController.dispose();
    checkphoneController.dispose();
    loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return
      Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Color(0xffF1EEDE),
          body:
          Column(
            children: [
              Expanded(
                child:
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 100),
                  child: Center(
                    child : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 75,
                        ),
                        Container(
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/loginLogo.png',
                              height: 120,
                            )
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _newUser ? Color(0xFF266000) : Colors.transparent,
                                border: Border.all(
                                  width: 1,
                                  color: const Color(0xFF266000),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _newUser == true ? null :
                                  setState(() {
                                    _register = true;
                                    _exitingUser = false;
                                    _newUser = true;
                                  });
                                },
                                child: Text('새로운가입자',
                                  style: TextStyle(
                                      fontFamily: 'AppleSDGothicNeo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.7,
                                      color: _newUser ? Colors.white : Colors.black
                                  ),),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _exitingUser ? Color(0xFF266000) : Colors.transparent,
                                border: Border.all(
                                  width: 1,
                                  color: const Color(0xFF266000),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _exitingUser == true ? null :
                                  setState(() {
                                    _register = false;
                                    _newUser = false;
                                    _exitingUser = true;
                                  });
                                },
                                child: Text('기존가입자',
                                  style: TextStyle(
                                      fontFamily: 'AppleSDGothicNeo',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.7,
                                      color: _exitingUser ? Colors.white : Colors.black
                                  ),),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        _newUser ?
                        Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    alignment: Alignment.center,
                                    width: width * 0.95,
                                    child: _pinInput()),
                                const SizedBox(height: 20,),
                                Container(
                                  alignment: Alignment.center,
                                  width: width * 0.95,
                                  child: _nameInput(),
                                ),
                                const SizedBox(height: 20,),
                                Container(
                                  alignment: Alignment.center,
                                  width: width * 0.95,
                                  child: _phoneInput(),
                                ),
                                const SizedBox(height: 20,),
                                Container(
                                  alignment: Alignment.center,
                                  width: width * 0.95,
                                  child: _checkphoneInput(),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                              ],
                            )
                        ) : Container(),
                        _exitingUser ?
                        Form(
                            key: _loginformKey,
                            child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 25,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width: width * 0.95,
                                  height: 50,
                                  child: const Text('기존가입자는 처음 등록해주신 전화번호를 입력해주세요.',
                                    style: TextStyle(
                                        fontFamily: 'AppleSDGothicNeo',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.7,
                                        color: Colors.grey
                                    ),),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width: width * 0.95,
                                  child: _loginInput(),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                              ],
                            )
                        ) : Container(),
                      ],
                    ),
                  ),
                ),
              ),
              _register ?
              Container(
                  alignment: Alignment.center,
                  child: _registerBtn()
              ) :
              Container(
                  alignment: Alignment.center,
                  child: _loginBtn()
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Footer(),
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          )
      );
  }
  TextFormField _pinInput() {
    return TextFormField(
      keyboardType: TextInputType.number,
      validator: ((String? value) {
        if (value!.isEmpty) {
          return "핀 번호를 입력해주세요.";
        }
        if (!RegExp(r'^\d+$').hasMatch(value)) {
          return "핀 번호는 숫자만 포함해야 합니다.";
        }
        if (!isValidPin(value)) {
          return "유효하지 않은 핀 번호입니다.";
        }

        return null;
      }),
      controller: codeController,
      maxLines: 1,
      decoration: InputDecoration(
        labelText: "핀 번호",
        hintText: "핀 번호를 입력하세요",
        prefixIcon: const Icon(Icons.pin),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }

  TextFormField _nameInput() {
    return TextFormField(
      controller: nameController,
      maxLines: 1,
      maxLength: 12,
      validator: ((String? value) {
        if (value?.isEmpty ?? true) {
          return "사용하실 닉네임을 입력해주세요.";
        }
        return null;
      }),
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelText: "닉네임",
        hintText: "사용하실 닉네임을 입력해주세요",
        prefixIcon: const Icon(Icons.account_circle),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        counterText: '', // 기존 카운터 텍스트를 숨깁니다.
        suffixText: '${nameController.text.length}/12', // 여기에 카운터를 추가합니다.
      ),
      onChanged: (value) {
        // 텍스트가 변경될 때마다 setState를 호출하여 UI를 업데이트합니다.
        setState(() {});
      },
    );
  }

  TextFormField _phoneInput() {
    return TextFormField(
      controller: phoneController,
      maxLines: 1,
      keyboardType: TextInputType.number,
      validator: ((String? value) {
        if (value?.isEmpty ?? true) {
          return "전화번호를 입력해주세요.";
        }
        return null;
      }),
      decoration: InputDecoration(
        labelText: "전화번호",
        hintText: "전화번호를 입력해주세요",
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }
  TextFormField _checkphoneInput() {
    return TextFormField(
      controller: checkphoneController,
      maxLines: 1,
      keyboardType: TextInputType.number,
      validator: ((String? value) {
        if (value?.isEmpty ?? true) {
          return "전화번호를 입력해주세요.";
        }
        if (value != phoneController.text) {
          return "전화번호를 확인해주세요.";
        }
        return null;
      }),
      decoration: InputDecoration(
        labelText: "전화번호 확인",
        hintText: "전화번호를 다시 한번 입력해주세요",
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }

  Widget _registerBtn() {
    return
      GestureDetector(
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            try {
              await detectedPin(codeController.text, context);
            } catch (e) {
              print('Error: $e');
            }
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 1,
          height: 50,
          color: const Color(0xFFFF8B00),
          child: const Text('등록',
            style: TextStyle(
                fontFamily: 'AppleSDGothicNeo',
                fontWeight: FontWeight.w600,
                fontSize: 14.7,
                color: Colors.white
            ),),
        ),
      );
  }


  TextFormField _loginInput() {
    return TextFormField(
      controller: loginController,
      maxLines: 1,
      keyboardType: TextInputType.phone,
      validator: ((String? value) {
        if (value?.isEmpty ?? true) {
          return "전화번호를 입력해주세요.";
        }
        return null;
      }),
      decoration: InputDecoration(
        labelText: "Login",
        hintText: "최초 등록하신 전화번호를 입력해주세요.",
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }

  Widget _loginBtn() {
    return
      GestureDetector(
        onTap: () async {
          if (_loginformKey.currentState!.validate()) {
            try {
              await loginCheck(context);
            } catch (e) {
              print('Error: $e');
            }
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 1,
          height: 50,
          color: const Color(0xFFFF8B00),
          child: const Text('확인',
            style: TextStyle(
                fontFamily: 'AppleSDGothicNeo',
                fontWeight: FontWeight.w600,
                fontSize: 14.7,
                color: Colors.white
            ),),
        ),
      );
  }

  Future<void> detectedPin(String code, BuildContext context) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    try {
      final phoneUser = firestore.collection('users');
      final nameUser = firestore.collection('users');
      QuerySnapshot<Map<String, dynamic>> detectedPhone =
      await phoneUser.where('phone', isEqualTo: phoneController.text).get();
      QuerySnapshot<Map<String, dynamic>> detectedName =
      await nameUser.where('name', isEqualTo: nameController.text).get();
      if(detectedName.docs.isNotEmpty && detectedName.docs[0]['name'] == nameController.text){
        setState(() {
          showNameDialog(context);
        });
      }else{
        if (detectedPhone.docs.isNotEmpty && detectedPhone.docs[0]['phone'] == phoneController.text) {
          setState(() {
            showPhoneDialog(context);
          });
        }else{
          final pinUser = firestore.collection('users');
          final QuerySnapshot<Map<String, dynamic>> value =
          await pinUser.where('code', isEqualTo: code).get();

          if (value.size > 0) {
            setState(() {
              showErrorDialog(context);
            });
          } else {
            await firestore.collection('users').add({
              'code': codeController.text,
              'name': nameController.text,
              'phone': phoneController.text
            });
            await storage.write(key:'storagePhone', value:phoneController.text);
            Navigator.pushNamed(context, '/main');
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  bool isValidPin(String codeController) {
    // 1. 길이 확인
    if (codeController.length != 7) return false;

    // 2. 첫 번째 자리 짝수 확인
    if (int.parse(codeController[0]) % 2 != 0) return false;

    // 3. 두 번째 자리 홀수 확인
    if (int.parse(codeController[1]) % 2 == 0) return false;

    // 4. 마지막 세 자리 소수 확인
    int lastThree = int.tryParse(codeController.substring(4)) ?? 0;
    if (!isPrime(lastThree)) return false;

    return true;
  }

  bool isPrime(int number) {
    if (number < 2) return false;
    for (int i = 2; i * i <= number; i++) {
      if (number % i == 0) return false;
    }
    return true;
  }

  Future<void> loginCheck(BuildContext context) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    try {
      final userNumber = firestore.collection('users');
      String? parsedPhone;
      try {
        parsedPhone = loginController.text;
      } catch (_) {
        print("전화번호 변환 중 오류 발생");
        return;
      }
      if(parsedPhone == "01057397300"){
        Navigator.pushReplacementNamed(context, '/managerPage');
      }
      else{
        QuerySnapshot<Map<String, dynamic>> loginNumber = await userNumber.where('phone', isEqualTo: parsedPhone).get();

        if (loginNumber.docs.isNotEmpty) {
          if (loginNumber.docs[0]['phone'] == parsedPhone) {
            await storage.write(key:'storagePhone', value:loginController.text);
            Navigator.pushReplacementNamed(context, '/main');
          }
        } else {
          showloginDialog(context);
        }
      }
    } catch (e) {
      print("로그인 체크 중 오류 발생: $e");
    }
  }

}
