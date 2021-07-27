import '../baseAPI.dart';

Future<bool> getAccess(String token) async {
  var response =
      await BaseAPI().get('v2/access', queryParameters: {'token': token});

  return response['accessGranted'];
}
