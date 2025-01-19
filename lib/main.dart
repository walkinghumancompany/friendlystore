import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:friendlystore/user.dart';
import 'package:provider/provider.dart';
import 'package:friendlystore/providers/userProvider.dart';
import 'firebase_options.dart';
import 'loginPage.dart';
import 'mainPage.dart';
import 'managerPage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

Future<void> initializeFirebase() async {
  try {
    // 이미 초기화된 Firebase 앱이 있는지 확인
    FirebaseApp? app;
    try {
      app = Firebase.app();
      print("Existing Firebase app found");
    } catch (e) {
      // 초기화된 앱이 없는 경우
      app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("New Firebase app initialized");
    }
  } catch (e) {
    print("Firebase initialization error: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await initializeFirebase();

  User? currentUser = await loadCurrentUser();

  kakao.KakaoSdk.init(
    nativeAppKey: '1725a39c5d520837c116cfb74ef98473',
    javaScriptAppKey: '34e562ee1ee8d8de2b4aa02a286ec902',
  );

  runApp(FriendlyStore(currentUser: currentUser));
}

Future<User?> loadCurrentUser() async {
  final storage = FlutterSecureStorage();
  String? savedPhone = await storage.read(key: 'storagePhone');

  if (savedPhone != null) {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: savedPhone)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        User currentUser = User(
          name: userData['name'],
          phone: userData['phone'],
          code: userData['code'],
        );
        print('Main: User loaded: ${currentUser.name}, ${currentUser.phone}, ${currentUser.code}');
        return currentUser;
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  print('Main: No user data found in secure storage.');
  return null;
}

class FriendlyStore extends StatelessWidget {
  final User? currentUser;

  const FriendlyStore({Key? key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => userProvider(user: currentUser),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'friendlybook',
        color: Color(0xffF1EEDE),
        initialRoute: currentUser == null ? '/loginPage' : '/mainPage',
        routes: {
          '/managerPage': ((context) => ManagerPage()),
          '/loginPage': ((context) => LoginPage()),
          '/mainPage': (context) => MainPage(),
          '/main': (context) => MainPage(),
        },
      ),
    );
  }
}