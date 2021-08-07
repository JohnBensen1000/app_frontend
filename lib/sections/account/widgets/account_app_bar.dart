import 'package:flutter/material.dart';

import '../../../widgets/back_arrow.dart';
import '../../../globals.dart' as globals;

class AccountAppBar extends PreferredSize {
  final double height;

  AccountAppBar({@required this.height});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Container(
          width: double.infinity,
          alignment: Alignment.topLeft,
          margin: EdgeInsets.only(left: .1 * globals.size.width),
          child: GestureDetector(
              child: BackArrow(), onTap: () => Navigator.pop(context)),
        ),
        Container(
          width: double.infinity,
        ),
        Container(
          width: .125 * globals.size.height,
          height: .125 * globals.size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/Entropy_small.PNG'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ]),
    );
  }
}
