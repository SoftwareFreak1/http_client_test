import 'package:http_client_test/src/loader/file_snapshot_loader.dart';
import 'package:test/test.dart';

void main() {
  group('FileSnapshotLoader', () {
    test('should load file content', () async {
      final loader = FileSnapshotLoader(
        'test/src/loader/file_snapshot_loader_test.http',
      );

      final result = await loader.load();
      expect(result, equals('FileContent'));
    });

    test('should return null when file doesn\'t exist', () async {
      final loader = FileSnapshotLoader('unknown_file.http');
      final result = await loader.load();
      expect(result, isNull);
    });
  });
}
