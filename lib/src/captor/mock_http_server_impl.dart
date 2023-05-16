import 'dart:convert';
import 'dart:io';
import 'package:http_client_test/src/captor/mock_http_server.dart';
import 'package:http_client_test/src/snapshot/request_snapshot.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';

class MockHttpServerImpl implements MockHttpServer {
  final int _port;
  final ResponseSnapshot _response;
  HttpServer? _server;
  RequestSnapshot? _capturedRequest;

  MockHttpServerImpl({
    required final int port,
    required final ResponseSnapshot response,
  })  : _port = port,
        _response = response;

  @override
  Future<Uri> createEndpoint() async {
    final server = (await HttpServer.bind(InternetAddress.loopbackIPv4, _port))
      ..listen((request) async {
        _capturedRequest = RequestSnapshot(
          method: request.method,
          path: request.uri.toString(),
          headers: _mapHeaders(request.headers),
          body: await utf8.decodeStream(request),
        );

        request.response.statusCode = _response.statusCode;
        _response.headers.forEach(request.response.headers.add);
        request.response.write(_response.body);
        await request.response.close();
      });

    _server = server;

    return Uri.parse('http://${server.address.host}:${server.port}');
  }

  @override
  Future<RequestSnapshot?> getCapturedRequest() async {
    await _server?.close();
    return _capturedRequest;
  }

  Map<String, String> _mapHeaders(final HttpHeaders headers) {
    final result = <String, String>{};

    headers.forEach((name, values) {
      if (name == HttpHeaders.hostHeader) return;
      result[name] = values[0];
    });

    return result;
  }
}
