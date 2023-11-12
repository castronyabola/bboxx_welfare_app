import 'package:bboxx_welfare_app/google_signin_provider.dart';
import 'package:bboxx_welfare_app/screens/header_page.dart';
import 'package:bboxx_welfare_app/screens/pageHandler.dart';
import 'package:bboxx_welfare_app/utils.dart';
import 'package:bboxx_welfare_app/utils/user_simple_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.init(cacheProvider: SharePreferenceCache());
  await UserSimplePreferences.init();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: ValueChangeObserver<bool>(
          cacheKey: HeaderPage.keyDarkMode,
          defaultValue: false,
          builder: (_, isDarkMode, __) =>
              MaterialApp(
                scaffoldMessengerKey: Utils.messengerKey,

                debugShowCheckedModeBanner: false,
                theme: isDarkMode
                    ? ThemeData.dark().copyWith(
                  textTheme: TextTheme(
                  ),
                  appBarTheme: AppBarTheme(
                      iconTheme: IconThemeData(color: Colors.lightBlue),
                      backgroundColor:Colors.white12,
                      titleTextStyle: TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 16)
                  ),
                  brightness: Brightness.dark,
                  primaryColor: Colors.black,
                  scaffoldBackgroundColor: Colors.black87,
                  canvasColor: Colors.black,
                  cardColor: Colors.white12,
                  dialogBackgroundColor: Colors.grey.shade800,
                  backgroundColor: Colors.grey.shade900,
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                      secondary: Colors.white),
                )
                    : ThemeData.light().copyWith(
                  appBarTheme: AppBarTheme(
                      iconTheme: IconThemeData(color: Colors.lightBlue),
                      backgroundColor:Colors.white,
                      //titleTextStyle: TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 16)
                  ),
                  brightness: Brightness.light,
                  primaryColor: Colors.white,
                  scaffoldBackgroundColor: Color(0XFFFCFDFDFF),
                  canvasColor: Colors.white,
                  cardColor: Colors.white,
                  dialogBackgroundColor: Colors.white,
                  backgroundColor: Colors.grey.shade200,
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                      secondary: Colors.black),
                ),
                home: AnimatedSplashScreen(
                    duration: 3000,
                    splash: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                height: 60,
                                width: 60,
                                child: Image.asset(
                                  'android/assets/images/Bboxx_icon.png',
                                  color: Colors.lightBlueAccent)
                            ),
                            Container(
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Bboxx Welfare", style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.lightBlueAccent),),
                                )
                            ),
                            SizedBox(height: 150,),
                            TweenAnimationBuilder(
                              tween: Tween(begin:0.0, end:1.0),
                              duration: Duration(seconds: 3),
                              builder: (context, value, _) => SizedBox(
                                height: 25,
                                width:25 ,
                                child: CircularProgressIndicator(
                                  value: value,
                                  backgroundColor: Colors.cyanAccent,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder(
                                  tween: Tween(begin:0.1, end:1.0),
                                  duration: Duration(seconds: 3),
                                  builder: (context, value, _) => SizedBox(
                                    height: 25,
                                    width:25 ,
                                    child: CircularProgressIndicator(
                                      value: value,
                                      backgroundColor: Colors.cyanAccent,
                                    ),
                                  ),
                                ),
                                TweenAnimationBuilder(
                                  tween: Tween(begin:1.0, end:0.0),
                                  duration: Duration(seconds: 3),
                                  builder: (context, value, _) => SizedBox(
                                      height: 25,
                                      width:25 ,
                                      child: CircularProgressIndicator(
                                        value: value,
                                        backgroundColor: Colors.cyanAccent,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text('Powered by Globsoko Ltd', style: TextStyle(fontSize:10,color:Colors.lightBlue))
                          ],
                        )
                    ),
                    splashIconSize: 600,
                    nextScreen: PageHandler(),
                    splashTransition: SplashTransition.decoratedBoxTransition,
                    pageTransitionType: PageTransitionType.fade,
                    backgroundColor: Colors.lightBlue
                ),
              ),
        )
    );
  }
}
