import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sections/welcome.dart';

import 'globals.dart' as globals;

RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return LifeCycle();
  }
}

class LifeCycle extends StatefulWidget {
  // This widget rebuilds the entire app when the user opens it up.
  @override
  _LifeCycleState createState() => _LifeCycleState();
}

class _LifeCycleState extends State<LifeCycle> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) if (globals.chatsRepository != null)
      globals.chatsRepository.refreshChatsList();
  }

  @override
  Widget build(BuildContext context) {
    // return MaterialApp();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Welcome(),
      navigatorObservers: <NavigatorObserver>[routeObserver],
    );
  }
}
// gcloud app logs tail -s default
