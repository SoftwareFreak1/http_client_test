import 'package:http_client_test/src/snapshot/request_snapshot.dart';

abstract class MockHttpServer {
  Future<Uri> createEndpoint();
  Future<RequestSnapshot?> getCapturedRequest();
}
