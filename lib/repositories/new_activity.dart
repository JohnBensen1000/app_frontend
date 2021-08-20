import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:test_flutter/repositories/repository.dart';

import '../../API/methods/users.dart';
import '../../globals.dart' as globals;

class NewActivityRepository extends Repository<bool> {
  NewActivityRepository() {
    _newActivityCallback();
  }

  bool _newActivity;

  bool get newActivity => _newActivity;

  Future<void> update() async {
    Map response = await updatedThatUserIsUpdated();
    if (response != null) {
      _newActivity = !response['isUpdated'];
      super.controller.sink.add(_newActivity);
    }
  }

  Future<void> _newActivityCallback() async {
    bool isUpdated = await getIfUserIsUpdated();
    _newActivity = !isUpdated;
    super.controller.sink.add(_newActivity);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.containsKey('newActivity')) {
        _newActivity = true;
        super.controller.sink.add(_newActivity);
      }
    });
  }
}
