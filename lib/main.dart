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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> setupFCM() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");

    bool isFCMSupported = await FirebaseMessaging.instance.isSupported();
    print("FCM Support: $isFCMSupported");

    if (isFCMSupported) {
      await setupFCM();
      await requestNotificationPermissions();
    }
  } catch (e) {
    print("Error initializing Firebase or setting up FCM: $e");
  }

  User? currentUser = await loadCurrentUser();

  kakao.KakaoSdk.init(
    nativeAppKey: '1725a39c5d520837c116cfb74ef98473',
    javaScriptAppKey: '34e562ee1ee8d8de2b4aa02a286ec902',
  );

  runApp(FriendlyStore(currentUser: currentUser));
}

Future<void> requestNotificationPermissions() async {
  if (!kIsWeb) {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      Map<Permission, PermissionStatus> statuses = await [
        Permission.notification,
      ].request();
      print("Permission statuses: $statuses");
    } catch (e) {
      print("Error requesting permissions: $e");
    }
  }
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