import 'package:flutter/material.dart';

import '../globals.dart' as globals;

class GenericAlertDialog extends StatelessWidget {
  const GenericAlertDialog({@required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          width: .769 * globals.size.width,
          height: .237 * globals.size.height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(.0237 * globals.size.height),
              color: Colors.white.withOpacity(.85)),
          child: Center(
              child: Text(
            text,
            textAlign: TextAlign.center,
          )),
        ));
  }
}
