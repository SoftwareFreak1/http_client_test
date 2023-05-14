abstract class MockHttpServer {
  Future<Uri> createEndpoint();
  Future<String?> getCapturedRequest();
}
