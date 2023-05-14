typedef RequestSender = Future<void> Function(Uri endpoint);

abstract class RequestCaptor {
  Future<String?> capture(RequestSender sendRequest);
}
