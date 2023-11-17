import 'dart:async';
import 'dart:io';

import 'package:bboxx_welfare_app/models/navigation.dart';
import 'package:bboxx_welfare_app/models/notifications.dart';
import 'package:bboxx_welfare_app/pdf_manager/api/pdf_api.dart';
import 'package:bboxx_welfare_app/pdf_manager/api/pdf_invoice_api.dart';
import 'package:bboxx_welfare_app/pdf_manager/model/customer.dart';
import 'package:bboxx_welfare_app/pdf_manager/model/invoice.dart';
import 'package:bboxx_welfare_app/pdf_manager/model/supplier.dart';
import 'package:bboxx_welfare_app/screens/guarantors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smart_select/smart_select.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class LoanPage extends StatefulWidget {
  @override
  _LoanPageState createState() {
    return _LoanPageState();
  }
}

class _LoanPageState extends State<LoanPage> {
  final String baseUrl = 'https://gvlb1ub624.execute-api.us-east-1.amazonaws.com/prod/sqs';
  final String authToken = 'RLFbz206A47vzWYltVvMR1chg4texn5U8OKvVW7z';
  final secretKey = 'Snyaca7590231234';
  String ipAddress = 'Loading...';

  FocusNode f1 = FocusNode();

  var currencyFormat = new NumberFormat.currency(locale: "en_US",
      symbol: "KES ", decimalDigits: 0);

  var now = DateTime.now();
  final DateFormat formatter = DateFormat('dd/MMM/yyyy');
  final DateFormat dateFormatter = DateFormat('ddMMyy');
  var time = const Duration(seconds: 5);

  final user = FirebaseAuth.instance.currentUser;
  bool controller = false;
  bool showProgressIndicator = false;
  bool alreadyCalled = false;
  int acceptedGuarantorCounterStore = 0;
  String myAccountID = '';
  double myLoan = 0;
  String myName = '';
  double mySavings = 0.0;
  String savingsStartDate = '';
  double loanInterest = 0.0;
  double loanPaid = 0.0;
  double loanDue = 0.0;
  double loanRequested = 0;
  double monthlySavings = 0;
  String dueDate;
  String guarantee = '';
  String guarantor = '';
  String guaranteeStatus = '';
  int acceptedGuarantorCounter = 0;
  double guarantorBalance = 0;
  int loanPeriod = 0;
  double loanInstallments = 0.0;
  double loanGranted = 0;
  String loanAdminApproval = '';
  String pdfDownloadURL = '';
  String employmentNumber;
  String membershipNumber;
  String IDNumber;
  String designation;
  String location;
  String phoneNumber;
  String reasonForLoan = '';
  String loanDisbursementMethod = '';
  double maxLoanAmount = 0.0;

  List _accountDetails = [];
  List filteredAccountDetails = [];

  final _formKey = GlobalKey<FormState>();
  final amountHolder = TextEditingController();
  final withdrawalAmountHolder = TextEditingController();
  final newSavingsAmountHolder = TextEditingController();
  String paymentPeriodValue = "";
  String reasonForLoanValue = "";
  String loanDisbursementValue = "";
  String amount = "";
  double withdrawalAmount = 0.0;
  String withdrawalRequestDate = '';
  String savingsChangeRequestDate = '';
  double newSavingsAmount = 0.0;
  String withdrawalRequestStatus = '';
  String savingsChangeRequestStatus = '';

  //String loanStatus = '';

  bool requestButtonsVisible = true;

  bool loanRequestView = false;
  bool birthRequestView = false;
  bool deathRequestView = false;
  bool withdrawalRequestView = false;
  bool savingsChangeRequestView = false;

  bool validated = false;

