import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    Key key,
    @required this.buttonName,
  }) : super(key: key);

  final String buttonName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 45,
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.grey[200],
      ),
      child: Center(
          child: Text(buttonName,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 18))),
    );
  }
}
