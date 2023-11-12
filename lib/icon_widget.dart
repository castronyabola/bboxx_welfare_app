import 'package:flutter/material.dart';

class IconWidget extends StatelessWidget {
  final IconData icon;
  final Color color;

  const IconWidget({
    Key key,
    this.icon,
    this.color,
  }) : super (key: key);

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery
        .of(context)
        .size;
    double var12 = size.height * 0.0185;

    return Container(
      padding: EdgeInsets.all(var12*0.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,

      ),
      child: Icon(icon, color: Colors.lightBlue),
    );
  }

}
