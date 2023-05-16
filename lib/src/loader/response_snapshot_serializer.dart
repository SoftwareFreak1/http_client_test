import 'package:http_client_test/src/snapshot/response_snapshot.dart';

abstract class ResponseSnapshotSerializer {
  ResponseSnapshot parse(String serializedSnapshot);
  String serialize(ResponseSnapshot snapshot);
}
