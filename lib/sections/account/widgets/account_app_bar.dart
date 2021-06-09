import 'package:flutter/material.dart';

import '../../../widgets/back_arrow.dart';

class AccountAppBar extends PreferredSize {
  final double height;

  AccountAppBar({@required this.height});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Container(
        width: double.infinity,
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(top: 20, left: 40),
        child: GestureDetector(
            child: BackArrow(), onTap: () => Navigator.pop(context)),
      ),
      SizedBox(
        width: 161.0,
        child: Text(
          'Entropy',
          style: TextStyle(
            fontFamily: 'Devanagari Sangam MN',
            fontSize: 40,
            color: const Color(0xff000000),
            shadows: [
              Shadow(
                color: const Color(0x29000000),
                offset: Offset(0, 3),
                blurRadius: 6,
              )
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        width: double.infinity,
      ),
      Container(
        width: 112.0,
        height: 105.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
          // image: DecorationImage(
          //   image: const AssetImage(''),
          //   fit: BoxFit.cover,
          // ),
          border: Border.all(width: 3.0, color: const Color(0xff1de0e0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x29000000),
              offset: Offset(0, 5),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    ]);
  }
}
