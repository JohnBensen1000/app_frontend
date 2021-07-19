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
      Container(
        width: double.infinity,
      ),
      Container(
        width: 112.0,
        height: 105.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/Entropy.PNG'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    ]);
  }
}
