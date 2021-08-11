import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/API/handle_requests.dart';
import 'package:test_flutter/API/methods/posts.dart';

import '../../models/user.dart';
import '../../models/profile.dart';
import '../../models/chat.dart';
import '../../models/post.dart';
import '../../API/methods/users.dart';
import '../../globals.dart' as globals;

class NewActivityRepository {
  bool _newActivity;
  final _controller = StreamController<bool>.broadcast();

  NewActivityRepository() {
    _newActivityCallback();
  }

  Stream<bool> get stream => _controller.stream;

  bool get newActivity => _newActivity;

  void dispose() {
    _controller.close();
  }

  Future<void> updateNewActivity(BuildContext context) async {
    Map response = await updatedThatUserIsUpdated();
    _controller.sink.add(response['isUpdated']);
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
