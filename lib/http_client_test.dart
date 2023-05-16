import 'package:http_client_test/src/captor/mock_http_server_impl.dart';
import 'package:http_client_test/src/captor/request_captor.dart';
import 'package:http_client_test/src/captor/request_captor_impl.dart';
import 'package:http_client_test/src/captor/snapshot_http_client_impl.dart';
import 'package:http_client_test/src/loader/request_snapshot_serializer_impl.dart';
import 'package:http_client_test/src/loader/response_snapshot_serializer_impl.dart';
import 'package:http_client_test/src/loader/snapshot_loader.dart';
import 'package:http_client_test/src/request_snapshot_comparator_impl.dart';
import 'package:http_client_test/src/loader/file_snapshot_loader.dart';
import 'package:http_client_test/src/matcher/request_snapshot_matcher.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';
import 'package:test/test.dart';

Matcher matchesRequestSnapshot(
  final String requestSnapshotFile, [
  final String? responseSnapshotFile,
]) =>
    RequestSnapshotMatcher(
      RequestSnapshotComparatorImpl(
        _newRequestCaptor(
          responseSnapshotFile == null
              ? null
              : () => _newLoader(responseSnapshotFile)
                  .loadResponse()
                  .then((response) => response!),
        ),
        _newLoader(requestSnapshotFile),
      ),
    );

Future<void> captureResponseSnapshot({
  required final String snapshotFile,
  required final Uri endpoint,
  required final RequestSender sendRequest,
}) async {
  final request = await _newRequestCaptor().capture(sendRequest);
  final response = await SnapshotHttpClientImpl().send(endpoint, request!);
  await _newLoader(snapshotFile).saveResponseCapture(response);
}

_newRequestCaptor([final ResponseSupplier? responseSupplier]) =>
    RequestCaptorImpl(
      MockHttpServerImpl(
        port: 8080,
        responseSupplier: responseSupplier ??
            () async => ResponseSnapshot(
                  statusCode: 200,
                  headers: {},
                  body: '',
                ),
      ),
    );

SnapshotLoader _newLoader(final String snapshotFile) => FileSnapshotLoader(
      requestSerializer: RequestSnapshotSerializerImpl(),
      responseSerializer: ResponseSnapshotSerializerImpl(),
      path: snapshotFile,
    );
