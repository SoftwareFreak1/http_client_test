import 'package:http_client_test/src/captor/mock_http_server_impl.dart';
import 'package:http_client_test/src/captor/request_captor.dart';
import 'package:http_client_test/src/captor/request_captor_impl.dart';
import 'package:http_client_test/src/captor/snapshot_http_client_impl.dart';
import 'package:http_client_test/src/loader/file_snapshot_loader.dart';
import 'package:http_client_test/src/loader/request_snapshot_serializer_impl.dart';
import 'package:http_client_test/src/loader/response_snapshot_serializer_impl.dart';
import 'package:http_client_test/src/loader/snapshot_loader.dart';
import 'package:http_client_test/src/request_snapshot_comparator_impl.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';

/// Asserts that the HTTP request sent by [send] match the request snapshot
/// saved at [request].
///
/// If the request doesn't matches the snapshot or the snapshot file doesn't
/// exist, the actual request will be saved as [request] extended with '.capture'
/// and a [Exception] will be thrown.
/// Optional the response with which the server will respond can be specified
/// using [response] as path to the snapshot file.
/// Returns the returned value by [send] for further assertions.
Future<T> matchesRequestSnapshot<T>({
  required final Future<T> Function(Uri) send,
  required final String request,
  final String? response,
}) async {
  final comparator = RequestSnapshotComparatorImpl(
    _newRequestCaptor(
      response == null
          ? null
          : () => _newLoader(response).loadResponse().then((r) => r!),
    ),
    _newLoader(request),
  );

  T? result;
  sendRequest(final Uri endpoint) async => result = await send(endpoint);

  if (!await comparator.compare(sendRequest)) {
    throw Exception('request snapshot isn\'t equal');
  }

  return result as T;
}

/// Saves a snapshot of the HTTP response produced by calling [send] against
/// the [endpoint], in the given [output] file path.
///
/// Should only be used to produce a base snapshot which can be used
/// at [matchesRequestSnapshot].
Future<void> captureResponseSnapshot({
  required final Uri endpoint,
  required final RequestSender send,
  required final String output,
}) async {
  sendRequest(final Uri endpoint) async {
    try {
      await send(endpoint);
    } catch (e) {} // ignore: empty_catches
  }

  final request = await _newRequestCaptor().capture(sendRequest);
  final response = await SnapshotHttpClientImpl().send(endpoint, request!);
  await _newLoader(output).saveResponseCapture(response);
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
