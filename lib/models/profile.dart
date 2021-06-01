class Profile {
  bool exists;
  bool isImage;
  String downloadURL;

  Profile.fromJson(Map postJson) {
    this.exists = postJson["exists"];
    if (this.exists) {
      this.isImage = postJson["isImage"];
      this.downloadURL = postJson["downloadURL"];
    }
  }
}
