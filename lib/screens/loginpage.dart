import 'package:bboxx_welfare_app/models/navigation.dart';
import 'package:bboxx_welfare_app/screens/forgotPasswordPage.dart';
import 'package:bboxx_welfare_app/screens/pageHandler.dart';
import 'package:bboxx_welfare_app/screens/registerPage.dart';
import 'package:bboxx_welfare_app/utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bboxx_welfare_app/google_signin_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final String baseUrl = 'https://gvlb1ub624.execute-api.us-east-1.amazonaws.com/prod/sqs';
  final String authToken = 'RLFbz206A47vzWYltVvMR1chg4texn5U8OKvVW7z';
  final secretKey = 'Snyaca7590231234';
  String ipAddress = 'Loading...';

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final emailHolder = TextEditingController();
  final passwordHolder = TextEditingController();

  String email;
  String password;

  bool passwordView = true;

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
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

    final encryptedEmail = encryptString(emailHolder.text.trim(), secretKey);
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
  Future signIn() async{
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailHolder.text.trim(),
          password: passwordHolder.text.trim()
      ).then((value) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageHandler())));
      sendLog('logs', 'User Successfully logged in to the app.');
      Navigator.of(context).pop();
    } on FirebaseAuthException catch(e){
      sendLog('logs', 'Login Error Encountered: ${e.message}.');
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
          title: Center(child: new Text('Alert!',style: TextStyle(fontSize: 14))),
          content: Text(e.message,
              textAlign: TextAlign.center,style: TextStyle(color:Colors.red,fontSize: 12)),
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

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;

    return WillPopScope(
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
              Text("Bboxx Welfare Self Help Group", style:TextStyle(fontWeight:FontWeight.w600,color: Colors.lightBlue, fontSize: 16)),
              SizedBox(height: 40),
            ],
          ),
          toolbarHeight: 150,
        ),
        body: Container(
          height: size.height,
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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  SizedBox(height: 20,),
                  Column(
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
                                    child: TextFormField(
                                      textAlignVertical: TextAlignVertical.top,
                                      focusNode: f1,
                                      keyboardType: TextInputType.emailAddress,
                                      controller: emailHolder,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.email,size: 20,),
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
                                        labelText: "Email address",
                                      ),
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onChanged: (value){
                                        //emailHolder.text = value;
                                      },
                                      validator: (value) {
                                        if (value != null && !EmailValidator.validate(value)){
                                          return "Please Enter a Valid Email";
                                        }
                                        return null;
                                      },
                                    ),
                                  )
                              ),
                              SizedBox(height: 10,),
                              Padding(
                                  padding: EdgeInsets.all(12),
                                  child:
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      textAlignVertical: TextAlignVertical.top,
                                      obscureText: passwordView,
                                      obscuringCharacter: '*',
                                      focusNode: f2,
                                      keyboardType: TextInputType.visiblePassword,
                                      controller: passwordHolder,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.lock, size: 20,),
                                        suffix: IconButton(
                                            padding: EdgeInsets.only(bottom: 5,top: 0),
                                            onPressed: (){
                                              if (!mounted) return;
                                              setState(() {
                                                return passwordView = !passwordView;
                                              });
                                            },
                                            icon: Icon(
                                              passwordView ? Icons.visibility_off: Icons.visibility,
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
                                        labelText: "Password",
                                      ),
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onChanged: (value){
                                         //passwordHolder.text = value;
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty){
                                          return "Please enter a valid password";
                                        }
                                        return null;
                                      },
                                    ),
                                  )
                              ),
                            ],
                          ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
                                },
                                child: Text('Forgot Password ?',style: TextStyle(color: Colors.lightBlue),)),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 25,),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(10),
                          //shadowColor: MaterialStateProperty.all(Theme.of(context).cardColor),
                          fixedSize: MaterialStateProperty.all(Size(size.width*0.75, size.height*0.05)),
                            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor,),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                )
                            )
                        ),
                        child: Text("Sign In", style: TextStyle(color: Colors.lightBlue)),
                        onPressed: () {
                            signIn();
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Or', style: TextStyle(fontWeight:FontWeight.bold,color: Colors.lightBlue)),
                  ),
                  SizedBox(height: 10,),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SignInButton(
                        Buttons.GoogleDark,
                        elevation:10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(3))
                        ),
                        onPressed: () async{
                          final provider =
                          Provider.of<GoogleSignInProvider>(context, listen: false);
                          provider.googleLogin();
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                        onPressed: (){
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Center(child: CircularProgressIndicator());
                              });
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Don\u0027t have an Account ? ',style: TextStyle(color: Colors.lightBlue)),
                            Text('Register', style: TextStyle(color:Colors.lightBlue,fontWeight: FontWeight.bold)),
                          ],
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }
}
