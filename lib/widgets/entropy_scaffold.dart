import 'package:flutter/material.dart';
import '../../globals.dart' as globals;
import '../models/post.dart';
import '../sections/post/post_widget.dart';

class EntropyScaffold extends StatelessWidget {
  EntropyScaffold(
      {@required this.body,
      this.disableAutoPadding = false,
      this.hidePostWithOpacity = false,
      this.drawer,
      this.backgroundWidget,
      this.backgroundColor = Colors.white});

  final Widget body;
  final Widget drawer;
  final Color backgroundColor;
  final Widget backgroundWidget;
  final bool hidePostWithOpacity;
  final bool disableAutoPadding;

  @override
  Widget build(BuildContext context) {
    double padding = 0;

    if (globals.size != null && disableAutoPadding == false) {
      padding += (MediaQuery.of(context).size.width - globals.size.width) / 2;
      padding += .02 * MediaQuery.of(context).size.width;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(children: <Widget>[
        if (backgroundWidget != null) backgroundWidget,
        if (hidePostWithOpacity)
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white.withOpacity(.7),
          ),
        Container(
            margin: EdgeInsets.only(
              left: padding,
              right: padding,
            ),
            child: Center(child: body))
      ]),
      drawer: drawer,
    );
  }
}
