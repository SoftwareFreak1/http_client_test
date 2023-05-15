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
}
