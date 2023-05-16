import 'package:http_client_test/src/snapshot/request_snapshot.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';

abstract class SnapshotHttpClient {
  Future<ResponseSnapshot> send(Uri endpoint, RequestSnapshot request);
}
