import 'package:http_client_test/src/captor/request_captor.dart';
import 'package:http_client_test/src/loader/snapshot_loader.dart';
import 'package:http_client_test/src/request_snapshot_comparator_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'request_snapshot_comparator_impl_test.mocks.dart';

@GenerateMocks([RequestCaptor, SnapshotLoader])
void main() {
  group('RequestSnapshotComparatorImpl', () {
    late MockRequestCaptor requestCaptor;
    late MockSnapshotLoader snapshotLoader;
    late RequestSender sendRequest;
    late RequestSnapshotComparatorImpl comparator;

    setUp(() {
      requestCaptor = MockRequestCaptor();
      snapshotLoader = MockSnapshotLoader();
      sendRequest = (_) async {};
      comparator = RequestSnapshotComparatorImpl(requestCaptor, snapshotLoader);
    });

    void mockCapture(final String? value) =>
        when(requestCaptor.capture(sendRequest)).thenAnswer((_) async => value);

    void mockSnapshot(final String? value) =>
        when(snapshotLoader.load()).thenAnswer((_) async => value);

    Future<bool> compare() => comparator.compare(sendRequest);

    group('compare', () {
      test('should return true when capture and snapshot are equal', () async {
        mockCapture('RequestSnapshot');
        mockSnapshot('RequestSnapshot');

        final result = await compare();
        expect(result, isTrue);
      });

      test(
        'should return false when capture and snapshot are not equal',
        () async {
          mockCapture('Capture');
          mockSnapshot('Snapshot');

          final result = await compare();
          expect(result, isFalse);
        },
      );

      test('should return false when capture and snapshot are null', () async {
        mockCapture(null);
        mockSnapshot(null);

        final result = await compare();
        expect(result, isFalse);
      });

      test('should save capture when not equal', () async {
        mockCapture('Capture');
        mockSnapshot('Snapshot');

        await compare();
        verify(snapshotLoader.saveCapture('Capture'));
      });

      test('should not save capture when equal', () async {
        mockCapture('RequestSnapshot');
        mockSnapshot('RequestSnapshot');

        await compare();
        verifyNever(snapshotLoader.saveCapture(any));
      });
    });
  });
}
