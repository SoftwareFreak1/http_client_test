import 'package:http_client_test/src/snapshot/request_snapshot.dart';

abstract class RequestSnapshotSerializer {
  RequestSnapshot parse(String serializedSnapshot);
  String serialize(RequestSnapshot snapshot);
}
