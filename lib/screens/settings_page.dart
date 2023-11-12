import 'package:bboxx_welfare_app/icon_widget.dart';
import 'package:bboxx_welfare_app/screens/about.dart';
import 'package:bboxx_welfare_app/screens/info.dart';
import 'package:bboxx_welfare_app/screens/header_page.dart';
import 'package:bboxx_welfare_app/screens/pageHandler.dart';
import 'package:bboxx_welfare_app/screens/transaction_history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:bboxx_welfare_app/google_signin_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';



class SettingsPage extends StatefulWidget{
  SettingsPage({Key key}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
  }

class _SettingsPageState extends State<SettingsPage> {
  final String baseUrl = 'https://gvlb1ub624.execute-api.us-east-1.amazonaws.com/prod/sqs';
  final String authToken = 'RLFbz206A47vzWYltVvMR1chg4texn5U8OKvVW7z';
  final secretKey = 'Snyaca7590231234';
  String ipAddress = 'Loading...';

 final user = FirebaseAuth.instance.currentUser;

 @override
 void initState() {
   if (!mounted) return;
   super.initState();
   _initPackageInfo();
   sendLog('logs', 'Settings Screen Launched');
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(

                child: HeaderPage()
            ),
            Container(
              height: size.height*0.4,
              child: ListView(
                 padding: EdgeInsets.all(5),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SettingsGroup(
                      title: '',
                      children: <Widget>[
                        buildTransactionHistory(),
                        SizedBox(height: size.height*0.02),
                        buildAbout(),
                        SizedBox(height: size.height*0.02),
                        buildLogout(),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height*0.05),
            Container(
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .cardColor,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 1,
                      blurRadius: 2,
                      blurStyle: BlurStyle.normal,
                      offset: Offset(5, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(size.height * 0.005),
                  child: Column(
                    children: [
                      Text('from', style: TextStyle(fontSize: 10)),
                      Text("Globsoko", style: TextStyle(color:Colors.lightBlue, fontSize: 12),)
                    ],
                  ),
                )
            ),
            SizedBox(height: size.height * 0.05),
            Padding(
              padding: EdgeInsets.all(size.height * 0.005),
              child: Text('version: ${_packageInfo.version}', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLogout() {
    return SimpleSettingsTile(
   title: 'Logout',
    subtitle: 'Sign out of the app',
    leading: IconWidget(icon: Icons.logout),
    onTap: () {
      final provider = Provider.of<GoogleSignInProvider>(context, listen:false);
      provider.logout();
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageHandler())
      );
      sendLog('logs', 'Logged out of the App');
    },
  );
  }
  Widget buildAbout() {
    return SimpleSettingsTile(
    title: 'About',
    subtitle: 'Details about what the app is all about',
    leading: IconWidget(icon: Icons.info),
    onTap: () {
      //Utils.showSnackBar(context, 'Clicked Logout');
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => About())
      );
      sendLog('logs', 'About Screen Launched');
    },
  );
  }

  Widget buildAppInfo() {
    return SimpleSettingsTile(
    title: 'App Info',
    subtitle: 'Information about the app version',
    leading: IconWidget(icon: Icons.info),
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InfoPage())
      );
    },
  );
  }

  Widget buildHome() {
    return SimpleSettingsTile(
    title: 'Home',
    subtitle: 'Go to Home Page',
    leading: IconWidget(icon: Icons.home),
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageHandler())
      );
    },
  );
  }

  Widget buildTransactionHistory() {
   return SimpleSettingsTile(
     title: 'Transaction History',
     subtitle: 'Information about Transactions',
     leading: IconWidget(icon: Icons.dataset),
     onTap: () {
       //Utils.showSnackBar(context, 'Clicked Logout');
       Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => TransactionHistory())
       );
     },
   );
 }

}
