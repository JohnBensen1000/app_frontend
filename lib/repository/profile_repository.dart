import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:test_flutter/API/methods/posts.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../globals.dart' as globals;
import '../models/user.dart';
import '../models/profile.dart';
import '../models/post.dart';

import '../API/methods/users.dart';

class ProfileRepository {
  HashMap profiles = new HashMap<User, Post>();

  Future<Post> getProfilePost(User user) async {
    if (profiles.containsKey(user)) return profiles[user];

    Post profile = await getProfile(user);
    profiles[user] = profile;

    return profile;
  }
}
