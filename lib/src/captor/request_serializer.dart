import 'dart:io';

abstract class RequestSerializer {
  Future<String> serialize(HttpRequest request);
}
