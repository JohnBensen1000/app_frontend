import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ntp/ntp.dart';

Future<String> uploadFile(
    String filePath, String directory, bool isImage) async {
  String fileExtension = (isImage) ? 'jpg' : 'mp4';

  Reference storageReference = FirebaseStorage.instance.ref().child(
      'USERS/$directory/${(await NTP.now()).microsecondsSinceEpoch.toString()}.$fileExtension');

  File file = File(filePath);

  await storageReference.putFile(file);
  String downloadURL;

  await storageReference.getDownloadURL().then((fileURL) {
    downloadURL = fileURL;
  });
  print(downloadURL);
  return downloadURL;
}

class BaseAPI {
  var baseURL = "192.168.0.180:8000";

  Future<dynamic> get(String url,
      {Map<String, dynamic> queryParameters}) async {
    try {
      var response = await http.get(Uri.http(baseURL, url, queryParameters));
      return decodeReponse(response);
    } on SocketException {
      throw NoInternetError("No internet");
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> post(String url, Map postBody) async {
    try {
      var response =
          await http.post(Uri.http(baseURL, url), body: json.encode(postBody));
      return decodeReponse(response);
    } on SocketException {
      throw NoInternetError("No internet");
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> delete(String url) async {
    try {
      http.Response response = await http.delete(Uri.http(baseURL, url));
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
      case 201:
      case 200:
        if (response.runtimeType != http.StreamedResponse &&
            !response.body.isEmpty)
          return json.decode(response.body);
        else
          return true;
        break;
      case 400:
      case 404:
        throw ClientFailedError("Client Failed");
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

class NoInternetError extends AppException {
  NoInternetError([String message]) : super(message, "NoInternetError: ");
}

class ClientFailedError extends AppException {
  ClientFailedError([String message]) : super(message, "ClientFailedError: ");
}

class ServerFailedException extends AppException {
  ServerFailedException([String message])
      : super(message, "ServerFailedException: ");
}

class UnknownErrorException extends AppException {
  UnknownErrorException([String message])
      : super(message, "UnknownErrorException: ");
}
