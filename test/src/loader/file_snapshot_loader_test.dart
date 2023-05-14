import 'dart:io';

import 'package:http_client_test/src/loader/file_snapshot_loader.dart';
import 'package:test/test.dart';

void main() {
  group('FileSnapshotLoader', () {
    const snapshotFilePath = 'test/src/loader/file_snapshot_loader_test.http';

    group('load', () {
      test('should load file content', () async {
        final loader = FileSnapshotLoader(snapshotFilePath);
        final result = await loader.load();
        expect(result, equals('FileContent'));
      });

      test('should return null when file doesn\'t exist', () async {
        final loader = FileSnapshotLoader('unknown_file.http');
        final result = await loader.load();
        expect(result, isNull);
      });
    });

    group('saveCapture', () {
      test('should save snapshot in different file', () async {
        final loader = FileSnapshotLoader(snapshotFilePath);
        await loader.saveCapture('Capture');

        const snapshotCaptureFilePath =
            'test/src/loader/file_snapshot_loader_test.http.capture';
        final result = await FileSnapshotLoader(snapshotCaptureFilePath).load();
        await File(snapshotCaptureFilePath).delete();

        expect(result, equals('Capture'));
      });
    });
  });
}
