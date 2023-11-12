import 'dart:async';

import 'package:bboxx_welfare_app/screens/accountCreation.dart';
import 'package:bboxx_welfare_app/screens/landingPage.dart';
import 'package:bboxx_welfare_app/screens/loginpage.dart';
import 'package:bboxx_welfare_app/screens/loginpageNew.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bboxx_welfare_app/google_signin_provider.dart';


class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer timer;

  @override
  void initState() {
    if (!mounted) return;
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser.emailVerified;

    if(!isEmailVerified) {
      sendVerificationEmail();

     timer =  Timer.periodic(
          Duration(seconds:3),
              (_) => checkEmailVerified(),
              );
    }

  }

  // @override
  // void dispose(){
  //   timer.cancel();
  //   super.dispose();
  // }

  Future checkEmailVerified()async{
    await FirebaseAuth.instance.currentUser.reload();
    if (!mounted) return;
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser.emailVerified;
    });
  }

  Future sendVerificationEmail() async{
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user.sendEmailVerification();
      if (!mounted) return;
      setState(() {
        canResendEmail = false;
      });
      await Future.delayed(Duration(seconds: 5));
      setState(() {
        canResendEmail = true;
      });
    } catch (e){

      // Navigator.of(context).pop();
      //
      // return showDialog(
      //   barrierDismissible: false,
      //   context: context,
      //   builder: (BuildContext context) => new AlertDialog(
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.only(
      //         bottomRight: Radius.circular(20),
      //         topLeft: Radius.circular(20)
      //       ),
      //     ),
      //     title: Center(child: new Text('Alert!',style: TextStyle(fontSize: 14))),
      //     content: Text(e.message,
      //         textAlign: TextAlign.center,style: TextStyle(color:Colors.red,fontSize: 12)),
      //     actions: <Widget>[
      //       Center(
      //         child: TextButton(
      //           child: Text("Ok"),
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //         ),
      //       ),
      //
      //     ],
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;

    return isEmailVerified ?
    LoginPageNew()://AccountCreationPage():
    WillPopScope(
      onWillPop: () {
        return Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(200),
              //bottomRight: Radius.circular(200)
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage())
              );
            },
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.lightBlue),
          backgroundColor: Theme
              .of(context)
              .cardColor,
          elevation: 3,
          title: Text('Email Verification', style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.lightBlue,
              fontSize: 16)),
          toolbarHeight: 50,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                        height: 50,
                        width: 50,
                        child: Image.asset(
                            'android/assets/images/Bboxx_icon.png')),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Container(
                      //height: 75,
                      //width: 75,
                        child: Text("Welfare", style: TextStyle(color: Colors
                            .lightBlue))),
                  ),
                  SizedBox(height: size.height * 0.06),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 30),
                    child: !canResendEmail ? Text('A Verification Link has been sent to your Email', textAlign: TextAlign.center):
                    Text('A Verification Link has been sent to your Email. In case you have not received the email, kindly click on the \u0027Resend Email\u0027 Button below:'
                    , textAlign: TextAlign.center,),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 10),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(10),
                            //shadowColor: MaterialStateProperty.all(Theme.of(context).cardColor),
                            fixedSize: MaterialStateProperty.all(
                                Size(size.width * 0.5, size.height * 0.05)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Theme
                                  .of(context)
                                  .cardColor,),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                )
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                Icons.email,
                                size: 20,
                                color: canResendEmail ? Colors.lightBlue: Colors.grey
                            ),
                            SizedBox(width: 15,),
                            Text("Resend Email", style: TextStyle(
                              color:  canResendEmail ? Colors.lightBlue: Colors.grey)
                            ),
                          ],
                        ),
                        onPressed: () {
                          canResendEmail ? sendVerificationEmail():null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextButton(
                    onPressed: () {
                      final provider = Provider.of<GoogleSignInProvider>(context, listen:false);
                      provider.logout();
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
