import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/models/chat.dart';

import '../../globals.dart' as globals;
import '../../API/users.dart';
import '../../models/user.dart';
import '../../widgets/profile_pic.dart';
import '../../widgets/back_arrow.dart';

import '../friends/chat_page.dart';
import '../friends/friends_page.dart';

class ColorStruct {
  // Contains information about an individual color, including it's Color
  // object, a lighter version of the color, and its name.

  Color color;
  Color softColor;
  String name;

  ColorStruct({@required this.color, @required this.name}) {
    this.softColor = Color.fromARGB(
        this.color.alpha,
        this.color.red + ((255 - this.color.red) * .9).round(),
        this.color.green + ((255 - this.color.green) * .9).round(),
        this.color.blue + ((255 - this.color.blue) * .9).round());
  }
}

class ChooseColorProvider extends ChangeNotifier {
  // Keep a list of ColorStructs, which is created from globals.colorsMap. Also
  // keeps track of the index of the chosen color.

  final List<ColorStruct> colorStructs = [
    for (String key in globals.colorsMap.keys)
      ColorStruct(color: globals.colorsMap[key], name: key)
  ];

  int _chosenIndex = -1;

  int get chosenIndex {
    return _chosenIndex;
  }

  set chosenIndex(int newChosenIndex) {
    _chosenIndex = newChosenIndex;
    notifyListeners();
  }
}

class ChooseColorPage extends StatelessWidget {
  // The page is divided into two sections: a header and a listView.builder. The
  // header displays the chosen color and allows the user to save the chosen
  // color. The ListView.builder displays how different aspects of a User's
  // account will look in a given color.

  @override
  Widget build(BuildContext context) {
    double headerHeight = 150;

    return Scaffold(
        body: ChangeNotifierProvider(
            create: (_) => ChooseColorProvider(),
            child: Consumer<ChooseColorProvider>(
                builder: (context, provider, child) {
              return Column(
                children: [
                  ChooseColorHeader(
                    height: headerHeight,
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height - headerHeight,
                      child: ListView.builder(
                        itemCount: provider.colorStructs.length,
                        itemBuilder: (context, index) {
                          return ChooseColorWidget(
                            colorStruct: provider.colorStructs[index],
                            index: index,
                          );
                        },
                      )),
                ],
              );
            })));
  }
}

class ChooseColorHeader extends StatelessWidget {
  // Maintains a ColorStruct variable given the chosen color. Allows the user
  // to save the chosen color and exit the page.
  ChooseColorHeader({@required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    ChooseColorProvider provider =
        Provider.of<ChooseColorProvider>(context, listen: false);
    ColorStruct chosenColor = (provider.chosenIndex >= 0)
        ? provider.colorStructs[provider.chosenIndex]
        : null;

    return Container(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: <Widget>[
              FlatButton(
                  child: BackArrow(), onPressed: () => Navigator.pop(context))
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                "The chosen color is: ",
                style: TextStyle(fontSize: 24),
              ),
              if (chosenColor != null)
                Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                    color: chosenColor.color,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: Text(
                      chosenColor.name,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                )
            ],
          ),
          Center(
              child: GestureDetector(
                  child: Container(
                    width: 75,
                    height: 25,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Center(
                      child: Text(
                        "Save",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  onTap: () async {
                    await updateColor(chosenColor.name);
                    globals.user.profileColor = chosenColor.color;
                    Navigator.pop(context);
                  }))
        ],
      ),
    );
  }
}

class ChooseColorWidget extends StatelessWidget {
  // Creates a tempUser variable so that a User object with the given color
  // could be passed into different widgets. Shows what the user's profile page
  // header, direct message chat widget, and text messages will look like with
  // the given color.
  const ChooseColorWidget({
    Key key,
    @required this.colorStruct,
    @required this.index,
  }) : super(key: key);

  final ColorStruct colorStruct;
  final int index;

  @override
  Widget build(BuildContext context) {
    ChooseColorProvider provider =
        Provider.of<ChooseColorProvider>(context, listen: false);

    User tempUser = User(
        profileColor: colorStruct.color,
        username: globals.user.username,
        userID: globals.user.userID,
        uid: globals.user.uid);

    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: (index == provider.chosenIndex)
              ? colorStruct.softColor
              : Colors.white,
          border: Border.all(color: Colors.grey[600]),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ComponentTitleWidget(text: 'How your profile will look:'),
            // ProfilePageHeader(
            //   user: globals.user,
            //   color: colorStruct.color,
            // ),
            ComponentTitleWidget(text: 'How your friends will see you:'),
            ChatWidget(
              chat: Chat(
                  'chatID',
                  tempUser.username,
                  true,
                  [tempUser],
                  ProfilePic(
                    diameter: 85,
                    user: tempUser,
                  ),
                  colorStruct.color),
            ),
            ComponentTitleWidget(text: 'How your texts will look:'),
            ChatItemWidgetText(
              backgroundColor: colorStruct.color,
              text: "This is what a text would look like.",
              mainAxisAlignment: MainAxisAlignment.start,
            )
          ],
        ),
      ),
      onTap: () => provider.chosenIndex = index,
    );
  }
}

class ComponentTitleWidget extends StatelessWidget {
  const ComponentTitleWidget({
    @required this.text,
    Key key,
  }) : super(key: key);

  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(
          text,
          style: TextStyle(fontSize: 24),
        )
      ]),
    );
  }
}
