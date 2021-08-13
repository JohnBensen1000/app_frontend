import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../API/methods/users.dart';
import '../../globals.dart' as globals;

class NewActivityRepository {
  NewActivityRepository() {
    _newActivityCallback();
  }

  bool _newActivity;
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get stream => _controller.stream;

  bool get newActivity => _newActivity;

  void dispose() {
    _controller.close();
  }

  Future<void> update() async {
    Map response = await updatedThatUserIsUpdated();
    _newActivity = response['isUpdated'];
    _controller.sink.add(_newActivity);
  }

  Future<void> _newActivityCallback() async {
    bool isUpdated = await getIfUserIsUpdated();
    _newActivity = !isUpdated;
    _controller.sink.add(_newActivity);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.containsKey('newActivity')) {
        _newActivity = true;
        _controller.sink.add(_newActivity);
      }
    });
  }
}
