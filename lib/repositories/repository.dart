import 'dart:async';

class Repository<T> {
  // Base Repository that all other repositories inherit from. All repositories
  // will have a stream controller, a getter that returns the stream, and a
  // dispose method that disposes of the controller.

  final controller = StreamController<T>.broadcast();

  Stream<T> get stream => controller.stream;

  void dispose() {
    controller.close();
  }
}
