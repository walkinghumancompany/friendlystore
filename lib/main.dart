import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:friendlystore/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:friendlystore/providers/userProvider.dart';
import 'firebase_options.dart';
import 'loginPage.dart';
import 'mainPage.dart';
import 'managerPage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bool _isFCMSupport = await FirebaseMessaging.instance.isSupported();

  if (_isFCMSupport) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
    );

    var initialzationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    var initialzationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    var initializationSettings = InitializationSettings(
      android: initialzationSettingsAndroid,
      iOS: initialzationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

// web에서 권한요청시 오류가 발생하기 때문에 체크
  if (!kIsWeb) {
    // 푸시알림 권한요청
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
    ].request();
  }

  final storage = FlutterSecureStorage();

  // 저장된 전화번호 로드
  String? savedPhone = await storage.read(key: 'storagePhone');

  // 로드된 전화번호를 바탕으로 Firestore에서 사용자 정보 조회
  User? currentUser;
  if (savedPhone != null) {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: savedPhone)
        .limit(1)
        .get();

    // Firestore에서 가져온 사용자 정보를 User 객체로 변환
    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs.first.data();
      currentUser = User(
        name: userData['name'],
        phone: userData['phone'],
        code: userData['code'],
      );
    }
  }
  kakao.KakaoSdk.init(
    nativeAppKey: '1725a39c5d520837c116cfb74ef98473',
    javaScriptAppKey: '34e562ee1ee8d8de2b4aa02a286ec902',
  );


  if (currentUser != null) {
    print('Main: User loaded: ${currentUser.name}, ${currentUser.phone}, ${currentUser.code}');
  } else {
    print('Main: No user data found in secure storage.');
  }
  runApp(FriendlyStore(currentUser: currentUser));
}

class FriendlyStore extends StatelessWidget {
  final User? currentUser;

  const FriendlyStore({Key? key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // currentUser가 null이 아닌 경우 userProvider에 초기화하여 제공
          create: (context) => userProvider(user: currentUser),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'friendlybook',
        color: Color(0xffF1EEDE),
        initialRoute: "/mainPage",
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