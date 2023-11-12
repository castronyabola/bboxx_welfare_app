import 'dart:async';

import 'package:bboxx_welfare_app/models/Account.dart';
import 'package:bboxx_welfare_app/models/navigation.dart';
import 'package:bboxx_welfare_app/screens/guarantorApprovals.dart';
import 'package:bboxx_welfare_app/screens/guarantors.dart';
import 'package:bboxx_welfare_app/screens/home.dart';
import 'package:bboxx_welfare_app/screens/loan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';

class MyProfile extends StatefulWidget {

  const MyProfile({
    Key key,
  }) : super(key: key);

  @override
  _MyProfileState createState() {
    return _MyProfileState();
  }
}

class _MyProfileState extends State<MyProfile> {
  final String baseUrl = 'https://gvlb1ub624.execute-api.us-east-1.amazonaws.com/prod/sqs';
  final String authToken = 'RLFbz206A47vzWYltVvMR1chg4texn5U8OKvVW7z';
  final secretKey = 'Snyaca7590231234';
  String ipAddress = 'Loading...';

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  FocusNode f4 = FocusNode();
  FocusNode f5 = FocusNode();
  FocusNode f6 = FocusNode();
  FocusNode f7 = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final employmentNumberHolder = TextEditingController();
  final memberShipNumberHolder = TextEditingController();
  final IDNumberHolder = TextEditingController();
  final designationHolder = TextEditingController();
  final locationHolder = TextEditingController();
  final phoneNumberHolder = TextEditingController();

  bool editProfile;

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    editProfile = false;
    getData();
    _initPackageInfo();
    sendLog('logs', 'User Profile Screen Launched');
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
  var currencyFormat = new NumberFormat.currency(locale: "en_US",
      symbol: "KES ", decimalDigits: 0);

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('EEEE, dd/MMMM/yyyy hh:mm a');

  final user = FirebaseAuth.instance.currentUser;
  var time = const Duration(seconds: 10);
  bool controller = false;
  String myName = '';
  String employmentNumber = '';
  String membershipNumber = '';
  String IDNumber = '';
  String designation = '';
  String location = '';
  String phoneNumber = '';

  List _accountDetails = [];

