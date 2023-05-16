import 'package:http_client_test/src/snapshot/request_snapshot.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';

abstract class SnapshotLoader {
  Future<RequestSnapshot?> load();
  Future<void> saveCapture(RequestSnapshot snapshot);
  Future<void> saveResponseCapture(ResponseSnapshot snapshot);
}
