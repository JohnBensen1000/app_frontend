import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_page.dart';
import 'settings.dart';

class SettingsDrawerProvider extends ChangeNotifier {
  // Controls animation for opening and closing the settings widget. When
  // xOffset equals 1, the settings widget is completely off the page. when
  // it equals 0, the settings widget is completely on the page, with the left
  // side of the widget aligned with the left side of the screen.

  SettingsDrawerProvider() {
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

class SettingsDrawer extends StatefulWidget {
  // Places a semi-transparent container on top of the profile page. On top of
  // this, retuns a row of two widgets: a Settings widget and a transparent
  // button. When this button is pressed, the settings widget is closed.

  SettingsDrawer({Key key, @required this.width}) : super(key: key);

  final double width;

  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  Settings settings;

  @override
  void initState() {
    super.initState();
    settings = new Settings(
      width: widget.width,
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    ProfileProvider profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    return ChangeNotifierProvider(
        create: (context) => SettingsDrawerProvider(),
        child: Consumer<SettingsDrawerProvider>(
            builder: (context, settingsDrawerProvider, child) =>
                Stack(children: <Widget>[
                  Container(
                      color: Colors.grey[900].withOpacity(.6),
                      width: width,
                      height: height),
                  Row(
                    children: [
                      Transform.translate(
                        offset: Offset(
                            settingsDrawerProvider.xOffset * -widget.width, 0),
                        child: settings,
                      ),
                      GestureDetector(
                          child: Container(
                            color: Colors.transparent,
                            width: width - widget.width,
                          ),
                          onTap: () async {
                            await settingsDrawerProvider.animateExit();
                            profileProvider.isSettingsOpen = false;
                          })
                    ],
                  )
                ])));
  }
}
