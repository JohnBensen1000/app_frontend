import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:test_flutter/API/handle_requests.dart';

import '../globals.dart' as globals;
import '../models/user.dart';
import '../models/profile.dart';
import '../models/post.dart';

import '../API/methods/users.dart';
import '../API/methods/posts.dart';

class ProfileRepository {
  HashMap profiles = new HashMap<User, Post>();

  Future<Post> getProfilePost(BuildContext context, User user) async {
    if (profiles.containsKey(user)) return profiles[user];

    Post profile = await handleRequest(context, getProfile(user));
    profiles[user] = profile;

    return profile;
  }
}
