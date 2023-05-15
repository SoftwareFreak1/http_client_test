class ResponseSnapshot {
  final int statusCode;
  final Map<String, String> headers;
  final String body;

  const ResponseSnapshot({
    required this.statusCode,
    required this.headers,
    required this.body,
  });
}
