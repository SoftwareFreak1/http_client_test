import 'package:http_client_test/src/snapshot/request_snapshot.dart';

abstract class SnapshotLoader {
  Future<RequestSnapshot?> load();
  Future<void> saveCapture(RequestSnapshot snapshot);
}
