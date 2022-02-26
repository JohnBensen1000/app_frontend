import 'dart:async';

import '../../models/user.dart';
import '../../globals.dart' as globals;
import '../API/methods/followings.dart';
import 'repository.dart';

class FollowingRepository extends Repository<Map<String, bool>> {
  FollowingRepository() {
    _getFollowingMap();
    _refreshCallback();
  }

  Map<String, bool> _followingMap = {};

  bool isFollowing(String uid) => _followingMap.containsKey(uid);

  Future<void> follow(User user) async {
    var response = await startFollowing(user);

    if (response != null && !response.containsKey('denied')) {
      String uid = response['creator'];
      _followingMap[uid] = true;
      super.controller.sink.add(_followingMap);
    }
  }

  Future<void> unfollow(User user) async {
    var response = await stopFollowing(user);

    if (response != null && response) {
      _followingMap.removeWhere((key, value) => key == user.uid);
      super.controller.sink.add(_followingMap);
    }
  }

  Future<void> _getFollowingMap() async {
    _followingMap = {};

    List<String> followingUids = await getFollowings();
    if (followingUids != null) {
      for (String followingUid in followingUids) {
        _followingMap[followingUid] = true;
      }
    }
    super.controller.sink.add(_followingMap);
  }

  Future<void> _refreshCallback() async {
    globals.blockedRepository.stream.listen((_) => _getFollowingMap());
  }
}
