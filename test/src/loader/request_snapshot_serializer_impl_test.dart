import 'package:http_client_test/src/loader/request_snapshot_serializer_impl.dart';
import 'package:http_client_test/src/snapshot/request_snapshot.dart';
import 'package:test/test.dart';

void main() {
  group('RequestSnapshotSerializerImpl', () {
    late RequestSnapshotSerializerImpl serializer;

    setUp(() {
      serializer = RequestSnapshotSerializerImpl();
    });

    final serializedSnapshot = [
      'POST /request/path?key=value',
      'content-type: application/json',
      'authorization: Bearer token',
      '',
      'Multiline',
      'Body'
    ].join('\n');

    group('parse', () {
      RequestSnapshot parse() => serializer.parse(serializedSnapshot);

      test('should parse method', () {
        final result = parse();
        expect(result.method, equals('POST'));
      });

      test('should parse path', () {
        final result = parse();
        expect(result.path, equals('/request/path?key=value'));
      });

      test('should parse headers', () {
        final result = parse();

        expect(
          result.headers,
          equals({
            'content-type': 'application/json',
            'authorization': 'Bearer token',
          }),
        );
      });

      test('should parse body', () {
        final result = parse();
        expect(result.body, equals('Multiline\nBody'));
      });
    });

    test('serialize', () {
      final result = serializer.serialize(
        RequestSnapshot(
          method: 'POST',
          path: '/request/path?key=value',
          headers: {
            'content-type': 'application/json',
            'authorization': 'Bearer token',
          },
          body: 'Multiline\nBody',
        ),
      );

      expect(result, equals(serializedSnapshot));
    });
  });
}
