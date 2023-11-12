import 'package:bboxx_welfare_app/screens/pageHandler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../models/Account.dart';
import '../models/navigation.dart';
import 'OTPScreen.dart';
import 'landingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';


class LoginPageNew extends StatefulWidget {
  const LoginPageNew({Key key, this.name}) : super(key: key);
  final String name;
  @override
  _LoginPageNewState createState() => _LoginPageNewState();
}

class _LoginPageNewState extends State<LoginPageNew> {
  final String baseUrl = 'https://gvlb1ub624.execute-api.us-east-1.amazonaws.com/prod/sqs';
  final String authToken = 'RLFbz206A47vzWYltVvMR1chg4texn5U8OKvVW7z';
  final secretKey = 'Snyaca7590231234';
  String ipAddress = 'Loading...';

  GlobalKey<FormState> _formKey = GlobalKey();

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();

  //final _formKey = GlobalKey<FormState>();
  final phoneHolder = TextEditingController();
  final passwordHolder = TextEditingController();

  String completePhoneNumber = '';
  String countryCode = '';

  String email;
  String password;

  bool passwordView = true;

  final user = FirebaseAuth.instance.currentUser;
  String userName = '';

  String phoneNumber;

  @override
  void initState() {
    if (!mounted) return;
    checkPhone();
    super.initState();
    sendLog('logs', 'Email Address and Password Validated successfully and automatically navigated to Lock PIN Screen');
    _initPackageInfo();
  }
  encrypt.Key generateAESKey(String secretKey) {
    // Ensure the secretKey is either 128, 192, or 256 bits long.
    final validKeyLengths = [16, 24, 32]; // In bytes (128, 192, 256 bits)
    final keyBytes = utf8.encode(secretKey);
    final keyLength = keyBytes.length;

    if (!validKeyLengths.contains(keyLength)) {
      throw ArgumentError('Invalid key length. Key must be 128, 192, or 256 bits long.');
    }

    return encrypt.Key(keyBytes);
  }
  String encryptString(String input, String secKey) {
    final key = generateAESKey(secretKey);
    final iv = encrypt.IV.fromLength(16); // 16 bytes for AES encryption

    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(input, iv: iv);

    return encrypted.base64;
  }
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }
  Future<void> sendLog(table, action) async {
    //get IP address
    final result = await http.get(Uri.parse('https://api.ipify.org?format=json'));

    if (result.statusCode == 200) {
      final data = await json.decode(result.body);
      setState(() {
        //print('IP Data: $data');
        ipAddress = data['ip'];
      });
    } else {
      setState(() {
        ipAddress = 'Error';
      });
    }

    // Get the current date and time
    DateTime now = DateTime.now();
    String createdTime = now.toString();

    final encryptedEmail = encryptString(user.email, secretKey);
    final encryptedTableName = encryptString(table, secretKey);
    final encryptedAction = encryptString(action + ' mav: ${_packageInfo.version}', secretKey);
    final encryptedTimeCreated = encryptString(createdTime, secretKey);
    final encryptedIPAddress = encryptString(ipAddress, secretKey);
    final encryptedAuthToken = encryptString(authToken, secretKey);

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $encryptedAuthToken'
    };
    var request = http.Request('POST', Uri.parse('$baseUrl'));
    request.body = json.encode({
      "headers": headers,
      "body": "{\"table\": \"$encryptedTableName\", \"email\": \"$encryptedEmail\", \"ipaddress\": \"$encryptedIPAddress\", \"action\": \"$encryptedAction\", \"created_at\": \"$encryptedTimeCreated\"}"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print('Log recorded');
    }
    else {
      print(response.reasonPhrase);
    }

  }
  Future phoneConfirmationDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft:Radius.circular(20),topRight:Radius.circular(20))
          ),
          backgroundColor: Theme.of(context).canvasColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Confirmation',style: TextStyle(fontSize: 12),),
            ],
          ),
          content: Text(
            'Ensure you have entered the official phone number registered with Bboxx Welfare Self Help Group. Unregistered phone number will not produce invalid results',
            textAlign: TextAlign.center,style: TextStyle(fontSize: 11),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text('Cancel',style: TextStyle(fontSize:12 )),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Proceed',style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OTPScreen(countryCode: countryCode,phoneNumber: completePhoneNumber, emailAddress: email)));

                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future invalidPhoneDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft:Radius.circular(20),topRight:Radius.circular(20))
          ),
          backgroundColor: Theme.of(context).canvasColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Invalid Phone Number',style: TextStyle(color:Colors.red,fontSize: 12),),
            ],
          ),
          content: Text(
            'Please enter a valid phone number',
            textAlign: TextAlign.center,style: TextStyle(fontSize: 11),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text('Okay',style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future signIn() async{
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: phoneHolder.text.trim(),
          password: passwordHolder.text.trim()
      ).then((value) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageHandler())));
      Navigator.of(context).pop();
    } on FirebaseAuthException catch(e){
      Navigator.of(context).pop();

      //Utils.showSnackBar(e.message);
      return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => new AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20)
            ),
          ),
          title: Center(child: new Text('Alert!',style: TextStyle(fontSize: 12))),
          content: Text(e.message,
              textAlign: TextAlign.center,style: TextStyle(color:Colors.red,fontSize: 11)),
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
        ),
      );
    }
    return Navigator.of(context).pop();
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
  Future checkPhone() async{
    try {
      await FirebaseFirestore.instance.collection("phoneNumbers").doc(
          user.email).get().then((value) {
        if (!mounted) return;
        setState(() {
          phoneNumber = value['phoneNumber'];
        });
      });
    }catch (e) {  }
    // phoneNumber != null ? Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => LandingPage())):
    // null;
  }

  @override
  Widget build(BuildContext context) {

   email = user.email;
    final Size size = MediaQuery.of(context).size;

    return phoneNumber != null ?
    LandingPage():
    WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(200),
              //bottomLeft: Radius.circular(200)
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.lightBlue),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 8,
          title: Column(
            children: [
              Center(
                child: Container(
                    height: 50,
                    width: 50,
                    child: Image.asset('android/assets/images/Bboxx_icon.png')),
              ),
              SizedBox(height: 10),
              Text("BWSHG", style:TextStyle(fontWeight:FontWeight.w600,color: Colors.lightBlue, fontSize: 16)),
              SizedBox(height: 40),
            ],
          ),
          toolbarHeight: 150,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              //height: size.height,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 0,
                    blurRadius: 0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                    Initicon(
                      elevation: 5,
                      color: Colors.lightBlue,
                      backgroundColor: Colors.lightBlueAccent.shade100,
                      text: userName,
                      size:40,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Text('''Please enter your official Mpesa Phone Number registered with Bboxx Welfare Self Help Group''', textAlign: TextAlign.center,style: TextStyle(fontSize: 12),),
                      ),
                    ),
                    SizedBox(height: size.height*0.14),
                    Center(
                      child: Column(
                        children: [
                          Form(
                            key:_formKey,
                            child:
                              Column(
                                children: [
                                  Padding(
                                      padding: EdgeInsets.all(12),
                                      child:
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: IntlPhoneField(
                                          style: TextStyle(fontSize: 12 ),
                                          dropdownTextStyle: TextStyle(fontSize: 12),
                                          initialCountryCode: 'KE',
                                          textAlignVertical: TextAlignVertical.center,
                                          focusNode: f1,
                                          keyboardType: TextInputType.phone,
                                          controller: phoneHolder,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.phone,size: 20,),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                color: Colors.lightBlueAccent.shade100,
                                                width: 1,
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(20))
                                            ),
                                            labelText: "Phone Number",
                                          ),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          onChanged: (phone){
                                            print(phone.completeNumber);
                                            completePhoneNumber = phone.completeNumber;
                                            countryCode = phone.countryCode;
                                          },
                                          validator: (value) {
                                            if (value == null ){
                                              return "Please Enter a Valid Phone";
                                            }
                                            return null;
                                          },
                                        ),
                                      )
                                  ),
                                  SizedBox(height: 10,),
                                ],
                              ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height*0.14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(10),
                                //shadowColor: MaterialStateProperty.all(Theme.of(context).cardColor),
                                fixedSize: MaterialStateProperty.all(Size(size.width*0.3, size.height*0.05)),
                                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor,),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      )
                                  )
                              ),
                              child: Text("Cancel", style: TextStyle(fontSize:12,color: Colors.lightBlue)),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => navigation())
                                );
                                },
                            ),
                          ),
                        ),
                        SizedBox(width: 40,),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(10),
                                  //shadowColor: MaterialStateProperty.all(Theme.of(context).cardColor),
                                  fixedSize: MaterialStateProperty.all(Size(size.width*0.3, size.height*0.05)),
                                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor,),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      )
                                  )
                              ),
                              child: Text("Submit", style: TextStyle(fontSize:12,color: Colors.lightBlue)),
                              onPressed: () {
                                if(_formKey.currentState.validate()) {
                                  phoneConfirmationDialog();
                                }else{
                                  invalidPhoneDialog();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }
}
