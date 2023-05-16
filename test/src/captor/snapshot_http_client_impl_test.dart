import 'package:http_client_test/src/captor/mock_http_server_impl.dart';
import 'package:http_client_test/src/captor/snapshot_http_client_impl.dart';
import 'package:http_client_test/src/snapshot/request_snapshot.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';
import 'package:test/test.dart';

void main() {
  group('SnapshotHttpClientImpl', () {
    late SnapshotHttpClientImpl client;

    setUp(() {
      client = SnapshotHttpClientImpl();
    });

    group('send', () {
      Future<_Result> mockServer(
        final Future<ResponseSnapshot> Function(Uri) sendRequest,
      ) async {
        final server = MockHttpServerImpl(
          port: 8081,
          response: ResponseSnapshot(
            statusCode: 202,
            headers: {
              'content-type': 'application/json',
              'x-custom-header': 'custom-value',
            },
            body: 'Multiline\nResponseBody',
          ),
        );

        final endpoint = await server.createEndpoint();
        final response = await sendRequest(endpoint);
        final request = await server.getCapturedRequest();

        return _Result(request: request, response: response);
      }

      Future<ResponseSnapshot> send(final Uri endpoint) => client.send(
            endpoint,
            RequestSnapshot(
              method: 'POST',
              path: '/request/path?key=value',
              headers: {
                'content-type': 'application/json',
                'authorization': 'Bearer token',
              },
              body: 'Multiline\nBody',
            ),
          );

      test('should return response', () async {
        final response = (await mockServer(send)).response;

        expect(response.statusCode, equals(202));
        expect(response.headers['content-type'], equals('application/json'));
        expect(response.headers['x-custom-header'], equals('custom-value'));
        expect(response.body, equals('Multiline\nResponseBody'));
      });

      test('should send request', () async {
        final request = (await mockServer(send)).request;

        expect(request?.method, equals('POST'));
        expect(request?.path, equals('/request/path?key=value'));
        expect(request?.headers['content-type'], equals('application/json'));
        expect(request?.headers['authorization'], equals('Bearer token'));
        expect(request?.body, equals('Multiline\nBody'));
      });
    });
  });
}

class _Result {
  final RequestSnapshot? request;
  final ResponseSnapshot response;

  const _Result({
    required this.request,
    required this.response,
  });
}
