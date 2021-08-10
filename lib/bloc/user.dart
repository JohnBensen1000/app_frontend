import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/profile.dart';
import '../../models/chat.dart';
import '../../models/post.dart';
import 'bloc.dart';

class UserBloc implements Bloc {
  UserBloc({@required User user}) {
    _user = user;
  }
  User _user;

  final _userController = StreamController<User>.broadcast();

  Stream<User> get stream => _userController.stream;

  set username(String username) {
    _user.username = username;
    _userController.sink.add(_user);
  }

  @override
  void dispose() {
    _userController.close();
  }
}

// class MainUserBloc implements Bloc {
//   bool _newActivity;
//   User _user;
//   Profile _profile;
//   List<Chat> _chatsList;
//   List<Post> _followingList;
//   List<Post> _recommendationsList;
//   List<User> _blockedList;

//   final _newActivityController = StreamController<bool>.broadcast();
//   final _userController = StreamController<bool>.broadcast();
//   final _profileController = StreamController<bool>.broadcast();
//   final _chatsListController = StreamController<bool>.broadcast();
//   final _followingListController = StreamController<bool>.broadcast();
//   final _recommendationsListController = StreamController<bool>.broadcast();
//   final _blockedListController = StreamController<bool>.broadcast();


// Stream<bool> 
//   @override
//   void dispose() {
//     _newActivityController.close();
//     _userController.close();
//     _profileController.close();
//     _chatsListController.close();
//     _followingListController.close();
//     _recommendationsListController.close();
//     _blockedListController.close();
//   }
// }
