import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../globals.dart' as globals;

import '../../repositories/new_activity_repository.dart';
import '../../repositories/profile_repository.dart';

import 'home/home_page.dart';

class Global<T> extends StatefulWidget {
  @override
  State createState() => _GlobalState();
}

class _GlobalState extends State<Global> {
  @override
  void initState() {
    globals.newActivityRepository = NewActivityRepository();
    globals.profileRepository = ProfileRepository();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}
