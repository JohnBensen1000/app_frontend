import 'package:flutter/material.dart';

class AddCommentButton extends StatelessWidget {
  AddCommentButton({@required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 343.0,
      height: 52.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.0),
        color: const Color(0xffffffff),
        border: Border.all(width: 1.0, color: const Color(0xff000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Container(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }
}
