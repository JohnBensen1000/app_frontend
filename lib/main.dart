import 'package:flutter/material.dart';

import 'welcome_page.dart';
import 'new_followers_page.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: WelcomePage());
    // home: NewFollowersPage());
  }
}
