import 'dart:convert';
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
    Future<String> Function(Uri) sendRequest({
      final String body = 'RequestBody',
    }) =>
        (endpoint) => HttpClient()
            .post(endpoint.host, endpoint.port, '/request/path?key=value')
            .then((request) {
              request.headers.add('authorization', 'Bearer token');
              return request;
            })
            .then((request) => request..write(body))
            .then((request) => request.close())
            .then((value) => 'RequestSenderResult');

    group('matchesRequestSnapshot', () {
      test('should succeed when request and snapshot are equal', () async {
        await matchesRequestSnapshot(
          send: sendRequest(),
          request: 'integration_test/matchesRequestSnapshot.http',
        );
      });

      test('should fail when request and snapshot aren\'t equal', () async {
        send() => matchesRequestSnapshot(
              send: sendRequest(body: 'DifferentBody'),
              request: 'integration_test/matchesRequestSnapshot.http',
            );

        await expectLater(send, throwsA(anything));
      });

      test('should fail when snapshot file doesn\'t exist', () async {
        send() => matchesRequestSnapshot(
              send: sendRequest(),
              request: 'unknown_snapshot.http',
            );

        await expectLater(send, throwsA(anything));
      });

      test('should save capture when failed', () async {
        send(final String snapshotFilePath) => matchesRequestSnapshot(
              send: sendRequest(body: 'DifferentBody'),
              request: snapshotFilePath,
            );

        const snapshotFileName = 'integration_test/matchesRequestSnapshot.http';
        const captureFileName = '$snapshotFileName.capture';
        await expectLater(() => send(snapshotFileName), throwsA(anything));
        await send(captureFileName);
      });

      test('should send response', () async {
        final container = _ResponseContainer();

        await matchesRequestSnapshot(
          send: container.sendRequest,
          request: 'integration_test/matchesRequestSnapshot.request.http',
          response: 'integration_test/matchesRequestSnapshot.response.http',
        );

        final response = container.response!;
        final responseBody = await utf8.decodeStream(response);

        expect(response.statusCode, equals(202));
        expect(
          response.headers.value('content-type'),
          equals('application/json'),
        );
        expect(responseBody, equals('ResponseBody'));
      });

      test('should return result of request sender', () async {
        final result = await matchesRequestSnapshot(
          send: sendRequest(),
          request: 'integration_test/matchesRequestSnapshot.http',
        );

        expect(result, equals('RequestSenderResult'));
      });
    });

    group('captureResponseSnapshot', () {
      Future<RequestSnapshot?> mockServer(final RequestSender sendRequest) =>
          RequestCaptorImpl(
            MockHttpServerImpl(
              port: 8081,
              responseSupplier: () async => ResponseSnapshot(
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
            endpoint: endpoint,
            send: sendRequest(),
            output: snapshotFile,
          ),
        );

        final actual = await readFile('$snapshotFile.capture');
        final expected = await readFile(snapshotFile);
        expect(actual, equals(expected));
      });

      test('should send request to real endpoint', () async {
        final request = await mockServer(
          (endpoint) => captureResponseSnapshot(
            endpoint: endpoint,
            send: sendRequest(),
            output: 'unknown_snapshot.http',
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

class _ResponseContainer {
  HttpClientResponse? _response;
  HttpClientResponse? get response => _response;

  Future<void> sendRequest(final Uri endpoint) async {
    _response = await HttpClient()
        .post(endpoint.host, endpoint.port, '/')
        .then((request) => request.close());
  }
}
