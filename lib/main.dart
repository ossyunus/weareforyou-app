import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weareforyou/gui/welcome.dart';
import 'package:weareforyou/gui/home.dart';
import 'package:weareforyou/gui/main_page.dart';
import 'package:weareforyou/gui/login.dart';
import 'package:weareforyou/gui/register.dart';
import 'package:weareforyou/gui/settings.dart';
import 'package:weareforyou/gui/edit_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:weareforyou/components/styles.dart';

const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
    'default_channel', // id
    'High Importance Notifications', // title
    importance: Importance.max,
    showBadge: true,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('default_sound')
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.data['android_channel_id']);
  print(message.data['sound']);
  print('A bg message just showed up :  ${message.messageId}');

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(defaultChannel);

}

Future<void> initializeDefault() async {



  Platform.isAndroid? await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD8lYegDIywHvq5eCmnq1jktOP4p9JAc-4",
      appId: "1:769611054704:android:4df6f4207f7e3693",
      messagingSenderId: "769611054704",
      projectId: "we-are-for-you-app",
    ),
  ):await Firebase.initializeApp();
  // print('Initialized default app $app');

  FirebaseMessaging.instance.subscribeToTopic("events");

  Platform.isIOS ? await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  ):'';
}


void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Locales.init(['ar', 'en']); //
  await initializeDefault();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(defaultChannel);

  runApp(const MaterialApp(
    home: MyApp(),
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
}

class MyApp extends StatefulWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }

}

class _MyAppState extends State<MyApp>{

  late Widget _screen;
  late Home _home;
  late Welcome _welcome;
  late String theLanguage;

  var styles = Styles();

  @override
  void initState(){
    super.initState();

    _requestPermissions();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/noti_icon');

    var initializationSettings = const InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      print('CCCCC');
      if (message != null) {
        Navigator.pushNamed(context,'Notifications');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.data['body']);
      print('xxxxx');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                  defaultChannel.id,
                  defaultChannel.name,
//                color: Colors.green,
//                enableVibration: true,
                  playSound: true,
                  sound: const RawResourceAndroidNotificationSound('default_sound'),
                  icon: '@mipmap/noti_icon',
                  priority: Priority.high,
                  importance: Importance.max
              ),

            ));

      }
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        //Navigator.push(context, MaterialPageRoute(builder: (context) => const Notifications()),);
//        showDialog(
//            context: context,
//            builder: (_) {
//              return AlertDialog(
//                title: Text('1111'),
//                content: SingleChildScrollView(
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: [Text('222')],
//                  ),
//                ),
//              );
//            });
      }
    });

    getSharedData().then((result){
      if(theLanguage == null || theLanguage == ''){
        theLanguage = 'tr';
      }
    });

    ///
    /// Let's save a pointer to this method, should the user wants to change its language
    /// We would then call: applic.onLocaleChanged(new Locale('en',''));
    ///

    // _checkVersion();
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

//   void _checkVersion() async {
//     final newVersion = NewVersion(
//         androidId: "com.weareforyou.osr.app.weareforyou",
//         iOSId: "com.weareforyou.osr.app.weareforyou"
//     );
//     final status = await newVersion.getVersionStatus();
//
//     if(status != null){
//       newVersion.showAlertIfNecessary(
//         context: context,
//       );
//
// //      print("DEVICE : " + status.localVersion);
// //      print("STORE : " + status.storeVersion);
//     }
//
//
//
//   }

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      theLanguage = prefs.getString('theLanguage')!;

      if(theLanguage != null){
      _welcome = Welcome();
      _screen = _welcome;
      }else{
      _home = Home();
      _screen = _home;
      }

    });
  }

  _MyAppState(){
    _home = Home();
    _screen = _home;
  }



  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return LocaleBuilder(
      builder: (locale) => MaterialApp(
        theme: ThemeData(
            fontFamily: 'Cairo',
            primaryColor: const Color.fromRGBO(16, 47, 76 , 1),
            scaffoldBackgroundColor: Colors.white,
            secondaryHeaderColor: const Color.fromRGBO(249, 178, 38 , 1),
//          primaryColorDark: Color.fromRGBO(19, 19, 27, 1),
            appBarTheme: const AppBarTheme(
              color: Colors.white,
              elevation: 1,
              shadowColor: Colors.black,
              centerTitle: true,
              actionsIconTheme: IconThemeData(
                color: Colors.white,
              ),
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
            ),
            textTheme: const TextTheme(
              labelMedium: TextStyle(fontSize: 16.0, color: Colors.white), // for appBar
              labelLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17.0), // for titles
              bodyMedium: TextStyle(color: Colors.black54, fontFamily: 'Cairo', fontSize: 15.0), // for normal text
            ),
            dividerTheme: const DividerThemeData(
              thickness: 0.3,color: Colors.black38,
            )
        ),

        debugShowCheckedModeBanner: true,
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,

        title: 'نحن من أجلكم',
        routes: <String, WidgetBuilder>{
          '/MainPage': (BuildContext context) => MainPage(),
          '/Home': (BuildContext context) => Home(),
          '/Login': (BuildContext context) => Login(),
          '/Register': (BuildContext context) => Register(),
          '/Settings': (BuildContext context) => Settings(),
          '/EditProfile': (BuildContext context) => EditProfile(),
        },
        home:  _screen,
      ),
    );
  }

}
