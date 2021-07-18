import 'package:flutter/material.dart';

class GenericAlertDialog extends StatelessWidget {
  const GenericAlertDialog({@required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          padding: EdgeInsets.all(10),
          width: 300,
          height: 200,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(.85)),
          child: Center(
              child: Text(
            text,
            textAlign: TextAlign.center,
          )),
        ));
  }
}
