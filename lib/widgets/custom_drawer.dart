import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../globals.dart' as globals;

class CustomDrawerProvider extends ChangeNotifier {
  // Controls animation for opening and closing the settings widget. When
  // xOffset equals 1, the custom drawer is completely off the page. when
  // it equals 0, the settings widget is completely on the page, with the left
  // side of the widget aligned with the left side of the screen.

  CustomDrawerProvider() {
    animateEntrance();
  }

  double xOffset = 1;
  double deltaX = .009;

  Future<void> animateEntrance() async {
    while (xOffset >= 0) {
      xOffset -= deltaX;
      await Future.delayed(Duration(milliseconds: 1));
      notifyListeners();
    }
  }

  Future<void> animateExit() async {
    while (xOffset <= 1) {
      xOffset += deltaX;
      await Future.delayed(Duration(milliseconds: 1));
      notifyListeners();
    }
  }
}

class CustomDrawer extends StatefulWidget {
  // Custom widget for drawers used in the app. When built, slides to from the
  // left side of the page. The drawer covers about 70% of the screen width and
  // 100% of the screen height. The rest of the screen is covered by a
  // semitransparent container that, when tapped, closes the drawer. The widget
  // 'child' is displayed on top of the drawer.

  CustomDrawer({Key key, @required this.child, @required this.parentProvider})
      : super(key: key);

  final Widget child;
  var parentProvider;

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double drawerWidth = .7 * globals.size.width;

    Widget childWidget =
        Container(width: drawerWidth, color: Colors.white, child: widget.child);

    return ChangeNotifierProvider(
        create: (context) => CustomDrawerProvider(),
        child: Consumer<CustomDrawerProvider>(
            builder: (context, provider, child) => Stack(children: <Widget>[
                  Container(
                      color: Colors.grey[900]
                          .withOpacity(.01 + .7 * (1 - provider.xOffset)),
                      width: width,
                      height: height),
                  Row(
                    children: [
                      Transform.translate(
                          offset: Offset(provider.xOffset * -drawerWidth, 0),
                          child: childWidget),
                      GestureDetector(
                          child: Container(
                            color: Colors.transparent,
                            width: width - drawerWidth,
                          ),
                          onTap: () async {
                            await provider.animateExit();
                            widget.parentProvider.isDrawerOpen = false;
                          })
                    ],
                  ),
                ])));
  }
}
