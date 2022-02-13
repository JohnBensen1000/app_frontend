import 'package:flutter/material.dart';
import 'package:test_flutter/widgets/forward_arrow.dart';

import '../../../globals.dart' as globals;

import '../widgets/account_app_bar.dart';

class AccountInputPage extends StatefulWidget {
  final Widget child;
  final Function onTap;
  final bool activateKeyboard;

  AccountInputPage(
      {@required this.child,
      @required this.onTap,
      this.activateKeyboard = true});

  @override
  State<AccountInputPage> createState() => _AccountInputPageState();
}

class _AccountInputPageState extends State<AccountInputPage> {
  @override
  Widget build(BuildContext context) {
    double titleBarHeight = .25;
    double forwardButtonHeight = .15;

    bool keyboardActivated = (MediaQuery.of(context).viewInsets.bottom != 0.0);
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AccountAppBar(height: titleBarHeight * globals.size.height),
      body: Center(
          child: Column(children: <Widget>[
        Container(
            padding: EdgeInsets.only(
              top: .01 * globals.size.height,
            ),
            height: (keyboardActivated)
                ? (1 - titleBarHeight) * globals.size.height - keyboardHeight
                : (1 - titleBarHeight - forwardButtonHeight) *
                    globals.size.height,
            child: widget.child),
        if (widget.activateKeyboard && keyboardActivated == false)
          Container(
            height: forwardButtonHeight * globals.size.height,
            alignment: Alignment.topCenter,
            child: GestureDetector(
              child: ForwardArrow(),
              onTap: () => widget.onTap(),
            ),
          )
      ])),
    );
  }
}
