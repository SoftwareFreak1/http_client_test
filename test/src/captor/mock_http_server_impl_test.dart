import 'dart:io';

import 'package:http_client_test/src/captor/mock_http_server_impl.dart';
import 'package:http_client_test/src/captor/request_serializer.dart';
import 'package:test/test.dart';

void main() {
  group('MockHttpServerImpl', () {
    late MockHttpServerImpl server;

    setUp(() {
      server = MockHttpServerImpl(_MockRequestSerializer());
    });

    Future<void> sendRequest(final Uri endpoint) => HttpClient()
        .get(endpoint.host, endpoint.port, '/')
        .then((request) => request.close());

    group('getCapturedRequest', () {
      test('should return null when no request was captured', () async {
        final result = await server.getCapturedRequest();
        expect(result, isNull);
      });

      test('should return captured request', () async {
        final endpoint = await server.createEndpoint();
        await sendRequest(endpoint);
        final result = await server.getCapturedRequest();
        expect(result, equals("SerializedRequest"));
      });

      test('should stop server', () async {
        final endpoint = await server.createEndpoint();
        await sendRequest(endpoint);
        await server.getCapturedRequest();

        expect(
          () => sendRequest(endpoint),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

class _MockRequestSerializer implements RequestSerializer {
  @override
  Future<String> serialize(final HttpRequest request) async =>
      'SerializedRequest';
}
