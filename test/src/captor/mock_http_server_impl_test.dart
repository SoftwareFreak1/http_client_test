import 'dart:io';

import 'package:http_client_test/src/captor/mock_http_server_impl.dart';
import 'package:test/test.dart';

void main() {
  group('MockHttpServerImpl', () {
    late MockHttpServerImpl server;

    setUp(() {
      server = MockHttpServerImpl();
    });

    Future<void> sendRequest(final Uri endpoint) => HttpClient()
            .post(endpoint.host, endpoint.port, '/request/path?key=value')
            .then(
          (request) async {
            request.headers.add('content-type', 'application/json');
            request.headers.add('authorization', 'Bearer token');
            request.write('Multiline\nBody');
            await request.close();
          },
        );

    group('getCapturedRequest', () {
      test('should return null when no request was captured', () async {
        final result = await server.getCapturedRequest();
        expect(result, isNull);
      });

      test('should return captured request', () async {
        final endpoint = await server.createEndpoint();
        await sendRequest(endpoint);
        final result = await server.getCapturedRequest();

        expect(result?.method, equals('POST'));
        expect(result?.path, equals('/request/path?key=value'));
        expect(result?.headers['content-type'], equals('application/json'));
        expect(result?.headers['authorization'], equals('Bearer token'));
        expect(result?.body, equals('Multiline\nBody'));
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
