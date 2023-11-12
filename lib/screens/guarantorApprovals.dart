import 'dart:async';

import 'package:bboxx_welfare_app/models/Account.dart';
import 'package:bboxx_welfare_app/models/fcm_notification_service.dart';
import 'package:bboxx_welfare_app/models/navigation.dart';
import 'package:bboxx_welfare_app/models/notifications.dart';
import 'package:bboxx_welfare_app/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';

class GuarantorApprovals extends StatefulWidget {

  @override
  State<GuarantorApprovals> createState() => _GuarantorApprovalsState();

}

class _GuarantorApprovalsState extends State<GuarantorApprovals> {
  final String baseUrl = 'https://gvlb1ub624.execute-api.us-east-1.amazonaws.com/prod/sqs';
  final String authToken = 'RLFbz206A47vzWYltVvMR1chg4texn5U8OKvVW7z';
  final secretKey = 'Snyaca7590231234';
  String ipAddress = 'Loading...';

  String phoneNumber;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FCMNotificationService _fcmNotificationService =
  FCMNotificationService();

  var currencyFormat = new NumberFormat.currency(locale: "en_US",
      symbol: "KES ", decimalDigits: 0);

  var now = DateTime.now();
  final DateFormat formatter = DateFormat('EEEE, dd MMMM yyyy hh:mm a');
  var time = const Duration(seconds: 10);

  bool controller = false;
  List _accountDetails = [];
  int myApprovedGuarantorCounter = 0;
  int acceptedGuarantorCounter = 0;
  int guarantorBalance = 0;
  String myName = '';
  int loanRequested = 0;
  int mySavings;
  String guarantor;
  String guarantee;
  String guaranteeStatus = '';
  final user = FirebaseAuth.instance.currentUser;

  List filteredAccountDetails = [];

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    getGuarantorData();
    Notifications.init();
    //Subscribe to the NEWS topic.
    _fcmNotificationService.subscribeToTopic(topic: 'NEWS');

