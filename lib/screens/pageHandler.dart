import 'package:bboxx_welfare_app/google_signin_provider.dart';
import 'package:bboxx_welfare_app/models/navigation.dart';
import 'package:bboxx_welfare_app/screens/lockPinPage.dart';
import 'package:bboxx_welfare_app/screens/loginpage.dart';
import 'package:bboxx_welfare_app/screens/verifyEmailPage.dart';
import 'package:bboxx_welfare_app/screens/welfareAdmin.dart';
import 'package:bboxx_welfare_app/screens/welfareUsers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../main.dart';

final user = FirebaseAuth.instance.currentUser;

class PageHandler extends StatefulWidget{

  @override
  State<PageHandler> createState() => _PageHandlerState();
}

class _PageHandlerState extends State<PageHandler> {

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.lightBlue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      topLeft: Radius.circular(20)
                  ),
                ),
                title: Text(notification.title),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body)
                    ],
                  ),
                ),
                actions: <Widget>[
                  Center(
                    child: TextButton(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),

                ],
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider (
        create: (context) => GoogleSignInProvider(),
        child:StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          final provider = Provider.of<GoogleSignInProvider>(context);
          if (provider.isSigningIn) {
            return Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasData) {
            return VerifyEmailPage();
          }
          else if (snapshot.hasError) {
            return Center(child: Text("Something went wrong"));
          }
          else{
            return LoginPage();
          }
        },
       ),
      ),
    );
  }
}
