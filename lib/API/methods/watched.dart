import 'dart:io';

import '../../models/profile.dart';
import '../../models/post.dart';
import '../../models/user.dart';

import '../../globals.dart' as globals;
import '../baseAPI.dart';

Future<Map> recordWatched(String postID, double userRating) async {
  Map postJson = {'uid': globals.uid, 'rating': userRating};
  return await globals.baseAPI.post('v2/watched/$postID', postJson);
}
