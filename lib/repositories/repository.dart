import 'dart:async';

class Repository<T> {
  final controller = StreamController<T>.broadcast();

  Stream<T> get stream => controller.stream;

  void dispose() {
    controller.close();
  }
}
