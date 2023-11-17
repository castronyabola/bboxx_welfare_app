import 'dart:io';

import 'package:bboxx_welfare_app/models/Account.dart';
import 'package:bboxx_welfare_app/models/navigation.dart';
import 'package:bboxx_welfare_app/screens/landingPage.dart';
import 'package:bboxx_welfare_app/screens/lockPinPage.dart';
import 'package:bboxx_welfare_app/screens/loginpage.dart';
import 'package:bboxx_welfare_app/screens/pageHandler.dart';
import 'package:bboxx_welfare_app/screens/verifyEmailPage.dart';
import 'package:bboxx_welfare_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:smart_select/smart_select.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';


class AccountCreationPage extends StatefulWidget {
  @override
  _AccountCreationPageState createState() => _AccountCreationPageState();
}

class _AccountCreationPageState extends State<AccountCreationPage> {
  final String baseUrl = 'https://gvlb1ub624.execute-api.us-east-1.amazonaws.com/prod/sqs';
  final String authToken = 'RLFbz206A47vzWYltVvMR1chg4texn5U8OKvVW7z';
  final secretKey = 'Snyaca7590231234';
  String ipAddress = 'Loading...';
  var currencyFormat = new NumberFormat.currency(locale: "en_US",
      symbol: "KES ", decimalDigits: 0);

  final user = FirebaseAuth.instance.currentUser;

  bool personalDetailsSubmitted = false;
  bool nextOfKinDetailsSubmitted = false;
  bool firstGuardianDetailsSubmitted = false;
  bool secondGuardianDetailsSubmitted = false;
  bool childDetailsSubmitted = false;
  bool welfareSavingsDetailsSubmitted = false;

  bool personalDetailsLaunch = false;
  bool nextOfKinDetailsLaunch = false;
  bool firstGuardianDetailsLaunch = false;
  bool secondGuardianDetailsLaunch = false;
  bool childDetailsLaunch = false;
  bool welfareSavingsDetailsLaunch = false;

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  FocusNode f4 = FocusNode();
  FocusNode f5 = FocusNode();
  FocusNode f6 = FocusNode();
  FocusNode f7 = FocusNode();
  FocusNode f8 = FocusNode();
  FocusNode f9 = FocusNode();
  FocusNode f10 = FocusNode();
  FocusNode f11 = FocusNode();
  FocusNode f12 = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final emailHolder = TextEditingController();
  final passwordHolder = TextEditingController();
  final myNameHolder = TextEditingController();
  final employmentNumberHolder = TextEditingController();
  final membershipNumberHolder = TextEditingController();
  final IDNumberHolder = TextEditingController();
  final designationHolder = TextEditingController();
  final locationHolder = TextEditingController();
  final phoneNumberHolder = TextEditingController();
  final roleHolder = TextEditingController();
  final postalAddressHolder = TextEditingController();
  final postalCodeHolder = TextEditingController();

  final nextOfKinNameHolder = TextEditingController();
  final nextOfKinIDNumberHolder = TextEditingController();
  final nextOfKinPhoneNumberHolder = TextEditingController();
  final nextOfKinRelationshipHolder = TextEditingController();

  final parent1NameHolder = TextEditingController();
  final parent1IDNumberHolder = TextEditingController();
  final parent1PhoneNumberHolder = TextEditingController();
  final parent1RelationshipHolder = TextEditingController();

  final parent2NameHolder = TextEditingController();
  final parent2IDNumberHolder = TextEditingController();
  final parent2PhoneNumberHolder = TextEditingController();
  final parent2RelationshipHolder = TextEditingController();

  final spouseNameHolder = TextEditingController();
  final spouseIDNumberHolder = TextEditingController();
  final spousePhoneNumberHolder = TextEditingController();
  final spouseRelationshipHolder = TextEditingController();

  final child1NameHolder = TextEditingController();
  final child1DateOfBirthHolder = TextEditingController();

  final child2NameHolder = TextEditingController();
  final child2DateOfBirthHolder = TextEditingController();

  final child3NameHolder = TextEditingController();
  final child3DateOfBirthHolder = TextEditingController();

  final child4NameHolder = TextEditingController();
  final child4DateOfBirthHolder = TextEditingController();

  final child5NameHolder = TextEditingController();
  final child5DateOfBirthHolder = TextEditingController();

  final monthlySavingsHolder = TextEditingController();
  final savingsStartDateHolder = TextEditingController();


  String password;
  //Personal Details
  String myName;
  String employmentNumber;
  String membershipNumber;
  String IDNumber;
  String designation;
  String location;
  String phoneNumber;
  String role;
  String postalAddress;
  String postalCode;
  String email;

  //Next of Kin
  String nextOfKinName;
  String nextOfKinIDNumber;
  String nextOfKinPhoneNumber;
  String nextOfKinRelationship;

  //BENEFICIARIES
  //Parent/Guardian1
  String parent1Name;
  String parent1IDNumber;
  String parent1PhoneNumber;
  String parent1Relationship;

  //Parent/Guardian2
  String parent2Name;
  String parent2IDNumber;
  String parent2PhoneNumber;
  String parent2Relationship;

  //Spouse
  String spouseName;
  String spouseIDNumber;
  String spousePhoneNumber;
  String spouseRelationship;

  //child1
  String child1Name;
  String child1DateOfBirth;

  //child2
  String child2Name;
  String child2DateOfBirth;

  //child3
  String child3Name;
  String child3DateOfBirth;

  //child4
  String child4Name;
  String child4DateOfBirth;

  //child5
  String child5Name;
  String child5DateOfBirth;

  //Savings
  int monthlySavings;
  String savingsStartDate;

  bool passwordView = true;
  bool otherSelected = false;

  List<Account> _accountDetails = [];

