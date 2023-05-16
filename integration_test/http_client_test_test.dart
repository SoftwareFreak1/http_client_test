import 'dart:io';

import 'package:http_client_test/src/captor/mock_http_server_impl.dart';
import 'package:http_client_test/src/captor/request_captor.dart';
import 'package:http_client_test/src/captor/request_captor_impl.dart';
import 'package:http_client_test/src/snapshot/request_snapshot.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';
import 'package:test/test.dart';
import 'package:http_client_test/http_client_test.dart';

void main() {
  group('http_client_test', () {
    Future<void> Function(Uri) sendRequest({
      final String body = 'RequestBody',
    }) =>
        (endpoint) => HttpClient()
            .post(endpoint.host, endpoint.port, '/request/path?key=value')
            .then((request) {
              request.headers.add('authorization', 'Bearer token');
              return request;
            })
            .then((request) => request..write(body))
            .then((request) => request.close());

    group('matchesRequestSnapshot', () {
      Future<bool> isFailed(Future<void> Function() function) async {
        bool isFailed = false;

        try {
          await function();
        } catch (e) {
          isFailed = true;
        }

        return isFailed;
      }

      test('should succeed when request and snapshot are equal', () async {
        final result = await isFailed(() => expectLater(
              sendRequest(),
              matchesRequestSnapshot(
                'integration_test/matchesRequestSnapshot.http',
              ),
            ));

        expect(result, isFalse);
      });

      test('should fail when request and snapshot aren\'t equal', () async {
        final result = await isFailed(() => expectLater(
              sendRequest(body: 'DifferentBody'),
              matchesRequestSnapshot(
                'integration_test/matchesRequestSnapshot.http',
              ),
            ));

        expect(result, isTrue);
      });

      test('should fail when snapshot file doesn\'t exist', () async {
        final result = await isFailed(() => expectLater(
              sendRequest(),
              matchesRequestSnapshot('unknown_snapshot.http'),
            ));

        expect(result, isTrue);
      });

      test('should save capture when failed', () async {
        run(final String snapshotFilePath) => isFailed(() => expectLater(
              sendRequest(body: 'DifferentBody'),
              matchesRequestSnapshot(snapshotFilePath),
            ));

        const snapshotFileName = 'integration_test/matchesRequestSnapshot.http';
        const captureFileName = '$snapshotFileName.capture';
        await run(snapshotFileName);
        final result = await run(captureFileName);

        expect(result, isFalse);
      });
    });

    group('captureResponseSnapshot', () {
      Future<RequestSnapshot?> mockServer(final RequestSender sendRequest) =>
          RequestCaptorImpl(
            MockHttpServerImpl(
              port: 8081,
              response: ResponseSnapshot(
                statusCode: 200,
                headers: {
                  'content-type': 'text/plain',
                },
                body: 'ResponseBody',
              ),
            ),
          ).capture(sendRequest);

      Future<String> readFile(final String path) => File(path).readAsString();

      test('should save response capture', () async {
        const snapshotFile = 'integration_test/captureResponseSnapshot.http';

        await mockServer(
          (endpoint) => captureResponseSnapshot(
            snapshotFile: snapshotFile,
            endpoint: endpoint,
            sendRequest: sendRequest(),
          ),
        );

        final actual = await readFile('$snapshotFile.capture');
        final expected = await readFile(snapshotFile);
        expect(actual, equals(expected));
      });

      test('should send request to real endpoint', () async {
        final request = await mockServer(
          (endpoint) => captureResponseSnapshot(
            snapshotFile: 'unknown_snapshot.http',
            endpoint: endpoint,
            sendRequest: sendRequest(),
          ),
        );

        expect(request?.method, equals('POST'));
        expect(request?.path, equals('/request/path?key=value'));
        expect(request?.headers['authorization'], equals('Bearer token'));
        expect(request?.body, equals('RequestBody'));
      });
    });
  });
}
