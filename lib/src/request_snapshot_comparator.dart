import 'package:http_client_test/src/captor/request_captor.dart';
import 'package:http_client_test/src/loader/snapshot_loader.dart';

class RequestSnapshotComparator {
  final RequestCaptor _captor;
  final SnapshotLoader _loader;

  const RequestSnapshotComparator(this._captor, this._loader);

  Future<bool> compare(final RequestSender sendRequest) async {
    final capturedSnapshot = await _captor.capture((_) async {});
    final snapshot = await _loader.load();

    return capturedSnapshot == snapshot && capturedSnapshot != null;
  }
}
