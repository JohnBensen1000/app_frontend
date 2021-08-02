import 'package:flutter/material.dart';

import '../../../globals.dart' as globals;

class AddCommentButton extends StatelessWidget {
  AddCommentButton({@required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: .879 * globals.size.width,
      height: .0616 * globals.size.height,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(globals.size.height),
        color: const Color(0xffffffff),
        border: Border.all(width: 1.0, color: const Color(0xff000000)),
      ),
      child: child,
    );
  }
}
