import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../widgets/bubbles_page.dart';
import '../../widgets/entropy_scaffold.dart';

import '../account/take_profile_pic.dart';

class ColorsProvider extends ChangeNotifier {
  // Keeps track of the chosen color. If the user selects a color that is
  // currently chosen, then sets chosen color to null.

  final bool isPartOfSignUpProcess;

  ColorsProvider({@required this.isPartOfSignUpProcess});

  String _chosenColorKey;

  String get chosenColorKey => _chosenColorKey;

  set chosenColorKey(String newColorKey) {
    if (newColorKey == _chosenColorKey)
      _chosenColorKey = null;
    else
      _chosenColorKey = newColorKey;

    notifyListeners();
  }

  Future<void> setColor(BuildContext context) async {
    if (_chosenColorKey != null) {
      await globals.userRepository.changeColor(_chosenColorKey);

      if (isPartOfSignUpProcess) {
        globals.googleAnalyticsAPI.logPickedColor();

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => TakeProfilePage()));
      } else {
        Navigator.pop(context);
      }
    }
  }
}

class ColorsPage extends StatelessWidget {
  // Determines layout of colors page. The colors page is divided into three
  // sections: header, body, and footer. The header contains text saying what
  // the user should do. The body contains a set of colors for the user to
  // choose from. The footer contains a button that lets the user save the
  // chosen color as their profile color.

  final bool isPartOfSignUpProcess;

  ColorsPage({this.isPartOfSignUpProcess = false});

  @override
  Widget build(BuildContext context) {
    double headerHeight = .23;
    double footerHeight = .37;
    double bodyHeight = MediaQuery.of(context).size.height -
        (headerHeight + footerHeight + .01) * globals.size.height;

    return ChangeNotifierProvider(
        create: (context) =>
            ColorsProvider(isPartOfSignUpProcess: isPartOfSignUpProcess),
        child: WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: BubblesPage(
              showBackArrow: isPartOfSignUpProcess ? false : true,
              headerText: "Pick\nYour Style",
              height: headerHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                  ),
                  ChooseColorBody(height: bodyHeight),
                  ChooseColorFooter(
                    height: footerHeight,
                  ),
                ],
              ),
            )));
  }
}

class ChooseColorBody extends StatelessWidget {
  ChooseColorBody({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    List<ChooseColorWidget> chooseColorWidgets = [];

    globals.colorsMap
        .forEach((key, value) => chooseColorWidgets.add(ChooseColorWidget(
              colorKey: key,
              color: value,
              height: .13 * globals.size.height,
            )));

    return Container(
        height: height,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (chooseColorWidgets.length % 3 > 0)
              ? chooseColorWidgets.length ~/ 3 + 1
              : chooseColorWidgets.length ~/ 3,
          itemBuilder: (context, index) =>
              buildWidgetRow(chooseColorWidgets, 3 * index),
        ));
  }

  Row buildWidgetRow(List<ChooseColorWidget> list, int index) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (ChooseColorWidget widget
          in list.sublist(index, min(index + 3, list.length)))
        widget
    ]);
  }
}

class ChooseColorWidget extends StatelessWidget {
  ChooseColorWidget(
      {@required this.colorKey, @required this.color, @required this.height});

  final String colorKey;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorsProvider>(
      builder: (context, provider, child) {
        bool isChosen = provider.chosenColorKey == colorKey;

        return GestureDetector(
            child: Container(
              margin: EdgeInsets.all(5),
              width: height,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(globals.size.height),
                color: color,
                border: Border.all(
                    width: isChosen ? 10.0 : 0.0, color: darken(color, 10)),
              ),
            ),
            onTap: () => provider.chosenColorKey = colorKey);
      },
    );
  }

  Color darken(Color c, [int fraction = 10]) {
    int diff = [c.red, c.blue, c.green].reduce(max) -
        [c.red, c.blue, c.green].reduce(min);
    int multiplier = 255 - (diff / fraction).round();

    return Color.fromARGB(
        c.alpha,
        (multiplier * (c.red * c.red) / (255 * 255)).round(),
        (multiplier * (c.green * c.green) / (255 * 255)).round(),
        (multiplier * (c.blue * c.blue) / (255 * 255)).round());
  }
}

class ChooseColorFooter extends StatelessWidget {
  const ChooseColorFooter({
    @required this.height,
    Key key,
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorsProvider>(
        builder: (context, provider, child) => Container(
              height: height * globals.size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: .1 * globals.size.width),
                    child: Text(
                      'The color you select will be used throughout your entire profile.',
                      style: TextStyle(
                        fontFamily: 'Helvetica Neue',
                        fontSize: .021 * globals.size.height,
                        color: const Color(0xff000000),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: .05 * globals.size.height),
                    child: GestureDetector(
                        child: Container(
                          height: .045 * globals.size.height,
                          width: .32 * globals.size.width,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: (provider.chosenColorKey != null)
                                      ? globals
                                          .colorsMap[provider.chosenColorKey]
                                      : Colors.grey[400],
                                  width: 2),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(globals.size.height))),
                          child: Center(
                            child: Text(
                              "Set Color",
                              style: TextStyle(
                                fontFamily: 'Helvetica Neue',
                                fontSize: .021 * globals.size.height,
                                color: const Color(0xff000000),
                              ),
                            ),
                          ),
                        ),
                        onTap: () => provider.setColor(context)),
                  ),
                ],
              ),
            ));
  }
}
