import 'dart:convert';
import 'dart:io';

import 'package:http_client_test/src/captor/mock_http_server_impl.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';
import 'package:test/test.dart';

void main() {
  group('MockHttpServerImpl', () {
    late MockHttpServerImpl server;

    setUp(() {
      server = MockHttpServerImpl(
        port: 8080,
        response: ResponseSnapshot(
          statusCode: 202,
          headers: {
            'content-type': 'application/json',
            'x-custom-header': 'custom-value',
          },
          body: 'Multiline\nResponseBody',
        ),
      );
    });

    Future<HttpClientResponse> sendRequest(final Uri endpoint) => HttpClient()
            .post(endpoint.host, endpoint.port, '/request/path?key=value')
            .then(
          (request) async {
            request.headers.add('content-type', 'application/json');
            request.headers.add('authorization', 'Bearer token');
            request.write('Multiline\nBody');
            return await request.close();
          },
        );

    group('createEndpoint', () {
      test('should send response', () async {
        final endpoint = await server.createEndpoint();
        final response = await sendRequest(endpoint);
        await server.getCapturedRequest();

        final responseBody = await utf8.decodeStream(response);
        expect(response.statusCode, equals(202));
        expect(
          response.headers.value('content-type'),
          equals('application/json'),
        );
        expect(
          response.headers.value('x-custom-header'),
          equals('custom-value'),
        );
        expect(responseBody, equals('Multiline\nResponseBody'));
      });

      test('should use configured port', () async {
        final endpoint = await server.createEndpoint();
        await server.getCapturedRequest();

        expect(endpoint.port, equals(8080));
      });
    });

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
