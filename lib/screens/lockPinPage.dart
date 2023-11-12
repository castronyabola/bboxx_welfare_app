import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:bboxx_welfare_app/models/Account.dart';
import 'package:bboxx_welfare_app/models/navigation.dart';
import 'package:bboxx_welfare_app/screens/pageHandler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:provider/provider.dart';
import 'package:random_string_generator/random_string_generator.dart';

import '../google_signin_provider.dart';

class LockPinPage extends StatefulWidget {

  const LockPinPage({
    Key key,
  }) : super(key: key);

  @override
  _LockPinPageState createState() {
    return _LockPinPageState();
  }
}

class _LockPinPageState extends State<LockPinPage> {
  var pinGenerator = RandomStringGenerator(
    hasAlpha: false,
    alphaCase: AlphaCase.UPPERCASE_ONLY,
    hasDigits: true,
    hasSymbols: false,
    fixedLength: 6,
    mustHaveAtLeastOneOfEach: false,
  );

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final myPinHolder = TextEditingController();
  final newPinHolder = TextEditingController();
  final pinConfirmHolder = TextEditingController();

  bool editProfile;

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    editProfile = false;
    getData();
  }

  var currencyFormat = new NumberFormat.currency(locale: "en_US",
      symbol: "KES ", decimalDigits: 0);

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('EEEE, dd/MMMM/yyyy hh:mm a');

  final user = FirebaseAuth.instance.currentUser;
  var time = const Duration(seconds: 10);
  bool newPinView = true;
  bool confirmPinView = true;
  bool logInPinView = true;
  bool controller = false;
  String myName = '';
  String employmentNumber = '';
  String membershipNumber = '';
  String IDNumber = '';
  String designation = '';
  String location = '';
  String phoneNumber = '';
  String myPin = '';
  String myPinLocalHolder = '';
  String newPinLocalHolder = '';
  String pinConfirmLocalHolder = '';
  String resetPin = '';

  bool accountExists = false;

  Future pinEditedDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          //backgroundColor: Colors.lightBlue,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Confirmation',style: TextStyle(fontSize: 15),),
            ],
          ),
          content: Container(
            //height: 100,
              child:
              Text('PIN Successfully Edited',
                style: TextStyle(fontSize: 12,), textAlign: TextAlign.center,)
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text('Ok',style: TextStyle()),
                  onPressed: () async{
                    await Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => navigation()));
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
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
    accountExists = doc.exists;
    await FirebaseFirestore.instance.collection("welfareUsers").doc(phoneNumber).get().then((value){
      if (!mounted ) return;
      setState(() {
            myName = value['myName'];
            employmentNumber = value['employmentNumber'];
            //membershipNumber = value['membershipNumber'];
            IDNumber = value['IDNumber'];
            designation = value['designation'];
            location = value['location'];
            phoneNumber = value['phoneNumber'];
            myPin = value['myPin'];
            resetPin = value['resetPin'];
      });
    });
  }

  upDateResetPin() async {
    String resetPinHolder = pinGenerator.generate();
    if (!mounted) return;
    setState(() {
      FirebaseFirestore.instance
          .collection("welfareUsers")
          .doc(phoneNumber)
          .update({
        'resetPin': resetPinHolder,
        'myPin': null,
      }).then((value) {
        return Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LockPinPage()));
      });

    });
    FirebaseFirestore.instance
        .collection('mail')
        .add(
        {
          'to': user.email,
          'cc':'info@globsoko.com',
          'message': {
            'subject': 'PIN Reset',
            'text': 'Hi ${myName}, Please find your reset PIN here: ${resetPinHolder}\n'
                '\n'
                'Bboxx Welfare',
          },
        }
    );
  }
  Future<bool> _onBackPressed() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        title: Center(child: new Text('Confirmation')),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Do you want to exit the App?'),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: Text("NO"),
                onPressed: () {
                  return Navigator.of(context).pop(false);
                },
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  return SystemNavigator.pop();
                },
                child: Text("YES"),
              ),
            ],
          ),

        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build (BuildContext context) {

    var formatted = formatter.format(now);

    final Size size = MediaQuery
        .of(context)
        .size;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: !accountExists ?
        AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ):
        AppBar(
          //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(200),
        //bottomRight: Radius.circular(200)
      ),
    ),
          automaticallyImplyLeading: false,
          excludeHeaderSemantics:false,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          //backgroundColor: Colors.lightBlue,
          elevation: 3,
          title: Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Initicon(
                            elevation: 5,
                            color: Colors.lightBlue,
                            backgroundColor: Colors.lightBlueAccent.shade100,
                            text: myName,
                            size: 70,
                          ),
                        ),
                        Text(myName, style:TextStyle(color: Colors.lightBlue,fontWeight: FontWeight.w400,fontSize:18, )),
                        Text(phoneNumber, style:TextStyle(color: Colors.lightBlue,fontWeight: FontWeight.w300,fontSize:16)),
                        Text(employmentNumber, style:TextStyle(color: Colors.lightBlue,fontWeight: FontWeight.w300,fontSize:12)),
                      ],
                    ),
                  ),
                  SizedBox(height: 40,)
                ],
              ),
            ],
          ),
          toolbarHeight: 180,
        ),
        bottomNavigationBar: !accountExists ?
        SizedBox():
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
              //topRight: Radius.circular(120),
              topLeft: Radius.circular(200)
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 3,
                blurRadius: 2,
                offset: Offset(1, 0), // changes position of shadow
              ),
            ],
          ),
          height: 50,
          child:Center(
            child: Text('Bboxx Welfare',
                style: TextStyle(color:Colors.lightBlue)),
          ),
        ),
        body:
        !accountExists ?
        SizedBox()
            :RefreshIndicator(
          onRefresh: getData,
             child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SizedBox(height: size.height*0.1),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(2, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: myPin != null && myPin != '' && resetPin == null ?
                          Text('ENTER LOG IN PIN',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14, color: Colors.lightBlue)):
                          resetPin != null && myPin == null?
                          Text('Enter the reset PIN sent to your email: ${user.email}',
                              textAlign:TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14, color: Colors.lightBlue)):
                          Text('CREATE NEW LOG IN PIN',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14, color: Colors.lightBlue))
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget> [
                              myPin != null && myPin != '' || resetPin != null ? Padding(
                                  padding: EdgeInsets.all(12),
                                  child:
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      textAlignVertical: TextAlignVertical.top,
                                      maxLength: 6,
                                      obscureText: logInPinView,
                                      obscuringCharacter: '*',
                                      focusNode: f1,
                                      keyboardType: TextInputType.number,
                                      controller: myPinHolder,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.lock, size: 20,),
                                        suffix: IconButton(
                                          padding: EdgeInsets.only(bottom: 5,top: 0),
                                            onPressed: (){
                                              if (!mounted) return;
                                              setState(() {
                                                return logInPinView = !logInPinView;
                                              });
                                            },
                                            icon: Icon(
                                              logInPinView ? Icons.visibility: Icons.visibility_off,
                                              color: Colors.lightBlue,
                                            )
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          borderSide: BorderSide(
                                            color: Colors.lightBlueAccent.shade100,
                                            width: 1,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                        ),
                                        labelText: "six digit pin",
                                        //helperText: 'Edit Your Employment Number',
                                      ),
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onChanged: (value) {
                                        if(myPinHolder.text.trim() == myPin){
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => navigation()));
                                        }
                                        else if (myPinHolder.text.trim() == resetPin){
                                           FirebaseFirestore.instance
                                              .collection("welfareUsers")
                                              .doc(phoneNumber)
                                              .update({
                                            'myPin': null,
                                             'resetPin': null,
                                          }).then((value) {
                                            return Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => LockPinPage()));
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty){
                                          return "Please Enter your log in PIN";
                                        }
                                        else if(value.length != 6)
                                          {
                                            return "Your PIN must be six digits";
                                          }
                                        else if (myPinHolder.text.trim() != myPin && resetPin == null)
                                          {
                                            return "Incorrect PIN!";
                                          }
                                        return null;
                                      },
                                    ),
                                  ),
                              ):
                              Column(
                                children: [
                                  Padding(
                                      padding: EdgeInsets.all(12),
                                      child:
                                      TextFormField(
                                        textAlignVertical: TextAlignVertical.top,
                                        maxLength: 6,
                                        obscureText: newPinView,
                                        obscuringCharacter: '*',
                                        focusNode: f2,
                                        keyboardType: TextInputType.number,
                                        controller: newPinHolder,
                                        decoration: InputDecoration(
                                          suffix: IconButton(
                                              padding: EdgeInsets.only(bottom: 10,top: 0),
                                              onPressed: (){
                                                if (!mounted) return;
                                                setState(() {
                                                  return newPinView = !newPinView;
                                                });
                                              },
                                              icon: Icon(
                                                newPinView ? Icons.visibility_off: Icons.visibility,
                                                color: Colors.lightBlue,
                                              )
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Colors.lightBlueAccent.shade100,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(20))
                                          ),
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          //hintText: "What is your Employment Number?",
                                          labelText: "new six digit PIN",
                                          //helperText: 'Edit Your Employment Number',
                                        ),
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        onChanged: (value) {
                                          //newPinLocalHolder = (value);
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty){
                                            return "Please Enter new log six digit PIN";
                                          }
                                          else if (value.length != 6){
                                            return "Please Enter a six digit PIN";
                                          }
                                          return null;
                                        },
                                      )
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(12),
                                      child:
                                      TextFormField(
                                        textAlignVertical: TextAlignVertical.top,
                                        maxLength: 6,
                                        obscureText: confirmPinView,
                                        obscuringCharacter: '*',
                                        focusNode: f3,
                                        keyboardType: TextInputType.number,
                                        controller: pinConfirmHolder,
                                        decoration: InputDecoration(
                                          suffix: IconButton(
                                              padding: EdgeInsets.only(bottom: 10,top: 0),
                                              onPressed: (){
                                                if (!mounted) return;
                                                setState(() {
                                                  return confirmPinView = !confirmPinView;
                                                });
                                              },
                                              icon: Icon(
                                                confirmPinView ? Icons.visibility_off: Icons.visibility,
                                                color: Colors.lightBlue,
                                              )
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Colors.lightBlueAccent.shade100,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(20))
                                          ),
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          //hintText: "What is your Employment Number?",
                                          labelText: "confirm six digit pin",
                                          //helperText: 'Edit Your Employment Number',
                                        ),
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        onChanged: (value) {
                                          //pinConfirmLocalHolder = (value);
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty){
                                            return "Please confirm your new PIN";
                                          }
                                          else if (pinConfirmHolder.text.trim() != newPinHolder.text.trim()){
                                            return "Your new PIN and confirm PIN do not match";
                                          }
                                          return null;
                                        },
                                      )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        resetPin == null && myPin == null ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton (
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      newPinHolder.text == pinConfirmHolder.text && newPinHolder.text.length == 6 ?
                                      Colors.lightBlue:
                                      Colors.grey
                                  ),
                                  fixedSize: MaterialStateProperty.all<Size>(
                                      Size(size.width*0.65, size.height*0.025)
                                  ),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                        //side: BorderSide(color: Colors.lightBlue)
                                      )
                                  )
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  if(pinConfirmHolder.text.trim() == newPinHolder.text.trim()){

                                    FirebaseFirestore.instance
                                        .collection("welfareUsers")
                                        .doc(phoneNumber)
                                        .update({
                                      'myPin': newPinHolder.text.trim(),
                                    });
                                    pinEditedDialog();
                                  }
                                }
                              },
                              child:
                              Text("Submit", style: TextStyle(color: Colors.white),)
                          ),
                        ):SizedBox(),
                        resetPin == null && myPin != null ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: (){
                                        upDateResetPin();
                                        //sendEmail();
                                  },
                                child: Text('Forgot PIN ? Reset Here'),
                              ),
                            ],
                          ),
                        ):SizedBox()
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                           Colors.lightBlue
                        ),
                        fixedSize: MaterialStateProperty.all<Size>(
                            Size(size.width*0.25, size.height*0.025)
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              //side: BorderSide(color: Colors.lightBlue)
                            )
                        )
                    ),
                    onPressed: (){
                      final provider = Provider.of<GoogleSignInProvider>(context, listen:false);
                      provider.logout();
                    },
                    child: Text('Sign Out'),
                  ),
                ),
              ],
            ),

          ),

        ),

      ),
    );
  }

}

