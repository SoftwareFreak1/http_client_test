import 'package:http_client_test/src/request_snapshot_comparator.dart';
import 'package:http_client_test/src/matcher/async_matcher.dart';
import 'package:test/test.dart';

class RequestSnapshotMatcher extends AsyncMatcher {
  final RequestSnapshotComparator _comparator;

  const RequestSnapshotMatcher(this._comparator);

  @override
  Description describe(final Description description) => description;

  @override
  Future<String?> matchAsync(final dynamic item) async {
    return await _comparator.compare(item)
        ? null
        : 'request snapshot isn\'t equal';
  }
}
