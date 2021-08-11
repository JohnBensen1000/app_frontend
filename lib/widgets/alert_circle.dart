import 'package:flutter/material.dart';

import '../globals.dart' as globals;

class AlertCircle extends StatelessWidget {
  AlertCircle({@required this.diameter, @required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: diameter,
      width: diameter,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(globals.size.height), color: color
          // color: globals.user.profileColor,
          ),
    );
  }
}
