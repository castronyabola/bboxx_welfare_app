//import 'dart:async';
import 'package:bboxx_welfare_app/models/Account.dart';
import 'package:bboxx_welfare_app/screens/guarantorApprovals.dart';
import 'package:bboxx_welfare_app/screens/guarantors.dart';
import 'package:bboxx_welfare_app/screens/notificationPage.dart';
import 'package:bboxx_welfare_app/screens/settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';

class HomePage extends StatefulWidget {

  const HomePage({
    Key key,
  }) : super(key: key);

  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final String baseUrl = 'https://gvlb1ub624.execute-api.us-east-1.amazonaws.com/prod/sqs';
  final String authToken = 'RLFbz206A47vzWYltVvMR1chg4texn5U8OKvVW7z';
  final secretKey = 'Snyaca7590231234';
  String ipAddress = 'Loading...';

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    getInitialData()
        .then((value) => createAccount()
        .then((value) => getData()
        .then((value) => load())));

    _initPackageInfo();
    sendLog('logs', 'Home Screen Launched');
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
  Future<void> load() async {
    //Request permission from user.
    if (Platform.isIOS) {
      _fcm.requestPermission();
    }

    //Fetch the fcm token for this device.
    String token = await _fcm.getToken();

    //Validate that it's not null.
    assert(token != null);

    await FirebaseFirestore.instance
        .collection("welfareUsers")
        .doc(phoneNumber)
        .update({'guarantorToken': token});
  }

  var currencyFormat = new NumberFormat.currency(locale: "en_US",
      symbol: "KES ", decimalDigits: 0);

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('EEEE, dd MMMM yyyy hh:mm a');
  final DateFormat twentyFourHourFormatter = DateFormat('HH');



  final user = FirebaseAuth.instance.currentUser;
  var time = const Duration(seconds: 10);
  bool controller = false;
  bool welfareCreateCheck;
  int acceptedGuarantorCounter = 0;
  bool checkExistence;
  String myAccountID = '';
  double myLoan = 0;
  String myName = '';
  String guarantee = '';
  double mySavings = 0;
  String savingsStartDate = '';
  double loanInterest = 0.0;
  double loanPaid = 0;
  double loanDue = 0;
  double monthlySavings = 0;
  String loanDueDate;
  int notificationCount = 0;
  String membershipNumber;
  String employmentNumber;
  String phoneNumber;
  String guarantorToken;

  List _accountDetails = [];

  Future<void> updateData() async{
    controller = false;
    if (!mounted || controller == true ) return;
      for ( int i = 0; i < _accountDetails.length; i++ ) {
        if(_accountDetails[i]['phoneNumber'] != phoneNumber && _accountDetails[i]['phoneNumber'] != null && _accountDetails[i]['myName'] != null ) {
           FirebaseFirestore.instance
              .collection("welfareUsers")
              .doc('${phoneNumber} to ${_accountDetails[i]['phoneNumber']} guarantorRequest')
              .set({
            'guarantee': myName,
            'guarantor': '${_accountDetails[i]['myName']}',
            'guarantorBalance': _accountDetails[i]['guarantorBalance'],
            'acceptedGuarantorCounter': acceptedGuarantorCounter,
            'guarantorToken': _accountDetails[i]['guarantorToken'],
            'guaranteephoneNumber': phoneNumber,
            'guarantorphoneNumber': _accountDetails[i]['phoneNumber'],
            'guaranteeToken': guarantorToken,
            'phoneNumber': _accountDetails[i]['phoneNumber']},
              SetOptions(merge: true)
          );
        }
      }

        checkExistence == true?
        FirebaseFirestore.instance
            .collection("welfareUsers")
            .doc(phoneNumber)
            .update({'guarantorBalance': mySavings - loanDue~/3}):null;

        FirebaseFirestore.instance
            .collection("welfareUsers")
            .doc(phoneNumber)
            .update({'loanDue': myLoan - loanPaid});
  }
  Future <void> createAccount()async{
    if (welfareCreateCheck == false){
      if (!mounted) return;
      setState(() {
        FirebaseFirestore.instance
            .collection("welfareUsers")
            .doc(phoneNumber)
            .update({
          'loanDue': 0,
          'acceptedGuarantorCounter': 0,
          'guarantorToken': '',
          'guarantorBalance': 0,
          'loanDisbursementMethod': '',
          'reasonForLoan': '',
          'loanPaid': 0,
          'loanInterest': 0.1,
          'loanPeriod': 0,
          'loanRequested': 0,
          'loanGranted': 0,
          'loanGrantedDate': '1900-01-01',
          'loanInstallments': 0.1,
          'loanDueDate': '',
          'myLoan': 0,
          'mySavings': 0,
          'selectedGuarantorCounter': 0,
          'dateApproved': '',
          'welfareCreateCheck': true,
        });
      });

    }
  }
  Future <void> getInitialData() async {
    await FirebaseFirestore.instance.collection("phoneNumbers").doc(
        user.email).get().then((value) {
      if (!mounted) return;
      setState(() {
        phoneNumber = value['phoneNumber'];
      });
    });
    await FirebaseFirestore.instance.collection("welfareUsers").doc(phoneNumber).get().then((value){
      if (!mounted ) return;
      setState(() {
            welfareCreateCheck = value['welfareCreateCheck'];
      });
    });
  }
  Future <void> getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("welfareUsers")
        .get();

