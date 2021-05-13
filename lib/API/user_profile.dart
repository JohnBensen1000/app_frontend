import '../models/user.dart';
import '../globals.dart' as globals;
import 'baseAPI.dart';

Future<List<User>> getFriendsList() async {
  List<User> friendsList = [];
  var response;

  try {
    response = await BaseAPI().get("users/${globals.userID}/friends/");
  } catch (e) {
    print(e);
    return null;
  }

  for (var friendJson in response["friends"]) {
    friendsList.add(
        User(userID: friendJson['userID'], username: friendJson['username']));
  }
  return friendsList;
}
