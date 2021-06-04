import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../friends/chat_page.dart';
import '../globals.dart' as globals;
import '../profile/profile_pic.dart';
import '../friends/friends_page.dart';
import '../profile/profile_page.dart';
import '../widgets/back_arrow.dart';

class ColorStruct {
  ColorStruct(
      {@required this.color, @required this.softColor, @required this.name});

  final Color color;
  final Color softColor;
  final String name;
}

class ChooseColorProvider extends ChangeNotifier {
  final List<ColorStruct> colorStructs = [
    ColorStruct(color: Colors.red, softColor: Colors.red[50], name: 'red'),
    ColorStruct(color: Colors.blue, softColor: Colors.blue[50], name: 'blue'),
    ColorStruct(
        color: Colors.yellow, softColor: Colors.yellow[50], name: 'yellow'),
    ColorStruct(
        color: Colors.green, softColor: Colors.green[50], name: 'green'),
    ColorStruct(
        color: Colors.purple, softColor: Colors.purple[50], name: 'purple'),
    ColorStruct(
        color: Colors.orange, softColor: Colors.orange[50], name: 'orange'),
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
  @override
  Widget build(BuildContext context) {
    double headerHeight = 125;

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
          )
        ],
      ),
    );
  }
}

class ChooseColorWidget extends StatelessWidget {
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

    Color backgroundColor =
        (index == provider.chosenIndex) ? colorStruct.softColor : Colors.white;

    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.grey[600]),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          children: [
            ComponentTitleWidget(text: 'How your profile will look:'),
            ProfilePageHeader(
              user: globals.user,
              color: colorStruct.color,
            ),
            ComponentTitleWidget(text: 'How your friends will see you:'),
            ChatWidget(
                chatName: globals.user.username,
                color: colorStruct.color,
                chatProfile: ProfilePic(
                    diameter: 85,
                    user: globals.user,
                    color: colorStruct.color)),
            ComponentTitleWidget(text: 'How your texts will look:'),
            ChatItemWidgetText(
              backgroundColor: colorStruct.color,
              text: "This is what a text would look like.",
              sender: globals.user,
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
