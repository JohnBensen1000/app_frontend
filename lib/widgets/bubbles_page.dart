import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../globals.dart' as globals;
import '../../../widgets/back_arrow.dart';

import 'entropy_scaffold.dart';

class BubblesPage extends StatelessWidget {
  final Widget child;
  final String headerText;
  final double height;
  final bool showBackArrow;
  final double sidePadding;

  BubblesPage({
    @required this.child,
    @required this.headerText,
    @required this.height,
    this.showBackArrow = true,
    this.sidePadding = 0,
  });
  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    bool isKeyboardActivated =
        (MediaQuery.of(context).viewInsets.bottom != 0.0);
    return EntropyScaffold(
        body: Container(
      padding: EdgeInsets.symmetric(horizontal: sidePadding),
      child: Stack(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            Container(
              height: height * globals.size.height,
              child: Column(
                children: [
                  if (showBackArrow)
                    Container(
                        width: double.infinity,
                        alignment: Alignment.bottomLeft,
                        height: .1 * globals.size.height,
                        child: GestureDetector(
                            child: BackArrow(),
                            onTap: () => Navigator.pop(context)))
                  else
                    Container(
                      width: double.infinity,
                      height: .1 * globals.size.height,
                    ),
                  Container(
                    width: double.infinity,
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontFamily: 'Helvetica Neue',
                          fontSize: .05 * globals.size.height,
                          color: const Color(0xff000000),
                        ),
                        children: [
                          TextSpan(
                            text: headerText,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.only(
                  top: .01 * globals.size.height,
                ),
                height: (isKeyboardActivated)
                    ? (1 - height) * globals.size.height - keyboardHeight
                    : (1 - height) * globals.size.height,
                child: child),
          ]),

          if (isKeyboardActivated == false)
            Container(
              alignment: Alignment.bottomCenter,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    child: Stack(children: <Widget>[
                      _circleWidget(context, -.12, 0, const Color(0x2cffadbf)),
                      _circleWidget(
                          context, -.01, -.05, const Color(0x2c1365d1)),
                      _circleWidget(context, .01, .04, const Color(0x2c00f8fe)),
                      _circleWidget(
                          context, .12, -.01, const Color(0x2cffc900)),
                      _circleWidget(context, .27, .02, const Color(0x2cf7000e)),
                      _circleWidget(
                          context, .21, -.06, const Color(0x2cff4800)),
                      _circleWidget(context, .43, 0, const Color(0x2c1365d1)),
                      _circleWidget(
                          context, .37, -.04, const Color(0x2cffadbf)),
                      _circleWidget(context, .54, .03, const Color(0x2c00f8fe)),
                      _circleWidget(
                          context, .56, -.05, const Color(0x2cf7000e)),
                      _circleWidget(context, .65, .01, const Color(0x2cffc900)),
                      _circleWidget(
                          context, .79, -.06, const Color(0x2c1365d1)),
                      _circleWidget(context, .81, .01, const Color(0x2cffadbf)),
                      _circleWidget(
                          context, 1.11, -.06, const Color(0x2cff4800)),
                      _circleWidget(context, .95, .02, const Color(0x2c1365d1)),
                      _circleWidget(
                          context, 1.01, -.04, const Color(0x2cffadbf)),
                    ]),
                  ),
                ],
              ),
            ),
          // )
        ],
      ),
    ));
  }

  Widget _circleWidget(BuildContext context, double x, double y, Color color) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Transform.translate(
      offset: Offset(x * width, y * height),
      child: Container(
        width: .12 * height,
        height: .12 * height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
          color: color.withOpacity(.15),
          border: Border.all(
              width: 1.0, color: const Color(0x2c707070).withOpacity(.1)),
        ),
      ),
    );
  }
}
