import 'package:flutter/material.dart';

import 'models/user.dart';
import 'repository/post_repository.dart';

User user;
double goldenRatio = 1.61803398875;
double cornerRadiusRatio = 1 / 19; // Fraction of height that corner radius is

String serverName = "DEVELOP";
String chatCollection = serverName + "_chats";

Map<String, Color> colorsMap = {
  'red': Colors.redAccent,
  'orange': Colors.orangeAccent,
  'yellow': Colors.yellowAccent,
  'green': Colors.greenAccent,
  'blue': Colors.blueAccent,
  'purple': Colors.purpleAccent
};

PostRepository postRepository = new PostRepository();
