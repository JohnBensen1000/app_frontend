import 'package:flutter/material.dart';
import 'package:test_flutter/API/methods/users.dart';

import 'models/user.dart';

import 'bloc/bloc.dart';
import 'bloc/user.dart';

class Welcome extends StatefulWidget {
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  User _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: _initializeAppState(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return BlocProvider(
                    bloc: UserBloc(user: _user), child: Container());
              } else {
                return Container();
              }
            }));
  }

  Future<void> _initializeAppState() {
    // _user = getUserFromUID(uid)
  }
}
