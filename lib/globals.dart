import 'package:flutter/material.dart';
import 'package:test_flutter/repository/profile_repository.dart';

import 'API/baseAPI.dart';

import 'models/user.dart';
import 'repository/post_repository.dart';
import 'repository/user_repository.dart';

User user;
double goldenRatio = 1.61803398875;
double cornerRadiusRatio = 1 / 19; // Fraction of height that corner radius is

String serverName = "DEVELOP";
String chatCollection = serverName + "_chats";

Map<String, Color> colorsMap = {
  '1': Color.fromRGBO(255, 72, 0, 1.0),
  '2': Color.fromRGBO(0, 248, 253, 1.0),
  '3': Color.fromRGBO(255, 173, 191, 1.0),
  '4': Color.fromRGBO(19, 100, 208, 1.0),
  '5': Color.fromRGBO(255, 199, 0, 1.0),
  '6': Color.fromRGBO(247, 0, 16, 1.0),
};

PostRepository postRepository = new PostRepository();
UserRepository userRepository = new UserRepository();
ProfileRepository profileRepository = new ProfileRepository();

BaseAPI baseAPI = new BaseAPI();
