import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class BaseAPI {
  String baseURL = "http://192.168.0.180:8000/";

  Future<dynamic> get(String url) async {
    try {
      var response = await http.get(baseURL + url);
      return decodeReponse(response);
    } on SocketException {
      print(" [ERROR] No Internet Connection");
    } catch (e) {
      print(" [ERROR] $e");
    }
    return null;
  }

  Future<dynamic> post(String url, Map postBody) async {
    try {
      var response =
          await http.post(baseURL + url, body: json.encode(postBody));
      return decodeReponse(response);
    } on SocketException {
      print(" [ERROR] No Internet Connection");
    } catch (e) {
      print(" [ERROR] $e");
    }
    return null;
  }

  Future<dynamic> postFile(String url, Map postBody, String filePath) async {
    try {
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(baseURL + url));

      request.fields['json'] = json.encode(postBody);
      request.files.add(await http.MultipartFile.fromPath('media', filePath));

      var response = await request.send();
      return decodeReponse(response);
    } on SocketException {
      print(" [ERROR] No Internet Connection");
    } catch (e) {
      print(" [ERROR] $e");
    }
    return null;
  }

  Future<dynamic> delete(String url) async {
    try {
      http.Response response = await http.delete(baseURL + url);
      return decodeReponse(response);
    } on HttpException {
      await Future.delayed(Duration(milliseconds: 100));
      return get(url);
    } on SocketException {
      print(" [ERROR] No Internet Connection");
    } catch (e) {
      print(" [ERROR] $e");
    }
    return null;
  }

  dynamic decodeReponse(var response) {
    switch (response.statusCode) {
      case 200:
        if (response.runtimeType != http.StreamedResponse &&
            !response.body.isEmpty)
          return json.decode(response.body);
        else
          return true;
        break;
      case 201:
        if (response.runtimeType != http.StreamedResponse &&
            !response.body.isEmpty)
          return json.decode(response.body);
        else
          return true;
        break;
      case 500:
        throw ServerFailedException("Server error");
        return false;
      default:
        throw UnknownErrorException();
        return false;
    }
  }
}

class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class ServerFailedException extends AppException {
  ServerFailedException([String message])
      : super(message, "an error occured on the server: ");
}

class UnknownErrorException extends AppException {
  UnknownErrorException([String message])
      : super(message, "an error occured on the server: ");
}
