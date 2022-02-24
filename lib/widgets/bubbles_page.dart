import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../globals.dart' as globals;
import '../../../widgets/back_arrow.dart';

class BubblesPage extends StatelessWidget {
  final Widget child;
  final String headerText;
  final double height;
  final bool showBackArrow;

  BubblesPage({
    @required this.child,
    @required this.headerText,
    @required this.height,
    this.showBackArrow = true,
  });
  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    bool isKeyboardActivated =
        (MediaQuery.of(context).viewInsets.bottom != 0.0);
    return Scaffold(
        body: Stack(
      children: [
        Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: .08 * globals.size.width,
            ),
            height: height * globals.size.height,
            child: Column(
              children: [
                if (showBackArrow)
                  Container(
                      width: double.infinity,
                      alignment: Alignment.bottomLeft,
                      height: .08 * globals.size.height,
                      child: GestureDetector(
                          child: BackArrow(),
                          onTap: () => Navigator.pop(context)))
                else
                  Container(
                    width: double.infinity,
                    height: .08 * globals.size.height,
                  ),
                Container(
                  padding: EdgeInsets.only(
                    top: .02 * globals.size.height,
                  ),
                  width: double.infinity,
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontFamily: 'Helvetica Neue',
                        fontSize: 42,
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
        Transform.translate(
          offset: Offset(0, .8 * globals.size.height),
          child: Stack(
            // alignment: Alignment.bottom,
            children: [
              Container(
                width: double.infinity,
                child: Stack(children: <Widget>[
                  _circleWidget(context, -.19, .1, const Color(0x2cffadbf)),
                  _circleWidget(context, -.01, .05, const Color(0x2c1365d1)),
                  _circleWidget(context, .01, .14, const Color(0x2c00f8fe)),
                  _circleWidget(context, .12, .09, const Color(0x2cffc900)),
                  _circleWidget(context, .27, .12, const Color(0x2cf7000e)),
                  _circleWidget(context, .21, .04, const Color(0x2cff4800)),
                  _circleWidget(context, .43, .10, const Color(0x2c1365d1)),
                  _circleWidget(context, .37, .03, const Color(0x2cffadbf)),
                  _circleWidget(context, .54, .13, const Color(0x2c00f8fe)),
                  _circleWidget(context, .56, .05, const Color(0x2cf7000e)),
                  _circleWidget(context, .65, .11, const Color(0x2cffc900)),
                  _circleWidget(context, .79, .04, const Color(0x2c1365d1)),
                  _circleWidget(context, .81, .11, const Color(0x2cffadbf)),
                ]),
              ),
            ],
          ),
        )
      ],
    ));
  }

  Widget _circleWidget(BuildContext context, double x, double y, Color color) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Transform.translate(
      offset: Offset(x * width, y * height),
      child: Container(
        width: 101,
        height: 101,
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
