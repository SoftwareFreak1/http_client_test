import 'dart:io';
import 'package:http_client_test/src/captor/mock_http_server.dart';
import 'package:http_client_test/src/captor/request_serializer.dart';

class MockHttpServerImpl implements MockHttpServer {
  final RequestSerializer _requestSerializer;
  HttpServer? _server;
  String? _capturedRequest;

  MockHttpServerImpl(this._requestSerializer);

  @override
  Future<Uri> createEndpoint() async {
    final server = (await HttpServer.bind(InternetAddress.loopbackIPv4, 8080))
      ..listen((request) async {
        _capturedRequest = await _requestSerializer.serialize(request);
        await request.response.close();
      });

    _server = server;

    return Uri.parse('http://${server.address.host}:${server.port}');
  }

  @override
  Future<String?> getCapturedRequest() async {
    await _server?.close();
    return _capturedRequest;
  }
}
