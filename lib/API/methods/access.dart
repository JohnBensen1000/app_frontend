import '../../globals.dart' as globals;
import '../baseAPI.dart';

Future<Map> getAccess(String accessCode) async {
  return await BaseAPI()
      .get('v1/access/', queryParameters: {'accessCode': accessCode});
}
