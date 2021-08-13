import 'dart:async';

import 'package:test_flutter/API/methods/blocked.dart';
import 'package:test_flutter/repositories/repository.dart';

import '../../models/user.dart';

class BlockedRepository extends Repository<List<User>> {
  BlockedRepository() {
    _getInitialValue();
  }

  List<User> _blockedList;

  List<User> get blockedList => _blockedList;

  Future<Map> block(User user) async {
    var response = await blockUser(user);

    if (response != null && !response.containsKey("denied")) {
      _blockedList.add(User.fromJson(response));
      super.controller.sink.add(_blockedList);
      return {};
    }
    return response;
  }

  Future<bool> unblock(User user) async {
    var response = await unblockUser(user);

    if (response != null && response) {
      _blockedList.removeWhere((blockedUser) => blockedUser.uid == user.uid);
      super.controller.sink.add(_blockedList);
      return true;
    }
    return false;
  }

  Future<void> _getInitialValue() async {
    var response = await getBlockedUsers();

    if (response != null) {
      _blockedList = response;
      super.controller.sink.add(_blockedList);
    }
  }
}
