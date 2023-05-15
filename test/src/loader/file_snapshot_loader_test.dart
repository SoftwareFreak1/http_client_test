import 'dart:io';

import 'package:http_client_test/src/loader/file_snapshot_loader.dart';
import 'package:http_client_test/src/loader/request_snapshot_serializer.dart';
import 'package:http_client_test/src/snapshot/request_snapshot.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'file_snapshot_loader_test.mocks.dart';

@GenerateMocks([RequestSnapshotSerializer])
void main() {
  group('FileSnapshotLoader', () {
    const snapshotFilePath = 'test/src/loader/file_snapshot_loader_test.http';
    late MockRequestSnapshotSerializer serializer;
    late FileSnapshotLoader loader;

    setUp(() {
      serializer = MockRequestSnapshotSerializer();
      loader = FileSnapshotLoader(serializer, snapshotFilePath);
    });

    RequestSnapshot newSnapshot() =>
        RequestSnapshot(method: '', path: '', headers: {}, body: '');

    group('load', () {
      test('should load request snapshot', () async {
        final snapshot = newSnapshot();
        when(serializer.parse('FileContent')).thenReturn(snapshot);

        final result = await loader.load();
        expect(result, same(snapshot));
      });

      test('should return null when file doesn\'t exist', () async {
        final loader = FileSnapshotLoader(serializer, 'unknown_file.http');
        final result = await loader.load();
        expect(result, isNull);
      });
    });

    group('saveCapture', () {
      test('should save snapshot in different file', () async {
        final snapshot = newSnapshot();
        when(serializer.serialize(snapshot)).thenReturn('Capture');

        await loader.saveCapture(snapshot);

        const snapshotCaptureFilePath = '$snapshotFilePath.capture';
        final captureFile = File(snapshotCaptureFilePath);
        final result = await captureFile.readAsString();
        await captureFile.delete();

        expect(result, equals('Capture'));
      });
    });
  });
}
