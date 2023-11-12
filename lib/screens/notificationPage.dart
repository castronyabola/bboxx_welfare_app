import 'dart:async';

import 'package:bboxx_welfare_app/models/Account.dart';
import 'package:bboxx_welfare_app/models/fcm_notification_service.dart';
import 'package:bboxx_welfare_app/models/navigation.dart';
import 'package:bboxx_welfare_app/models/notifications.dart';
import 'package:bboxx_welfare_app/screens/guarantors.dart';
import 'package:bboxx_welfare_app/screens/home.dart';
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

class NotificationPage extends StatefulWidget {

  @override
  State<NotificationPage> createState() => _NotificationPageState();

}

class _NotificationPageState extends State<NotificationPage> {
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
  int notificationCount;
  String phoneNumber;
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
  // Future <void> updateGuarantorData() async {
  //   if (!mounted) return;
  //   setState(() {
  //    FirebaseFirestore.instance
  //       .collection("welfareUsers")
  //       .doc('Accounts')
  //       .update({'${myName}.${'acceptedGuarantorCounter'}': acceptedGuarantorCounter});
  //   });
  // }
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
        myName = value['myName'];

        loanRequested = value['loanRequested'];

        loanPeriod = value['loanPeriod'];

        mySavings = value['mySavings'];

        filteredAccountDetails = _accountDetails.where((element) =>
            element["guarantee"] == myName &&
            element["guaranteeStatus"] != 'awaiting response' &&
            element["guaranteeStatus"] != null &&
            element["notificationRead"] != true)
            .toList();

        selectedGuarantorCounter = _accountDetails
            .where((element) =>
        element['guaranteeStatus'] != null &&
            element['guaranteeStatus'] != 'rejected' &&
            element['guarantee'] == myName)
            .length;

        acceptedGuarantorCounter = _accountDetails
            .where((element) =>
        element['guaranteeStatus'] == 'accepted' &&
            element['guarantee'] == myName)
            .length;

      });
    });
    controller = false;
    //updateGuarantorData();
  }
  Future <void> updateGuarantorData() async {
    for (int i = 0; i < _accountDetails.length; i++) {
      if (_accountDetails[i]['phoneNumber'] != phoneNumber &&
          _accountDetails[i]['phoneNumber'] != null && _accountDetails[i]['myName'] != null) {
        await FirebaseFirestore.instance
            .collection("welfareUsers")
            .doc(
            '${phoneNumber} to ${_accountDetails[i]['phoneNumber']} guarantorRequest')
            .update({
          'guarantee': myName,
          'guarantor': '${_accountDetails[i]['myName']}',
          'guarantorBalance': _accountDetails[i]['guarantorBalance'],
          'acceptedGuarantorCounter': acceptedGuarantorCounter
        }).then((value) => getGuarantorData());
      }
    }
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
          title: Text('Notifications', style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.lightBlue,
              fontSize: 16)),
          toolbarHeight: 50,
        ),
        body: _accountDetails.isEmpty ?
        Center(child: CircularProgressIndicator())
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
                    child: Text('You have no notifications at this time.',
                      textAlign: TextAlign.center,),
                  ),
                ),
              ),
            ),
          ),
        )
            :Container(
          //color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Container(
                height: size.height * 0.6,
                child: RefreshIndicator(
                  onRefresh: updateGuarantorData,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('welfareUsers')
                        .where('guarantee', isEqualTo: myName)
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
                      notificationCount = snapshot.data.docs
                          .where((element) {
                        Map<String, dynamic> data = element.data();
                        return data['guarantee'] == myName &&
                            data.containsKey('guaranteeStatus') &&
                            data.containsKey('loanRequested') &&
                            data.containsKey('notificationRead') &&
                            data['guaranteeStatus'] != 'awaiting response' &&
                            data['guaranteeStatus'] != null &&
                            data['notificationRead'] != true;
                      })
                          .length;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20 ),
                            child: ElevatedButton(
                              onPressed: ()
                              {
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
                                mainAxisAlignment: MainAxisAlignment.center,
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
                          ),
                          Expanded(
                            child: ListView(
                                children: snapshot.data.docs.where((element) {
                                  Map<String, dynamic> data = element.data();
                                  return data['guarantee'] == myName &&
                                      data.containsKey('guaranteeStatus') &&
                                      data.containsKey('loanRequested') &&
                                      data.containsKey('notificationRead') &&
                                      data['guaranteeStatus'] != 'awaiting response' &&
                                      data['notificationRead'] != true &&
                                      data['guaranteeStatus'] != null;
                                }).map((document){
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: document['notificationRead'] == true
                                            && document['notificationRead'] != null ?
                                        Theme.of(context).cardColor
                                            : Colors.red.withOpacity(0.2),
                                        //borderRadius: BorderRadius.circular(2),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            spreadRadius: 1,
                                            blurRadius: 1,
                                            offset: Offset(0, 1), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        //isThreeLine: true,
                                        visualDensity: VisualDensity.comfortable,
                                        horizontalTitleGap: 0,
                                        //dense:true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                                        leading:Icon(Icons.info, color: document['notificationRead'] == true ?
                                        Colors.lightBlue: Colors.redAccent),
                                        // leading: Icon(Icons.add_circle,color: document.guaranteeStatus == 'awaiting response' ?
                                        // Colors.orange: document.guaranteeStatus == 'accepted' ? Colors.lightGreen
                                        //     :document.guaranteeStatus == 'rejected' ? Colors.red: null),
                                        title: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                                          child: Text('${document['guarantor']} ${document['guaranteeStatus']} your guarantor request',
                                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                        ),
                                        subtitle:document['notificationRead'] == true
                                            && document['notificationRead'] != null &&
                                            document['guaranteeStatus'] != null ?
                                        Text('Loan Requested: ${currencyFormat.format(document['loanRequested'])}\n'
                                            'Date: ${document['dateApproved']}',
                                            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12) )
                                            :null,
                                        onTap:  () {
                                          FirebaseFirestore.instance
                                              .collection("welfareUsers")
                                              .doc('${phoneNumber} to ${document['phoneNumber']} guarantorRequest')
                                              .update({'notificationRead': true });

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
              ),
            ],
          ),
        ),
      ),
    );
  }
}