import 'package:flutter/material.dart';

import '../globals.dart' as globals;

class AlertCircle extends StatelessWidget {
  AlertCircle({@required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: .01 * globals.size.height,
      width: .01 * globals.size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(globals.size.height),
        color: globals.user.profileColor,
      ),
    );
  }
}
