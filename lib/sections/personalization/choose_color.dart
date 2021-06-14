import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../API/methods/users.dart';
import '../../widgets/back_arrow.dart';

class ColorsProvider extends ChangeNotifier {
  // Keeps track of the chosen color. If the user selects a color that is
  // currently chosen, then sets chosen color to null.

  String _chosenColorKey;

  String get chosenColorKey => _chosenColorKey;

  set chosenColorKey(String newColorKey) {
    if (newColorKey == _chosenColorKey)
      _chosenColorKey = null;
    else
      _chosenColorKey = newColorKey;

    notifyListeners();
  }
}

class ColorsPage extends StatelessWidget {
  // Determines layout of colors page. The colors page is divided into three
  // sections: header, body, and footer. The header contains text saying what
  // the user should do. The body contains a set of colors for the user to
  // choose from. The footer contains a button that lets the user save the
  // chosen color as their profile color.

  @override
  Widget build(BuildContext context) {
    double headerHeight = 180;
    double footerHeight = 340;
    double bodyHeight =
        MediaQuery.of(context).size.height - headerHeight - footerHeight;

    return ChangeNotifierProvider(
        create: (context) => ColorsProvider(),
        child: Scaffold(
            body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
            ),
            ChooseColorHeader(height: headerHeight),
            ChooseColorBody(height: bodyHeight),
            ChooseColorFooter(
              height: footerHeight,
            ),
          ],
        )));
  }
}

class ChooseColorHeader extends StatelessWidget {
  const ChooseColorHeader({
    @required this.height,
    Key key,
  }) : super(key: key);

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 30, left: 40),
              child: GestureDetector(
                child: BackArrow(),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        Text(
          'Pick your style',
          style: TextStyle(
            fontFamily: 'Helvetica Neue',
            fontSize: 49,
            color: const Color(0xff000000),
          ),
          textAlign: TextAlign.left,
        ),
      ]),
    );
  }
}

class ChooseColorBody extends StatelessWidget {
  ChooseColorBody({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    List<ChooseColorWidget> chooseColorWidgets = new List<ChooseColorWidget>();

    globals.colorsMap
        .forEach((key, value) => chooseColorWidgets.add(ChooseColorWidget(
              colorKey: key,
              color: value,
              height: 110,
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
    double deltaHeight = .15 * height;

    return Consumer<ColorsProvider>(
      builder: (context, provider, child) {
        bool isChosen = provider.chosenColorKey == colorKey;
        double adjustedHeight = (isChosen) ? height - deltaHeight : height;
        double adjustedMargin = (isChosen) ? 5 + .5 * deltaHeight : 5;

        return GestureDetector(
            child: Container(
              margin: EdgeInsets.all(adjustedMargin),
              width: adjustedHeight,
              height: adjustedHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(.25 * adjustedHeight),
                color: color,
                border: Border.all(width: 1.0, color: const Color(0xff707070)),
              ),
            ),
            onTap: () => provider.chosenColorKey = colorKey);
      },
    );
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
              padding: EdgeInsets.only(bottom: 40),
              height: height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'The color you select will be used throughout your entire profile.',
                      style: TextStyle(
                        fontFamily: 'Helvetica Neue',
                        fontSize: 15,
                        color: const Color(0xff000000),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                      child: Container(
                        height: 35,
                        width: 105,
                        margin: EdgeInsets.all(40),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: (provider.chosenColorKey != null)
                                    ? globals.colorsMap[provider.chosenColorKey]
                                    : Colors.grey[400],
                                width: 2),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Center(
                          child: Text("Set Color"),
                        ),
                      ),
                      onTap: () async {
                        await updateColor(provider.chosenColorKey);
                        globals.user.profileColor =
                            globals.colorsMap[provider.chosenColorKey];
                        Navigator.pop(context);
                      }),
                  Container(
                      height: 100,
                      child: Image.asset('assets/images/Entropy.PNG'))
                ],
              ),
            ));
  }
}
