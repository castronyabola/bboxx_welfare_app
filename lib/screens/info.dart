import 'dart:async';
import 'package:bboxx_welfare_app/utils/user_simple_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InfoPage extends StatefulWidget {
  InfoPage({Key key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final user = FirebaseAuth.instance.currentUser;
  String language = "English";

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    language = UserSimplePreferences.getLanguage() ?? '';
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
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    double var12 = size.height * 0.0185;

    return Scaffold(
     // drawer: SettingsPage(),
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.lightBlue),
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 50,
        title: Text("App Info",style:TextStyle(fontWeight:FontWeight.w800,color: Colors.lightBlue, fontSize: 18)),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        //color:Theme.of(context).scaffoldBackgroundColor,
        //height: size.height,
        //width: size.width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal:12,vertical: size.height *0.075),
          child: Container(
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
            // color:Theme.of(context).scaffoldBackgroundColor,
            // height: size.height * 0.85,
            // width: size.width,
            child: Padding(
              padding: EdgeInsets.only(top:var12*2.5),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                      height: 30,
                      width: 30,
                      child: Image.asset('android/assets/images/Bboxx_icon.png')
                  ),
                  Padding(
                    padding: EdgeInsets.all(var12),
                    child: Text("Bboxx Welfare",style: TextStyle(fontWeight:FontWeight.w600,fontSize: 16),textAlign: TextAlign.center,),
                  ),
                  Padding(
                    padding: EdgeInsets.all(var12),
                    child: Text('''Bboxx Welfare app manages welfare loans and savings.'''
                        ,style: TextStyle(fontSize: 16,),textAlign: TextAlign.center,)
                  ),
                  SizedBox(height: var12),
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: var12),
                    child:
                    _infoTile('Build number', _packageInfo.buildNumber)
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: var12),
                    child:
                    _infoTile('Build signature', _packageInfo.buildSignature)
                  ),
                  SizedBox(height:var12*4),
                  Padding(
                    padding: EdgeInsets.all(var12),
                    child:
                    Text("2021. GLOBSOKO LTD. ALL RIGHTS RESERVED",
                        textAlign: TextAlign.center, style: TextStyle(fontWeight:FontWeight.w600,
                            fontSize: 12,color: Colors.lightBlue))
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}