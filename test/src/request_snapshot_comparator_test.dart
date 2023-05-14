import 'package:http_client_test/src/captor/request_captor.dart';
import 'package:http_client_test/src/loader/snapshot_loader.dart';
import 'package:http_client_test/src/request_snapshot_comparator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'request_snapshot_comparator_test.mocks.dart';

@GenerateMocks([RequestCaptor, SnapshotLoader])
void main() {
  group('RequestSnapshotComparator', () {
    late MockRequestCaptor requestCaptor;
    late MockSnapshotLoader snapshotLoader;
    late RequestSnapshotComparator comparator;

    setUp(() {
      requestCaptor = MockRequestCaptor();
      snapshotLoader = MockSnapshotLoader();
      comparator = RequestSnapshotComparator(requestCaptor, snapshotLoader);
    });

    void mockCapture(final String? value) =>
        when(requestCaptor.capture(any)).thenAnswer((_) async => value);

    void mockSnapshot(final String? value) =>
        when(snapshotLoader.load()).thenAnswer((_) async => value);
    ;

    group('compare', () {
      test('should return true when capture and snapshot are equal', () async {
        mockCapture('RequestSnapshot');
        mockSnapshot('RequestSnapshot');

        final result = await comparator.compare((_) async {});
        expect(result, isTrue);
      });

      test(
        'should return false when capture and snapshot are not equal',
        () async {
          mockCapture('Capture');
          mockSnapshot('Snapshot');

          final result = await comparator.compare((_) async {});
          expect(result, isFalse);
        },
      );

      test('should return false when capture and snapshot are null', () async {
        mockCapture(null);
        mockSnapshot(null);

        final result = await comparator.compare((_) async {});
        expect(result, isFalse);
      });
    });
  });
}
