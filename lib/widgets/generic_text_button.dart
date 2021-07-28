import 'package:flutter/material.dart';

import '../globals.dart' as globals;

class GenericTextButton extends StatelessWidget {
  // Generic widget used for all buttons on the custom drawer page.

  GenericTextButton(
      {@required this.buttonName,
      @required this.onPressed,
      this.fontColor = Colors.black});

  final String buttonName;
  final Function onPressed;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: .01 * globals.size.height),
        width: .49 * globals.size.width,
        height: .036 * globals.size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(globals.size.height),
          color: Colors.transparent,
          border: Border.all(width: 1.0, color: const Color(0xff707070)),
        ),
        child: Center(
            child: Text(buttonName,
                style: TextStyle(
                    fontSize: .018 * globals.size.height, color: fontColor))),
      ),
      onTap: onPressed,
    );
  }
}
