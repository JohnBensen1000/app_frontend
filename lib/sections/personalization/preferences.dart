import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:collection';

import 'package:provider/provider.dart';

import '../../globals.dart' as globals;
import '../../API/methods/preferences.dart';
import '../../widgets/back_arrow.dart';
import '../../API/handle_requests.dart';
import '../../widgets/forward_arrow.dart';
import '../../widgets/entropy_scaffold.dart';

class PreferencesProvider extends ChangeNotifier {
  // From a list of preferences field names, creates a Map to keep track of
  // which fields have been selected by the user. When saveNewPreferences() is
  // called, creates a list of all selected field names and calls
  // updateUserPreferences() to send the field names to the backend.

  PreferencesProvider({
    @required List<String> preferencesList,
  }) {
    for (var preference in preferencesList) {
      isPreferenceSelected[preference] = false;
    }
  }

  Map<String, bool> isPreferenceSelected = new HashMap<String, bool>();

  void changedSelectedStatus(String name) {
    isPreferenceSelected[name] = !isPreferenceSelected[name];
    notifyListeners();
  }
}

class PreferencesPage extends StatelessWidget {
  // Gets a list of preference field names from the backend. The preferences
  // page is divided into 3 sections: a header, a body, and a footer.

  @override
  Widget build(BuildContext context) {
    double headerHeight = .2 * globals.size.height;
    double footerHeight = .2 * globals.size.height;
    double bodyHeight =
        MediaQuery.of(context).size.height - headerHeight - footerHeight;

    return EntropyScaffold(
        body: FutureBuilder(
            future: handleRequest(context, getPreferenceFields()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ChangeNotifierProvider(
                    create: (context) =>
                        PreferencesProvider(preferencesList: snapshot.data),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        PreferencesHeader(
                          scaling: .0009 * globals.size.height,
                          height: headerHeight,
                        ),
                        PreferencesBody(
                          height: bodyHeight,
                          // widgetMargin: 5,
                          widgetMargin: .0065 * globals.size.height,
                        ),
                        PreferenceFooter(height: footerHeight)
                      ],
                    ));
              } else {
                return Container();
              }
            }));
  }
}

class PreferencesHeader extends StatelessWidget {
  // Has a back button for leaving the page and some text. The size of the text
  // is controlled by the variable 'scaling'. Every value used to create the
  // text is some constant multiplied by the 'scaling'.

  const PreferencesHeader({
    Key key,
    @required this.scaling,
    @required this.height,
  }) : super(key: key);

  final double scaling;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                    top: .05 * globals.size.height,
                    left: .05 * globals.size.width,
                    bottom: .01 * globals.size.height,
                    right: .01 * globals.size.width),
                alignment: Alignment.topLeft,
                child: GestureDetector(
                    child: BackArrow(), onTap: () => Navigator.pop(context))),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(width: double.infinity),
                  SizedBox(
                    width: scaling * 278.0,
                    child: Text(
                      'What Are You\n\n',
                      style: TextStyle(
                        fontFamily: 'Rockwell',
                        fontSize: scaling * 35,
                        color: const Color(0xff000000),
                        letterSpacing: scaling * -0.84,
                        height: scaling * 0.6285714285714286,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: scaling * 382.0,
                    height: scaling * 63.0,
                    child: SizedBox(
                      width: scaling * 458.0,
                      child: Text(
                        'Interested In?',
                        style: TextStyle(
                          fontFamily: 'Rockwell',
                          fontSize: scaling * 59,
                          color: const Color(0xff000000),
                          letterSpacing: scaling * -1.416,
                          height: scaling * 0.6440677966101694,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ]),
          ],
        ));
  }
}

class PreferencesBody extends StatelessWidget {
  // This widget is passed 2 variables: height and widgetMargin. height is the
  // total height of the body, widgetMargin is how much space there is between
  // two widgets. First determines the height of each individual widget.
  // Then creates a list of all widgets. From this list, creates a list of rows,
  // where each row contains 3 widgets. Extra widgets are put in the last row.

