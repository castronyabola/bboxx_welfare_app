

import 'package:bboxx_welfare_app/screens/guarantorApprovals.dart';
import 'package:bboxx_welfare_app/screens/guarantors.dart';
import 'package:bboxx_welfare_app/screens/home.dart';
import 'package:bboxx_welfare_app/screens/loan.dart';
import 'package:bboxx_welfare_app/screens/lockPinPage.dart';
import 'package:bboxx_welfare_app/screens/myProfile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class navigation extends StatefulWidget {
  const navigation({Key key}) : super(key: key);

  @override
  _navigationState createState() => _navigationState();
}

class _navigationState extends State<navigation> {
  int index = 0;
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  final screens = [
    HomePage(),
    LoanPage(),
    Guarantors(),
    GuarantorApprovals(),
  ];

  final items = <Widget> [
    Column(
      children: [
        SizedBox(height: 20,),
        Icon(Icons.home),
        Text('Home', style:TextStyle(fontSize: 10, color: Colors.lightBlue))
      ],
    ),
    Column(
      children: [
        SizedBox(height: 20,),
        Icon(Icons.account_balance_wallet),
        Text('Requests', style:TextStyle(fontSize: 10, color: Colors.lightBlue))
      ],
    ),
    Column(
      children: [
        SizedBox(height: 20,),
        Icon(Icons.account_balance),
        Text('Guarantors', style:TextStyle(fontSize: 10, color: Colors.lightBlue))
      ],
    ),
    Column(
      children: [
        SizedBox(height: 20,),
        Icon(Icons.approval),
        Text('Approvals', style:TextStyle(fontSize: 10, color: Colors.lightBlue))
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBody: true,
      body: screens[index],
      bottomNavigationBar: Theme(
        data:Theme.of(context).copyWith(
          iconTheme: IconThemeData(color:Colors.lightBlue)
        ),
        child: CurvedNavigationBar(
          animationCurve: Curves.easeInOutQuad,
          key: navigationKey,
          color: Theme.of(context).backgroundColor,// Colors.lightBlue,
          buttonBackgroundColor: Colors.transparent,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          height:50,
          items: items,
          index: index,
          onTap: (index) => setState(() => this.index = index),
        ),
      ),
    );
  }
}
