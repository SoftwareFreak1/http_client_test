import 'package:http_client_test/src/matcher/request_snapshot_matcher.dart';
import 'package:http_client_test/src/request_snapshot_comparator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'request_snapshot_matcher_test.mocks.dart';

@GenerateMocks([RequestSnapshotComparator])
void main() {
  group('RequestSnapshotMatcher', () {
    late RequestSnapshotComparator comparator;
    late RequestSnapshotMatcher matcher;

    setUp(() {
      comparator = MockRequestSnapshotComparator();
      matcher = RequestSnapshotMatcher(comparator);
    });

    Future<bool> isFailed(final Future<void> Function() function) async {
      bool isFailed = false;

      try {
        await function();
      } catch (e) {
        isFailed = true;
      }

      return isFailed;
    }

    Future<bool> testMatcher({required final bool comparatorResult}) async {
      sendRequest(_) async => {};

      when(comparator.compare(sendRequest))
          .thenAnswer((_) async => comparatorResult);

      return await isFailed(() => expectLater(sendRequest, matcher));
    }

    test('should succeed when comparator returns true', () async {
      final isFailed = await testMatcher(comparatorResult: true);
      expect(isFailed, isFalse);
    });

    test('should fail when comparator returns false', () async {
      final isFailed = await testMatcher(comparatorResult: false);
      expect(isFailed, isTrue);
    });
  });
}
