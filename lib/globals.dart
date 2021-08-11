import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'API/baseAPI.dart';

import 'models/user.dart';

import 'repositories/new_activity_repository.dart';
import 'repositories/account_repository.dart';
import 'repositories/profile_repository.dart';

User user;
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

NewActivityRepository newActivityRepository;
AccountRepository accountRepository;
ProfileRepository profileRepository;
