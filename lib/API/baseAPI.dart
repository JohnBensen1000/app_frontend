import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class BaseAPI {
  String baseURL = "http://192.168.0.180:8000/";

  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      http.Response response = await http.get(baseURL + url);
      responseJson = decodeReponse(response);
    } on SocketException {
      throw ConnectionFailedException("No internet connection");
    }
    return responseJson;
  }

  dynamic decodeReponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body);
      case 201:
        return true;
      case 500:
        throw ConnectionFailedException("Server error");
      default:
        return null;
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

class ConnectionFailedException extends AppException {
  ConnectionFailedException([String message])
      : super(message, "Error During Communication: ");
}
