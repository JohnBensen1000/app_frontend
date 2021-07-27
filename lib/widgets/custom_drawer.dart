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

    return ChangeNotifierProvider(
        create: (context) => CustomDrawerProvider(),
        child: Consumer<CustomDrawerProvider>(
            builder: (context, provider, child) => Stack(children: <Widget>[
                  Container(
                      color: Colors.grey[900].withOpacity(.6),
                      width: width,
                      height: height),
                  Row(
                    children: [
                      Transform.translate(
                        offset: Offset(provider.xOffset * -drawerWidth, 0),
                        child: Container(
                            width: drawerWidth,
                            color: Colors.white,
                            child: widget.child),
                      ),
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

class CustomDrawerButton extends StatelessWidget {
  // Generic widget used for all buttons on the custom drawer page.

  CustomDrawerButton(
      {@required this.buttonName,
      @required this.onPressed,
      this.fontColor = Colors.black});

  final String buttonName;
  final Function onPressed;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: .01 * globals.size.height),
        width: .49 * globals.size.width,
        height: .036 * globals.size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(globals.size.height),
          color: const Color(0xffffffff),
          border: Border.all(width: 1.0, color: const Color(0xff707070)),
        ),
        child: Center(
            child: Text(buttonName,
                style: TextStyle(
                    fontSize: .018 * globals.size.height, color: fontColor))),
      ),
      onTap: onPressed,
    );
  }
}
