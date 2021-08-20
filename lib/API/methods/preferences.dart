import '../../models/user.dart';

import '../../globals.dart' as globals;

Future<List<String>> getPreferenceFields() async {
  var response = await globals.baseAPI.get('v2/preferences');

  return [for (var field in response['fields']) field.toString()];
}

Future<Map> postUserPreferences(List<String> updatePreferences) async {
  Map<String, List<String>> postBody = {'preferences': updatePreferences};

  return await globals.baseAPI.put('v2/preferences/${globals.uid}', postBody);
}