  @override
  void initState() {
    super.initState();
    getData();
    Notifications.init();
    sendLog('logs', 'Requests Screen Launched');
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

  void listenNotifications(){
    Notifications.onNotifications.stream.listen(onClickedNotification);
  }

  void onClickedNotification(String payload){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Guarantors())
    );
  }

  Future loanDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          backgroundColor: Colors.lightBlue,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Loan Confirmation',style: TextStyle(fontSize: 15,color:Colors.white),),
            ],
          ),
          content: Container(
            height: 100,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        'Loan Requested: ',
                      style: TextStyle(fontSize: 14,color:Colors.white),),
                    Text(
                       '${currencyFormat.format(int.parse(amount))}',
                        style: TextStyle(fontSize: 14,color:Colors.white),),
                  ],
                ),
                SizedBox(height:10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                          'Loan to be granted: ',
                      style: TextStyle(fontSize: 14,color:Colors.white),),
                    Text(
                      '${currencyFormat.format((int.parse(amount) - (int.parse(amount) * 0.1)).toInt())}',
                      style: TextStyle(fontSize: 14,color:Colors.white),),
                  ],
                ),
                SizedBox(height:10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Period: ',
                      style: TextStyle(fontSize: 14,color:Colors.white),),
                    Text(
                      '${int.parse(paymentPeriodValue)} Months',
                      style: TextStyle(fontSize: 14,color:Colors.white),),
                  ],
                ),
                SizedBox(height:10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Installments: ',
                      style: TextStyle(fontSize: 14,color:Colors.white),),
                    Text(
                      '${currencyFormat.format((int.parse(amount)/int.parse(paymentPeriodValue)).toDouble())}',
                      style: TextStyle(fontSize: 14,color:Colors.white),),
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
                  child: Text('Cancel',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Confirm',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    Navigator.pop(context);
                    await uploadData();//.then((value) => getData());
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future loanTermsDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          backgroundColor: Colors.lightBlue,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Loan Repayment Terms',style: TextStyle(fontSize: 15, color:Colors.white),),
            ],
          ),
          content: Container(
            //height: 100,
            child:
            Text('I ${myName} hereby apply for a loan of ${currencyFormat.format(int.parse(amount))} '
                'for a period of ${paymentPeriodValue} months to be repaid in instalment of ${currencyFormat.format((int.parse(amount)/int.parse(paymentPeriodValue)).toDouble())}'
                ' each month, commencing on ${formatter.format(DateTime(now.year,now.month + 1))}.'
                'The loan will be repaid to NIC bank account number 1003911787 or via M-pesa pay bill number 488488 to account number 1003911787. '
                'Proof of payment should reach the treasurer by latest 5th of every month.',
                 style: TextStyle(fontSize: 12,color:Colors.white), textAlign: TextAlign.start,)
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Cancel',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Agree',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    await Navigator.pop(context);
                    loanConsentDialog();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future withdrawalDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          backgroundColor: Colors.lightBlue,
          title: Center(child: Text('Withdrawal Request Confirmation',style: TextStyle(fontSize: 15, color:Colors.white),)),
          content: Container(
            //height: 100,
              child:
              withdrawalAmount == (mySavings - loanRequested)?
              Text('I ${myName} hereby request to withdraw all my savings of ${currencyFormat.format(withdrawalAmount)} thereby exiting Bboxx Welfare.',
                style: TextStyle(fontSize: 12,color:Colors.white), textAlign: TextAlign.center,):
              Text('I ${myName} hereby request to withdraw ${currencyFormat.format(withdrawalAmount)} '
        'from my Savings. After this withdrawal, my savings will be ${currencyFormat.format((mySavings - loanRequested) - withdrawalAmount)}.',
        style: TextStyle(fontSize: 12,color:Colors.white), textAlign: TextAlign.center,)
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text('Cancel',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Accept',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    requestButtonsVisible = true;
                    await Navigator.pop(context);
                    requestButtonsVisible = true;
                    uploadWithdrawalData();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future savingsChangeDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          backgroundColor: Colors.lightBlue,
          title: Center(child: Text('Savings Change Confirmation',style: TextStyle(fontSize: 15, color:Colors.white),)),
          content: Container(
            //height: 100,
              child:
              Text('I ${myName} hereby request to update my monthly savings from ${currencyFormat.format(monthlySavings)} to ${currencyFormat.format(newSavingsAmount)}.',
                style: TextStyle(fontSize: 12,color:Colors.white), textAlign: TextAlign.center)
              ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text('Cancel',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Accept',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    requestButtonsVisible = true;
                    await Navigator.pop(context);
                    uploadSavingsChangeData();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future loanConsentDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          backgroundColor: Colors.lightBlue,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Consent',style: TextStyle(fontSize: 15, color:Colors.white),),
            ],
          ),
          content: Container(
            //height: 100,
              child:
              Text('I agree to abide by the repayment terms failure to which'
                  ' I consent for the payroll to proceed and deduct automatically'
                  ' ${currencyFormat.format(int.parse(amount))} from my salary in '
                  'installments of ${currencyFormat.format((int.parse(amount)/int.parse(paymentPeriodValue)).toDouble())} '
                  'for ${paymentPeriodValue} months commencing on ${formatter.format(DateTime(now.year,now.month + 1))} '
                  'to NIC account number1003911787. This agreement is irrevocable till the loan is paid in full. '
                  'NOTE  - Any member willing to pay any extra amount to clear the loan is allowed to make payment to NIC bank account number 1003911787 or via M-pesa pay bill number 488488.',
                style: TextStyle(fontSize: 12,color:Colors.white), textAlign: TextAlign.start,)
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('Cancel',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Agree',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    await Navigator.pop(context);
                    loanDialog();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future cancelLoanDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          backgroundColor: Colors.lightBlue,//Theme.of(context).cardColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Loan Cancellation',style: TextStyle(fontSize: 15, color:Colors.white),),
            ],
          ),
          content: Text(
            'Cancel loan request ?',
            textAlign: TextAlign.center,style: TextStyle(fontSize: 14, color:Colors.white),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('No',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    await Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Yes',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    Navigator.pop(context);
                    setState(() {
                      showProgressIndicator = true;
                    });
                    await updateGuaranteeStatus();
                    await FirebaseFirestore.instance
                        .collection("welfareUsers")
                        .doc(phoneNumber)
                        .update({
                      'loanRequested': 0,
                      'loanDue': 0,
                      'loanPaid': 0,
                      'myLoan': 0,
                      'loanDueDate': '',
                      'loanGranted': 0,
                      'loanInterest': 0.1,
                      'loanPeriod': 0,
                      'guarantorBalance': guarantorBalance,
                      'loanInstallments': 0.0 })
                        .then((value) =>  getData());

                    sendLog('logs','Loan Request of ${currencyFormat.format(loanRequested)} Cancelled by ${myName}');

                    setState(() {
                      showProgressIndicator = false;
                    });
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future <void> updateGuaranteeStatus() async{
    if (!mounted) return;
         for (int i = 0; i < _accountDetails.length; i++) {
           if('${_accountDetails[i]['phoneNumber']}' != phoneNumber && '${_accountDetails[i]['phoneNumber']}' != null) {
             await FirebaseFirestore.instance
                 .collection("welfareUsers")
                 .doc('${phoneNumber} to ${_accountDetails[i]['phoneNumber']} guarantorRequest')
                 .update({
                    'guaranteeStatus': null,
                    'notificationRead': false
                 });
              }
         }
  }
  Future <void> uploadData() async {
    if (!mounted) return;
    setState(() {
      showProgressIndicator = true;
      guarantorBalance = mySavings - int.parse(amount)~/3;
     FirebaseFirestore.instance
        .collection("welfareUsers")
        .doc(phoneNumber)
        .update({
       'loanRequested': int.parse(amount),
       'loanDisbursementMethod': loanDisbursementValue,
       'reasonForLoan': reasonForLoanValue,
       'loanGranted': (int.parse(amount) - (int.parse(amount) * 0.1)).toInt(),
      'loanInterest': int.parse(paymentPeriodValue) < 13 ? 0.1 : 0.15,
      'loanPeriod': int.parse(paymentPeriodValue),
      'guarantorBalance': guarantorBalance,
       'loanDue': int.parse(amount),
       'loanInstallments': (int.parse(amount)/int.parse(paymentPeriodValue)).toDouble()});
    });
    sendLog('logs','Loan of ${currencyFormat.format(double.parse(amount))} Requested by ${myName}');
    updateGuaranteeStatus();
    getData();
  }
  Future <void> uploadWithdrawalData() async {
      FirebaseFirestore.instance
          .collection("welfareUsers")
          .doc(phoneNumber)
          .update({
        'withdrawalRequestAmount': withdrawalAmount,
        'withdrawalRequestStatus': "Awaiting Withdrawal Request Disbursement",
        'withdrawalRequestDate': formatter.format(DateTime.now()),
    });
      sendLog('logs','Withdrawal Request of ${currencyFormat.format(withdrawalAmount)} made by ${myName}');
  }
  Future <void> uploadSavingsChangeData() async {
    FirebaseFirestore.instance
        .collection("welfareUsers")
        .doc(phoneNumber)
        .update({
      'savingsChangeRequestAmount': newSavingsAmount,
      'savingsChangeRequestStatus': "Awaiting Savings Change Request Approval",
      'savingsChangeRequestDate': formatter.format(DateTime.now()),
    });
    sendLog('logs','Savings Change Request from ${currencyFormat.format(monthlySavings)} to ${currencyFormat.format(newSavingsAmount)} made by ${myName}');
  }
  Future <void> updateData() async {
    controller = false;

    if (!mounted || controller == true ) return;

      Notifications.showNotification(
      title: 'Congratulations ${myName}!',
      body: 'Loan request Approved: ${currencyFormat.format(loanRequested)}.',
    );

      setState(() {
        alreadyCalled = true;
        getData().then((value) =>
          FirebaseFirestore.instance
            .collection("welfareUsers")
            .doc(phoneNumber)
            .update({
            'myLoan': loanRequested,
            'loanDueDate':'${formatter.format(DateTime(now.year,now.month + loanPeriod))}',
            }).then((value) => generatePDF()));
      });

      for ( int i = 0; i < _accountDetails.length; i++ ) {
        if(_accountDetails[i]['phoneNumber'] != phoneNumber && _accountDetails[i]['phoneNumber'] != null && _accountDetails[i]['myName'] != null ) {
          FirebaseFirestore.instance
              .collection("welfareUsers")
              .doc('${phoneNumber} to ${_accountDetails[i]['phoneNumber']} guarantorRequest')
              .set({
            'loanRequested': loanRequested},
              SetOptions(merge: true)
          );
        }
      }

  }
  Future <void> getData() async {
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
            mySavings = value["mySavings"].toDouble();
            myLoan = value["myLoan"].toDouble();
            loanDue = value["loanDue"].toDouble();
            loanPaid = value["loanPaid"].toDouble();
            loanInterest = value["loanInterest"].toDouble();
            dueDate = value["loanDueDate"];
            savingsStartDate = value["savingsStartDate"];
            monthlySavings = value["monthlySavings"].toDouble();
            myName = value["myName"];
            loanRequested = value["loanRequested"].toDouble();
            loanPeriod = value["loanPeriod"];
            loanInstallments = value["loanInstallments"].toDouble();
            loanGranted = value["loanGranted"].toDouble();
            employmentNumber = value["employmentNumber"];
            membershipNumber = value["membershipNumber"];
            IDNumber = value["IDNumber"];
            designation = value["designation"];
            location = value["location"];
            phoneNumber = value["phoneNumber"];
            reasonForLoan = value["reasonForLoan"];
            loanDisbursementMethod = value["loanDisbursementMethod"];

            try {
              savingsChangeRequestStatus = value["savingsChangeRequestStatus"];
            }catch(e){
              savingsChangeRequestStatus = "";
            }

            try {
              newSavingsAmount = value["savingsChangeRequestAmount"];
            }catch(e){
              newSavingsAmount = 0.0;
            }

            try {
              withdrawalRequestStatus = value["withdrawalRequestStatus"];
            }catch(e){
              withdrawalRequestStatus = "";
            }

            try {
              withdrawalAmount = value["withdrawalRequestAmount"];
            }catch(e){
              withdrawalAmount = 0.0;
            }

            try {
              withdrawalRequestDate = value["withdrawalRequestDate"];
            }catch(e){
              withdrawalRequestDate = '';
            }

            try {
              savingsChangeRequestDate = value["savingsChangeRequestDate"];
            }catch(e){
              savingsChangeRequestDate = '';
            }

            try{
              loanAdminApproval = value["loanAdminApproval"];
            }catch(e){
              loanAdminApproval = '';
            }

            acceptedGuarantorCounter = _accountDetails
                .where((element) =>
            element["guaranteeStatus"] == 'accepted' &&
                element["guarantee"] == myName)
                .length;


          filteredAccountDetails = _accountDetails.where((element) =>
          element["guarantee"] == myName && element["guaranteeStatus"] == 'accepted').toList();
          showProgressIndicator = false;
      });
    });
    acceptedGuarantorCounterStore = acceptedGuarantorCounter;
    controller = false;
  }

  List<S2Choice<String>> paymentPeriodOptions = [
    S2Choice<String>(value: '1', title: 'One Month'),
    S2Choice<String>(value: '2', title: 'Two Months'),
    S2Choice<String>(value: '3', title: 'Three Months'),
    S2Choice<String>(value: '4', title: 'Four Months'),
    S2Choice<String>(value: '5', title: 'Five Months'),
    S2Choice<String>(value: '6', title: 'Six Months'),
    S2Choice<String>(value: '7', title: 'Seven Months'),
    S2Choice<String>(value: '8', title: 'Eight Months'),
    S2Choice<String>(value: '9', title: 'Nine Months'),
    S2Choice<String>(value: '10', title: 'Ten Months'),
    S2Choice<String>(value: '11', title: 'Eleven Months'),
    S2Choice<String>(value: '12', title: 'Twelve Months'),
    S2Choice<String>(value: '13', title: 'Thirteen Months'),
    S2Choice<String>(value: '14', title: 'Fourteen Months'),
    S2Choice<String>(value: '15', title: 'Fifteen Months'),
    S2Choice<String>(value: '16', title: 'Sixteen Months'),
    S2Choice<String>(value: '17', title: 'Seventeen Months'),
    S2Choice<String>(value: '18', title: 'Eighteen Months'),
    S2Choice<String>(value: '19', title: 'Nineteen Months'),
    S2Choice<String>(value: '20', title: 'Twenty Months'),
    S2Choice<String>(value: '21', title: 'Twenty-one Months'),
    S2Choice<String>(value: '22', title: 'Twenty-two Months'),
    S2Choice<String>(value: '23', title: 'Twenty-three Months'),
    S2Choice<String>(value: '24', title: 'Twenty-four Months'),
  ];
  List<S2Choice<String>> reasonForLoanOptions = [
    S2Choice<String>(value: 'Emergency', title: 'Emergency'),
    S2Choice<String>(value: 'School Fees', title: 'School Fees'),
    S2Choice<String>(value: 'Medical', title: 'Medical'),
    S2Choice<String>(value: 'Investment Project', title: 'Investment Project'),
    S2Choice<String>(value: 'Other', title: 'Other'),
  ];
  List<S2Choice<String>> loanDisbursementOptions = [
    S2Choice<String>(value: 'Mpesa', title: 'Mpesa'),
    S2Choice<String>(value: 'Cash', title: 'Cash'),
    S2Choice<String>(value: 'Cheque', title: 'Cheque'),

  ];

  generatePDF() async{
    var baseFormatter = dateFormatter.format(now);
    var newFormatter = formatter.format(now);

    String guarantorAmount = '${currencyFormat.format(loanRequested~/3)}';

     String name0;
     String date0;

    String name1;
    String date1;

    String name2;
    String date2;

    filteredAccountDetails.asMap().forEach((key, value) async{
      name0 = filteredAccountDetails[0].guarantor;
      date0 = filteredAccountDetails[0].dateApproved;

      name1 = filteredAccountDetails[1].guarantor;
      date1 = filteredAccountDetails[1].dateApproved;

      name2 = filteredAccountDetails[2].guarantor;
      date2 = filteredAccountDetails[2].dateApproved;
    });

    final invoice = Invoice(
      supplier: Supplier(
        name: 'BBOXX STAFF WELFARE SELF HELP GROUP',
        address:
        'P.O. BOX 1886-40100\n'
        'KISUMU-KENYA\n'
        'Tel:0700110790/0722537356\n'
        'Email: bboxxwelfare@gmail.com',
      ),
      customer: Customer(
        name: myName,
        address: 'Loan: ${currencyFormat.format(loanRequested)}',
      ),
      info: InvoiceInfo(
        mySavings: mySavings.toInt().toString(),
        loanAmount: loanRequested.toInt().toString(),
        reasonForLoan: reasonForLoan,
        loanDisbursementMethod: loanDisbursementMethod,
        loanInstallments: currencyFormat.format(loanInstallments),
        myName: myName,
        employmentNumber: employmentNumber,
        membershipNumber: membershipNumber,
        IDNumber: IDNumber.toString(),
        designation: designation,
        location: location,
        phoneNumber: phoneNumber,
        date: newFormatter,
        dueDate: '${formatter.format(DateTime(now.year,now.month + loanPeriod))}',
        paymentPeriod: '${loanPeriod} Months',
        description: 'The undersigned, hereby accept jointly and severally liable for the repayment of the loan in the event of the borrower\u0027s default. The amount in default may be recovered by an offset against their savings in the Welfare, salaries or dividends till the defaulted amount has been cleared in full. This undertaking should be honored accordingly till the loan in default is fully recovered.',
        number: 'BXCK0013${baseFormatter}',
        totalGuarantorAmount: '${currencyFormat.format(loanRequested)}'
      ),
      items: [
        InvoiceItem(
          name: name0,
          guarantorAmount: guarantorAmount,
          guarantorRequestStatus: 'accepted',
          date: date0,
        ),
        InvoiceItem(
          name: name1,
          guarantorAmount: guarantorAmount,
          guarantorRequestStatus: 'accepted',
          date: date1,
        ),
        InvoiceItem(
          name: name2,
          guarantorAmount: guarantorAmount,
          guarantorRequestStatus: 'accepted',
          date: date2,
        ),
      ],
      loanDetails:
        [
          InvoiceInfo(
            applicantDetails: 'Current Savings',
            date: '${currencyFormat.format(mySavings)}',
          ),
          InvoiceInfo(
            applicantDetails: 'Loan limit',
            date: '${currencyFormat.format((mySavings*3) - loanDue)}',
          ),
          InvoiceInfo(
            applicantDetails: 'Monthly savings',
            date: '${currencyFormat.format(monthlySavings)}',
          ),
          InvoiceInfo(
            applicantDetails: 'Loan requested',
            date: '${currencyFormat.format(loanGranted)}',
          ),
          InvoiceInfo(
            applicantDetails: 'Loan balance',
            date: '${currencyFormat.format(loanDue)}',
          ),
          InvoiceInfo(
            applicantDetails: '50% qualification amount',
            date: '${currencyFormat.format(loanGranted)}',
          ),
          InvoiceInfo(
            applicantDetails: 'Repayment period (Months)',
            date: '${loanPeriod} Months',
          ),
          InvoiceInfo(
            applicantDetails: 'Instalments',
            date: '${currencyFormat.format(loanInstallments)}',
          ),
        ]
    );

    final pdfFile = await PdfInvoiceApi.generate(invoice);

    PdfApi.openFile(pdfFile)
        .then((value) => uploadPDF())
        .then((value) => sendEmail());

  }
  uploadPDF() async{
   var formatted = formatter.format(now);

    FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child("${myName} Loan on: " + formatted.toString() +'.pdf');
  UploadTask uploadTask = ref.putFile(File(PdfApi.url));
    var downloadUrl = await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
    String url = downloadUrl.toString();
    print('URL is: $url');
    pdfDownloadURL = url;
    return url;

}
  sendEmail() async {
    var formatted = formatter.format(now);

    await FirebaseFirestore.instance
        .collection('mail')
        .add(
      {
        'to': user.email,
        //'cc':'info@globsoko.com',
        'message': {
          'subject': 'Bboxx Welfare Loan Form ${formatted.toString()}',
          'text': 'Dear ${myName},\n'
              '\n'
              'Your loan request of Kes. ${currencyFormat.format(loanRequested)} has been approved.\n'
              'Please find attached the approved loan form.\n'
              '\n'
              'Regards,\n'
              'Bboxx Welfare',
          'attachments': [{
            'contentType':'pdf',
            'filename':'${myName} Welfare Loan.pdf',
            'href': pdfDownloadURL
          }]
        },
      }
    );
  }

  @override
  Widget build (BuildContext context) {

    FirebaseFirestore.instance.collection("phoneNumbers").doc(
        user.email).get().then((value) {
      if (!mounted) return;
      setState(() {
        phoneNumber = value['phoneNumber'];
      });
    });

    //(acceptedGuarantorCounter == 3 && myLoan != loanRequested && alreadyCalled == false) || (loanRequested <= mySavings && myLoan != loanRequested && alreadyCalled == false) ? updateData() :null;
    //loanAdminApproval == 'approved' && alreadyCalled == false ? updateData():null;
    loanAdminApproval == 'approved' && myLoan != loanRequested ? updateData():null;

    final Size size = MediaQuery
        .of(context)
        .size;
    double var12 = size.height * 0.0185;

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
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.lightBlue),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 3,
          title:
          loanRequestView ?
          Text("Loan Request", style:TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 16)):
          withdrawalRequestView ?
          Text("Withdrawal Request", style:TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 16)):
          savingsChangeRequestView ?
          Text("Savings Change Request", style:TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 16)):
          birthRequestView ?
          Text("Birth Compensation Request", style:TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 16)):
          deathRequestView ?
          Text("Bereavement Compensation Request", style:TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 16)):
          Text("Welfare Requests", style:TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 16)),
          toolbarHeight: 50,
        ),
        body:
          requestButtonsVisible?
          Padding(
            padding: EdgeInsets.symmetric(vertical:45,horizontal: 20),
            child: Container(
              width: size.width,
                height: size.height * 0.65,
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
                      offset: Offset(
                          0, 1), // changes position of shadow
                    ),
                  ],
                ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20),
                      child: ElevatedButton(
                        onPressed: () async{
                          await getData();
                          setState(() {
                            requestButtonsVisible = false;
                            loanRequestView = true;
                            birthRequestView = false;
                            deathRequestView = false;
                            withdrawalRequestView = false;
                            savingsChangeRequestView = false;
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor:
                            loanRequested == 0 ?
                            MaterialStateProperty.all<Color>(Theme.of(context).cardColor):
                            MaterialStateProperty.all<Color>(Colors.lightBlue.shade50),

                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      1000.0),
                                )
                            )
                        ),
                        child: Text(
                          'Request Loan',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20),
                      child: ElevatedButton(
                        onPressed: () async{
                          await getData();
                          setState(() {
                            requestButtonsVisible = false;
                            withdrawalRequestView = true;
                            loanRequestView = false;
                            birthRequestView = false;
                            deathRequestView = false;
                            savingsChangeRequestView = false;
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor:
                            withdrawalRequestStatus == "" ?
                            MaterialStateProperty.all<Color>(Theme.of(context).cardColor):
                            MaterialStateProperty.all<Color>(Colors.lightBlue.shade50),

                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      1000.0),
                                )
                            )
                        ),
                        child: Text(
                          'Request Withdrawal',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20),
                      child: ElevatedButton(
                        onPressed: () async{
                          await getData();
                          setState(() {
                            requestButtonsVisible = false;
                            savingsChangeRequestView = true;
                            loanRequestView = false;
                            birthRequestView = false;
                            deathRequestView = false;
                            withdrawalRequestView = false;
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor:
                            savingsChangeRequestStatus == "" ?
                            MaterialStateProperty.all<Color>(Theme.of(context).cardColor):
                            MaterialStateProperty.all<Color>(Colors.lightBlue.shade50),

                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      1000.0),
                                )
                            )
                        ),
                        child: Text(
                          'Request Savings Change',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20),
                      child: ElevatedButton(
                        onPressed: () async{
                          await getData();
                          setState(() {
                            requestButtonsVisible = false;
                            birthRequestView = true;
                            loanRequestView = false;
                            deathRequestView = false;
                            withdrawalRequestView = false;
                            savingsChangeRequestView = false;
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<
                                Color>(Theme
                                .of(context)
                                .cardColor),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      1000.0),
                                )
                            )
                        ),
                        child: Text(
                          'Request Birth Compensation',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20),
                      child: ElevatedButton(
                        onPressed: () async{
                          await getData();
                          setState(() {
                            requestButtonsVisible = false;
                            deathRequestView = true;
                            loanRequestView = false;
                            birthRequestView = false;
                            withdrawalRequestView = false;
                            savingsChangeRequestView = false;
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<
                                Color>(Theme
                                .of(context)
                                .cardColor),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      1000.0),
                                )
                            )
                        ),
                        child: Text(
                          'Request Bereavement Compensation',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ),
          ):
          Container(
            height: size.height * 0.75,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child:
                 loanRequestView?
                 StreamBuilder(
                   stream: FirebaseFirestore.instance.collection('welfareUsers').doc(phoneNumber).snapshots(),
                   builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                     loanStatus(){
                       if(acceptedGuarantorCounter == 2 &&
                           snapshot.data['loanRequested'] != 0 &&
                           snapshot.data['loanRequested'] >
                               snapshot.data['mySavings']){
                         return "Awaiting ${3 - acceptedGuarantorCounter} guarantor to approve";
                       }else if(acceptedGuarantorCounter < 2 &&
                           snapshot.data['loanRequested'] != 0 &&
                           snapshot.data['loanRequested'] >
                               snapshot.data['mySavings']){
                         return "Awaiting ${3 - acceptedGuarantorCounter} guarantors to approve";
                       }else if((acceptedGuarantorCounter == 3 &&
                           snapshot.data['loanRequested'] != 0 &&
                           snapshot.data['loanRequested'] > snapshot.data['mySavings']) ||
                           (acceptedGuarantorCounter != 3 &&
                               snapshot.data['loanRequested'] <= snapshot.data['mySavings']) &&
                               (snapshot.data['loanAdminApproval'] != 'approved' && snapshot.data['loanAdminApproval'] != 'rejected')){
                         return "Awaiting Welfare Admin Approval";
                       }else if(snapshot.data['loanAdminApproval'] == 'approved' && ((acceptedGuarantorCounter == 3 &&
                           snapshot.data['loanRequested'] != 0 &&
                           snapshot.data['loanRequested'] >
                               snapshot.data['mySavings']) || (acceptedGuarantorCounter != 3 &&
                           snapshot.data['loanRequested'] <=
                               snapshot.data['mySavings']))){
                         return "AWaiting Loan Disbursement";
                       }else if(snapshot.data['loanAdminApproval'] == 'rejected' && ((acceptedGuarantorCounter == 3 &&
                           snapshot.data['loanRequested'] != 0 &&
                           snapshot.data['loanRequested'] >
                               snapshot.data['mySavings']) || (acceptedGuarantorCounter != 3 &&
                           snapshot.data['loanRequested'] <=
                               snapshot.data['mySavings']))){
                         return "Loan Request Rejected by Welfare Admin";
                       }else{
                         return "Request Loan";
                       }
                     }

                     if(!snapshot.hasData || showProgressIndicator == true) {
                       return Center(
                           heightFactor: size.height * 0.025,
                           child: CircularProgressIndicator(
                             backgroundColor: Colors.lightBlueAccent,
                           )
                       );
                     }
                       snapshot.data.exists? maxLoanAmount =
                           ((snapshot.data['mySavings'] * 3) - snapshot.data['loanDue']).toDouble():null;
                       return snapshot.data.exists?
                       Column(
                           children: [
                             SizedBox(height: 20),
                             loanRequested != 0 ?
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 (acceptedGuarantorCounter >= 3 ) || (loanRequested <= mySavings) ?
                                 SizedBox():
                                 Padding(
                                   padding: const EdgeInsets.symmetric(
                                       horizontal: 10.0, vertical: 0),
                                   child: ElevatedButton(
                                     onPressed: () {
                                       cancelLoanDialog();
                                     },
                                     style: ButtonStyle(
                                         backgroundColor: MaterialStateProperty.all<
                                             Color>(Theme
                                             .of(context)
                                             .cardColor),
                                         shape: MaterialStateProperty.all<
                                             RoundedRectangleBorder>(
                                             RoundedRectangleBorder(
                                               borderRadius: BorderRadius.circular(
                                                   1000.0),
                                             )
                                         )
                                     ),
                                     child: Row(
                                       children: [
                                         Icon(
                                           Icons.cancel_sharp,
                                           size: 20,
                                           color: Colors.lightBlue,
                                         ),
                                         SizedBox(width: 10,),
                                         Text(
                                           'Cancel',
                                           textAlign: TextAlign.center,
                                           style: TextStyle(color: Colors.lightBlue),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                               ],
                             ) :
                             SizedBox(),
                             loanRequested != 0 ?
                             Padding(
                               padding: EdgeInsets.symmetric(
                                   horizontal: 10.0, vertical: 20.0),
                               child: Container(
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
                                         offset: Offset(
                                             0, 1), // changes position of shadow
                                       ),
                                     ],
                                   ),
                                   child: Column(
                                     children: [
                                       Padding(
                                         padding: EdgeInsets.symmetric(
                                             horizontal: 10.0, vertical: 20.0),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment
                                               .spaceBetween,
                                           children: [
                                             Text("Loan Status:",
                                               textAlign: TextAlign.center,
                                               style: TextStyle()),
                                             Text(loanStatus(), style: TextStyle())
                                           ],
                                         ),
                                       ),
                                       Divider(
                                         indent: 12,
                                         endIndent: 12,
                                         thickness: 1,
                                       ),
                                       SizedBox(height: 10,),
                                       Padding(
                                         padding: EdgeInsets.symmetric(
                                             horizontal: 10.0, vertical: 5.0),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment
                                               .spaceBetween,
                                           children: [
                                             Text("Loan Requested:",
                                               textAlign: TextAlign.center,
                                               style: TextStyle(),),
                                             snapshot.data['loanRequested'] == 0 ? Text(
                                               "n/a",)
                                                 : Text("${currencyFormat.format(
                                                 snapshot.data['loanRequested'])}",
                                               style: TextStyle(color: Colors.red),),
                                           ],
                                         ),
                                       ),
                                       Padding(
                                         padding: EdgeInsets.symmetric(
                                             horizontal: 10.0, vertical: 5.0),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment
                                               .spaceBetween,
                                           children: [
                                             Text("Loan Interest (${loanInterest * 100}%):",
                                               textAlign: TextAlign.center,),
                                             snapshot.data['loanRequested'] == 0 ? Text(
                                               "n/a",)
                                                 : Text("${currencyFormat.format(
                                                 snapshot.data['loanRequested'] *
                                                     snapshot.data['loanInterest'])}",
                                               style: TextStyle(color: Colors.red),),
                                           ],
                                         ),
                                       ),
                                       Padding(
                                         padding: EdgeInsets.symmetric(
                                             horizontal: 10.0, vertical: 5.0),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment
                                               .spaceBetween,
                                           children: [
                                             acceptedGuarantorCounter == 3 ? Text(
                                                 "Loan Granted:",
                                                 textAlign: TextAlign.center,
                                                 style: TextStyle())
                                                 : Text("Loan to be Granted:",
                                               textAlign: TextAlign.center,
                                               style: TextStyle(),),
                                             snapshot.data['loanRequested'] == 0 ? Text(
                                               "n/a",)
                                                 : Text("${currencyFormat.format(
                                                 snapshot.data['loanGranted'])}",
                                               style: TextStyle(color: Colors.blue),),
                                           ],
                                         ),
                                       ),
                                       Padding(
                                         padding: EdgeInsets.symmetric(
                                             horizontal: 10.0, vertical: 5.0),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment
                                               .spaceBetween,
                                           children: [
                                             Text("Payment Period:",
                                               textAlign: TextAlign.center,),
                                             snapshot.data['loanRequested'] == 0 ? Text(
                                               "n/a",) :
                                             Text("${snapshot
                                                 .data['loanPeriod']} Months",),
                                           ],
                                         ),
                                       ),
                                       Padding(
                                         padding: EdgeInsets.symmetric(
                                             horizontal: 10.0, vertical: 5.0),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment
                                               .spaceBetween,
                                           children: [
                                             Text("Loan Installments:",
                                               textAlign: TextAlign.center,),
                                             snapshot.data['loanRequested'] == 0 ? Text(
                                               "n/a",)
                                                 : Text("${currencyFormat.format(
                                                 snapshot.data['loanInstallments'])}",),
                                           ],
                                         ),
                                       ),
                                       Divider(
                                         indent: 12,
                                         endIndent: 12,
                                         thickness: 1,
                                       ),
                                       SizedBox(height: 10,),
                                       acceptedGuarantorCounter == 3 ?
                                       Padding(
                                         padding: EdgeInsets.symmetric(
                                             horizontal: 10.0, vertical: 10.0),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment
                                               .spaceBetween,
                                           children: [
                                             Text(
                                               "Due date:", textAlign: TextAlign.center,
                                               style: TextStyle(),),
                                             Text("${snapshot.data['loanDueDate']}",
                                                 style: TextStyle())
                                           ],
                                         ),
                                       ) : Text(''),
                                       Padding(
                                         padding: EdgeInsets.symmetric(
                                             horizontal: 10.0, vertical: 10.0),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment
                                               .spaceBetween,
                                           children: [
                                             Text("Loan Limit:",
                                               textAlign: TextAlign.center,
                                               style: TextStyle(),),
                                             Text("${currencyFormat.format(
                                                 maxLoanAmount)}", style: TextStyle(),),
                                           ],
                                         ),
                                       ),
                                       Divider(
                                         indent: 12,
                                         endIndent: 12,
                                         thickness: 1,
                                       ),
                                       SizedBox(height: 10,),
                                       Padding(
                                         padding: EdgeInsets.symmetric(
                                             horizontal: 10.0, vertical: 5.0),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment
                                               .spaceBetween,
                                           children: [
                                             Text("Loan Disbursement Method:",
                                               textAlign: TextAlign.center,),
                                             snapshot.data['loanRequested'] == 0 ? Text(
                                               "n/a",) :
                                             Text("${snapshot
                                                 .data['loanDisbursementMethod']}",),
                                           ],
                                         ),
                                       ),
                                       loanDisbursementMethod == 'Mpesa' ? Padding(
                                         padding: EdgeInsets.symmetric(
                                             horizontal: 10.0, vertical: 5.0),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment
                                               .spaceBetween,
                                           children: [
                                             Text("Official Mpesa Number:",
                                               textAlign: TextAlign.center,),
                                             Text("${phoneNumber}"),
                                           ],
                                         ),
                                       ) : SizedBox(),
                                       Padding(
                                         padding: EdgeInsets.symmetric(
                                             horizontal: 10.0, vertical: 5.0),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment
                                               .spaceBetween,
                                           children: [
                                             Text("Reason for Loan:",
                                               textAlign: TextAlign.center,),
                                             snapshot.data['loanRequested'] == 0 ? Text(
                                               "n/a",) :
                                             Text("${snapshot.data['reasonForLoan']}",),
                                           ],
                                         ),
                                       ),
                                       Divider(
                                         indent: 12,
                                         endIndent: 12,
                                         thickness: 1,
                                       ),
                                       SizedBox(height: size.height * 0.04),
                                       ElevatedButton(
                                         onPressed: () async{
                                           await getData();
                                           setState(() {
                                              loanRequestView = false;
                                              birthRequestView = false;
                                              deathRequestView = false;
                                              withdrawalRequestView = false;
                                              savingsChangeRequestView = false;
                                              requestButtonsVisible = true;
                                           });
                                         },
                                         style: ButtonStyle(
                                             backgroundColor: MaterialStateProperty.all<
                                                 Color>(Theme
                                                 .of(context)
                                                 .cardColor),
                                             shape: MaterialStateProperty.all<
                                                 RoundedRectangleBorder>(
                                                 RoundedRectangleBorder(
                                                   borderRadius: BorderRadius.circular(
                                                       1000.0),
                                                 )
                                             )
                                         ),
                                         child: Text(
                                           'Back',
                                           textAlign: TextAlign.center,
                                           style: TextStyle(color: Colors.lightBlue),
                                         ),
                                       ),
                                       SizedBox(height: size.height * 0.01),
                                     ],
                                   )
                               ),
                             ) :
                             Text(''),
                             snapshot.data['loanRequested'] == 0 ?
                             Padding(
                               padding: const EdgeInsets.symmetric(
                                   horizontal: 10.0, vertical: 1.0),
                               child: Container(
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
                                       offset: Offset(
                                           0, 1), // changes position of shadow
                                     ),
                                   ],
                                 ),
                                 child: Column(
                                   children: [
                                     Padding(
                                       padding: const EdgeInsets.all(8.0),
                                       child: Text('REQUEST FOR A LOAN',
                                           style: TextStyle(fontWeight: FontWeight.bold,
                                               fontSize: 14,
                                               color: Colors.lightBlue)),
                                     ),
                                     Divider(
                                       indent: 12,
                                       endIndent: 12,
                                       thickness: 1,
                                     ),
                                     Form(
                                       key: _formKey,
                                       child: Column(
                                         children: <Widget>[
                                           Padding(
                                               padding: EdgeInsets.all(var12),
                                               child:
                                               TextFormField(
                                                 focusNode: f1,
                                                 keyboardType: TextInputType.number,
                                                 controller: amountHolder,
                                                 decoration: InputDecoration(
                                                   border: OutlineInputBorder(
                                                       borderRadius: BorderRadius.all(
                                                           Radius.circular(5))
                                                   ),
                                                   //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                                   hintText: "How much would you wish to borrow?",
                                                   labelText: "Amount",
                                                   helperText: 'Maximum amount ${currencyFormat
                                                       .format(maxLoanAmount)}',
                                                 ),
                                                 onChanged: (value) {
                                                   //controller = false;
                                                   amount = value;
                                                 },
                                                 validator: (value) {
                                                   if (value == null || value.isEmpty) {
                                                     return "Please enter loan amount";
                                                   }
                                                   else if (int.parse(amount) >
                                                       maxLoanAmount) {
                                                     return 'You do not qualify for this amount';
                                                   }
                                                   return null;
                                                 },
                                               )
                                           ),
                                           Container(
                                             width: size.width * 0.87,
                                             height: size.height * 0.09,
                                             decoration: BoxDecoration(
                                               border: Border.all(
                                                   color: Colors.black38
                                               ),
                                               color: Colors.transparent,
                                               borderRadius: BorderRadius.circular(5),
                                             ),
                                             child: SmartSelect<String>.single(
                                               tileBuilder: (context, state) {
                                                 return S2Tile(
                                                   padding: EdgeInsets.symmetric(
                                                       horizontal: 12),
                                                   title: state.titleWidget,
                                                   value: state.valueDisplay,
                                                   onTap: state.showModal,
                                                   loadingText: 'loading...',
                                                   trailing: Icon(
                                                       Icons.keyboard_arrow_down,
                                                       color: Colors.lightBlue),
                                                   //leading: Icon(Icons.access_time,color: Colors.lightBlue),
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
                                                 backgroundColor: Theme
                                                     .of(context)
                                                     .backgroundColor,
                                                 textStyle: TextStyle(fontSize: 18,
                                                     color: Colors.lightBlue),
                                               ),
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
                                                 backgroundColor: Colors.white12
                                                     .withOpacity(0.8),
                                               ),
                                               modalType: S2ModalType.popupDialog,
                                               choiceDirection: Axis.vertical,
                                               placeholder: "Please select one",
                                               title: 'Payment Period',
                                               value: paymentPeriodValue,
                                               choiceItems: paymentPeriodOptions,
                                               onChange: (state) {
                                                 controller = false;
                                                 setState(() =>
                                                 paymentPeriodValue = state.value);
                                               },
                                             ),
                                           ),
                                           SizedBox(height: 30,),
                                           Container(
                                             width: size.width * 0.87,
                                             height: size.height * 0.09,
                                             decoration: BoxDecoration(
                                               border: Border.all(
                                                   color: Colors.black38
                                               ),
                                               color: Colors.transparent,
                                               borderRadius: BorderRadius.circular(5),
                                             ),
                                             child: SmartSelect<String>.single(
                                               tileBuilder: (context, state) {
                                                 return S2Tile(
                                                   padding: EdgeInsets.symmetric(
                                                       horizontal: 12),
                                                   title: state.titleWidget,
                                                   value: state.valueDisplay,
                                                   onTap: state.showModal,
                                                   loadingText: 'loading...',
                                                   trailing: Icon(
                                                       Icons.keyboard_arrow_down,
                                                       color: Colors.lightBlue),
                                                   //leading: Icon(Icons.access_time,color: Colors.lightBlue),
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
                                                 backgroundColor: Theme
                                                     .of(context)
                                                     .backgroundColor,
                                                 textStyle: TextStyle(fontSize: 18,
                                                     color: Colors.lightBlue),
                                               ),
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
                                                 backgroundColor: Colors.white12
                                                     .withOpacity(0.8),
                                               ),
                                               modalType: S2ModalType.popupDialog,
                                               choiceDirection: Axis.vertical,
                                               placeholder: "Please select one",
                                               title: 'Reason for the loan',
                                               value: reasonForLoanValue,
                                               choiceItems: reasonForLoanOptions,
                                               onChange: (state) {
                                                 controller = false;
                                                 setState(() =>
                                                 reasonForLoanValue = state.value);
                                               },
                                             ),
                                           ),
                                           SizedBox(height: 30,),
                                           Container(
                                             width: size.width * 0.87,
                                             height: size.height * 0.09,
                                             decoration: BoxDecoration(
                                               border: Border.all(
                                                   color: Colors.black38
                                               ),
                                               color: Colors.transparent,
                                               borderRadius: BorderRadius.circular(5),
                                             ),
                                             child: SmartSelect<String>.single(
                                               tileBuilder: (context, state) {
                                                 return S2Tile(
                                                   padding: EdgeInsets.symmetric(
                                                       horizontal: 12),
                                                   title: state.titleWidget,
                                                   value: state.valueDisplay,
                                                   onTap: state.showModal,
                                                   loadingText: 'loading...',
                                                   trailing: Icon(
                                                       Icons.keyboard_arrow_down,
                                                       color: Colors.lightBlue),
                                                   //leading: Icon(Icons.access_time,color: Colors.lightBlue),
                                                   isTwoLine: true,
                                                 );
                                               },
                                               choiceStyle: S2ChoiceStyle(
                                                 accentColor: Colors.lightBlue,
                                                 color: Colors.black,
                                                 runSpacing: 4,
                                                 spacing: 12,
                                                 showCheckmark: true,
                                               ),
                                               choiceType: S2ChoiceType.switches,
                                               modalHeaderStyle: S2ModalHeaderStyle(
                                                 backgroundColor: Theme
                                                     .of(context)
                                                     .backgroundColor,
                                                 textStyle: TextStyle(fontSize: 18,
                                                     color: Colors.lightBlue),
                                               ),
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
                                                 backgroundColor: Colors.white12
                                                     .withOpacity(0.8),
                                               ),
                                               modalType: S2ModalType.popupDialog,
                                               choiceDirection: Axis.vertical,
                                               placeholder: "Please select one",
                                               title: 'Loan Disbursement Method',
                                               value: loanDisbursementValue,
                                               choiceItems: loanDisbursementOptions,
                                               onChange: (state) {
                                                 controller = false;
                                                 setState(() =>
                                                 loanDisbursementValue = state.value);
                                               },
                                             ),
                                           ),
                                           SizedBox(height: 20,),
                                           Divider(
                                             indent: 12,
                                             endIndent: 12,
                                             thickness: 1,
                                           ),
                                           Padding(
                                             padding: EdgeInsets.symmetric(
                                                 vertical: var12),
                                             child: Center(
                                               child: ElevatedButton(
                                                   style: ButtonStyle(
                                                       backgroundColor: MaterialStateProperty
                                                           .all(
                                                           loanDue == 0
                                                               && paymentPeriodValue
                                                               .isNotEmpty
                                                               && reasonForLoanValue
                                                               .isNotEmpty
                                                               && loanDisbursementValue
                                                               .isNotEmpty
                                                               && amount.isNotEmpty
                                                               && int.parse(amount) <=
                                                               maxLoanAmount ? Colors
                                                               .lightBlue
                                                               : Colors.grey
                                                       ),
                                                       fixedSize: MaterialStateProperty
                                                           .all<Size>(
                                                           Size(size.width * 0.65,
                                                               size.height * 0.025)
                                                       ),
                                                       shape: MaterialStateProperty.all<
                                                           RoundedRectangleBorder>(
                                                           RoundedRectangleBorder(
                                                             borderRadius: BorderRadius
                                                                 .circular(18.0),
                                                             //side: BorderSide(color: Colors.lightBlue)
                                                           )
                                                       )
                                                   ),
                                                   onPressed: () {
                                                     if (_formKey.currentState
                                                         .validate()) {
                                                       if (paymentPeriodValue.isEmpty) {
                                                         ScaffoldMessenger.of(context)
                                                             .showSnackBar(
                                                           SnackBar(
                                                               behavior: SnackBarBehavior
                                                                   .floating,
                                                               dismissDirection: DismissDirection
                                                                   .down,
                                                               content:
                                                               Text(
                                                                   "Please Select a payment period",
                                                                   style: TextStyle(
                                                                       color: Colors
                                                                           .red),
                                                                   textAlign: TextAlign
                                                                       .center)

                                                           ),
                                                         );
                                                       }
                                                       else
                                                       if (reasonForLoanValue.isEmpty) {
                                                         ScaffoldMessenger.of(context)
                                                             .showSnackBar(
                                                           SnackBar(
                                                               behavior: SnackBarBehavior
                                                                   .floating,
                                                               dismissDirection: DismissDirection
                                                                   .down,
                                                               content:
                                                               Text(
                                                                   "Please Select the reason for loan application",
                                                                   style: TextStyle(
                                                                       color: Colors
                                                                           .red),
                                                                   textAlign: TextAlign
                                                                       .center)

                                                           ),
                                                         );
                                                       }
                                                       else if (loanDisbursementValue
                                                           .isEmpty) {
                                                         ScaffoldMessenger.of(context)
                                                             .showSnackBar(
                                                           SnackBar(
                                                               behavior: SnackBarBehavior
                                                                   .floating,
                                                               dismissDirection: DismissDirection
                                                                   .down,
                                                               content:
                                                               Text(
                                                                   "Please Select how the loan should be disbursed",
                                                                   style: TextStyle(
                                                                       color: Colors
                                                                           .red),
                                                                   textAlign: TextAlign
                                                                       .center)

                                                           ),
                                                         );
                                                       }
                                                       else {
                                                         loanTermsDialog();
                                                         //loanDialog();
                                                       }
                                                     }
                                                   },
                                                   child:
                                                   Text("Continue", style: TextStyle(
                                                       color: Colors.white),)
                                               ),
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                     ElevatedButton(
                                       onPressed: () async{
                                         await getData();
                                         setState(() {
                                           loanRequestView = false;
                                           birthRequestView = false;
                                           deathRequestView = false;
                                           withdrawalRequestView = false;
                                           savingsChangeRequestView = false;
                                           requestButtonsVisible = true;
                                         });
                                       },
                                       style: ButtonStyle(
                                           backgroundColor: MaterialStateProperty.all<
                                               Color>(Theme
                                               .of(context)
                                               .cardColor),
                                           shape: MaterialStateProperty.all<
                                               RoundedRectangleBorder>(
                                               RoundedRectangleBorder(
                                                 borderRadius: BorderRadius.circular(
                                                     1000.0),
                                               )
                                           )
                                       ),
                                       child: Text(
                                         'Back',
                                         textAlign: TextAlign.center,
                                         style: TextStyle(color: Colors.lightBlue),
                                       ),
                                     ),
                                     SizedBox(height: size.height * 0.075),
                                   ],
                                 ),

                               ),
                             ) :
                             Text('')
                           ]
                       ):
                       Center(
                           heightFactor: size.height * 0.025,
                           child: CircularProgressIndicator(
                             backgroundColor: Colors.lightBlueAccent,
                           )
                       );
                   },
                 ):
                 withdrawalRequestView?
                 Padding(
                   padding:  EdgeInsets.symmetric(horizontal: 10.0, vertical: size.height * 0.05),
                   child: Center(
                     child: Container(
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
                             offset: Offset(
                                 0, 1), // changes position of shadow
                           ),
                         ],
                       ),
                       child:
                       withdrawalRequestStatus == ""?
                       Column(
                         children: [
                           Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Text('REQUEST FOR WITHDRAWAL',
                                 style: TextStyle(fontWeight: FontWeight.bold,
                                     fontSize: 14,
                                     color: Colors.lightBlue)),
                           ),
                           Divider(
                             indent: 12,
                             endIndent: 12,
                             thickness: 1,
                           ),
                           Form(
                             key: _formKey,
                             child: Column(
                               children: <Widget>[
                                 Padding(
                                     padding: EdgeInsets.all(var12),
                                     child:
                                     TextFormField(
                                       focusNode: f1,
                                       keyboardType: TextInputType.number,
                                       controller: withdrawalAmountHolder,
                                       decoration: InputDecoration(
                                         border: OutlineInputBorder(
                                             borderRadius: BorderRadius.all(
                                                 Radius.circular(5))
                                         ),
                                         //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                         hintText: "How much would you wish to withdraw?",
                                         labelText: "Amount to withdraw",
                                         helperText: 'Maximum amount ${currencyFormat
                                             .format(mySavings - loanRequested)}',
                                       ),
                                       maxLength: 8,
                                       autovalidateMode: AutovalidateMode.onUserInteraction,
                                       onChanged: (value) {
                                         withdrawalAmount = double.parse(value).toDouble();
                                       },
                                       validator: (value) {
                                         if (value == null || value.isEmpty) {
                                           validated = false;
                                           return "Please enter amount to withdraw";
                                         }
                                         else if (withdrawalAmount > (mySavings - loanRequested)) {
                                           validated = false;
                                           return 'You cannot withdraw more than ${currencyFormat.format(mySavings - loanRequested)}';
                                         }
                                         validated = true;
                                         return null;
                                       },
                                     )
                                 ),
                                 Divider(
                                   indent: 12,
                                   endIndent: 12,
                                   thickness: 1,
                                 ),
                                 validated?
                                 Padding(
                                   padding: EdgeInsets.symmetric(
                                       vertical: size.height * 0.05),
                                   child: Center(
                                     child: ElevatedButton(
                                         style: ButtonStyle(
                                             backgroundColor: MaterialStateProperty
                                                 .all(
                                                 Colors.lightBlue
                                             ),
                                             fixedSize: MaterialStateProperty
                                                 .all<Size>(
                                                 Size(size.width * 0.65,
                                                     size.height * 0.025)
                                             ),
                                             shape: MaterialStateProperty.all<
                                                 RoundedRectangleBorder>(
                                                 RoundedRectangleBorder(
                                                   borderRadius: BorderRadius
                                                       .circular(18.0),
                                                   //side: BorderSide(color: Colors.lightBlue)
                                                 )
                                             )
                                         ),
                                         onPressed: () {
                                           if (_formKey.currentState.validate()) {
                                             withdrawalDialog();
                                           }
                                         },
                                         child:
                                         Text("Continue", style: TextStyle(
                                             color: Colors.white),)
                                     ),
                                   ),
                                 ):
                                 SizedBox()
                               ],
                             ),
                           ),
                           Padding(
                             padding: const EdgeInsets.symmetric(
                                 horizontal: 10.0, vertical: 20),
                             child: ElevatedButton(
                               onPressed: () async{
                                 await getData();
                                 setState(() {
                                   loanRequestView = false;
                                   birthRequestView = false;
                                   deathRequestView = false;
                                   withdrawalRequestView = false;
                                   savingsChangeRequestView = false;
                                   requestButtonsVisible = true;
                                 });
                               },
                               style: ButtonStyle(
                                   backgroundColor: MaterialStateProperty.all<
                                       Color>(Theme
                                       .of(context)
                                       .cardColor),
                                   shape: MaterialStateProperty.all<
                                       RoundedRectangleBorder>(
                                       RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(
                                             1000.0),
                                       )
                                   )
                               ),
                               child: Text(
                                 'Back',
                                 textAlign: TextAlign.center,
                                 style: TextStyle(color: Colors.lightBlue),
                               ),
                             ),
                           ),
                         ],
                       ):
                       Padding(
                         padding: const EdgeInsets.all(20.0),
                         child: Column(
                           children: [
                             Container(
                                 decoration: BoxDecoration(
                                   color: Theme
                                       .of(context)
                                       .cardColor,
                                   borderRadius: BorderRadius.circular(5),
                                   boxShadow: const [
                                     BoxShadow(
                                       color: Colors.black12,
                                       spreadRadius: 2,
                                       blurRadius: 10,
                                       blurStyle: BlurStyle.normal,
                                       offset: Offset(5, 5),
                                     ),
                                   ],
                                 ),
                                 child: Row(
                                   children: [
                                     SizedBox(width: size.width * 0.02),
                                     Padding(
                                       padding: EdgeInsets.symmetric(vertical:15,horizontal: 4.0),
                                       child: Text('Status:', style: TextStyle(fontWeight:FontWeight.bold,color: Colors.lightBlue)),
                                     ),
                                     Padding(
                                       padding: EdgeInsets.all(4.0),
                                       child: Text('$withdrawalRequestStatus'),
                                     ),
                                   ],
                                 )
                             ),
                             SizedBox(height: size.height * 0.05),
                             Container(
                                 width: size.width * 0.6,
                                 decoration: BoxDecoration(
                                   color: Theme
                                       .of(context)
                                       .cardColor,
                                   borderRadius: BorderRadius.circular(5),
                                   boxShadow: const [
                                     BoxShadow(
                                       color: Colors.black12,
                                       spreadRadius: 2,
                                       blurRadius: 10,
                                       blurStyle: BlurStyle.normal,
                                       offset: Offset(5, 5),
                                     ),
                                   ],
                                 ),
                                 child: Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Icon(
                                         Icons.access_time_sharp, // Replace this with the desired icon
                                         size: 16, // Set the size of the icon
                                         color: Colors.lightBlue, // Set the color of the icon
                                       ),
                                       Padding(
                                         padding: const EdgeInsets.all(8.0),
                                         child: Text('Request Date: $withdrawalRequestDate'),
                                       ),
                                     ],
                                   ),
                                 )
                             ),
                             SizedBox(height: size.height * 0.025),
                             Container(
                                 width: size.width * 0.6,
                                 decoration: BoxDecoration(
                                   color: Theme
                                       .of(context)
                                       .cardColor,
                                   borderRadius: BorderRadius.circular(5),
                                   boxShadow: const [
                                     BoxShadow(
                                       color: Colors.black12,
                                       spreadRadius: 2,
                                       blurRadius: 10,
                                       blurStyle: BlurStyle.normal,
                                       offset: Offset(5, 5),
                                     ),
                                   ],
                                 ),
                                 child: Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Icon(
                                         Icons.monetization_on_outlined, // Replace this with the desired icon
                                         size: 16, // Set the size of the icon
                                         color: Colors.lightBlue, // Set the color of the icon
                                       ),
                                       Padding(
                                         padding: const EdgeInsets.all(8.0),
                                         child: Text('Amount: ${currencyFormat.format(withdrawalAmount)}'),
                                       ),
                                     ],
                                   ),
                                 )
                             ),
                             SizedBox(height: size.height * 0.075),
                             Padding(
                               padding: const EdgeInsets.symmetric(
                                   horizontal: 10.0, vertical: 20),
                               child: ElevatedButton(
                                 onPressed: () async{
                                   await getData();
                                   setState(() {
                                     loanRequestView = false;
                                     birthRequestView = false;
                                     deathRequestView = false;
                                     withdrawalRequestView = false;
                                     savingsChangeRequestView = false;
                                     requestButtonsVisible = true;
                                   });
                                 },
                                 style: ButtonStyle(
                                     backgroundColor: MaterialStateProperty.all<
                                         Color>(Theme
                                         .of(context)
                                         .cardColor),
                                     shape: MaterialStateProperty.all<
                                         RoundedRectangleBorder>(
                                         RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(
                                               1000.0),
                                         )
                                     )
                                 ),
                                 child: Text(
                                   'Back',
                                   textAlign: TextAlign.center,
                                   style: TextStyle(color: Colors.lightBlue),
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ),

                     ),
                   ),
                 ):
                 savingsChangeRequestView?
                 Padding(
                   padding:  EdgeInsets.symmetric(horizontal: 10.0, vertical: size.height * 0.05),
                   child: Center(
                     child: Container(
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
                             offset: Offset(
                                 0, 1), // changes position of shadow
                           ),
                         ],
                       ),
                       child:
                       savingsChangeRequestStatus == ""?
                       Column(
                         children: [
                           Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Text('REQUEST TO CHANGE MONTHLY SAVINGS',
                                 style: TextStyle(fontWeight: FontWeight.bold,
                                     fontSize: 14,
                                     color: Colors.lightBlue)),
                           ),
                           Divider(
                             indent: 12,
                             endIndent: 12,
                             thickness: 1,
                           ),
                           Form(
                             key: _formKey,
                             child: Column(
                               children: <Widget>[
                                 Padding(
                                     padding: EdgeInsets.all(var12),
                                     child:
                                     TextFormField(
                                       focusNode: f1,
                                       keyboardType: TextInputType.number,
                                       controller: newSavingsAmountHolder,
                                       decoration: InputDecoration(
                                         border: OutlineInputBorder(
                                             borderRadius: BorderRadius.all(
                                                 Radius.circular(5))
                                         ),
                                         //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                         hintText: "How much would you wish to save monthly?",
                                         labelText: "New Monthly Savings",
                                         helperText: 'Minimum amount KES. 1,500',
                                       ),
                                       maxLength: 8,
                                       autovalidateMode: AutovalidateMode.onUserInteraction,
                                       onChanged: (value) {
                                         newSavingsAmount = double.parse(value).toDouble();
                                       },
                                       validator: (value) {
                                         if (value == null || value.isEmpty) {
                                           validated = false;
                                           return "Please enter new amount to save";
                                         }
                                         else if (newSavingsAmount < 1500) {
                                           validated = false;
                                           return 'You cannot save less than KES. 1,500';
                                         }
                                         validated = true;
                                         return null;
                                       },
                                     )
                                 ),
                                 Divider(
                                   indent: 12,
                                   endIndent: 12,
                                   thickness: 1,
                                 ),
                                 validated?
                                 Padding(
                                   padding: EdgeInsets.symmetric(
                                       vertical: size.height * 0.05),
                                   child: Center(
                                     child: ElevatedButton(
                                         style: ButtonStyle(
                                             backgroundColor: MaterialStateProperty
                                                 .all(
                                                 Colors.lightBlue
                                             ),
                                             fixedSize: MaterialStateProperty
                                                 .all<Size>(
                                                 Size(size.width * 0.65,
                                                     size.height * 0.025)
                                             ),
                                             shape: MaterialStateProperty.all<
                                                 RoundedRectangleBorder>(
                                                 RoundedRectangleBorder(
                                                   borderRadius: BorderRadius
                                                       .circular(18.0),
                                                   //side: BorderSide(color: Colors.lightBlue)
                                                 )
                                             )
                                         ),
                                         onPressed: () {
                                           if (_formKey.currentState.validate()) {
                                             savingsChangeDialog();
                                           }
                                         },
                                         child:
                                         Text("Continue", style: TextStyle(
                                             color: Colors.white),)
                                     ),
                                   ),
                                 ):
                                 SizedBox()
                               ],
                             ),
                           ),
                           Padding(
                             padding: const EdgeInsets.symmetric(
                                 horizontal: 10.0, vertical: 20),
                             child: ElevatedButton(
                               onPressed: () async{
                                 await getData();
                                 setState(() {
                                   loanRequestView = false;
                                   birthRequestView = false;
                                   deathRequestView = false;
                                   withdrawalRequestView = false;
                                   savingsChangeRequestView = false;
                                   requestButtonsVisible = true;
                                 });
                               },
                               style: ButtonStyle(
                                   backgroundColor: MaterialStateProperty.all<
                                       Color>(Theme
                                       .of(context)
                                       .cardColor),
                                   shape: MaterialStateProperty.all<
                                       RoundedRectangleBorder>(
                                       RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(
                                             1000.0),
                                       )
                                   )
                               ),
                               child: Text(
                                 'Back',
                                 textAlign: TextAlign.center,
                                 style: TextStyle(color: Colors.lightBlue),
                               ),
                             ),
                           ),
                         ],
                       ):
                       Padding(
                         padding: const EdgeInsets.all(20.0),
                         child: Column(
                           children: [
                             Container(
                                 decoration: BoxDecoration(
                                   color: Theme
                                       .of(context)
                                       .cardColor,
                                   borderRadius: BorderRadius.circular(5),
                                   boxShadow: const [
                                     BoxShadow(
                                       color: Colors.black12,
                                       spreadRadius: 2,
                                       blurRadius: 10,
                                       blurStyle: BlurStyle.normal,
                                       offset: Offset(5, 5),
                                     ),
                                   ],
                                 ),
                                 child: Row(
                                   children: [
                                     SizedBox(width: size.width * 0.02),
                                     Padding(
                                       padding: EdgeInsets.symmetric(vertical:15,horizontal: 4.0),
                                       child: Text('Status:', style: TextStyle(fontWeight:FontWeight.bold,color: Colors.lightBlue)),
                                     ),
                                     Padding(
                                       padding: EdgeInsets.all(4.0),
                                       child: Text('$savingsChangeRequestStatus'),
                                     ),
                                   ],
                                 )
                             ),
                             SizedBox(height: size.height * 0.05),
                             Container(
                                 width: size.width * 0.6,
                                 decoration: BoxDecoration(
                                   color: Theme
                                       .of(context)
                                       .cardColor,
                                   borderRadius: BorderRadius.circular(5),
                                   boxShadow: const [
                                     BoxShadow(
                                       color: Colors.black12,
                                       spreadRadius: 2,
                                       blurRadius: 10,
                                       blurStyle: BlurStyle.normal,
                                       offset: Offset(5, 5),
                                     ),
                                   ],
                                 ),
                                 child: Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Icon(
                                         Icons.access_time_sharp, // Replace this with the desired icon
                                         size: 16, // Set the size of the icon
                                         color: Colors.lightBlue, // Set the color of the icon
                                       ),
                                       Padding(
                                         padding: const EdgeInsets.all(8.0),
                                         child: Text('Request Date: $savingsChangeRequestDate'),
                                       ),
                                     ],
                                   ),
                                 )
                             ),
                             SizedBox(height: size.height * 0.025),
                             Container(
                                 width: size.width * 0.6,
                                 decoration: BoxDecoration(
                                   color: Theme
                                       .of(context)
                                       .cardColor,
                                   borderRadius: BorderRadius.circular(5),
                                   boxShadow: const [
                                     BoxShadow(
                                       color: Colors.black12,
                                       spreadRadius: 2,
                                       blurRadius: 10,
                                       blurStyle: BlurStyle.normal,
                                       offset: Offset(5, 5),
                                     ),
                                   ],
                                 ),
                                 child: Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Row(
                                     crossAxisAlignment: CrossAxisAlignment.center,
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Icon(
                                         Icons.monetization_on_outlined, // Replace this with the desired icon
                                         size: 16, // Set the size of the icon
                                         color: Colors.lightBlue, // Set the color of the icon
                                       ),
                                       Padding(
                                         padding: const EdgeInsets.all(8.0),
                                         child: Text('Desired Amount: ${currencyFormat.format(newSavingsAmount)}'),
                                       ),
                                     ],
                                   ),
                                 )
                             ),
                             SizedBox(height: size.height * 0.075),
                             Padding(
                               padding: const EdgeInsets.symmetric(
                                   horizontal: 10.0, vertical: 20),
                               child: ElevatedButton(
                                 onPressed: () async{
                                   await getData();
                                   setState(() {
                                     loanRequestView = false;
                                     birthRequestView = false;
                                     deathRequestView = false;
                                     withdrawalRequestView = false;
                                     savingsChangeRequestView = false;
                                     requestButtonsVisible = true;
                                   });
                                 },
                                 style: ButtonStyle(
                                     backgroundColor: MaterialStateProperty.all<
                                         Color>(Theme
                                         .of(context)
                                         .cardColor),
                                     shape: MaterialStateProperty.all<
                                         RoundedRectangleBorder>(
                                         RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(
                                               1000.0),
                                         )
                                     )
                                 ),
                                 child: Text(
                                   'Back',
                                   textAlign: TextAlign.center,
                                   style: TextStyle(color: Colors.lightBlue),
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ),

                     ),
                   ),
                 ):
                 birthRequestView?
                 Container():
                 Container()
        ),
          )
      ),
    );
  }
}

