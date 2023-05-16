import 'package:http_client_test/src/loader/response_snapshot_serializer_impl.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';
import 'package:test/test.dart';

void main() {
  group('ResponseSnapshotSerializerImpl', () {
    late ResponseSnapshotSerializerImpl serializer;

    setUp(() {
      serializer = ResponseSnapshotSerializerImpl();
    });

    final serializedSnapshot = [
      '202',
      'content-type: application/json',
      'x-custom-header: custom-value',
      '',
      'Multiline',
      'Body'
    ].join('\n');

    group('parse', () {
      ResponseSnapshot parse() => serializer.parse(serializedSnapshot);

      test('should parse status code', () {
        final result = parse();
        expect(result.statusCode, equals(202));
      });

      test('should parse headers', () {
        final result = parse();

        expect(
          result.headers,
          equals({
            'content-type': 'application/json',
            'x-custom-header': 'custom-value',
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
        ResponseSnapshot(
          statusCode: 202,
          headers: {
            'content-type': 'application/json',
            'x-custom-header': 'custom-value',
          },
          body: 'Multiline\nBody',
        ),
      );

      expect(result, equals(serializedSnapshot));
    });
  });
}