      _accountDetails = querySnapshot.docs.map((doc) => doc.data()).toList();


     await FirebaseFirestore.instance.collection("welfareUsers").doc(phoneNumber).get().then((value){
       if (!mounted ) return;
       setState(() {
        //_accountDetails.clear();
            mySavings = value["mySavings"].toDouble();
            myLoan = value["myLoan"].toDouble();
            loanDue = value["loanDue"].toDouble();
            loanPaid = value["loanPaid"].toDouble();
            loanInterest = value["loanInterest"].toDouble();
            loanDueDate = value["loanDueDate"];
            savingsStartDate = value["savingsStartDate"];
            monthlySavings = value["monthlySavings"].toDouble();
            myName = value["myName"];
            welfareCreateCheck = value["welfareCreateCheck"];
            membershipNumber = value["membershipNumber"];
            employmentNumber = value["employmentNumber"];
            guarantorToken = value["guarantorToken"];

          //_accountDetails.add();
          checkExistence = myName.isEmpty;//_accountDetails.where((element) => element.guarantee == myName).isEmpty;

          acceptedGuarantorCounter = _accountDetails
              .where((element) =>
          element["guaranteeStatus"] == 'accepted' &&
              element["guarantee"] == myName)
              .length;

          notificationCount = _accountDetails.where((element) =>
              element["guarantee"] == myName &&
              element["guaranteeStatus"] != 'awaiting response' &&
              element["guaranteeStatus"] != null &&
              element["notificationRead"] != true)
              .length;
      });
    }).then((value) => updateData());
     FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
       // Handle navigation or perform any logic here
       if(remoteMessage.notification.title  == 'Loan Guarantor Request'
           || remoteMessage.notification.title  == 'Loan Guarantor Request Withdrawal') {
         Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => GuarantorApprovals())
         );
       }
       else if(remoteMessage.notification.title  == 'Loan Guarantor Request withdrawn'
           || remoteMessage.notification.title  == 'Loan Guarantor Request Rejected'
           || remoteMessage.notification.title  == 'Loan Guarantor Request Approved') {
         Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => Guarantors())
         );
       }
     });

  }

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
                onPressed: () {
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
  Widget build (BuildContext context) {
    var formatted = formatter.format(now);

    final Size size = MediaQuery
        .of(context)
        .size;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        drawer: Container(
          width: size.width*0.85,
            child: SettingsPage()),
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(100),
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.lightBlue),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 3,
          title: Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 25),
              Text("My Loans & Savings", style:TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 16)),
              SizedBox(width: 35),
              ElevatedButton(
                onPressed: ()
                {
                  controller = false;
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationPage())
                  );
                },
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(1),
                    //shadowColor: MaterialStateProperty.all(Theme.of(context).cardColor),
                    backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor,),
                    shape: MaterialStateProperty.all<CircleBorder>(
                        CircleBorder(
                         // borderRadius: BorderRadius.circular(100.0),
                        )
                    )
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_rounded,
                      size: 25,
                      color: Colors.lightBlue,
                    ),
                    Text(
                      '$notificationCount',style:TextStyle(height:-0.1,color:Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
          toolbarHeight: 50,
        ),
        body: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
          //       child: Column(
          //         children: [
          //         Padding(
          //         padding: const EdgeInsets.all(10.0),
          //         child: Text("$formatted", style:TextStyle(fontWeight:FontWeight.w600,color: Colors.grey, fontSize: 12)),
          //       ),
          //           SizedBox(height: 20,),
          //           Initicon(
          //             elevation: 5,
          //             color: Colors.lightBlue,
          //             backgroundColor: Colors.lightBlueAccent.shade100,
          //             text: myName,
          //             size: 50,
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(10.0),
          //             child: int.parse(twentyFourHourFormatter.format(DateTime.now())) < 12 ?
          //             Text("Good Morning ${myName}\n"
          //                 "${membershipNumber}",
          //                 textAlign:TextAlign.center,style:TextStyle(color: Colors.lightBlue, fontSize: 14)):
          //             int.parse(twentyFourHourFormatter.format(DateTime.now())) >= 12 && int.parse(twentyFourHourFormatter.format(DateTime.now())) < 18 ?
          //                 Text("Good Afternoon ${myName}\n"
          //                 "${membershipNumber}",
          //                 textAlign:TextAlign.center,style:TextStyle(color: Colors.lightBlue, fontSize: 14))
          //             :Text("Good Evening ${myName}\n"
          //                 "${membershipNumber}",
          //                 textAlign:TextAlign.center,style:TextStyle(color: Colors.lightBlue, fontSize: 14))
          //             ,
          //           ),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30),
          //         child: Container(
          //           width: size.width,
          //           height: size.height * 0.45,
          //           decoration: BoxDecoration(
          //             color: Theme.of(context).cardColor,
          //             borderRadius: BorderRadius.circular(5),
          //             boxShadow: const [
          //               BoxShadow(
          //                 color: Colors.black12,
          //                 spreadRadius: 1,
          //                 blurRadius: 2,
          //                 offset: Offset(0, 1), // changes position of shadow
          //               ),
          //             ],
          //           ),
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             Padding(
          //               padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
          //               child: Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: [
          //                   Text('TOTAL SAVINGS', style: TextStyle(fontWeight:FontWeight.w800,color:Colors.lightBlue)),
          //                   Text('${currencyFormat.format(mySavings)}', style: TextStyle(fontWeight:FontWeight.w800,color:Colors.lightBlue))
          //                 ]
          //               ),
          //             ),
          //             Divider(
          //               indent:10 ,
          //               endIndent:10,
          //               thickness: 1,
          //             ),
          //             Padding(
          //               padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
          //               child: Container(
          //                 width: size.width,
          //                 height: size.height * 0.3,
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     Container(
          //                       width: size.width*0.42,
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           Text('LOAN', style: TextStyle(color:Colors.lightBlue)),
          //                           SizedBox(height: 20,),
          //                           Container(
          //                             width: size.width * 0.4,
          //                             child: Row(
          //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                               children: [
          //                                 Text('Loan:'),
          //                                 acceptedGuarantorCounter == 3 || myLoan <= mySavings ?
          //                                 Text('${currencyFormat.format(myLoan)}', style: TextStyle(fontWeight:FontWeight.w600)):
          //                                 Text('NA', style: TextStyle(fontWeight:FontWeight.w600)),
          //                               ],
          //                             ),
          //                           ),
          //                           SizedBox(height: 20,),
          //                           Container(
          //                             width: size.width * 0.4,
          //                             child: Row(
          //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                               children: [
          //                                 Text('Interest:'),
          //                                 acceptedGuarantorCounter == 3 || myLoan <= mySavings?
          //                                 Text('${loanInterest * 100} %', style: TextStyle(fontWeight:FontWeight.w600)):
          //                                 Text('NA', style: TextStyle(fontWeight:FontWeight.w600)),
          //                               ],
          //                             ),
          //                           ),
          //                           SizedBox(height: 20,),
          //                           Container(
          //                             width: size.width * 0.4,
          //                             child: Row(
          //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                               children: [
          //                                 Text('Balance:'),
          //                                 acceptedGuarantorCounter == 3 || myLoan <= mySavings?
          //                                 Text('${currencyFormat.format(loanDue)}', style: TextStyle(fontWeight:FontWeight.w600)):
          //                                 Text('NA', style: TextStyle(fontWeight:FontWeight.w600)),
          //                               ],
          //                             ),
          //                           ),
          //                           SizedBox(height: 20,),
          //                           Container(
          //                             width: size.width * 0.4,
          //                             child: Row(
          //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                               children: [
          //                                 Text('Paid:'),
          //                                 acceptedGuarantorCounter == 3 || myLoan <= mySavings?
          //                                 Text('${currencyFormat.format(loanPaid)}', style: TextStyle(fontWeight:FontWeight.w600)):
          //                                 Text('NA', style: TextStyle(fontWeight:FontWeight.w600)),
          //                               ],
          //                             ),
          //                           ),
          //                           SizedBox(height: 20,),
          //                           Container(
          //                             width: size.width * 0.4,
          //                             child: Row(
          //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                               children: [
          //                                 Text('Due\nDate:'),
          //                                 acceptedGuarantorCounter == 3 || myLoan <= mySavings?
          //                                 Text("${loanDueDate}", style: TextStyle(fontWeight: FontWeight.w600)):
          //                                 Text('NA', style: TextStyle(fontWeight:FontWeight.w600)),
          //                               ],
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                     VerticalDivider(
          //                       indent:1 ,
          //                       endIndent:1,
          //                       thickness: 1,),
          //                     Padding(
          //                       padding: const EdgeInsets.only(left:5.0),
          //                       child: Container(
          //                         width: size.width*0.4,
          //                         child: Column(
          //                           crossAxisAlignment: CrossAxisAlignment.start,
          //                           children: [
          //                             Text('MY SAVINGS', style: TextStyle(color:Colors.lightBlue)),
          //                             SizedBox(height: 20,),
          //                             Container(
          //                               width: size.width * 0.4,
          //                               child: Row(
          //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                                 children: [
          //                                   Text('Savings:'),
          //                                   Text('${currencyFormat.format(mySavings)}', style: TextStyle(fontWeight:FontWeight.w600)),
          //                                 ],
          //                               ),
          //                             ),
          //                             SizedBox(height: 20,),
          //                             Container(
          //                               width: size.width * 0.4,
          //                               child: Row(
          //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                                 children: [
          //                                   Text('Deductions:'),
          //                                   Text('${currencyFormat.format(monthlySavings)}', style: TextStyle(fontWeight:FontWeight.w600)),
          //                                 ],
          //                               ),
          //                             ),
          //                             SizedBox(height: 20,),
          //                             Container(
          //                               width: size.width * 0.4,
          //                               child: Row(
          //                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                                 children: [
          //                                   Text('Start Date:'),
          //                                   Text('$savingsStartDate', style: TextStyle(fontWeight:FontWeight.w600)
          //                                   ),
          //                                 ],
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     )
          //                   ],
          //                 ),
          //               ),
          //             ),
          //            ],
          //           ),
          //         ),
          //       ),
          //       // Padding(
          //       //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
          //       //   child: Column(
          //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       //     children: [
          //       //       ElevatedButton(
          //       //           onPressed: ()
          //       //           {
          //       //             controller = false;
          //       //             Navigator.push(
          //       //                 context,
          //       //                 MaterialPageRoute(builder: (context) => LoanPage())
          //       //             );
          //       //           },
          //       //         style: ButtonStyle(
          //       //             backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor,),
          //       //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //       //                 RoundedRectangleBorder(
          //       //                   borderRadius: BorderRadius.circular(18.0),
          //       //                 )
          //       //             )
          //       //         ),
          //       //           child: Row(
          //       //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       //             children: [
          //       //               Row(
          //       //                 children: [
          //       //                   Icon(
          //       //                     Icons.account_balance_wallet,
          //       //                     size: 20,
          //       //                     color: Colors.lightBlue,
          //       //                   ),
          //       //                   SizedBox(width: 10,),
          //       //                   Text(
          //       //                     'Loan',style: TextStyle(color:Colors.lightBlue),
          //       //                   ),
          //       //                 ],
          //       //               ),
          //       //               Icon(
          //       //                 Icons.chevron_right,
          //       //                 size: 20,
          //       //                 color: Colors.lightBlue,
          //       //               ),
          //       //             ],
          //       //           ),
          //       //       ),
          //       //       ElevatedButton(
          //       //         onPressed: ()
          //       //         {
          //       //           controller = false;
          //       //           Navigator.push(
          //       //               context,
          //       //               MaterialPageRoute(builder: (context) => GuarantorApprovals())
          //       //           );
          //       //         },
          //       //         style: ButtonStyle(
          //       //             //elevation: MaterialStateProperty.all(0),
          //       //             //shadowColor: MaterialStateProperty.all(Theme.of(context).cardColor),
          //       //             backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor,),
          //       //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //       //                 RoundedRectangleBorder(
          //       //                   borderRadius: BorderRadius.circular(18.0),
          //       //                 )
          //       //             )
          //       //         ),
          //       //         child: Row(
          //       //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       //           children: [
          //       //             Row(
          //       //               children: [
          //       //                 Icon(
          //       //                   Icons.account_balance,
          //       //                   size: 20,
          //       //                   color: Colors.lightBlue,
          //       //                 ),
          //       //                 SizedBox(width: 10,),
          //       //                 Text(
          //       //                   'Guarantor Approvals',style: TextStyle(color:Colors.lightBlue),
          //       //                 ),
          //       //               ],
          //       //             ),
          //       //             Icon(
          //       //               Icons.chevron_right,
          //       //               size: 20,
          //       //               color: Colors.lightBlue,
          //       //             ),
          //       //           ],
          //       //         ),
          //       //       ),
          //       //     ],
          //       //   ),
          //       // )
          //     ],
          // ),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('welfareUsers').doc(phoneNumber).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                     if(!snapshot.hasData){
                       return Center(
                         heightFactor: size.height * 0.025,
                           child: CircularProgressIndicator(
                             backgroundColor: Colors.lightBlueAccent,
                           )
                       );
                     }
                     return snapshot.data.exists?
                     Column(
                       children: [
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: Text("$formatted", style:TextStyle(fontWeight:FontWeight.w600,color: Colors.grey, fontSize: 12)),
                         ),
                         SizedBox(height: 20,),
                         Initicon(
                           elevation: 5,
                           color: Colors.lightBlue,
                           backgroundColor: Colors.lightBlueAccent.shade100,
                           text: snapshot.data['myName'],
                           size: 50,
                         ),
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: int.parse(twentyFourHourFormatter.format(DateTime.now())) < 12 ?
                           Text("Good Morning ${snapshot.data['myName']}\n"
                               "${snapshot.data['membershipNumber']}",
                               textAlign:TextAlign.center,style:TextStyle(color: Colors.lightBlue, fontSize: 14)):
                           int.parse(twentyFourHourFormatter.format(DateTime.now())) >= 12 && int.parse(twentyFourHourFormatter.format(DateTime.now())) < 18 ?
                           Text("Good Afternoon ${snapshot.data['myName']}\n"
                               "${snapshot.data['membershipNumber']}",
                               textAlign:TextAlign.center,style:TextStyle(color: Colors.lightBlue, fontSize: 14))
                               :Text("Good Evening ${snapshot.data['myName']}\n"
                               "${snapshot.data['membershipNumber']}",
                               textAlign:TextAlign.center,style:TextStyle(color: Colors.lightBlue, fontSize: 14))
                           ,
                         ),
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30),
                           child: Container(
                             width: size.width,
                             height: size.height * 0.45,
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
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Padding(
                                   padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
                                   child: Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Text('TOTAL SAVINGS', style: TextStyle(fontWeight:FontWeight.w800,color:Colors.lightBlue)),
                                         Text('${currencyFormat.format(snapshot.data['mySavings'])}', style: TextStyle(fontWeight:FontWeight.w800,color:Colors.lightBlue))
                                       ]
                                   ),
                                 ),
                                 Divider(
                                   indent:10 ,
                                   endIndent:10,
                                   thickness: 1,
                                 ),
                                 Padding(
                                   padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
                                   child: Container(
                                     width: size.width,
                                     height: size.height * 0.3,
                                     child: Row(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                         Container(
                                           width: size.width*0.42,
                                           child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               Text('LOAN', style: TextStyle(color:Colors.lightBlue)),
                                               SizedBox(height: 20,),
                                               Container(
                                                 width: size.width * 0.4,
                                                 child: Row(
                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                   children: [
                                                     Text('Loan:'),
                                                     acceptedGuarantorCounter == 3 || snapshot.data['myLoan'] <= snapshot.data['mySavings'] ?
                                                     Text('${currencyFormat.format(snapshot.data['myLoan'])}', style: TextStyle(fontWeight:FontWeight.w600)):
                                                     Text('NA', style: TextStyle(fontWeight:FontWeight.w600)),
                                                   ],
                                                 ),
                                               ),
                                               SizedBox(height: 20,),
                                               Container(
                                                 width: size.width * 0.4,
                                                 child: Row(
                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                   children: [
                                                     Text('Interest:'),
                                                     acceptedGuarantorCounter == 3 || snapshot.data['myLoan'] <= snapshot.data['mySavings']?
                                                     Text('${snapshot.data['loanInterest'] * 100} %', style: TextStyle(fontWeight:FontWeight.w600)):
                                                     Text('NA', style: TextStyle(fontWeight:FontWeight.w600)),
                                                   ],
                                                 ),
                                               ),
                                               SizedBox(height: 20,),
                                               Container(
                                                 width: size.width * 0.4,
                                                 child: Row(
                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                   children: [
                                                     Text('Balance:'),
                                                     acceptedGuarantorCounter == 3 || snapshot.data['myLoan'] <= snapshot.data['mySavings']?
                                                     Text('${currencyFormat.format(snapshot.data['loanDue'])}', style: TextStyle(fontWeight:FontWeight.w600)):
                                                     Text('NA', style: TextStyle(fontWeight:FontWeight.w600)),
                                                   ],
                                                 ),
                                               ),
                                               SizedBox(height: 20,),
                                               Container(
                                                 width: size.width * 0.4,
                                                 child: Row(
                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                   children: [
                                                     Text('Paid:'),
                                                     acceptedGuarantorCounter == 3 || snapshot.data['myLoan'] <= snapshot.data['mySavings']?
                                                     Text('${currencyFormat.format(snapshot.data['loanPaid'])}', style: TextStyle(fontWeight:FontWeight.w600)):
                                                     Text('NA', style: TextStyle(fontWeight:FontWeight.w600)),
                                                   ],
                                                 ),
                                               ),
                                               SizedBox(height: 20,),
                                               Container(
                                                 width: size.width * 0.4,
                                                 child: Row(
                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                   children: [
                                                     Text('Due\nDate:'),
                                                     acceptedGuarantorCounter == 3 || snapshot.data['myLoan'] <= snapshot.data['mySavings']?
                                                     Text("${snapshot.data['loanDueDate']}", style: TextStyle(fontWeight: FontWeight.w600)):
                                                     Text('NA', style: TextStyle(fontWeight:FontWeight.w600)),
                                                   ],
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ),
                                         VerticalDivider(
                                           indent:1 ,
                                           endIndent:1,
                                           thickness: 1,),
                                         Padding(
                                           padding: const EdgeInsets.only(left:5.0),
                                           child: Container(
                                             width: size.width*0.4,
                                             child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                 Text('MY SAVINGS', style: TextStyle(color:Colors.lightBlue)),
                                                 SizedBox(height: 20,),
                                                 Container(
                                                   width: size.width * 0.4,
                                                   child: Row(
                                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                     children: [
                                                       Text('Savings:'),
                                                       Text('${currencyFormat.format(snapshot.data['mySavings'])}', style: TextStyle(fontWeight:FontWeight.w600)),
                                                     ],
                                                   ),
                                                 ),
                                                 SizedBox(height: 20,),
                                                 Container(
                                                   width: size.width * 0.4,
                                                   child: Row(
                                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                     children: [
                                                       Text('Deductions:'),
                                                       Text('${currencyFormat.format(snapshot.data['monthlySavings'])}', style: TextStyle(fontWeight:FontWeight.w600)),
                                                     ],
                                                   ),
                                                 ),
                                                 SizedBox(height: 20,),
                                                 Container(
                                                   width: size.width * 0.4,
                                                   child: Row(
                                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                     children: [
                                                       Text('Start Date:'),
                                                       Text('${snapshot.data['savingsStartDate']}', style: TextStyle(fontWeight:FontWeight.w600)
                                                       ),
                                                     ],
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ),
                                         )
                                       ],
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ),
                         // Padding(
                         //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                         //   child: Column(
                         //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         //     children: [
                         //       ElevatedButton(
                         //           onPressed: ()
                         //           {
                         //             controller = false;
                         //             Navigator.push(
                         //                 context,
                         //                 MaterialPageRoute(builder: (context) => LoanPage())
                         //             );
                         //           },
                         //         style: ButtonStyle(
                         //             backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor,),
                         //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                         //                 RoundedRectangleBorder(
                         //                   borderRadius: BorderRadius.circular(18.0),
                         //                 )
                         //             )
                         //         ),
                         //           child: Row(
                         //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         //             children: [
                         //               Row(
                         //                 children: [
                         //                   Icon(
                         //                     Icons.account_balance_wallet,
                         //                     size: 20,
                         //                     color: Colors.lightBlue,
                         //                   ),
                         //                   SizedBox(width: 10,),
                         //                   Text(
                         //                     'Loan',style: TextStyle(color:Colors.lightBlue),
                         //                   ),
                         //                 ],
                         //               ),
                         //               Icon(
                         //                 Icons.chevron_right,
                         //                 size: 20,
                         //                 color: Colors.lightBlue,
                         //               ),
                         //             ],
                         //           ),
                         //       ),
                         //       ElevatedButton(
                         //         onPressed: ()
                         //         {
                         //           controller = false;
                         //           Navigator.push(
                         //               context,
                         //               MaterialPageRoute(builder: (context) => GuarantorApprovals())
                         //           );
                         //         },
                         //         style: ButtonStyle(
                         //             //elevation: MaterialStateProperty.all(0),
                         //             //shadowColor: MaterialStateProperty.all(Theme.of(context).cardColor),
                         //             backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).cardColor,),
                         //             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                         //                 RoundedRectangleBorder(
                         //                   borderRadius: BorderRadius.circular(18.0),
                         //                 )
                         //             )
                         //         ),
                         //         child: Row(
                         //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         //           children: [
                         //             Row(
                         //               children: [
                         //                 Icon(
                         //                   Icons.account_balance,
                         //                   size: 20,
                         //                   color: Colors.lightBlue,
                         //                 ),
                         //                 SizedBox(width: 10,),
                         //                 Text(
                         //                   'Guarantor Approvals',style: TextStyle(color:Colors.lightBlue),
                         //                 ),
                         //               ],
                         //             ),
                         //             Icon(
                         //               Icons.chevron_right,
                         //               size: 20,
                         //               color: Colors.lightBlue,
                         //             ),
                         //           ],
                         //         ),
                         //       ),
                         //     ],
                         //   ),
                         // )
                       ],
                     ):
                     Center(
                         heightFactor: size.height * 0.025,
                         child: CircularProgressIndicator(
                           backgroundColor: Colors.lightBlueAccent,
                         )
                     );
                },
              ),
        ),
      ),
    );
  }
}

