import 'package:http_client_test/src/snapshot/request_snapshot.dart';
import 'package:test/test.dart';

void main() {
  group('RequestSnapshot', () {
    RequestSnapshot newSnapshot({
      final String method = 'POST',
      final String path = '/request/path',
      final Map<String, String>? headers,
      final String body = 'body',
    }) =>
        RequestSnapshot(
          method: method,
          path: path,
          // don't assign const value
          headers: headers ?? {'content-type': 'application/json'},
          body: body,
        );

    group('isEqual', () {
      test('should return true when equal', () {
        final result = RequestSnapshot.isEqual(newSnapshot(), newSnapshot());
        expect(result, isTrue);
      });

      test('should return false when method is different', () {
        final result = RequestSnapshot.isEqual(
          newSnapshot(),
          newSnapshot(method: 'GET'),
        );

        expect(result, isFalse);
      });

      test('should return false when path is different', () {
        final result = RequestSnapshot.isEqual(
          newSnapshot(),
          newSnapshot(path: '/'),
        );

        expect(result, isFalse);
      });

      test('should return false when headers are different', () {
        final result = RequestSnapshot.isEqual(
          newSnapshot(),
          newSnapshot(headers: {'authorization': 'Bearer token'}),
        );

        expect(result, isFalse);
      });

      test('should return false when body is different', () {
        final result = RequestSnapshot.isEqual(
          newSnapshot(),
          newSnapshot(body: 'different'),
        );

        expect(result, isFalse);
      });

      test('should return false when first is null', () {
        final result = RequestSnapshot.isEqual(null, newSnapshot());
        expect(result, isFalse);
      });

      test('should return false when second is null', () {
        final result = RequestSnapshot.isEqual(newSnapshot(), null);
        expect(result, isFalse);
      });

      test('should return false when both are null', () {
        final result = RequestSnapshot.isEqual(null, null);
        expect(result, isFalse);
      });
    });
  });
}
