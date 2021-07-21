import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

import '../globals.dart' as globals;

class ForwardArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: .0687 * globals.size.height,
        height: .0687 * globals.size.height,
        padding: EdgeInsets.all(.0118 * globals.size.height),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
          // color: const Color(0xffffffff),
          border: Border.all(width: 2.0, color: const Color(0xff000000)),
        ),
        child: SvgPicture.string(
          _svg_eqywfy,
          allowDrawingOutsideViewBox: true,
        ));
  }
}

const String _svg_eqywfy =
    '<svg viewBox="173.5 670.5 28.0 18.0" ><path transform="translate(173.5, 679.5)" d="M 0 0 L 28 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(190.5, 679.5)" d="M 0 9 L 11 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(190.5, 670.5)" d="M 11 9 L 0 0" fill="none" stroke="#707070" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
