import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../globals.dart' as globals;
import '../../../widgets/back_arrow.dart';
import '../../../widgets/bubbles_page.dart';

class AccountInputPageWrapper extends StatefulWidget {
  final Widget child;
  final Function onTap;
  final String headerText;
  final double height;
  final bool showBackArrow;
  final int pageNum;

  AccountInputPageWrapper({
    Key key,
    @required this.child,
    @required this.onTap,
    @required this.headerText,
    @required this.pageNum,
    this.height = .35,
    this.showBackArrow = true,
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
            pageNum: widget.pageNum,
            showBackArrow: widget.showBackArrow,
            height: widget.height,
            headerText: widget.headerText,
            child: widget.child,
            onTap: _onTap));
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
  final double height;
  final bool showBackArrow;
  final int pageNum;

  AccountInputPage({
    @required this.child,
    @required this.onTap,
    @required this.headerText,
    @required this.height,
    @required this.showBackArrow,
    @required this.pageNum,
  });
  final KeyboardVisibilityController keyboardController =
      KeyboardVisibilityController();

  bool _hasBeenTapped = false;

  @override
  Widget build(BuildContext context) {
    keyboardController.onChange
        .listen((isActivated) => _onKeyboardChange(isActivated));
    bool isKeyboardActivated =
        (MediaQuery.of(context).viewInsets.bottom != 0.0);

    return BubblesPage(
        child: child,
        headerText: headerText,
        height: height,
        showBackArrow: showBackArrow);
  }

  void _onKeyboardChange(bool isActivated) {
    if (!isActivated && onTap != null && !_hasBeenTapped) {
      onTap();
      _hasBeenTapped = true;
    }
  }
}
