import '../baseAPI.dart';

import '../../models/user.dart';
import '../../globals.dart' as globals;

Future<List<User>> getNewFollowers() async {
  Map response = await BaseAPI().get('v2/followers/${globals.uid}/new');
  return [for (var userJson in response["followers"]) User.fromJson(userJson)];
}
