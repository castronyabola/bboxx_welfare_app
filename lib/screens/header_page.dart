import 'package:bboxx_welfare_app/models/Account.dart';
import 'package:bboxx_welfare_app/screens/Home.dart';
import 'package:bboxx_welfare_app/screens/myProfile.dart';
import 'package:bboxx_welfare_app/screens/pageHandler.dart';
import 'package:bboxx_welfare_app/utils/user_simple_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:bboxx_welfare_app/icon_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HeaderPage extends StatefulWidget {
  static const keyDarkMode = 'key-dark-mode';

  @override
  State<HeaderPage> createState() => _HeaderPageState();
}

class _HeaderPageState extends State<HeaderPage> {
  final user = FirebaseAuth.instance.currentUser;
  final googleSignIn = GoogleSignIn();
  String phoneNumber;

  String myName = '';
  String membershipNumber = '';

  List<Account> _accountDetails = [];

  List<Account> getAccount() {
    return _accountDetails;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }
  Future <void> getData() async {
    await FirebaseFirestore.instance.collection("phoneNumbers").doc(
        user.email).get().then((value) {
      if (!mounted) return;
      setState(() {
        phoneNumber = value['phoneNumber'];
      });
    });
    await FirebaseFirestore.instance.collection("welfareUsers").doc(phoneNumber).get().then((value){
      setState(() {
      myName = value["myName"];
      membershipNumber = value["membershipNumber"];
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: buildUser(context),
        ),
        SizedBox(height: size.height*0.02),
        Divider(
          thickness: 1,
        ),
        SizedBox(height: size.height*0.05),
        buildDarkMode(),
      ],
    );
  }

  Widget buildDarkMode() {
    return SwitchSettingsTile(
        enabledLabel: "Dark Mode",
        disabledLabel: "Light Mode",
        settingKey: HeaderPage.keyDarkMode,
        leading: IconWidget(
          icon: Icons.dark_mode,
          //color: Colors.lightBlue,
        ),
        title: 'Mode',
        onChange: (_) {},
      );
  }

  Widget buildHeader() {
    return Container(
      child: Center(
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ),
    );
  }

  Widget buildUser(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
     return myName == '' ?
         SizedBox(
           height: 30,
             width: 30,
             child: CircularProgressIndicator(
               backgroundColor: Colors.lightBlueAccent,
               strokeWidth: 2,
             )
         )
     :InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Initicon(
              elevation: 5,
              color: Colors.lightBlue,
              backgroundColor: Colors.lightBlueAccent.shade100,
              text: myName,
              size: 50,
            ),
          ),
          //SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  myName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  membershipNumber,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 25,),
          Icon(
              Icons.chevron_right,
              color: Colors.lightBlue,
              size: 30,),
        ],
      ),
      onTap: () {
        //Utils.showSnackBar(context, 'Clicked Logout');
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyProfile())
        );
      },
    );
  }
}
