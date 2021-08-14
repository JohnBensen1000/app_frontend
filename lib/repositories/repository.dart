import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../globals.dart' as globals;

class Repository<T> {
  final controller = StreamController<T>.broadcast();

  Stream<T> get stream => controller.stream;

  void dispose() {
    controller.close();
  }
}
