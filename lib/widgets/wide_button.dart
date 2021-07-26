import 'package:flutter/material.dart';

import '../globals.dart' as globals;

class WideButton extends StatelessWidget {
  WideButton({@required this.buttonName});

  final String buttonName;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        width: .75 * globals.size.width,
        height: .05 * globals.size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(globals.size.height),
          color: const Color(0xffffffff),
          border: Border.all(width: 1.0, color: Colors.grey[400]),
          boxShadow: [
            BoxShadow(
              color: const Color(0x29000000),
              blurRadius: .01 * globals.size.width,
            ),
          ],
        ),
        child: Center(
          child: Text(
            buttonName,
            style: TextStyle(
              fontFamily: 'Devanagari Sangam MN',
              fontSize: .03 * globals.size.height,
              color: const Color(0xff707070),
            ),
          ),
        ),
      ),
    );
  }
}
