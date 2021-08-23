import 'package:flutter/material.dart';
import '../../../globals.dart' as globals;

class ProfilePageHeaderButton extends StatelessWidget {
  const ProfilePageHeaderButton(
      {Key key,
      @required this.name,
      @required this.color,
      @required this.borderColor,
      @required this.width})
      : super(key: key);

  final String name;
  final Color color;
  final Color borderColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: .034 * globals.size.height,
      width: width,
      decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2.0),
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(globals.size.height))),
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            fontFamily: 'Helvetica Neue',
            fontSize: .024 * globals.size.height,
            color: const Color(0xff000000),
          ),
        ),
      ),
    );
  }
}
