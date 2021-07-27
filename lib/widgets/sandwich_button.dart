import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../globals.dart' as globals;

class SandwichButton extends StatelessWidget {
  SandwichButton({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: .04 * globals.size.height,
      child: Center(
        child: SvgPicture.string(
          _svg_eqwtyu,
          allowDrawingOutsideViewBox: true,
        ),
      ),
    );
  }
}

const String _svg_eqwtyu =
    '<svg viewBox="9.0 11.3 17.9 15.5" ><path transform="translate(9.04, 11.25)" d="M 0 0 L 17.92163467407227 0" fill="none" stroke="#000000" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(9.04, 19.0)" d="M 0 0 L 17.92163467407227 0" fill="none" stroke="#000000" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(9.04, 26.75)" d="M 0 0 L 17.92163467407227 0" fill="none" stroke="#000000" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
