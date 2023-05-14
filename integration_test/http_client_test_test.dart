import 'dart:io';

import 'package:test/test.dart';
import 'package:http_client_test/http_client_test.dart';

void main() {
  group('http_client_test', () {
    group('matchesRequestSnapshot', () {
      Future<void> Function(Uri) sendRequest({
        final String body = 'RequestBody',
      }) =>
          (endpoint) => HttpClient()
              .post(endpoint.host, endpoint.port, '/request/path?key=value')
              .then((request) => request..write(body))
              .then((request) => request.close());

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
        final run =
            (final String snapshotFilePath) => isFailed(() => expectLater(
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
  });
}
