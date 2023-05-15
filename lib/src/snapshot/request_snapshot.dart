import 'package:collection/collection.dart';

class RequestSnapshot {
  final String method;
  final String path;
  final Map<String, String> headers;
  final String body;

  const RequestSnapshot({
    required this.method,
    required this.path,
    required this.headers,
    required this.body,
  });

  static bool isEqual(final RequestSnapshot? s1, final RequestSnapshot? s2) =>
      s1 != null &&
      s2 != null &&
      s1.method == s2.method &&
      s1.path == s2.path &&
      MapEquality().equals(s1.headers, s2.headers) &&
      s1.body == s2.body;
}
