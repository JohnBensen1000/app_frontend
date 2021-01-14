import 'package:flutter/material.dart';
import 'LogInScreen1.dart';

void main() {
  runApp(MyApp());
}

class UserInfo extends InheritedWidget {
  final String userID;
  final Widget child;

  UserInfo({this.userID, this.child});

  static UserInfo of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserInfo>();
  }

  @override
  bool updateShouldNotify(UserInfo old) => userID != old.userID;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return UserInfo(
      userID: "John1000",
      child: MaterialApp(
        home: LogInScreen1(),
      ),
    );
  }
}
