import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ntp/ntp.dart';

import '../../globals.dart' as globals;

Future<String> uploadFile(File file, String directory, bool isImage) async {
  String fileExtension = (isImage) ? 'jpg' : 'mp4';

  String fileName = (await NTP.now()).microsecondsSinceEpoch.toString();

  Reference storageReference = FirebaseStorage.instance
      .ref()
      .child('USERS/$directory/$fileName.$fileExtension');

  await storageReference.putFile(file);

  return await storageReference.getDownloadURL();
}

class BaseAPI {
  // var baseURL = '10.184.74.184:8000';
  // var baseURL = '10.186.34.249:8000';
  // var baseURL = "10.186.36.50:8000";
  // var baseURL = "192.168.0.180:8000";
  // var baseURL = "192.168.0.12:8000";
  // var baseURL = "10.186.36.126";
  // var baseURL = "10.186.41.170:8000";
  // var baseURL = "192.168.1.200:8000";
  // var baseURL = "10.186.43.82:8000";
  String baseURL = 'entropy-317014.uc.r.appspot.com';
  // var baseURL = "10.186.36.37:8000";

  Future<dynamic> get(String url,
      {Map<String, dynamic> queryParameters}) async {
    return handleResponse(http.get(Uri.https(baseURL, url, queryParameters),
        headers: {'uid': globals.uid}));
  }

  Future<dynamic> post(String url, Map postBody) async {
    return handleResponse(http.post(Uri.https(baseURL, url),
        body: json.encode(postBody), headers: {'uid': globals.uid}));
  }

  Future<dynamic> put(String url, Map postBody) async {
    return handleResponse(http.put(Uri.https(baseURL, url),
        body: json.encode(postBody), headers: {'uid': globals.uid}));
  }

  Future<dynamic> delete(String url) async {
    return handleResponse(
        http.delete(Uri.https(baseURL, url), headers: {'uid': globals.uid}));
  }

  dynamic handleResponse(Future future) async {
    var response;

    try {
      response = await future;
    } on SocketException {
      return null;
    } catch (e) {
      return null;
    }

    switch (response.statusCode) {
      case 200:
        return json.decode(response.body);
        break;
      case 400:
      case 404:
        throw ClientFailedException("Client Failed");
        break;
      case 500:
        throw ServerFailedException("Server error");
        break;
      default:
        throw UnknownErrorException();
        break;
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

class NoInternetException extends AppException {
  NoInternetException([String message]) : super(message, "NoInternetError: ");
}

class ClientFailedException extends AppException {
  ClientFailedException([String message])
      : super(message, "ClientFailedError: ");
}

class ServerFailedException extends AppException {
  ServerFailedException([String message])
      : super(message, "ServerFailedException: ");
}

class UnknownErrorException extends AppException {
  UnknownErrorException([String message])
      : super(message, "UnknownErrorException: ");
}

// L0MyZOGazAdZ9Lx2VXOhRMFQXIg2
// L0MyZOGazAdZ9Lx2VXOhRMFQXIg29