  @override
  void initState() {
    if (!mounted) return;
    getPhone();
    super.initState();
    //getData();
    personalDetailsSubmitted = false;
    nextOfKinDetailsSubmitted = false;
    firstGuardianDetailsSubmitted = false;
    secondGuardianDetailsSubmitted = false;
    childDetailsSubmitted = false;
    welfareSavingsDetailsSubmitted = false;

    // personalDetailsLaunch = false;
    // nextOfKinDetailsLaunch = false;
    // firstGuardianDetailsLaunch = false;
    // secondGuardianDetailsLaunch = false;
    // childDetailsLaunch = false;
    // welfareSavingsDetailsLaunch = false;
    _initPackageInfo();
    sendLog('logs', 'Account Creation Screen Launched');
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

  Future getPhone() async{
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
  Future personalDetailsDialog() async{
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
              Text('Confirmation',style: TextStyle(),),
            ],
          ),
          content: Container(
            height: 210,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Full Name:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${myNameHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Staff ID:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${employmentNumberHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Position:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${roleHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('National ID:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${IDNumberHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Designation:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${designationHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Workstation:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${locationHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text('Phone Number:',style: TextStyle(fontWeight: FontWeight.bold),),
                //     Text('${phoneNumberHolder.text}')
                //   ],
                // ),
                // SizedBox(height: 10,),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Cancel',style: TextStyle()),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Confirm',style: TextStyle()),
                  onPressed: () async{
                    submitPersonalDetails();
                    await Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future nextOfKinDialog() async{
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
              Text('Confirmation',style: TextStyle(),),
            ],
          ),
          content: Container(
            height: 110,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Full Name:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${nextOfKinNameHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ID Number:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${nextOfKinIDNumberHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Phone Number:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${nextOfKinPhoneNumberHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Relationship:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${nextOfKinRelationship}')
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Cancel',style: TextStyle()),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Confirm',style: TextStyle()),
                  onPressed: () async{
                    submitNextOfKinDetails();
                    await Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future firstGuardianDialog() async{
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
              Text('Confirmation',style: TextStyle(),),
            ],
          ),
          content: Container(
            height: 120,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Full Name: ',style: TextStyle(fontWeight: FontWeight.bold),),
                    Flexible(child: Text('${parent1NameHolder.text}'
                    ,style: TextStyle(overflow: TextOverflow.fade),))
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ID Number:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${parent1IDNumberHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Phone Number:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${parent1PhoneNumberHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Relationship:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${parent1Relationship}')
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Cancel',style: TextStyle()),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Confirm',style: TextStyle()),
                  onPressed: () async{
                    submitFirstGuardianDetails();
                    await Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future secondGuardianDialog() async{
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
              Text('Confirmation',style: TextStyle(),),
            ],
          ),
          content: Container(
            height: 120,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Full Name: ',style: TextStyle(fontWeight: FontWeight.bold),),
                    Flexible(child: Text('${parent2NameHolder.text}'))
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ID Number:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${parent2IDNumberHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Phone Number:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${parent2PhoneNumberHolder.text}')
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Relationship:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${parent2Relationship}')
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Cancel',style: TextStyle()),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Confirm',style: TextStyle()),
                  onPressed: () async{
                    submitSecondGuardianDetails();
                    await Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future childDialog() async{
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
              Text('Confirmation',style: TextStyle(),),
            ],
          ),
          content: Container(
            //height: 550,
            child: Column(
              children: [
                Text('First Child',style: TextStyle(fontWeight:FontWeight.bold,color:Colors.lightBlue)),
                //SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Full Name: ',style: TextStyle(fontWeight: FontWeight.bold),),
                    Flexible(child: Text('${child1NameHolder.text}'))
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date of Birth:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${child1DateOfBirthHolder.text}')
                  ],
                ),
                SizedBox(height: 20,),
                Text('Second Child',style: TextStyle(fontWeight:FontWeight.bold,color:Colors.lightBlue)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Full Name: ',style: TextStyle(fontWeight: FontWeight.bold),),
                    Flexible(child: Text('${child2NameHolder.text}'))
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date of Birth:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${child2DateOfBirthHolder.text}')
                  ],
                ),
                SizedBox(height: 20,),
                Text('Third Child',style: TextStyle(fontWeight:FontWeight.bold,color:Colors.lightBlue)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Full Name: ',style: TextStyle(fontWeight: FontWeight.bold),),
                    Flexible(child: Text('${child3NameHolder.text}'))
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date of Birth:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${child3DateOfBirthHolder.text}')
                  ],
                ),
                SizedBox(height: 20,),
                Text('Fourth Child',style: TextStyle(fontWeight:FontWeight.bold,color:Colors.lightBlue)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Full Name: ',style: TextStyle(fontWeight: FontWeight.bold),),
                    Flexible(child: Text('${child4NameHolder.text}'))
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date of Birth:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${child4DateOfBirthHolder.text}')
                  ],
                ),
                SizedBox(height: 20,),
                Text('Fifth Child',style: TextStyle(fontWeight:FontWeight.bold,color:Colors.lightBlue)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Full Name: ',style: TextStyle(fontWeight: FontWeight.bold),),
                    Flexible(child: Text('${child5NameHolder.text}'))
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Date of Birth:',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text('${child5DateOfBirthHolder.text}')
                  ],
                ),
                SizedBox(height: 20,),
                Text('DECLARATION',style: TextStyle(fontWeight: FontWeight.bold)),
                Text('I solemnly declare that the information I have given in this form is, to the best of my knowledge, true and complete.'
                ,textAlign: TextAlign.justify,)
                  ],
                ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Cancel',style: TextStyle()),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Confirm',style: TextStyle()),
                  onPressed: () async{
                    submitChildDetails();
                    await Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future welfareSavingsDialog() async{
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
              Text('Authorization',style: TextStyle(),),
            ],
          ),
          content: Container(
            //height: 100,
            child: Text('I, ${myName}, ID No. ${IDNumber}, Workstation ${location}, authorize my employer Boxx Kenya Ltd to deduct KES 300 per month from my salary as welfare contribution and KES ${monthlySavingsHolder.text} per month from my salary as welfare savings with effect from ${savingsStartDateHolder.text} and remit it to BBOXX Staff Welfare Self Help Group.\n\n'
                'Note: This authority supersedes any earlier one and can only be stopped/amended by another one forwarded through the Executive Committee of BBOXX Staff Welfare Self Help Group.'
            ,textAlign:TextAlign.justify,style: TextStyle(fontSize: 14)),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Decline',style: TextStyle()),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Accept',style: TextStyle()),
                  onPressed: () async{
                    submitWelfareSavingsDetails();
                    await Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LandingPage())
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future <void> submitPersonalDetails() async{
    sendLog('logs','User ${myNameHolder.text.trim()}\'s Personal Details Submitted');
    await FirebaseFirestore.instance
        .collection("welfareUsers")
        .doc(phoneNumber)
        .set({
      'myName': myNameHolder.text.trim(),
      'email': user.email,
      'employmentNumber': employmentNumberHolder.text.trim(),
      'role': roleHolder.text.trim(),
      'IDNumber': IDNumberHolder.text.trim(),
      'designation': designationHolder.text.trim(),
      'location': locationHolder.text.trim(),
      'phoneNumber': phoneNumber,
      'membershipNumber': employmentNumberHolder.text.trim().replaceAll(
          'BXCK', 'BWSHG').replaceAll('bxck', 'BWSHG')
    });
    setState(() {
      personalDetailsSubmitted = true;
      nextOfKinDetailsSubmitted = false;
    });
  }
  Future <void> submitNextOfKinDetails() async{
    sendLog('logs','User ${myNameHolder.text.trim()}\'s next of kin Details Submitted');
    await FirebaseFirestore.instance
        .collection("welfareUsers")
        .doc(phoneNumber)
        .update({
      'nextOfKinName': nextOfKinNameHolder.text.trim(),
      'nextOfKinIDNumber': nextOfKinIDNumberHolder.text.trim(), //double.parse(value) < 7 ? 0.1 : 0.15,
      'nextOfKinPhoneNumber': nextOfKinPhoneNumberHolder.text.trim(),
      'nextOfKinRelationship': nextOfKinRelationship.trim(),
    });
    setState(() {
      personalDetailsSubmitted = true;
      nextOfKinDetailsSubmitted = true;
      firstGuardianDetailsSubmitted = false;
    });
  }
  Future <void> submitFirstGuardianDetails() async{
    sendLog('logs','User ${myNameHolder.text.trim()}\'s first guardian Details Submitted');
    await FirebaseFirestore.instance
        .collection("welfareUsers").doc(phoneNumber)
        .update({
      'parent1Name': parent1NameHolder.text.trim(),
      'parent1IDNumber': parent1IDNumberHolder.text.trim(), //double.parse(value) < 7 ? 0.1 : 0.15,
      'parent1PhoneNumber': parent1PhoneNumberHolder.text.trim(),
      'parent1Relationship': parent1Relationship.trim(),
    });
    setState(() {
      personalDetailsSubmitted = true;
      nextOfKinDetailsSubmitted = true;
      firstGuardianDetailsSubmitted = true;
      secondGuardianDetailsSubmitted = false;
    });
  }
  Future <void> submitSecondGuardianDetails() async{
    sendLog('logs','User ${myNameHolder.text.trim()}\'s second guardian Details Submitted');
    await FirebaseFirestore.instance
        .collection("welfareUsers")
        .doc(phoneNumber)
        .update({
      'parent2Name': parent2NameHolder.text.trim(),
      'parent2IDNumber': parent2IDNumberHolder.text.trim(), //double.parse(value) < 7 ? 0.1 : 0.15,
      'parent2PhoneNumber': parent2PhoneNumberHolder.text.trim(),
      'parent2Relationship': parent2Relationship.trim(),
    });
    setState(() {
      personalDetailsSubmitted = true;
      nextOfKinDetailsSubmitted = true;
      firstGuardianDetailsSubmitted = true;
      secondGuardianDetailsSubmitted = true;
    });
  }
  Future <void> submitChildDetails() async{
    sendLog('logs','User ${myNameHolder.text.trim()}\'s child Details Submitted');
    await FirebaseFirestore.instance
        .collection("welfareUsers")
        .doc(phoneNumber)
        .update({
      'child1Name': child1NameHolder.text.trim(),
      'child1DateOfBirth': child1DateOfBirthHolder.text.trim(),
      'child2Name': child2NameHolder.text.trim(),
      'child2DateOfBirth': child2DateOfBirthHolder.text.trim(),
      'child3Name': child3NameHolder.text.trim(),
      'child3DateOfBirth': child3DateOfBirthHolder.text.trim(),
      'child4Name': child4NameHolder.text.trim(),
      'child4DateOfBirth': child4DateOfBirthHolder.text.trim(),
      'child5Name': child5NameHolder.text.trim(),
      'child5DateOfBirth': child5DateOfBirthHolder.text.trim(),
    });
    setState(() {
      personalDetailsSubmitted = true;
      nextOfKinDetailsSubmitted = true;
      firstGuardianDetailsSubmitted = true;
      secondGuardianDetailsSubmitted = true;
      childDetailsSubmitted = true;
    });
    // return Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => LockPinPage()));
  }
  Future <void> submitWelfareSavingsDetails() async{
    sendLog('logs','User ${myNameHolder.text.trim()}\'s welfare Savings Details Submitted');
    await FirebaseFirestore.instance
        .collection("welfareUsers")
        .doc(phoneNumber)
        .update({
      'monthlySavings': monthlySavings,
      'savingsStartDate': savingsStartDateHolder.text.trim(),
      'mySavings': 0,
      'uid': phoneNumber,
      'myPin': null,
      'resetPin': null,
      'welfareCreateCheck': false,
      'loanDisbursementMethod': '',
      'loanDue': 0,
      'loanDueDate': '',
      'loanGranted': 0,
      'loanGrantedDate': '1900-01-01',
      'loanInstallments': 0,
      'loanInterest': 0.1,
      'loanPaid': 0,
      'loanPeriod': 0,
      'loanRequested': 0,
      'myLoan': 0,
      'reasonForLoan': '',
      'guarantorBalance': 0
    });
    setState(() {
      personalDetailsSubmitted = true;
      nextOfKinDetailsSubmitted = true;
      firstGuardianDetailsSubmitted = true;
      secondGuardianDetailsSubmitted = true;
      welfareSavingsDetailsSubmitted = true;
    });
  }

  List<S2Choice<String>> designationOptions = [
    S2Choice<String>(value: 'Mr', title: 'Mr'),
    S2Choice<String>(value: 'Mrs', title: 'Mrs'),
    S2Choice<String>(value: 'Miss', title: 'Miss'),
    S2Choice<String>(value: 'Ms', title: 'Ms'),
    S2Choice<String>(value: 'Dr', title: 'Dr'),
    S2Choice<String>(value: 'Eng', title: 'Eng'),
    S2Choice<String>(value: 'Prof', title: 'Prof'),
    S2Choice<String>(value: 'Hon', title: 'Hon'),

  ];

  List<S2Choice<String>> nextOfKinOptions = [
    S2Choice<String>(value: 'Spouse', title: 'Spouse'),
    S2Choice<String>(value: 'Parent', title: 'Parent'),
    S2Choice<String>(value: 'Child', title: 'Child'),
    S2Choice<String>(value: 'Sibling', title: 'Sibling'),
    S2Choice<String>(value: 'Other', title: 'Other')
  ];
  Future<bool> _onBackPressed() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        backgroundColor: Theme.of(context).cardColor,
        title: Center(child: new Text('Confirmation')),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Do you want to exit the App?'),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text("NO"),
                onPressed: () {
                  return Navigator.of(context).pop(false);
                },
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("welfareUsers")
                      .doc(phoneNumber)
                      .delete();
                  exit(0);
                  //return SystemNavigator.pop();
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
    if(nextOfKinRelationship == 'Other' || parent1Relationship == 'Other' || parent2Relationship == 'Other'){
      otherSelected = true;
    }else{
      otherSelected = false;
    }

    final Size size = MediaQuery.of(context).size;

    return WillPopScope(
        // onWillPop: () {
        //   final provider =
        //   Provider.of<GoogleSignInProvider>(context, listen: false);
        //   return provider.logout();
        // },
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(200),
                //bottomRight: Radius.circular(200)
              ),
            ),
            // leading: IconButton(
            //   icon: Icon(Icons.arrow_back),
            //   onPressed: ()
            //   {
            //     final provider =
            //     Provider.of<GoogleSignInProvider>(context, listen: false);
            //     return provider.logout();
            //   },
            // ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.lightBlue),
            backgroundColor: Theme.of(context).cardColor,
            elevation: 8,
            title: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Welfare Registration', style:TextStyle(color: Colors.lightBlue, fontSize: 16)),
                ),
              ],
            ),
            toolbarHeight: 50,
          ),
          bottomNavigationBar: Container(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  personalDetailsSubmitted ?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_sharp,size: 15,color: Colors.lightBlue),
                          SizedBox(width: 10),
                          Text("Back", style: TextStyle(color: Colors.lightBlue)),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          welfareSavingsDetailsSubmitted == true ? welfareSavingsDetailsSubmitted = false:
                          childDetailsSubmitted == true ? childDetailsSubmitted = false:
                          secondGuardianDetailsSubmitted == true ? secondGuardianDetailsSubmitted = false:
                          firstGuardianDetailsSubmitted == true ? firstGuardianDetailsSubmitted = false:
                          nextOfKinDetailsSubmitted == true ? nextOfKinDetailsSubmitted = false:
                          personalDetailsSubmitted == true ? personalDetailsSubmitted = false
                              :null;
                        });

                      },
                    ),
                  ):
                  SizedBox(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
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
                      child: !childDetailsSubmitted ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Next", style: TextStyle(color: Colors.lightBlue)),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward,size: 15,color: Colors.lightBlue),
                        ],
                      ):
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Submit", style: TextStyle(color: Colors.lightBlue)),
                          SizedBox(width: 10),
                          Icon(Icons.done,size: 15,color: Colors.lightBlue),
                        ],
                      ),
                      onPressed: () {
                        if(_formKey.currentState.validate()) {
                          !personalDetailsSubmitted ?
                          personalDetailsDialog()
                              : !nextOfKinDetailsSubmitted ?
                          nextOfKinDialog()
                              : !firstGuardianDetailsSubmitted ?
                          firstGuardianDialog()
                              :!secondGuardianDetailsSubmitted ?
                          secondGuardianDialog()
                              :!childDetailsSubmitted ?
                          childDialog()
                              :!welfareSavingsDetailsSubmitted?
                          welfareSavingsDialog()
                              :null;
                          otherSelected = false;
                          //submitData();
                        }
                      },
                    ),
                  ),
                ],
              )
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 50,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      //height: size.height * 0.2,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Form(
                        key: _formKey,
                        child:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            !personalDetailsSubmitted ?
                            Container(
                              height: size.height*0.65,
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: <Widget> [
                                    Text("PERSONAL DETAILS", style:TextStyle(color: Colors.lightBlue, fontSize: 16)),
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f3,
                                          keyboardType: TextInputType.name,
                                          controller: myNameHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.account_circle),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            //hintText: "What is your Employment Number?",
                                            labelText: "Full Name",
                                            //helperText: 'Edit Your Employment Number',
                                          ),
                                          onChanged: (value) {
                                            myName = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please enter your Full Name";
                                            }
                                            return null;
                                          },
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f4,
                                          keyboardType: TextInputType.text,
                                          controller: employmentNumberHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.perm_identity),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            //hintText: "What is your Employment Number?",
                                            labelText: "Bboxx Staff ID",
                                            //helperText: 'Edit Your Employment Number',
                                          ),
                                          onChanged: (value) {
                                            employmentNumber = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please enter your Employment Number";
                                            }
                                            return null;
                                          },
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f5,
                                          keyboardType: TextInputType.text,
                                          controller: roleHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.hourglass_bottom),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            //hintText: "What is your Role?",
                                            labelText: "Position/Job",
                                            //helperText: 'Edit Your Membership number',
                                          ),
                                          onChanged: (value) {
                                            role = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please enter your Role";
                                            }
                                            return null;
                                          },
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f6,
                                          keyboardType: TextInputType.number,
                                          controller: IDNumberHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.confirmation_number),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            //hintText: "What is your National ID Number ?",
                                            labelText: "IDNumber",
                                            //helperText: 'Edit Your National ID Number',
                                          ),
                                          onChanged: (value) {
                                            IDNumber = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please enter your National ID Number";
                                            }
                                            return null;
                                          },
                                        )
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Container(
                                      //width: size.width*0.87,
                                      height: size.height*0.075,
                                      decoration: BoxDecoration(
                                        border:Border.all(
                                            color: Colors.lightBlueAccent.shade100,
                                        ),
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: SmartSelect<String>.single(
                                        tileBuilder: (context, state) {
                                          return S2Tile(
                                            padding: EdgeInsets.symmetric(horizontal: 12),
                                            title: state.titleWidget,
                                            value: state.valueDisplay,
                                            onTap: state.showModal,
                                            trailing: Icon(Icons.keyboard_arrow_down),
                                            leading: Icon(Icons.wc),
                                            isTwoLine: true,
                                          );
                                        },
                                        choiceStyle: S2ChoiceStyle(
                                          activeColor: Colors.lightBlue,
                                          color: Colors.black,
                                          runSpacing: 4,
                                          spacing: 12,
                                          showCheckmark: true,
                                        ),
                                        choiceType: S2ChoiceType.switches,
                                        modalHeaderStyle: S2ModalHeaderStyle(
                                          backgroundColor: Theme.of(context).backgroundColor,
                                          textStyle: TextStyle(fontSize:18,color:Colors.lightBlue),
                                        ) ,
                                        modalConfig: S2ModalConfig(
                                            filterAuto: true,
                                            barrierDismissible: false,
                                            useConfirm: true,
                                            useFilter: true,
                                            useHeader: true,
                                            confirmIcon: Icon(
                                                Icons.check_circle_outline),
                                            confirmColor: Colors.lightBlue
                                        ),
                                        modalStyle: S2ModalStyle(
                                          elevation: 20,
                                          backgroundColor: Colors.white12.withOpacity(0.8),
                                        ),
                                        modalType: S2ModalType.popupDialog,
                                        choiceDirection: Axis.vertical,
                                        placeholder: "Please select one",
                                        title: 'Designation',
                                        value: designationHolder.text,
                                        choiceItems: designationOptions,
                                        onChange: (state) {
                                          setState(() => designationHolder.text = state.value);
                                        },
                                      ),
                                    ),
                                  ),
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f7,
                                          keyboardType: TextInputType.text,
                                          controller: locationHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.location_city),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            // hintText: "Where is your work station ?",
                                            labelText: "Workstation",
                                            //helperText: 'Edit Your work station',
                                          ),
                                          onChanged: (value) {
                                            location = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please enter your work station";
                                            }
                                            return null;
                                          },
                                        )
                                    ),
                                    SizedBox(height: 10,),
                                  ],
                                ),
                              ),
                            )
                                :!nextOfKinDetailsSubmitted?
                            Container(
                              height: size.height*0.65,
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: <Widget> [
                                    Text("NEXT OF KIN", style:TextStyle(color: Colors.lightBlue, fontSize: 16)),
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f1,
                                          keyboardType: TextInputType.name,
                                          controller: nextOfKinNameHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.account_circle),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            //hintText: "What is your Employment Number?",
                                            labelText: "Next of Kin Full Name",
                                            //helperText: 'Edit Your Employment Number',
                                          ),
                                          onChanged: (value) {
                                            nextOfKinName = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please enter next of Kin Full Name";
                                            }
                                            return null;
                                          },
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f2,
                                          keyboardType: TextInputType.number,
                                          controller: nextOfKinIDNumberHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.perm_identity),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            //hintText: "What is your Employment Number?",
                                            labelText: "Next of Kin ID number",
                                            //helperText: 'Edit Your Employment Number',
                                          ),
                                          onChanged: (value) {
                                            nextOfKinIDNumber = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please enter Next of Kin ID number";
                                            }
                                            return null;
                                          },
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f3,
                                          keyboardType: TextInputType.phone,
                                          controller: nextOfKinPhoneNumberHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.hourglass_bottom),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            //hintText: "What is your Role?",
                                            labelText: "Phone Number",
                                            //helperText: 'Edit Your Membership number',
                                          ),
                                          onChanged: (value) {
                                            nextOfKinPhoneNumber = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please enter your Phone NUmber";
                                            }
                                            return null;
                                          },
                                        )
                                    ),
                                    otherSelected ?
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f4,
                                          keyboardType: TextInputType.text,
                                          controller: nextOfKinRelationshipHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.wc),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            //hintText: "What is your National ID Number ?",
                                            labelText: "Next of Kin Relationship",
                                            //helperText: 'Edit Your National ID Number',
                                          ),
                                          onChanged: (value) {
                                            nextOfKinRelationship = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please enter Next of Kin Relationship";
                                            }
                                            return null;
                                          },
                                        )
                                    ): Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Container(
                                        //width: size.width*0.87,
                                        height: size.height*0.075,
                                        decoration: BoxDecoration(
                                          border:Border.all(
                                            color: Colors.lightBlueAccent.shade100,
                                          ),
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: SmartSelect<String>.single(
                                          tileBuilder: (context, state) {
                                            return S2Tile(
                                              padding: EdgeInsets.symmetric(horizontal: 12),
                                              title: state.titleWidget,
                                              value: state.valueDisplay,
                                              onTap: state.showModal,
                                              trailing: Icon(Icons.keyboard_arrow_down),
                                              leading: Icon(Icons.wc),
                                              isTwoLine: true,
                                            );
                                          },
                                          choiceStyle: S2ChoiceStyle(
                                            activeColor: Colors.lightBlue,
                                            color: Colors.black,
                                            runSpacing: 4,
                                            spacing: 12,
                                            showCheckmark: true,
                                          ),
                                          choiceType: S2ChoiceType.switches,
                                          modalHeaderStyle: S2ModalHeaderStyle(
                                            backgroundColor: Theme.of(context).backgroundColor,
                                            textStyle: TextStyle(fontSize:18,color:Colors.lightBlue),
                                          ) ,
                                          modalConfig: S2ModalConfig(
                                              filterAuto: true,
                                              barrierDismissible: false,
                                              useConfirm: true,
                                              useFilter: true,
                                              useHeader: true,
                                              confirmIcon: Icon(
                                                  Icons.check_circle_outline),
                                              confirmColor: Colors.lightBlue
                                          ),
                                          modalStyle: S2ModalStyle(
                                            elevation: 20,
                                            backgroundColor: Colors.white12.withOpacity(0.8),
                                          ),
                                          modalType: S2ModalType.popupDialog,
                                          choiceDirection: Axis.vertical,
                                          placeholder: "Please select one",
                                          title: 'Next of Kin Relationship',
                                          value: nextOfKinRelationship,
                                          choiceItems: nextOfKinOptions,
                                          onChange: (state) {
                                              setState(() =>
                                              nextOfKinRelationship = state.value);
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    // Divider(
                                    //   thickness: 1,
                                    //   indent: 30,
                                    //   endIndent: 30,
                                    // ),
                                  ],
                                ),
                              ),
                            )
                                :!firstGuardianDetailsSubmitted ?
                            Container(
                              height: size.height*0.65,
                              child: Column(
                                children: <Widget> [
                                  Text("BENEFICIARIES", style:TextStyle(color: Colors.lightBlue, fontSize: 16)),
                                  Text("First Guardian/Parent Details", style:TextStyle(color: Colors.lightBlue, fontSize: 14)),
                                  Padding(
                                      padding: EdgeInsets.all(12),
                                      child:
                                      TextFormField(
                                        focusNode: f1,
                                        keyboardType: TextInputType.name,
                                        controller: parent1NameHolder,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.account_circle),
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
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          //hintText: "What is your Employment Number?",
                                          labelText: "Full Name",
                                          //helperText: 'Edit Your Employment Number',
                                        ),
                                        onChanged: (value) {
                                          parent1Name = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty){
                                            return "Please Guardian Full Name";
                                          }
                                          return null;
                                        },
                                      )
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(12),
                                      child:
                                      TextFormField(
                                        focusNode: f2,
                                        keyboardType: TextInputType.number,
                                        controller: parent1IDNumberHolder,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.perm_identity),
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
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          //hintText: "What is your Employment Number?",
                                          labelText: "Guardian ID number",
                                          //helperText: 'Edit Your Employment Number',
                                        ),
                                        onChanged: (value) {
                                          parent1IDNumber = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty){
                                            return "Please enter Guardian ID number";
                                          }
                                          return null;
                                        },
                                      )
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(12),
                                      child:
                                      TextFormField(
                                        focusNode: f3,
                                        keyboardType: TextInputType.phone,
                                        controller: parent1PhoneNumberHolder,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.hourglass_bottom),
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
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          //hintText: "What is your Role?",
                                          labelText: "Guardian Phone NUmber",
                                          //helperText: 'Edit Your Membership number',
                                        ),
                                        onChanged: (value) {
                                          parent1PhoneNumber = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty){
                                            return "Please enter Guardian Phone NUmber";
                                          }
                                          return null;
                                        },
                                      )
                                  ),
                                  otherSelected ?
                                  Padding(
                                      padding: EdgeInsets.all(12),
                                      child:
                                      TextFormField(
                                        focusNode: f4,
                                        keyboardType: TextInputType.text,
                                        controller: parent1RelationshipHolder,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.confirmation_number),
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
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          //hintText: "What is your National ID Number ?",
                                          labelText: "Guardian Relationship",
                                          //helperText: 'Edit Your National ID Number',
                                        ),
                                        onChanged: (value) {
                                          parent1Relationship = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty){
                                            return "Please enter Guardian Relationship";
                                          }
                                          return null;
                                        },
                                      )
                                  ): Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Container(
                                      //width: size.width*0.87,
                                      height: size.height*0.075,
                                      decoration: BoxDecoration(
                                        border:Border.all(
                                          color: Colors.lightBlueAccent.shade100,
                                        ),
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: SmartSelect<String>.single(
                                        tileBuilder: (context, state) {
                                          return S2Tile(
                                            padding: EdgeInsets.symmetric(horizontal: 12),
                                            title: state.titleWidget,
                                            value: state.valueDisplay,
                                            onTap: state.showModal,
                                            trailing: Icon(Icons.keyboard_arrow_down),
                                            leading: Icon(Icons.confirmation_number),
                                            isTwoLine: true,
                                          );
                                        },
                                        choiceStyle: S2ChoiceStyle(
                                          activeColor: Colors.lightBlue,
                                          color: Colors.black,
                                          runSpacing: 4,
                                          spacing: 12,
                                          showCheckmark: true,
                                        ),
                                        choiceType: S2ChoiceType.switches,
                                        modalHeaderStyle: S2ModalHeaderStyle(
                                          backgroundColor: Theme.of(context).backgroundColor,
                                          textStyle: TextStyle(fontSize:18,color:Colors.lightBlue),
                                        ) ,
                                        modalConfig: S2ModalConfig(
                                            filterAuto: true,
                                            barrierDismissible: false,
                                            useConfirm: true,
                                            useFilter: true,
                                            useHeader: true,
                                            confirmIcon: Icon(
                                                Icons.check_circle_outline),
                                            confirmColor: Colors.lightBlue
                                        ),
                                        modalStyle: S2ModalStyle(
                                          elevation: 20,
                                          backgroundColor: Colors.white12.withOpacity(0.8),
                                        ),
                                        modalType: S2ModalType.popupDialog,
                                        choiceDirection: Axis.vertical,
                                        placeholder: "Please select one",
                                        title: 'Guardian Relationship',
                                        value: parent1Relationship,
                                        choiceItems: nextOfKinOptions,
                                        onChange: (state) {
                                          setState(() =>
                                          parent1Relationship = state.value);
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  // Divider(
                                  //   thickness: 1,
                                  //   indent: 30,
                                  //   endIndent: 30,
                                  // ),
                                ],
                              ),
                            )
                                :!secondGuardianDetailsSubmitted ?
                            Container(
                              height: size.height*0.65,
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: <Widget> [
                                    Text("BENEFICIARIES", style:TextStyle(color: Colors.lightBlue, fontSize: 16)),
                                    Text("Second Guardian/Parent Details", style:TextStyle(color: Colors.lightBlue, fontSize: 14)),
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f1,
                                          keyboardType: TextInputType.name,
                                          controller: parent2NameHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.account_circle),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            //hintText: "What is your Employment Number?",
                                            labelText: "Full Name",
                                            //helperText: 'Edit Your Employment Number',
                                          ),
                                          onChanged: (value) {
                                            parent2Name = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please Guardian Full Name";
                                            }
                                            return null;
                                          },
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f2,
                                          keyboardType: TextInputType.number,
                                          controller: parent2IDNumberHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.perm_identity),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            //hintText: "What is your Employment Number?",
                                            labelText: "Guardian ID number",
                                            //helperText: 'Edit Your Employment Number',
                                          ),
                                          onChanged: (value) {
                                            parent2IDNumber = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please enter Guardian ID number";
                                            }
                                            return null;
                                          },
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f3,
                                          keyboardType: TextInputType.phone,
                                          controller: parent2PhoneNumberHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.hourglass_bottom),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            //hintText: "What is your Role?",
                                            labelText: "Guardian Phone NUmber",
                                            //helperText: 'Edit Your Membership number',
                                          ),
                                          onChanged: (value) {
                                            parent2PhoneNumber = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please enter Guardian Phone NUmber";
                                            }
                                            return null;
                                          },
                                        )
                                    ),
                                    otherSelected ?
                                    Padding(
                                        padding: EdgeInsets.all(12),
                                        child:
                                        TextFormField(
                                          focusNode: f4,
                                          keyboardType: TextInputType.text,
                                          controller: parent2RelationshipHolder,
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.confirmation_number),
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
                                            //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                            //hintText: "What is your National ID Number ?",
                                            labelText: "Guardian Relationship",
                                            //helperText: 'Edit Your National ID Number',
                                          ),
                                          onChanged: (value) {
                                            parent2Relationship = value;
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty){
                                              return "Please enter Guardian Relationship";
                                            }
                                            return null;
                                          },
                                        )
                                    ): Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Container(
                                        //width: size.width*0.87,
                                        height: size.height*0.075,
                                        decoration: BoxDecoration(
                                          border:Border.all(
                                            color: Colors.lightBlueAccent.shade100,
                                          ),
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: SmartSelect<String>.single(
                                          tileBuilder: (context, state) {
                                            return S2Tile(
                                              padding: EdgeInsets.symmetric(horizontal: 12),
                                              title: state.titleWidget,
                                              value: state.valueDisplay,
                                              onTap: state.showModal,
                                              trailing: Icon(Icons.keyboard_arrow_down),
                                              leading: Icon(Icons.confirmation_number),
                                              isTwoLine: true,
                                            );
                                          },
                                          choiceStyle: S2ChoiceStyle(
                                            activeColor: Colors.lightBlue,
                                            color: Colors.black,
                                            runSpacing: 4,
                                            spacing: 12,
                                            showCheckmark: true,
                                          ),
                                          choiceType: S2ChoiceType.switches,
                                          modalHeaderStyle: S2ModalHeaderStyle(
                                            backgroundColor: Theme.of(context).backgroundColor,
                                            textStyle: TextStyle(fontSize:18,color:Colors.lightBlue),
                                          ) ,
                                          modalConfig: S2ModalConfig(
                                              filterAuto: true,
                                              barrierDismissible: false,
                                              useConfirm: true,
                                              useFilter: true,
                                              useHeader: true,
                                              confirmIcon: Icon(
                                                  Icons.check_circle_outline),
                                              confirmColor: Colors.lightBlue
                                          ),
                                          modalStyle: S2ModalStyle(
                                            elevation: 20,
                                            backgroundColor: Colors.white12.withOpacity(0.8),
                                          ),
                                          modalType: S2ModalType.popupDialog,
                                          choiceDirection: Axis.vertical,
                                          placeholder: "Please select one",
                                          title: 'Guardian Relationship',
                                          value: parent2Relationship,
                                          choiceItems: nextOfKinOptions,
                                          onChange: (state) {
                                            setState(() =>
                                            parent2Relationship = state.value);
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    // Divider(
                                    //   thickness: 1,
                                    //   indent: 30,
                                    //   endIndent: 30,
                                    // ),
                                  ],
                                ),
                              ),
                            )
                                :!childDetailsSubmitted?
                            Container(
                              height: size.height*0.65,
                              child:SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: <Widget> [
                                    Text("BENEFICIARIES", style:TextStyle(color: Colors.lightBlue, fontSize: 16)),
                                    Column(
                                      children: [
                                        Text("First Child", style:TextStyle(color: Colors.lightBlue, fontSize: 14)),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child:
                                            TextFormField(
                                              focusNode: f1,
                                              keyboardType: TextInputType.name,
                                              controller: child1NameHolder,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.account_circle),
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
                                                //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                                //hintText: "What is your Employment Number?",
                                                labelText: "Full Name",
                                                //helperText: 'Edit Your Employment Number',
                                              ),
                                              onChanged: (value) {
                                                child1Name = value;
                                              },
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty){
                                              //     return "Please enter Full Name";
                                              //   }
                                              //   return null;
                                              // },
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child:
                                            TextFormField(
                                              focusNode: f2,
                                              keyboardType: TextInputType.datetime,
                                              controller: child1DateOfBirthHolder,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.perm_identity),
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
                                                //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                                //hintText: "What is your Employment Number?",
                                                labelText: "Date of Birth",
                                                //helperText: 'Edit Your Employment Number',
                                              ),
                                              onTap:() async{
                                                DateTime date = DateTime(1900);
                                                final DateFormat formatter = DateFormat('dd/MMM/yyyy');

                                                // Below line stops keyboard from appearing
                                                FocusScope.of(context).requestFocus(new FocusNode());

                                                date = await showDatePicker(
                                                    context: context,
                                                    initialDate:DateTime.now(),
                                                    firstDate:DateTime(1900),
                                                    lastDate: DateTime(2100));

                                                child1DateOfBirthHolder.text = formatter.format(date);//date.toIso8601String();

                                              },
                                              onChanged: (value) {
                                                child1DateOfBirth = value;
                                              },
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty){
                                              //     return "Please enter Date of Birth";
                                              //   }
                                              //   return null;
                                              // },
                                            )
                                        ),
                                        Text("Second Child", style:TextStyle(color: Colors.lightBlue, fontSize: 14)),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child:
                                            TextFormField(
                                              focusNode: f3,
                                              keyboardType: TextInputType.name,
                                              controller: child2NameHolder,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.account_circle),
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
                                                //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                                //hintText: "What is your Employment Number?",
                                                labelText: "Full Name",
                                                //helperText: 'Edit Your Employment Number',
                                              ),
                                              onChanged: (value) {
                                                child2Name = value;
                                              },
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty){
                                              //     return "Please enter Full Name";
                                              //   }
                                              //   return null;
                                              // },
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child:
                                            TextFormField(
                                              focusNode: f4,
                                              keyboardType: TextInputType.datetime,
                                              controller: child2DateOfBirthHolder,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.perm_identity),
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
                                                //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                                //hintText: "What is your Employment Number?",
                                                labelText: "Date of Birth",
                                                //helperText: 'Edit Your Employment Number',
                                              ),
                                              onTap:() async{
                                                DateTime date = DateTime(1900);
                                                final DateFormat formatter = DateFormat('dd/MMM/yyyy');

                                                // Below line stops keyboard from appearing
                                                FocusScope.of(context).requestFocus(new FocusNode());

                                                date = await showDatePicker(
                                                    context: context,
                                                    initialDate:DateTime.now(),
                                                    firstDate:DateTime(1900),
                                                    lastDate: DateTime(2100));

                                                child2DateOfBirthHolder.text = formatter.format(date);//date.toIso8601String();

                                              },
                                              onChanged: (value) {
                                                child2DateOfBirth = value;
                                              },
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty){
                                              //     return "Please enter Date of Birth";
                                              //   }
                                              //   return null;
                                              // },
                                            )
                                        ),
                                        Text("Third Child", style:TextStyle(color: Colors.lightBlue, fontSize: 14)),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child:
                                            TextFormField(
                                              focusNode: f5,
                                              keyboardType: TextInputType.name,
                                              controller: child3NameHolder,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.account_circle),
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
                                                //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                                //hintText: "What is your Employment Number?",
                                                labelText: "Full Name",
                                                //helperText: 'Edit Your Employment Number',
                                              ),
                                              onChanged: (value) {
                                                child3Name = value;
                                              },
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty){
                                              //     return "Please enter Full Name";
                                              //   }
                                              //   return null;
                                              // },
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child:
                                            TextFormField(
                                              focusNode: f6,
                                              keyboardType: TextInputType.datetime,
                                              controller: child3DateOfBirthHolder,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.perm_identity),
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
                                                //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                                //hintText: "What is your Employment Number?",
                                                labelText: "Date of Birth",
                                                //helperText: 'Edit Your Employment Number',
                                              ),
                                              onTap:() async{
                                                DateTime date = DateTime(1900);
                                                final DateFormat formatter = DateFormat('dd/MMM/yyyy');

                                                // Below line stops keyboard from appearing
                                                FocusScope.of(context).requestFocus(new FocusNode());

                                                date = await showDatePicker(
                                                    context: context,
                                                    initialDate:DateTime.now(),
                                                    firstDate:DateTime(1900),
                                                    lastDate: DateTime(2100));

                                                child3DateOfBirthHolder.text = formatter.format(date);//date.toIso8601String();

                                              },
                                              onChanged: (value) {
                                                child3DateOfBirth = value;
                                              },
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty){
                                              //     return "Please enter Date of Birth";
                                              //   }
                                              //   return null;
                                              // },
                                            )
                                        ),
                                        Text("Fourth Child", style:TextStyle(color: Colors.lightBlue, fontSize: 14)),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child:
                                            TextFormField(
                                              focusNode: f7,
                                              keyboardType: TextInputType.name,
                                              controller: child4NameHolder,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.account_circle),
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
                                                //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                                //hintText: "What is your Employment Number?",
                                                labelText: "Full Name",
                                                //helperText: 'Edit Your Employment Number',
                                              ),
                                              onChanged: (value) {
                                                child4Name = value;
                                              },
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty){
                                              //     return "Please enter Full Name";
                                              //   }
                                              //   return null;
                                              // },
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child:
                                            TextFormField(
                                              focusNode: f8,
                                              keyboardType: TextInputType.datetime,
                                              controller: child4DateOfBirthHolder,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.perm_identity),
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
                                                //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                                //hintText: "What is your Employment Number?",
                                                labelText: "Date of Birth",
                                                //helperText: 'Edit Your Employment Number',
                                              ),
                                              onTap:() async{
                                                DateTime date = DateTime(1900);
                                                final DateFormat formatter = DateFormat('dd/MMM/yyyy');

                                                // Below line stops keyboard from appearing
                                                FocusScope.of(context).requestFocus(new FocusNode());

                                                date = await showDatePicker(
                                                    context: context,
                                                    initialDate:DateTime.now(),
                                                    firstDate:DateTime(1900),
                                                    lastDate: DateTime(2100));

                                                child4DateOfBirthHolder.text = formatter.format(date);//date.toIso8601String();

                                              },
                                              onChanged: (value) {
                                                child4DateOfBirth = value;
                                              },
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty){
                                              //     return "Please enter Date of Birth";
                                              //   }
                                              //   return null;
                                              // },
                                            )
                                        ),
                                        Text("Fifth Child", style:TextStyle(color: Colors.lightBlue, fontSize: 14)),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child:
                                            TextFormField(
                                              focusNode: f9,
                                              keyboardType: TextInputType.name,
                                              controller: child5NameHolder,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.account_circle),
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
                                                //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                                //hintText: "What is your Employment Number?",
                                                labelText: "Full Name",
                                                //helperText: 'Edit Your Employment Number',
                                              ),
                                              onChanged: (value) {
                                                child5Name = value;
                                              },
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty){
                                              //     return "Please enter Full Name";
                                              //   }
                                              //   return null;
                                              // },
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.all(12),
                                            child:
                                            TextFormField(
                                              focusNode: f10,
                                              keyboardType: TextInputType.datetime,
                                              controller: child5DateOfBirthHolder,
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.perm_identity),
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
                                                //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                                //hintText: "What is your Employment Number?",
                                                labelText: "Date of Birth",
                                                //helperText: 'Edit Your Employment Number',
                                              ),
                                              onTap:() async{
                                                DateTime date = DateTime(1900);
                                                final DateFormat formatter = DateFormat('dd/MMM/yyyy');

                                                // Below line stops keyboard from appearing
                                                FocusScope.of(context).requestFocus(new FocusNode());

                                                date = await showDatePicker(
                                                    context: context,
                                                    initialDate:DateTime.now(),
                                                    firstDate:DateTime(1900),
                                                    lastDate: DateTime(2100));

                                                child5DateOfBirthHolder.text = formatter.format(date);//date.toIso8601String();

                                              },
                                              onChanged: (value) {
                                                child5DateOfBirth = value;
                                              },
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty){
                                              //     return "Please enter Date of Birth";
                                              //   }
                                              //   return null;
                                              // },
                                            )
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    // Divider(
                                    //   thickness: 1,
                                    //   indent: 30,
                                    //   endIndent: 30,
                                    // ),
                                  ],
                                ),
                              ),
                            )
                                :!welfareSavingsDetailsSubmitted?
                            Container(
                              height: size.height*0.65,
                              child: Column(
                                children: <Widget> [
                                  Text("WELFARE SAVINGS", style:TextStyle(color: Colors.lightBlue, fontSize: 16)),
                                  Padding(
                                      padding: EdgeInsets.all(12),
                                      child:
                                      TextFormField(
                                        focusNode: f11,
                                        keyboardType: TextInputType.number,
                                        controller: monthlySavingsHolder,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.savings),
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
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          //hintText: "What is your Employment Number?",
                                          labelText: "Welfare Savings Monthly Contribution",
                                          //helperText: 'Edit Your Employment Number',
                                        ),
                                        onChanged: (value) {
                                          monthlySavings = int.parse(value);
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty){
                                            return "Please enter Welfare Savings Monthly Contribution";
                                          }
                                          return null;
                                        },
                                      )
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(12),
                                      child:
                                      TextFormField(
                                        focusNode: f12,
                                        keyboardType: TextInputType.datetime,
                                        controller: savingsStartDateHolder,
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.date_range),
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
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          //hintText: "What is your Employment Number?",
                                          labelText: "Savings start date",
                                          //helperText: 'Edit Your Employment Number',
                                        ),
                                        onTap:() async{
                                          DateTime date = DateTime(1900);
                                          final DateFormat formatter = DateFormat('dd/MMM/yyyy');

                                          // Below line stops keyboard from appearing
                                          FocusScope.of(context).requestFocus(new FocusNode());

                                          date = await showDatePicker(
                                              context: context,
                                              initialDate:DateTime.now(),
                                              firstDate:DateTime(1900),
                                              lastDate: DateTime(2100));

                                          savingsStartDateHolder.text = formatter.format(date);//date.toIso8601String();
                                          monthlySavingsHolder.text = currencyFormat.format(monthlySavings) ;
                                        },
                                        onChanged: (value) {
                                          savingsStartDate = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty){
                                            return "Please enter Savings start date";
                                          }
                                          return null;
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10,),
                                  // Divider(
                                  //   thickness: 1,
                                  //   indent: 30,
                                  //   endIndent: 30,
                                  // ),
                                ],
                              ),
                            )
                                :SizedBox()
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
    // Center(child: CircularProgressIndicator(
    //   backgroundColor: Colors.lightBlueAccent,
    // ));
  }
}
