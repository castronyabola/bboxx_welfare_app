import 'dart:async';

import 'package:bboxx_welfare_app/models/Account.dart';
import 'package:bboxx_welfare_app/models/fcm_notification_service.dart';
import 'package:bboxx_welfare_app/models/navigation.dart';
import 'package:bboxx_welfare_app/models/notifications.dart';
import 'package:bboxx_welfare_app/screens/loan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';

class Guarantors extends StatefulWidget {

  @override
  State<Guarantors> createState() => _GuarantorsState();

}

class _GuarantorsState extends State<Guarantors> {
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

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('EEEE, dd/MMMM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    getGuarantorData();
    updateGuarantorData();
    Notifications.init();
    //Subscribe to the NEWS topic.
    _fcmNotificationService.subscribeToTopic(topic: 'NEWS');
    load();
    _initPackageInfo();
    sendLog('logs', 'Guarantors Screen Launched');
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

  var time = const Duration(seconds: 10);

  bool controller = false;
  bool progressIndicator = false;
  List _accountDetails = [];
  int selectedGuarantorCounter = 0;
  int acceptedGuarantorCounter = 0;
  String myName;
  int loanRequested = 0;
  int loanPeriod = 0;
  int mySavings = 0;
  int guarantorBalance = 0;
  String guarantor;
  String guaranteeStatus = '';
  final user = FirebaseAuth.instance.currentUser;

  List filteredAccountDetails = [];


  void listenNotifications(){
    Notifications.onNotifications.stream.listen(onClickedNotification);
  }

  void onClickedNotification(String payload){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Guarantors())
    );
  }

  Future <void> updateGuarantorData() async{
    if (!mounted) return;
    for ( int i = 0; i < _accountDetails.length; i++ ) {
      if(_accountDetails[i]['phoneNumber'] != phoneNumber && _accountDetails[i]['phoneNumber'] != null && _accountDetails[i]['myName'] != null) {
        await FirebaseFirestore.instance
            .collection("welfareUsers")
            .doc(
            '${phoneNumber} to ${_accountDetails[i]['phoneNumber']} guarantorRequest')
            .update({
          'guarantee': myName,
          'guarantor': '${_accountDetails[i]['myName']}',
          'guarantorBalance': _accountDetails[i]['guarantorBalance'],
          'acceptedGuarantorCounter': acceptedGuarantorCounter,
          'loanRequested': loanRequested
          });
      }
    }
    }

  Future <void> getGuarantorData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("welfareUsers")
        .get();

    setState(() {
      _accountDetails = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
    await FirebaseFirestore.instance.collection("phoneNumbers").doc(
        user.email).get().then((value) {
      if (!mounted) return;
      setState(() {
        phoneNumber = value['phoneNumber'];
      });
    });
    controller = true;
    await FirebaseFirestore.instance.collection("welfareUsers").doc(phoneNumber).get().then((value){
      if (!mounted || controller == false) return;
        mySavings = value["mySavings"];
        myName = value["myName"];
        loanRequested = value["loanRequested"];
        loanPeriod = value["loanPeriod"];
        phoneNumber = value["phoneNumber"];
          });

        setState(() {
          filteredAccountDetails = _accountDetails.where((element) =>
              element['guarantorBalance'] != null
              && element['guarantorBalance'] > (loanRequested/3.toInt())
              && element['guarantor'] != null
              && element['guarantee'] == myName ||
              element['guaranteeStatus']== 'accepted'
                  && element['guarantee'] == myName
                  && element['guarantor'] != null
              && element['phoneNumber'] != null
          ).toList();

          acceptedGuarantorCounter = _accountDetails
              .where((element) =>
          element['guaranteeStatus'] == 'accepted' &&
              element['guarantee'] == myName)
              .length;

        });

    controller = false;
    //updateGuarantorData();
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
          appBar: AppBar(
            shape: RoundedRectangleBorder(
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
            //automaticallyImplyLeading: true,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.lightBlue),
            backgroundColor: Theme
                .of(context)
                .cardColor,
            elevation: 3,
            title: Text('Guarantors', style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.lightBlue,
                fontSize: 16)),
            toolbarHeight: 50,
          ),
          body: _accountDetails.isEmpty ?
          Center(child: CircularProgressIndicator(
            backgroundColor: Colors.lightBlueAccent,
          ))
          :loanRequested == 0 ?
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
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
                  child: Text('You have not requested for a loan yet. Kindly go to the loan page to request for a loan. Thanks.',
                    textAlign: TextAlign.center,),
                ),
              ),
            ),
          )
              :filteredAccountDetails.isEmpty ?
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: RefreshIndicator(
                onRefresh: updateGuarantorData,
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
                      child: Text('Please contact potential guarantors to log in to the app for you to request their approvals, and pull down to reload.',
                        textAlign: TextAlign.center,),
                    ),
                  ),
                ),
              ),
            ),
          )
              :loanRequested <= mySavings?
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: RefreshIndicator(
                onRefresh: updateGuarantorData,
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
                      child: Text('Your loan request has been guaranteed by your Savings. You do not need to request for additional guarantors',
                        textAlign: TextAlign.center,),
                    ),
                  ),
                ),
              ),
            ),
          )
              :
          RefreshIndicator(
            onRefresh: updateGuarantorData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
               children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30 ),
                 child: Text('Please select up to 3 guarantors'),
              ),
                 Container(
                   height: size.height * 0.7,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('welfareUsers')
                      .where('guarantee', isEqualTo: myName)
                      .snapshots(),

                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if(!snapshot.hasData){
                        Center(
                            heightFactor: size.height * 0.025,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.lightBlueAccent,
                            )
                        );
                      }else if (snapshot.hasData) {
                        selectedGuarantorCounter = snapshot.data.docs
                            .where((element) {
                          Map<String, dynamic> data = element.data();
                          return
                                data.containsKey('loanRequested') &&
                                data.containsKey('guaranteeStatus') &&
                                data['guarantee'] == myName &&
                                data['guaranteeStatus'] != null;
                        }).length;
                      }

                         return Column(
                           children: [
                             Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20 ),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Text('Guarantors selected: ',),
                                   Text('$selectedGuarantorCounter', style: TextStyle(color: selectedGuarantorCounter > 2 ? Colors.redAccent: null)),
                                 ],
                               ),
                             ),
                             Expanded(
                               child: snapshot.hasData ?
                                    ListView(
                                        children: snapshot.data.docs.where((element) {
                                          Map<String, dynamic> data = element.data();
                                          return
                                                data.containsKey('loanRequested') &&
                                                data.containsKey('guaranteeStatus') &&
                                                data['guarantorBalance'] > (loanRequested/3.toInt());
                                        }).map((document){

                                            Future <void> showMyDialog() {
                                       return showDialog<void>(
                                         context: context,
                                         barrierDismissible: false, // user must tap button!
                                         builder: (BuildContext context) {
                                           return AlertDialog(
                                             shape: RoundedRectangleBorder(
                                                 borderRadius: BorderRadius.all(Radius.circular(10))
                                             ),
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
                                                   document['guaranteeStatus'] == null ? Row(
                                                     mainAxisAlignment: MainAxisAlignment.center,
                                                     children: [
                                                       selectedGuarantorCounter < 3 ? Flexible(
                                                         child: Text('Request ${document['guarantor']} to be your guarantor?',
                                                             textAlign: TextAlign.center , style: TextStyle(color:Colors.white)),
                                                       )
                                                           :Flexible(
                                                         child: Text('''You have reached maximum guarantor requests allowed. Please contact guarantors to approve your requests.''',
                                                             textAlign: TextAlign.center ,style: TextStyle(color:Colors.white)),
                                                       ),
                                                     ],
                                                   )
                                                       :Row(
                                                     mainAxisAlignment: MainAxisAlignment.center,
                                                     children: [
                                                       document['guaranteeStatus'] == 'awaiting response' ?
                                                       Flexible(
                                                         child: Text('''You have already requested ${document['guarantor']} to be your guarantor. Withdraw request ?''',
                                                             textAlign: TextAlign.center ,style: TextStyle(color:Colors.white)),
                                                       )
                                                           :Flexible(
                                                         child: Text('''${document['guarantor']} has ${document['guaranteeStatus']} your request.''',
                                                             textAlign: TextAlign.center ,style: TextStyle(color:Colors.white)),
                                                       )
                                                     ],
                                                   ),
                                                 ],
                                               ),
                                             ),
                                             actions: <Widget>[
                                               document['guaranteeStatus'] == null && selectedGuarantorCounter < 3 ? Row(
                                                 mainAxisAlignment: MainAxisAlignment.end,
                                                 children: [
                                                   TextButton(
                                                     child: Text('Yes',style: TextStyle(color:Colors.white)),
                                                     onPressed: () async{
                                                       sendLog('logs','Loan Guarantor Request of ${currencyFormat.format(loanRequested)} from ${myName} to ${document['guarantor']} Made');
                                                       if (document['phoneNumber'] != phoneNumber && document['phoneNumber'] != null) {
                                                          FirebaseFirestore.instance
                                                             .collection("welfareUsers")
                                                             .doc(
                                                             '${phoneNumber} to ${document['phoneNumber']} guarantorRequest')
                                                             .update({
                                                           'guaranteeStatus': 'awaiting response',
                                                           'guarantee': myName,
                                                           'guarantor': '${document['guarantor']}',
                                                           'loanRequested': loanRequested});

                                                          _fcmNotificationService
                                                             .sendNotificationToUser(
                                                           title: 'Loan Guarantor Request',
                                                           body: 'Requester: ${myName}\n'
                                                               'Loan: ${currencyFormat.format(
                                                               loanRequested)}\n'
                                                               'Loan Period: ${loanPeriod} Month(s)',
                                                           fcmToken: document['guarantorToken'],

                                                         );
                                                         await Navigator.pop(context);
                                                       }
                                                     },
                                                   ),
                                                   TextButton(
                                                     child: Text('No',style: TextStyle(color:Colors.white)),
                                                     onPressed: () async{
                                                       controller == true;

                                                       await Navigator.pop(context);
                                                     },
                                                   ),
                                                 ],
                                               )
                                                   :document['guaranteeStatus'] == 'awaiting response'  ?
                                               Row(
                                                 mainAxisAlignment: MainAxisAlignment.end,
                                                 children: [
                                                   TextButton(
                                                     child: Text('Withdraw',style: TextStyle(color:Colors.white)),
                                                     onPressed: () async{
                                                       sendLog('logs','Loan Guarantor Request of ${currencyFormat.format(loanRequested)} from ${myName} to ${document['guarantor']} Withdrawn');
                                                       if (document['phoneNumber'] != phoneNumber && document['phoneNumber'] != null && document['guaranteeStatus'] == 'awaiting response') {
                                                          FirebaseFirestore.instance
                                                             .collection("welfareUsers")
                                                             .doc('${phoneNumber} to ${document['phoneNumber']} guarantorRequest')
                                                             .update({
                                                           'guaranteeStatus': null,
                                                           'loanRequested':0
                                                         });
                                                       }
                                                        _fcmNotificationService.sendNotificationToUser(
                                                         title: 'Loan Guarantor Request Withdrawal',
                                                         body: '${myName} has withdrawn your loan guarantor request',
                                                         fcmToken: document['guarantorToken'],
                                                       );

                                                       await Navigator.pop(context);
                                                     },
                                                   ),
                                                   TextButton(
                                                     child: Text('Cancel',style: TextStyle(color:Colors.white)),
                                                     onPressed: () async{
                                                       await Navigator.pop(context);
                                                     },
                                                   ),
                                                 ],
                                               )
                                                   : TextButton(
                                                 child: Text('Ok',style: TextStyle(color:Colors.white)),
                                                 onPressed: () async{
                                                   await Navigator.pop(context);
                                                 },
                                               ),
                                             ],
                                           );

                                         },
                                       );
                                     }
                                     return Padding(
                                       padding: const EdgeInsets.all(8.0),
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
                                           child:ListTile(
                                             visualDensity: VisualDensity.compact,
                                             horizontalTitleGap: 0,
                                             dense:true,
                                             contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),

                                             leading: Icon(Icons.add_circle,color: document['guaranteeStatus'] == 'awaiting response' ?
                                             Colors.orange: document['guaranteeStatus'] == 'accepted' ? Colors.lightGreen
                                                 :document['guaranteeStatus'] == 'rejected' ? Colors.red: null),
                                             title: Text('${document['guarantor']}'),
                                             subtitle:document['guaranteeStatus'] != null ?
                                             Text('${document['guaranteeStatus']}',
                                                 style: TextStyle(color: document['guaranteeStatus'] == 'awaiting response' ?
                                                 Colors.orange: document['guaranteeStatus'] == 'accepted' ? Colors.lightGreen : Colors.red) )
                                                 :Text('Request for guarantee'),
                                             onTap:  () {

                                               controller = false;

                                               showMyDialog();

                                             },
                                             onLongPress: () {
                                             },

                                           ),
                                         ),
                                     );
                                   }).toList()
                       )
                                   :Container(),
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