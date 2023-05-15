import 'package:http_client_test/src/captor/mock_http_server.dart';
import 'package:http_client_test/src/captor/request_captor_impl.dart';
import 'package:http_client_test/src/snapshot/request_snapshot.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'request_captor_impl_test.mocks.dart';

@GenerateMocks([MockHttpServer])
void main() {
  group('RequestCaptorImpl', () {
    late MockMockHttpServer server;
    late RequestCaptorImpl captor;

    setUp(() {
      server = MockMockHttpServer();
      captor = RequestCaptorImpl(server);
    });

    void mockServer({
      final Uri? endpoint,
      final RequestSnapshot? capturedRequest,
    }) {
      when(server.createEndpoint()).thenAnswer(
        (_) async => endpoint ?? Uri.parse('http://localhost'),
      );
      when(server.getCapturedRequest()).thenAnswer(
        (_) async => capturedRequest,
      );
    }

    group('capture', () {
      RequestSnapshot newSnapshot() =>
          RequestSnapshot(method: '', path: '', headers: {}, body: '');

      test('should call request sender with endpoint', () async {
        final endpoint = Uri.parse('http://localhost:1234/endpoint');
        mockServer(endpoint: endpoint);

        final sender = _MockRequestSender();
        await captor.capture(sender);
        expect(sender.endpoint, same(endpoint));
      });

      test('should return captured request', () async {
        final capturedRequest = newSnapshot();
        mockServer(capturedRequest: capturedRequest);

        final result = await captor.capture(_MockRequestSender());
        expect(result, same(capturedRequest));
      });
    });
  });
}

class _MockRequestSender {
  Uri? _endpoint;
  Uri? get endpoint => _endpoint;

  Future<void> call(final Uri endpoint) async => _endpoint = endpoint;
}
