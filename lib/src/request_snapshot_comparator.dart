import 'package:http_client_test/src/captor/request_captor.dart';

abstract class RequestSnapshotComparator {
  Future<bool> compare(final RequestSender sendRequest);
}
