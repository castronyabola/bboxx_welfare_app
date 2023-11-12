import 'dart:async';
import 'package:bboxx_welfare_app/utils/user_simple_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';


class About extends StatefulWidget {
  About({Key key}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
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

  Widget _infoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title,style: TextStyle(fontSize: 12)),
      subtitle: Text(subtitle.isEmpty ? 'Not set' : subtitle,style: TextStyle(fontSize: 12)),
      focusColor: Colors.lightBlue,
    );
  }


  @override
  Widget build(BuildContext context){
    final Size size = MediaQuery.of(context).size;
    double var12 = size.height * 0.0185;

    return Scaffold(
      //drawer: SettingsPage(),
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(100),
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.lightBlue),
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 50,
        title: Text("About", style:TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 18)),
        elevation: 3,
      ),
      //backgroundColor: Colors.white12,
      //backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal:size.width*0.015),
        child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.all(var12 * 0.3575),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text('''Bboxx Welfare App is designed for Bboxx Self Help Group members to simplify processes; from viewing your savings, loan balances to application of loans and finding guarantors instantly without having to physically go them. You can now select 3 guarantors of your choice and they are able to approve your loan request by the click of a button. It's also possible to know at a glance how much loan you qualify for from this App. More will be availed as the development continues.''',
                                textAlign: TextAlign.center,style: TextStyle(fontSize: 16)),
                                ),
                            Divider(
                              indent: 10,
                              endIndent: 10,
                              thickness: 1,
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: var12),
                                child:
                                _infoTile('App name', _packageInfo.appName)
                            ),
                            //_infoTile('Package name', _packageInfo.packageName),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: var12),
                                child:
                                _infoTile('App version', _packageInfo.version)
                            ),
                            Divider(
                              indent: 10,
                              endIndent: 10,
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text('gsl 2023. All Rights Reserved.',
                                  style: TextStyle(color:Colors.lightBlue)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
    ),
      ),

    );
}
}