import 'package:http_client_test/src/snapshot/request_snapshot.dart';

typedef RequestSender = Future<void> Function(Uri endpoint);

abstract class RequestCaptor {
  Future<RequestSnapshot?> capture(RequestSender sendRequest);
}
