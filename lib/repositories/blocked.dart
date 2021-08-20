import 'dart:async';

import 'package:test_flutter/API/methods/blocked.dart';
import 'package:test_flutter/repositories/repository.dart';

import '../../models/user.dart';

class BlockedRepository extends Repository<List<User>> {
  List<User> _blockedList;

  List<User> get blockedList {
    if (_blockedList != null) return _blockedList;
    _getBlockedList();
    return [];
  }

  Future<Map> block(User user) async {
    var response = await blockUser(user);

    if (response != null && !response.containsKey("denied")) {
      blockedList.add(user);
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

  Future<void> _getBlockedList() async {
    var response = await getBlockedUsers();

    if (response != null) {
      _blockedList = response;
      super.controller.sink.add(_blockedList);
    }
  }
}