    load();
    _initPackageInfo();
    sendLog('logs', 'Approvals Screen Launched');
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

  }

  Future <void> subtractGuarantorBalance() async{
      for ( int i = 0; i < filteredAccountDetails.length; i++ ) {
        await FirebaseFirestore.instance
            .collection("welfareUsers")
            .doc('${filteredAccountDetails[i]['guaranteephoneNumber']} to ${phoneNumber} guarantorRequest')
            .update({
          'guarantorBalance':(filteredAccountDetails[i]['guarantorBalance'] - (loanRequested/3)).toInt()})
            .then((value) => getGuarantorData());
    }
  }

  Future <void> addGuarantorBalance() async{
    for ( int i = 0; i < filteredAccountDetails.length; i++ ) {
      await FirebaseFirestore.instance
          .collection("welfareUsers")
          .doc('${filteredAccountDetails[i]['guaranteephoneNumber']} to ${phoneNumber} guarantorRequest')
          .update({
        'guarantorBalance':(filteredAccountDetails[i]['guarantorBalance'] + (loanRequested/3)).toInt()})
          .then((value) => getGuarantorData());
    }
  }

  Future <void> getGuarantorData() async {
    await FirebaseFirestore.instance.collection("phoneNumbers").doc(
        user.email).get().then((value) {
      if (!mounted) return;
      setState(() {
        phoneNumber = value['phoneNumber'];
      });
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("welfareUsers")
        .get();

    setState(() {
      _accountDetails = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
    controller = true;
    await FirebaseFirestore.instance.collection("welfareUsers").doc(phoneNumber).get().then((value){
      if (!mounted || controller == false) return;
      setState(() {

          myName = value["myName"];

          filteredAccountDetails = _accountDetails.where((element) => element['guarantor'] == myName && element['loanRequested'] != null && element['guaranteeStatus'] != null && element.containsKey('guaranteeStatus') && element.containsKey('loanRequested')).toList();

          myApprovedGuarantorCounter = filteredAccountDetails.where((element) =>
              element['guaranteeStatus'] == 'accepted' &&
              element.containsKey('guaranteeStatus') &&
              element.containsKey('loanRequested') &&
              element['loanRequested'] != null
          ).length;

      });
    });
    controller = false;
  }

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery
        .of(context)
        .size;

    return WillPopScope(
      onWillPop: () async => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => navigation())
      ),
      child: Scaffold(
        appBar: AppBar(shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(100),
          ),
        ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: ()
            {
              controller = false;
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => navigation())
              );
            },
          ),
         // automaticallyImplyLeading: true,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.lightBlue),
          backgroundColor: Theme
              .of(context)
              .cardColor,
          elevation: 3,
          title: Text('Guarantor Approvals', style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.lightBlue,
              fontSize: 16)),
          toolbarHeight: 50,
        ),
        body: _accountDetails.isEmpty ?
        Center(child: CircularProgressIndicator(
          backgroundColor: Colors.lightBlueAccent,
        ))
            :filteredAccountDetails.isEmpty ?
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: RefreshIndicator(
              onRefresh: getGuarantorData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 70),
                    child: Text('You have no approvals to make at this time. Pull down to reload.',
                      textAlign: TextAlign.center,),
                  ),
                ),
              ),
            ),
          ),
        ):
        RefreshIndicator(
          onRefresh: getGuarantorData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30 ),
                  child: Text('Please guarantee the loan requests below:'),
                ),
                //SizedBox(height: size.height * 0.1),
                Container(
                  height: size.height * 0.7,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('welfareUsers')
                        .where('guarantor', isEqualTo: myName)
                        .snapshots(),

                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if(!snapshot.hasData){
                        return Center(
                            heightFactor: size.height * 0.025,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.lightBlueAccent,
                            )
                        );
                      }
                      myApprovedGuarantorCounter = snapshot.data.docs
                      .where((element) {
                        Map<String, dynamic> data = element.data();
                        return
                              data.containsKey('loanRequested') &&
                              data.containsKey('guaranteeStatus') &&
                              data['guaranteeStatus'] == 'accepted' &&
                              data['loanRequested'] != null;
                      }).length;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20 ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Guarantor requests you have approved: ',),
                                Text('${myApprovedGuarantorCounter}', style: TextStyle()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                                children: snapshot.data.docs.where((element) {
                                  Map<String, dynamic> data = element.data();
                                  return
                                      data.containsKey('loanRequested') &&
                                      data.containsKey('guaranteeStatus') &&
                                      data['guaranteeStatus'] != null &&
                                      data['loanRequested'] != null;
                                }).map((document){
                                  Future showMyDialog() async{
                                    return showDialog<void>(
                                      context: context,
                                      barrierDismissible: false, // user must tap button!
                                      builder: (BuildContext context) {

                                        return AlertDialog(
                                          backgroundColor: Colors.lightBlue,
                                          title: document['guaranteeStatus'] == null ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Confirmation',style: TextStyle(color:Colors.white))
                                            ],
                                          )
                                              :Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Information',style: TextStyle(color:Colors.white)),
                                            ],
                                          ),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children:  <Widget>[
                                                document['guaranteeStatus'] == 'awaiting response' ? Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Flexible(
                                                      child: Text('Do you accept to be the guarantor for ${document['guarantee']} ?',
                                                          textAlign: TextAlign.center ,style: TextStyle(color:Colors.white)),
                                                    )
                                                  ],
                                                )
                                                    :Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    document['guaranteeStatus'] == 'accepted' ?
                                                    Flexible(
                                                      child: Text('''You have accepted to be the guarantor for ${document['guarantee']}. Withdraw response ?''',
                                                          textAlign: TextAlign.center ,style: TextStyle(color:Colors.white)),
                                                    )
                                                        :Flexible(
                                                      child: Text('''You have rejected to be the guarantor for ${document['guarantee']}. Withdraw response ?''',
                                                          textAlign: TextAlign.center ,style: TextStyle(color:Colors.white)),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            document['guaranteeStatus'] == 'awaiting response' ? Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  child: Text('Approve',style: TextStyle(color:Colors.white)),
                                                  onPressed: () async{
                                                    sendLog('logs','Guarantor Request for loan of ${currencyFormat.format(double.parse(document['loanRequested']))} from ${document['guarantee']} Approved by ${myName}');
                                                    await Navigator.pop(context);
                                                    loanRequested = document['loanRequested'];
                                                    await FirebaseFirestore.instance
                                                        .collection("welfareUsers")
                                                        .doc('${document['guaranteephoneNumber']} to ${phoneNumber} guarantorRequest')
                                                        .update({
                                                      'guaranteeStatus':'accepted',
                                                      'dateApproved':formatter.format(DateTime.now())})
                                                        .then((value) => acceptedGuarantorCounter = filteredAccountDetails
                                                        .where((element) =>
                                                    element['guaranteeStatus'] == 'accepted' &&
                                                        element['guarantee'] == document['guarantee'] )
                                                        .length).then((value) =>
                                                        FirebaseFirestore.instance
                                                            .collection("welfareUsers")
                                                            .doc('${document['guaranteephoneNumber']} to ${phoneNumber} guarantorRequest')
                                                            .update({
                                                          'acceptedGuarantorCounter': acceptedGuarantorCounter,
                                                          'guarantorBalance': (document['guarantorBalance'] - (document['loanRequested']/3)).toInt() }))
                                                        .then((value) => subtractGuarantorBalance());

                                                    await FirebaseFirestore.instance
                                                        .collection("welfareUsers")
                                                        .doc('${document['guaranteephoneNumber']}')
                                                        .update({
                                                          'acceptedGuarantorCounter': acceptedGuarantorCounter,
                                                    });

                                                    await _fcmNotificationService.sendNotificationToUser(
                                                      title: 'Loan Guarantor Request Approved',
                                                      body: '${myName} has approved your loan guarantor request',
                                                      fcmToken: document['guaranteeToken'],

                                                    );

                                                     },
                                                ),
                                                TextButton(
                                                  child: Text('Reject',style: TextStyle(color:Colors.white)),
                                                  onPressed: () async{
                                                    sendLog('logs','Guarantor Request for loan of ${currencyFormat.format(double.parse(document['loanRequested']))} from ${document['guarantee']} Rejected by ${myName}');
                                                    await Navigator.pop(context);
                                                      await FirebaseFirestore.instance
                                                          .collection("welfareUsers")
                                                          .doc('${document['guaranteephoneNumber']} to ${phoneNumber} guarantorRequest')
                                                          .update({
                                                        'guaranteeStatus': 'rejected',
                                                        'dateApproved': formatter.format(DateTime.now())})
                                                          .then((value) =>
                                                          getGuarantorData());

                                                    await FirebaseFirestore.instance
                                                        .collection("welfareUsers")
                                                        .doc('${document['guaranteephoneNumber']}')
                                                        .update({
                                                      'acceptedGuarantorCounter': acceptedGuarantorCounter,
                                                    });

                                                    await _fcmNotificationService.sendNotificationToUser(
                                                      title: 'Loan Guarantor Request Rejected',
                                                      body: '${myName} has rejected your loan guarantor request',
                                                      fcmToken: document['guaranteeToken'],

                                                    );
                                                  },
                                                ),
                                              ],
                                            )
                                                :Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  child: Text('Yes',style: TextStyle(color:Colors.white)),
                                                  onPressed: () async{
                                                    sendLog('logs','Guarantor Request for loan of ${currencyFormat.format(double.parse(document['loanRequested']))} from ${document['guarantee']} Withdrawn by ${myName}');
                                                    await Navigator.pop(context);
                                                    loanRequested = document['loanRequested'];
                                                    await FirebaseFirestore.instance
                                                        .collection("welfareUsers")
                                                        .doc('${document['guaranteephoneNumber']} to ${phoneNumber} guarantorRequest')
                                                        .update({
                                                      'guaranteeStatus':'awaiting response',
                                                      'dateApproved': formatter.format(DateTime.now())})
                                                        .then((value) => acceptedGuarantorCounter = filteredAccountDetails
                                                        .where((element) =>
                                                    element['guaranteeStatus'] == 'accepted' &&
                                                        element['guarantee'] == document['guarantee'] )
                                                        .length).then((value) =>
                                                        FirebaseFirestore.instance
                                                            .collection("welfareUsers")
                                                            .doc('${document['guaranteephoneNumber']} to ${phoneNumber} guarantorRequest')
                                                            .update({
                                                          'acceptedGuarantorCounter': acceptedGuarantorCounter,
                                                          'guarantorBalance': (document['guarantorBalance'] + (document['loanRequested']/3)).toInt() }))
                                                        .then((value) => addGuarantorBalance());

                                                    await _fcmNotificationService.sendNotificationToUser(
                                                      title: 'Loan Guarantor Request withdrawn',
                                                      body: '${myName} has withdrawn guarantor request approval',
                                                      fcmToken: document['guaranteeToken'],

                                                    );
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Cancel',style: TextStyle(color:Colors.white)),
                                                  onPressed: () async{
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
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: Offset(0, 1), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        visualDensity: VisualDensity.compact,
                                        horizontalTitleGap: 0,
                                        dense:true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),

                                        leading: document['guaranteeStatus'] == 'awaiting response' ?
                                        Icon(Icons.add_circle,color: Colors.orange)
                                            :document['guaranteeStatus'] == 'accepted' ?
                                        Icon(Icons.check_circle,color: Colors.lightGreen)
                                            :Icon(Icons.remove_circle,color: Colors.red),

                                        title: Text('${document['guarantee']}'),

                                        subtitle: Text('Loan Request: ${currencyFormat.format(document['loanRequested'])}'),

                                        trailing:document['guaranteeStatus'] != null ?
                                        Text('${document['guaranteeStatus']}',
                                            style: TextStyle(color: document['guaranteeStatus'] == 'awaiting response' ?
                                            Colors.orange: document['guaranteeStatus'] == 'accepted' ? Colors.lightGreen : Colors.red) )
                                            :Text('Request for guarantee'),
                                        onTap:  () {
                                          controller = false;
                                          showMyDialog();
                                          controller = false;
                                        },

                                      ),
                                    ),
                                  );
                                }).toList()
                            ),
                          ),
                        ],
                      );
                    },
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