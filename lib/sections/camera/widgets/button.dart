import 'package:flutter/material.dart';

import '../../../globals.dart' as globals;

class Button extends StatelessWidget {
  const Button({
    Key key,
    @required this.buttonName,
  }) : super(key: key);

  final String buttonName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: .231 * globals.size.width,
      height: .0533 * globals.size.height,
      decoration: new BoxDecoration(
        borderRadius:
            BorderRadius.all(Radius.circular(.0118 * globals.size.height)),
        color: Colors.grey[200],
      ),
      child: Center(
          child: Text(buttonName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: .0213 * globals.size.height))),
    );
  }
}
