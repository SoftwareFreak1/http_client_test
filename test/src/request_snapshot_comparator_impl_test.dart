import 'package:http_client_test/src/captor/request_captor.dart';
import 'package:http_client_test/src/loader/snapshot_loader.dart';
import 'package:http_client_test/src/request_snapshot_comparator_impl.dart';
import 'package:http_client_test/src/snapshot/request_snapshot.dart';
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

    void mockCapture(final RequestSnapshot? value) =>
        when(requestCaptor.capture(sendRequest)).thenAnswer((_) async => value);

    void mockSnapshot(final RequestSnapshot? value) =>
        when(snapshotLoader.load()).thenAnswer((_) async => value);

    Future<bool> compare() => comparator.compare(sendRequest);

    group('compare', () {
      RequestSnapshot newSnapshot({final String method = 'POST'}) =>
          RequestSnapshot(method: method, path: '/', headers: {}, body: '');

      test('should return true when capture and snapshot are equal', () async {
        mockCapture(newSnapshot());
        mockSnapshot(newSnapshot());

        final result = await compare();
        expect(result, isTrue);
      });

      test(
        'should return false when capture and snapshot are not equal',
        () async {
          mockCapture(newSnapshot(method: 'GET'));
          mockSnapshot(newSnapshot(method: 'POST'));

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
        final capture = newSnapshot(method: 'GET');
        mockCapture(capture);
        mockSnapshot(newSnapshot(method: 'POST'));

        await compare();
        verify(snapshotLoader.saveCapture(capture));
      });

      test('should not save capture when equal', () async {
        mockCapture(newSnapshot());
        mockSnapshot(newSnapshot());

        await compare();
        verifyNever(snapshotLoader.saveCapture(any));
      });
    });
  });
}
