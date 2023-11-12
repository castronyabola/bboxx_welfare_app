import 'package:flutter/material.dart';

class Utils {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  static showSnackBar(String text){

    if (text == null) return;

    final snackBar = SnackBar(
      elevation: 12,
      content: Text(text, textAlign: TextAlign.center,style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.deepOrange,
      shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.all(Radius.circular(10))
      ),
    );

    messengerKey.currentState
    ..removeCurrentSnackBar()
    ..showSnackBar(snackBar);
  }
}