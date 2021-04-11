import 'package:flutter/material.dart';

import 'home_screen.dart';

String userID = "Collin1000";
double goldenRatio = 1.6180;

class UserInfo extends StatefulWidget {
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    return HomeScreen(pageLabel: PageLabel.friends);
  }
}
