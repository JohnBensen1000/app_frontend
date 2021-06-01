class User {
  String userID;
  String username;
  String uid;

  User({this.userID, this.username, this.uid});

  User.fromJson(Map userJson) {
    this.userID = userJson['userID'];
    this.username = userJson['username'];
    this.uid = userJson['uid'];
  }
}
