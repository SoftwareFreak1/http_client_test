import 'package:http_client_test/src/captor/request_captor.dart';
import 'package:http_client_test/src/loader/snapshot_loader.dart';
import 'package:http_client_test/src/request_snapshot_comparator.dart';

class RequestSnapshotComparatorImpl implements RequestSnapshotComparator {
  final RequestCaptor _captor;
  final SnapshotLoader _loader;

  const RequestSnapshotComparatorImpl(this._captor, this._loader);

  @override
  Future<bool> compare(final RequestSender sendRequest) async {
    final capturedSnapshot = await _captor.capture(sendRequest);
    final snapshot = await _loader.load();

    return capturedSnapshot == snapshot && capturedSnapshot != null;
  }
}