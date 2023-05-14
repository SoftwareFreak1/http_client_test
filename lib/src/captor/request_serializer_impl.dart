import 'dart:convert';
import 'dart:io';

import 'request_serializer.dart';

class RequestSerializerImpl implements RequestSerializer {
  @override
  Future<String> serialize(final HttpRequest request) async {
    final methodAndUri = '${request.method} ${request.requestedUri}';
    final headers = request.headers.toString();
    final body = await utf8.decodeStream(request);

    return '$methodAndUri\n$headers\n$body';
  }
}
