import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../globals.dart' as globals;

class AccountInputPageWrapper extends StatefulWidget {
  final Widget child;
  final Function onTap;
  final String headerText;

  AccountInputPageWrapper({
    Key key,
    @required this.child,
    @required this.onTap,
    @required this.headerText,
  }) : super(key: key);

  @override
  State<AccountInputPageWrapper> createState() =>
      _AccountInputPageWrapperState();
}

class _AccountInputPageWrapperState extends State<AccountInputPageWrapper> {
  bool _allowTap;

  @override
  void initState() {
    _allowTap = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: UniqueKey(),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction == 1.0) {
            _allowTap = true;
          } else {
            _allowTap = false;
          }
        },
        child: AccountInputPage(
            headerText: widget.headerText, child: widget.child, onTap: _onTap));
  }

  Future<void> _onTap() async {
    if (_allowTap) {
      widget.onTap();
      _allowTap = false;
    }
  }
}

class AccountInputPage extends StatelessWidget {
  final Widget child;
  final Function onTap;
  final String headerText;

  AccountInputPage({
    @required this.child,
    @required this.onTap,
    @required this.headerText,
  });
  final KeyboardVisibilityController keyboardController =
      KeyboardVisibilityController();

  bool _hasBeenTapped = false;

  @override
  Widget build(BuildContext context) {
    double titleBarHeight = .34;
    double forwardButtonHeight = .15;

    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    bool isKeyboardActivated =
        (MediaQuery.of(context).viewInsets.bottom != 0.0);

    keyboardController.onChange
        .listen((isActivated) => _onKeyboardChange(isActivated));

    return Scaffold(
        body: Stack(
      children: [
        Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Container(
            height: titleBarHeight * globals.size.height,
            child: Container(
              padding: EdgeInsets.only(
                left: .08 * globals.size.width,
                top: .08 * globals.size.height,
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
          ),
          Container(
              padding: EdgeInsets.only(
                top: .01 * globals.size.height,
              ),
              height: (isKeyboardActivated)
                  ? (1 - titleBarHeight) * globals.size.height - keyboardHeight
                  : (1 - titleBarHeight - forwardButtonHeight) *
                      globals.size.height,
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
              _progressIndicator(6),
            ],
          ),
        )
      ],
    ));
  }

  void _onKeyboardChange(bool isActivated) {
    if (!isActivated && onTap != null && !_hasBeenTapped) {
      onTap();
      _hasBeenTapped = true;
    }
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

  Widget _progressIndicator(int pageNum) {
    List<Widget> widgets = List.filled(8, _progressIndicatorCircle(false));

    return Container();
    // return Container(width: 200, height: 50, color: Colors.red);
    // return Row(
    //   children: widgets,
    // );
  }

  Widget _progressIndicatorCircle(bool isActivated) {
    return Container(
      width: 5.0,
      height: 5.0,
      decoration: new BoxDecoration(
          color: isActivated ? Colors.white : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[700])),
    );
  }
}