  PreferencesBody({@required this.height, @required this.widgetMargin});
  final double height;
  final double widgetMargin;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double widgetHeight =
        ((width - 8 * widgetMargin) / 3) / globals.goldenRatio;

    return Container(
        height: height,
        child: Consumer<PreferencesProvider>(
          builder: (context, provider, child) {
            List<PreferencesWidget> widgets =
                buildWidgets(widgetHeight, provider.isPreferenceSelected);

            return ListView.builder(
                padding: EdgeInsets.only(top: 0),
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    (provider.isPreferenceSelected.entries.length % 3 > 0)
                        ? widgets.length ~/ 3 + 1
                        : widgets.length ~/ 3,
                itemBuilder: (context, index) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        buildWidgetRow(widgets, 3 * index, widgetHeight)));
          },
        ));
  }

  List<Widget> buildWidgets(
      double widgetHeight, HashMap<String, bool> isPreferenceSelected) {
    List<PreferencesWidget> widgets = [];

    isPreferenceSelected.forEach((key, value) => widgets.add(PreferencesWidget(
        height: widgetHeight,
        margin: widgetMargin,
        name: key,
        isSelected: value)));

    return widgets;
  }

  List<Widget> buildWidgetRow(
      List<PreferencesWidget> list, int index, double widgetHeight) {
    return [
      for (PreferencesWidget widget
          in list.sublist(index, min(index + 3, list.length)))
        widget
    ];
  }
}

class PreferencesWidget extends StatelessWidget {
  // A button for selecting an individual preference widget. If the field has
  // been selected, decrease the height and width of the widget and add a
  // shadow (the margin is increased so the widget takes up the same amount of
  // space as if it wasn't selected). Also converts the field's name from camel
  // case to normal (e.g. camelCase -> Camel Case), where each word is
  // capitalized.

  const PreferencesWidget({
    @required this.height,
    @required this.margin,
    @required this.name,
    @required this.isSelected,
    Key key,
  }) : super(key: key);

  final double height;
  final double margin;
  final String name;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    PreferencesProvider provider =
        Provider.of<PreferencesProvider>(context, listen: false);

    double width = height * globals.goldenRatio;
    double selectedSizeChange = .8;

    double newHeight = (isSelected) ? selectedSizeChange * height : height;
    double newWidth = (isSelected) ? selectedSizeChange * width : width;

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: margin + (height - newHeight) / 2,
          horizontal: margin + (width - newWidth) / 2),
      child: GestureDetector(
          child: Stack(
            children: [
              Container(
                height: newHeight,
                width: newWidth,
                child: Center(
                  child: getImageFromName(name),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(newHeight / 3.5),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.7),
                        spreadRadius: 4,
                        blurRadius: 20,
                      ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => provider.changedSelectedStatus(name)),
    );
  }

  String convertFromCamelCase(String name) {
    String newName = name[0].toUpperCase();

    for (int i = 1; i < name.length; i++) {
      if (name[i] == name[i].toUpperCase())
        newName += " " + name[i];
      else
        newName += name[i];
    }
    return newName;
  }

  Image getImageFromName(String name) {
    String fileName = "assets/images/interests/" + name + ".png";
    return Image.asset(fileName);
  }
}

class PreferenceFooter extends StatelessWidget {
  // Found at the bottom of the Preferences Page. Contains a button that, when
  // pressed, sends the selected preference fields to the server.

  PreferenceFooter({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    PreferencesProvider provider =
        Provider.of<PreferencesProvider>(context, listen: false);

    return Container(
        height: height,
        width: double.infinity,
        alignment: Alignment.topCenter,
        child: GestureDetector(
            child: ForwardArrow(),
            onTap: () async {
              List<String> updatePreferences = [];

              provider.isPreferenceSelected.forEach((field, isSelected) {
                if (isSelected) updatePreferences.add(field);
              });
              await handleRequest(
                  context, postUserPreferences(updatePreferences));

              Navigator.pop(context);
            }));
  }
}
