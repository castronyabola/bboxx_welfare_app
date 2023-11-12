import 'dart:async';

import 'package:bboxx_welfare_app/models/Account.dart';
import 'package:bboxx_welfare_app/screens/accountCreation.dart';
import 'package:bboxx_welfare_app/screens/lockPinPage.dart';
import 'package:bboxx_welfare_app/screens/loginpage.dart';
import 'package:bboxx_welfare_app/screens/pageHandler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with WidgetsBindingObserver{
  final user = FirebaseAuth.instance.currentUser;
  int accountCreatedCheck = 0;
  String phoneNumber;

  List<Account> _accountDetails = [];

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getData();
  }
  @override
  void dispose ()
  {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    super.didChangeAppLifecycleState(state);

    if(state == AppLifecycleState.paused
        || state == AppLifecycleState.inactive
        || state == AppLifecycleState.detached) return;

    final isResumed = state == AppLifecycleState.resumed;

    if(isResumed){
      if (!mounted) return;
      setState(() {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PageHandler()));
      });
    }
  }

  Future <void> getData() async {
    await FirebaseFirestore.instance.collection("phoneNumbers").doc(
        user.email).get().then((value) {
      if (!mounted) return;
      setState(() {
        phoneNumber = value['phoneNumber'];
      });
    });

    var collectionRef = FirebaseFirestore.instance
        .collection("welfareUsers");
    var doc = await collectionRef.doc(phoneNumber).get();

    if (doc.exists) { // Check if the document exists
      var docData = doc.data();
      if (docData != null && docData.containsKey('monthlySavings')) {
        // The field exists in the phoneNumber document
        await FirebaseFirestore.instance
            .collection("welfareUsers")
            .doc(phoneNumber)
            .update({
          'email': user.email,
        });
        setState(() {
          accountCreatedCheck = 2;
        });
      } else {
        // The field doesn't exist in the phoneNumber document
        setState(() {
          accountCreatedCheck = 1;
        });
      }
    } else {
      // The phoneNumber document doesn't exist
      setState(() {
        accountCreatedCheck = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      return accountCreatedCheck == 2 ?
          LockPinPage()
      :accountCreatedCheck == 0 ?
      Scaffold(
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                ),
                SizedBox(height: 10,),
                Text('loading...', style: TextStyle(color:Colors.lightBlue))
              ],
            )
        ),
      )
          :AccountCreationPage();
  }
}