  Future submitProfileDialog() async{
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
              Text('Profile Edit Confirmation',style: TextStyle(fontSize: 15, color:Colors.white),),
            ],
          ),
          content: Container(
            //height: 100,
              child:
              Text('Submit Edited Profile ?',
                style: TextStyle(color:Colors.white), textAlign: TextAlign.center,)
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text('No',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    await Navigator.pop(context);
                    await ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        width: 150,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        behavior: SnackBarBehavior.floating,
                        dismissDirection: DismissDirection.down,
                        content:
                        Text("Profile Not Edited",
                            style: TextStyle(color:Colors.redAccent),
                            textAlign: TextAlign.center),
                      ),
                    );
                    setState(() {
                      editProfile = false;
                    });
                  },
                ),
                TextButton(
                  child: Text('Yes',style: TextStyle(color:Colors.white)),
                  onPressed: () async{
                    await Navigator.pop(context);
                    await ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        width: 200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        behavior: SnackBarBehavior.floating,
                        dismissDirection: DismissDirection.down,
                        content:
                        Text("Profile Successfully Edited",
                            style: TextStyle(color:Colors.lightBlue),
                            textAlign: TextAlign.center),
                      ),
                    );
                    await FirebaseFirestore.instance
                        .collection("welfareUsers")
                        .doc(phoneNumber)
                        .update({
                      'employmentNumber': employmentNumber,
                      'membershipNumber': membershipNumber, //double.parse(value) < 7 ? 0.1 : 0.15,
                      'IDNumber': IDNumber,
                      'designation': designation,
                      'location': location,
                      'phoneNumber': phoneNumber})
                        .then((value) => setState(() {
                      editProfile = false;
                    }));
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future <void> uploadInitialData() async {
    if (!mounted || employmentNumber != null) return;
    setState(() {
      FirebaseFirestore.instance
          .collection("welfareUsers")
          .doc(phoneNumber)
          .update({
        'myName': myName,
        'employmentNumber': 'BXCK0013',
        'membershipNumber': 'BWL1234',
        'IDNumber': 112345678,
        'designation': 'Mr./Mrs.',
        'location': 'DC Kisumu',
        'phoneNumber': '0728194758'
          });
    });
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
    _accountDetails = querySnapshot.docs.map((doc) => doc.data()).toList();
     await FirebaseFirestore.instance.collection("welfareUsers").doc(phoneNumber).get().then((value){
       if (!mounted ) return;
       setState(() {
            myName = value['myName'];
            employmentNumber = value['employmentNumber'];
            membershipNumber = value['membershipNumber'];
            IDNumber = value['IDNumber'];
            designation = value['designation'];
            location = value['location'];
            phoneNumber = value['phoneNumber'];
      });
    }).then((value) => uploadInitialData());
  }

  int index = 0;
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  final screens = [
    HomePage(),
    LoanPage(),
    Guarantors(),
    GuarantorApprovals(),
    MyProfile()
  ];

  final items = <Widget> [
    Icon(Icons.home),
    Icon(Icons.account_balance_wallet),
    Icon(Icons.home),
    Icon(Icons.home),
    Icon(Icons.person),
  ];


  @override
  Widget build (BuildContext context) {

    var formatted = formatter.format(now);

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
             bottomRight: Radius.circular(220),
             ),
          ),
          automaticallyImplyLeading: false,
          excludeHeaderSemantics:false,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.lightBlue,
          elevation: 8,
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
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
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Initicon(
                      elevation: 5,
                      color: Colors.lightBlue,
                      backgroundColor: Colors.lightBlueAccent.shade100,
                      text: myName,
                      size: 70,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0,vertical: 5),
                    child: Column(
                      children: [
                        Text(myName, style:TextStyle(fontSize:18,color:Colors.white, fontWeight: FontWeight.w800)),
                        Text(membershipNumber, style:TextStyle(fontSize:16,color:Colors.white)),
                        SizedBox(height: 40,)
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          toolbarHeight: 220,
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
            child: Text('Bboxx Welfare',
                style: TextStyle(color:Colors.lightBlue)),
          ),
        ),
        // floatingActionButton: editProfile == false ?
        // BuildFloatingActionEditButton():
        // BuildFloatingActionSubmitButton(),
        // floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
        body:
        _accountDetails.isEmpty ?
             Center(child: CircularProgressIndicator())
            :RefreshIndicator(
                onRefresh: getData,
                child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    editProfile == false ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0,vertical: 20),
                          child: Row(
                            children: [
                              Text('Account Info', style:TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.perm_identity, color: Colors.lightBlue,),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name', style: TextStyle(fontWeight: FontWeight.w800),),
                                  Text('${myName}', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          indent: 30,
                          endIndent: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.admin_panel_settings, color: Colors.lightBlue,),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Employment Number', style: TextStyle(fontWeight: FontWeight.w800),),
                                  Text('${employmentNumber}', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          indent: 30,
                          endIndent: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.card_membership_rounded, color: Colors.lightBlue,),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Membership Number', style: TextStyle(fontWeight: FontWeight.w800),),
                                  Text('${membershipNumber}', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          indent: 30,
                          endIndent: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.confirmation_number, color: Colors.lightBlue,),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ID Number', style: TextStyle(fontWeight: FontWeight.w800),),
                                  Text('${IDNumber}', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          indent: 30,
                          endIndent: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.account_circle, color: Colors.lightBlue,),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Designation', style: TextStyle(fontWeight: FontWeight.w800),),
                                  Text('${designation}', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          indent: 30,
                          endIndent: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.location_city_rounded, color: Colors.lightBlue,),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('location', style: TextStyle(fontWeight: FontWeight.w800),),
                                  Text('${location}', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          indent: 30,
                          endIndent: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.phone, color: Colors.lightBlue,),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w800),),
                                  Text('${phoneNumber}', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          indent: 30,
                          endIndent: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(Icons.email_rounded, color: Colors.lightBlue,),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email', style: TextStyle(fontWeight: FontWeight.w800),),
                                  Text('${user.email}', style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30,),
                        Divider(
                          thickness: 1,
                          indent: 30,
                          endIndent: 30,
                        ),
                      ],
                    ):
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(2, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('EDIT YOUR PROFILE',
                                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14, color: Colors.lightBlue)),
                            ),
                            Divider(
                              indent: 12,
                              endIndent: 12,
                              thickness: 1,
                            ),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget> [
                                  Padding(
                                      padding: EdgeInsets.all(12),
                                      child:
                                      TextFormField(
                                        focusNode: f1,
                                        keyboardType: TextInputType.text,
                                        controller: employmentNumberHolder,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Colors.lightBlueAccent.shade100,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(20))
                                          ),
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          hintText: "What is your Employment Number?",
                                          labelText: "${employmentNumber}",
                                          helperText: 'Edit Your Employment Number',
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
                                        focusNode: f2,
                                        keyboardType: TextInputType.text,
                                        controller: memberShipNumberHolder,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Colors.lightBlueAccent.shade100,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(20))
                                          ),
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          hintText: "What is your Welfare membership Number ?",
                                          labelText: "${membershipNumber}",
                                          helperText: 'Edit Your Membership number',
                                        ),
                                        onChanged: (value) {
                                          membershipNumber = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty){
                                            return "Please enter your Membership number";
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
                                        keyboardType: TextInputType.number,
                                        controller: IDNumberHolder,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Colors.lightBlueAccent.shade100,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(20))
                                          ),
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          hintText: "What is your National ID Number ?",
                                          labelText: "${IDNumber}",
                                          helperText: 'Edit Your National ID Number',
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
                                      padding: EdgeInsets.all(12),
                                      child:
                                      TextFormField(
                                        focusNode: f4,
                                        keyboardType: TextInputType.text,
                                        controller: designationHolder,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Colors.lightBlueAccent.shade100,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(20))
                                          ),
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          hintText: "What is your Designation (Mr./Mrs./Miss) ?",
                                          labelText: "${designation}",
                                          helperText: 'Edit Your Designation (Mr./Mrs./Miss)',
                                        ),
                                        onChanged: (value) {
                                          designation = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty){
                                            return "Please enter your Designation (Mr./Mrs./Miss)";
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
                                        controller: locationHolder,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Colors.lightBlueAccent.shade100,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(20))
                                          ),
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          hintText: "Where is your work station ?",
                                          labelText: "${location}",
                                          helperText: 'Edit Your work station',
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
                                  Padding(
                                      padding: EdgeInsets.all(12),
                                      child:
                                      TextFormField(
                                        focusNode: f6,
                                        keyboardType: TextInputType.number,
                                        controller: phoneNumberHolder,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25.0),
                                            borderSide: BorderSide(
                                              color: Colors.lightBlueAccent.shade100,
                                              width: 2.0,
                                            ),
                                          ),
                                          //isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(20))
                                          ),
                                          //icon: Icon(Icons.redeem, size: 20,color: Colors.lightBlue,),
                                          hintText: "What is your official Mpesa Number ?",
                                          labelText: "${phoneNumber}",
                                          helperText: 'Edit Your official Mpesa Number',
                                        ),
                                        onChanged: (value) {
                                          phoneNumber = value;
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty){
                                            return "Please enter your official Mpesa Number";
                                          }
                                          return null;
                                        },
                                      )
                                  ),
                                  SizedBox(height: 10,),
                                  Divider(
                                    thickness: 1,
                                    indent: 30,
                                    endIndent: 30,
                                  ),
                                  SizedBox(height: 5,),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
          ),

        ),

            ),

      ),
    );
  }

  Widget BuildFloatingActionEditButton() {
    final Size size = MediaQuery
        .of(context)
        .size;
    return Container(

      child: Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: FloatingActionButton.extended(
          onPressed: (){
            setState(() {
              editProfile = true;
             });
          },
        backgroundColor: Theme.of(context).dialogBackgroundColor, //Colors.lightBlue,
        elevation: 5,
        label:editProfile == false ? Text('Edit my Profile',
            style: TextStyle(fontWeight:FontWeight.bold,color:Colors.lightBlue))
        :Text('Submit',
            style: TextStyle(fontWeight:FontWeight.bold,color:Colors.lightBlue)),
        icon: Icon(
            Icons.edit,
            color:Colors.lightBlue,
            size: 20,
        ),
          ),
  ),
    );
  }
  Widget BuildFloatingActionSubmitButton() {
    final Size size = MediaQuery
        .of(context)
        .size;
    return Container(

      child: Padding(
        padding: EdgeInsets.only(bottom: 5),
        child: FloatingActionButton.extended(
          onPressed: (){
              submitProfileDialog();
          },
          backgroundColor: Theme.of(context).dialogBackgroundColor, //Colors.lightBlue,
          elevation: 5,
          label: Text('Submit',
              style: TextStyle(fontWeight:FontWeight.bold,color:Colors.lightBlue)),
          icon: Icon(
            Icons.done,
            color:Colors.lightBlue,
            size: 20,
          ),
        ),
      ),
    );
  }
}

