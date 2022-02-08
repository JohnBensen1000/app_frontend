import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'API/baseAPI.dart';
import 'API/google_analytics.dart';

import 'models/user.dart';

import 'repositories/blocked.dart';
import 'repositories/chats.dart';
import 'repositories/following.dart';
import 'repositories/new_activity.dart';
import 'repositories/profile.dart';
import 'repositories/user.dart';
import 'repositories/account.dart';
import 'repositories/post_list.dart';

// User user;
String uid;

double goldenRatio = 1.61803398875;
double cornerRadiusRatio = 1 / 19; // Fraction of height that corner radius is

String chatCollection = "CHATS";

Map<String, Color> colorsMap = {
  '1': Color.fromRGBO(255, 72, 0, 1.0),
  '2': Color.fromRGBO(0, 248, 253, 1.0),
  '3': Color.fromRGBO(255, 173, 191, 1.0),
  '4': Color.fromRGBO(19, 100, 208, 1.0),
  '5': Color.fromRGBO(255, 199, 0, 1.0),
  '6': Color.fromRGBO(247, 0, 16, 1.0),
};

BaseAPI baseAPI = new BaseAPI();
GoogleAnalyticsAPI googleAnalyticsAPI = new GoogleAnalyticsAPI();

class SizeConfig {
  SizeConfig({@required BuildContext context}) {
    MediaQueryData _mediaQueryData = MediaQuery.of(context);
    this.width = _mediaQueryData.size.width;
    this.height = _mediaQueryData.size.height;
  }

  double width;
  double height;
}

SizeConfig size;

AccountRepository accountRepository = new AccountRepository();

BlockedRepository blockedRepository;
ChatsRepository chatsRepository;
FollowingRepository followingRepository;
NewActivityRepository newActivityRepository;
ProfileRepository profileRepository;
UserRepository userRepository;
PostListRepository recommendationPostsRepository;
PostListRepository followingPostsRepository;
// CommentsRepository commentsRepository;

// Set to true if someone is in the process of creating an account,
// set to false otherwise. Useful for google analytics.
bool isNewUser;
