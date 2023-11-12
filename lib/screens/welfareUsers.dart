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

import 'guarantors.dart';

class WelfareUsers extends StatefulWidget {

  @override
  State<WelfareUsers> createState() => _WelfareUsersState();

}

class _WelfareUsersState extends State<WelfareUsers> {
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
  List <Account> _accountDetails = <Account>[];
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

  List <Account> filteredAccountDetails = <Account>[];


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

     setState(() {
      _accountDetails.asMap().forEach((key, value) async{

        '${_accountDetails[key].phoneNumber}' != phoneNumber && '${_accountDetails[key].phoneNumber}' != 'null' && '${_accountDetails[key].phoneNumber}' != null ?
        await FirebaseFirestore.instance
              .collection("welfareUsers")
              .doc('Accounts')
              .update({
           '${phoneNumber} to ${_accountDetails[key]
            .phoneNumber} guarantorRequest.guarantee': myName,
            '${phoneNumber} to ${_accountDetails[key]
                .phoneNumber} guarantorRequest.guarantor': '${_accountDetails[key]
                .myName}',
            '${phoneNumber} to ${_accountDetails[key]
              .phoneNumber} guarantorRequest.guarantorBalance': _accountDetails[key]
              .guarantorBalance,
            '${phoneNumber}.${'acceptedGuarantorCounter'}': acceptedGuarantorCounter})
            .then((value) => getGuarantorData())
            :null;
        });
      });
    }

  Future <void> getGuarantorData() async {
    await FirebaseFirestore.instance.collection("phoneNumbers").doc(
        user.email).get().then((value) {
      if (!mounted) return;
      setState(() {
        phoneNumber = value['phoneNumber'];
      });
    });
    controller = true;
    await FirebaseFirestore.instance.collection("welfareUsers").doc('728149975').get().then((value){
      if (!mounted || controller == false) return;
      setState(() {
        _accountDetails.clear();
        List.from(value.data().values).forEach((element) {
          Account data = Account.fromJson(element);
            _accountDetails.add(data);

          data.phoneNumber == phoneNumber ?
          loanRequested = data.loanRequested: null;

          data.phoneNumber == phoneNumber ?
          loanPeriod = data.loanPeriod: null;

          data.phoneNumber == phoneNumber ?
          mySavings = data.mySavings: null;

          data.phoneNumber == phoneNumber ?
          myName = data.myName: null;

          filteredAccountDetails = _accountDetails;

             selectedGuarantorCounter = _accountDetails
              .where((element) =>
              element.guaranteeStatus != null &&
              element.guaranteeStatus != 'rejected' &&
                  element.guarantee == myName)
              .length;

          acceptedGuarantorCounter = _accountDetails
              .where((element) =>
          element.guaranteeStatus == 'accepted' &&
              element.guarantee == myName)
              .length;

        });
      });
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
          body: Container(
                //color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                 children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30 ),
                   child: Text('Please select up to 3 guarantors'),
                ),
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
                   Container(
                  height: size.height * 0.6,
                    child: RefreshIndicator(
                      onRefresh: updateGuarantorData,
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: filteredAccountDetails.length,
                      itemBuilder: (ctx, index) {

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
                                title: filteredAccountDetails[index].guaranteeStatus == null ? Row(
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
                                      filteredAccountDetails[index].guaranteeStatus == null ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          selectedGuarantorCounter < 3 ? Flexible(
                                            child: Text('Request ${filteredAccountDetails[index].guarantor} to be your guarantor?',
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
                                                     filteredAccountDetails[index].guaranteeStatus == 'awaiting response' ?
                                                     Flexible(
                                                       child: Text('''You have already requested ${filteredAccountDetails[index].guarantor} to be your guarantor. Withdraw request ?''',
                                                       textAlign: TextAlign.center ,style: TextStyle(color:Colors.white)),
                                                     )
                                                         :Flexible(
                                                           child: Text('''${filteredAccountDetails[index].guarantor} has ${filteredAccountDetails[index].guaranteeStatus} your request.''',
                                                           textAlign: TextAlign.center ,style: TextStyle(color:Colors.white)),
                                                         )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  filteredAccountDetails[index].guaranteeStatus == null && selectedGuarantorCounter < 3 ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: Text('Yes',style: TextStyle(color:Colors.white)),
                                        onPressed: () async{
                                          FirebaseFirestore.instance
                                              .collection("welfareUsers")
                                              .doc('Accounts')
                                              .update({'${phoneNumber} to ${filteredAccountDetails[index].guarantorUid} guarantorRequest.guaranteeStatus':'awaiting response',
                                            '${phoneNumber} to ${filteredAccountDetails[index].guarantorUid} guarantorRequest.guarantee':'${myName}',
                                            '${phoneNumber} to ${filteredAccountDetails[index].guarantorUid} guarantorRequest.guarantor':'${filteredAccountDetails[index].guarantor}',
                                            '${phoneNumber} to ${filteredAccountDetails[index].guarantorUid} guarantorRequest.loanRequested':loanRequested})
                                              .then((value) => getGuarantorData());

                                          await _fcmNotificationService.sendNotificationToUser(
                                            title: 'Loan Guarantor Request',
                                            body: 'Requester: ${myName}\n'
                                                'Loan: ${currencyFormat.format(loanRequested)}\n'
                                                'Loan Period: ${loanPeriod} Month(s)',
                                            fcmToken: filteredAccountDetails[index].guarantorToken,

                                          );
                                               await Navigator.pop(context);
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
                                      :filteredAccountDetails[index].guaranteeStatus == 'awaiting response'  ?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                             TextButton(
                                                child: Text('Withdraw',style: TextStyle(color:Colors.white)),
                                                 onPressed: () async{

                                                   if (filteredAccountDetails[index].guaranteeStatus == 'awaiting response') {
                                                     FirebaseFirestore.instance
                                                         .collection("welfareUsers")
                                                         .doc('Accounts')
                                                         .update({'${phoneNumber} to ${filteredAccountDetails[index].guarantorUid} guarantorRequest.guaranteeStatus': null,
                                                         '${phoneNumber} to ${filteredAccountDetails[index].guarantorUid} guarantorRequest.loanRequested':0})
                                                         .then((value) => getGuarantorData());
                                                   }

                                                   await _fcmNotificationService.sendNotificationToUser(
                                                     title: 'Loan Guarantor Request Withdrawal',
                                                     body: '${myName} has withdrawn your loan guarantor request',
                                                     fcmToken: filteredAccountDetails[index].guarantorToken,
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
                           child:ListTile(
                             visualDensity: VisualDensity.compact,
                             horizontalTitleGap: 0,
                             dense:true,
                             contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),

                            leading: Icon(Icons.add_circle,color: filteredAccountDetails[index].guaranteeStatus == 'awaiting response' ?
                            Colors.orange: filteredAccountDetails[index].guaranteeStatus == 'accepted' ? Colors.lightGreen
                                :filteredAccountDetails[index].guaranteeStatus == 'rejected' ? Colors.red: null),
                            title: Text('KES. ${filteredAccountDetails[index].myLoan}'),
                            subtitle:Text('KES. ${filteredAccountDetails[index].loanDue}'),
                            onTap:  () {
                              //progressIndicator = true;
                                 controller = false;
                                 // if(controller == true){
                                 //   showMyDialog().then((value) => controller = false);
                                 // }
                                 // else if(progressIndicator == true){
                                 //   return null;
                                 // }
                                 showMyDialog();

                            },
                             onLongPress: () {
                               // if (filteredAccountDetails[index].guaranteeStatus == 'awaiting response') {
                               //   FirebaseFirestore.instance
                               //       .collection("welfareUsers")
                               //       .doc('Accounts')
                               //       .update({'${myName} to ${filteredAccountDetails[index].guarantor} guarantorRequest.guaranteeStatus': null});
                               // }
                             },

                             ),
                         ),
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