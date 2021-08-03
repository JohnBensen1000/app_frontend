import 'package:flutter/material.dart';

import '../../globals.dart' as globals;

class PostCaption extends StatelessWidget {
  const PostCaption({@required this.text, this.textColor = Colors.white});

  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: .01 * globals.size.height),
        child: Container(
            width: .6 * globals.size.width,
            padding: EdgeInsets.symmetric(
                horizontal: .04 * globals.size.width,
                vertical: .01 * globals.size.height),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.45),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(text,
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: .018 * globals.size.height,
                  color: textColor,
                ))));
  }
}
