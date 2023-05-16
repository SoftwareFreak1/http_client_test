import 'dart:io';

import 'package:http_client_test/src/loader/file_snapshot_loader.dart';
import 'package:http_client_test/src/loader/request_snapshot_serializer.dart';
import 'package:http_client_test/src/loader/response_snapshot_serializer.dart';
import 'package:http_client_test/src/snapshot/request_snapshot.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'file_snapshot_loader_test.mocks.dart';

@GenerateMocks([RequestSnapshotSerializer, ResponseSnapshotSerializer])
void main() {
  group('FileSnapshotLoader', () {
    const snapshotFilePath = 'test/src/loader/file_snapshot_loader_test.http';
    late MockRequestSnapshotSerializer requestSerializer;
    late MockResponseSnapshotSerializer responseSerializer;
    late FileSnapshotLoader loader;

    setUp(() {
      requestSerializer = MockRequestSnapshotSerializer();
      responseSerializer = MockResponseSnapshotSerializer();
      loader = FileSnapshotLoader(
        requestSerializer: requestSerializer,
        responseSerializer: responseSerializer,
        path: snapshotFilePath,
      );
    });

    RequestSnapshot newSnapshot() =>
        RequestSnapshot(method: '', path: '', headers: {}, body: '');

    group('load', () {
      test('should load request snapshot', () async {
        final snapshot = newSnapshot();
        when(requestSerializer.parse('FileContent')).thenReturn(snapshot);

        final result = await loader.load();
        expect(result, same(snapshot));
      });

      test('should return null when file doesn\'t exist', () async {
        final loader = FileSnapshotLoader(
          requestSerializer: requestSerializer,
          responseSerializer: responseSerializer,
          path: 'unknown_file.http',
        );

        final result = await loader.load();
        expect(result, isNull);
      });
    });

    group('loadResponse', () {
      test('should load response snapshot', () async {
        final snapshot = ResponseSnapshot(statusCode: 0, headers: {}, body: '');
        when(responseSerializer.parse('FileContent')).thenReturn(snapshot);

        final result = await loader.loadResponse();
        expect(result, same(snapshot));
      });

      test('should return null when file doesn\'t exist', () async {
        final loader = FileSnapshotLoader(
          requestSerializer: requestSerializer,
          responseSerializer: responseSerializer,
          path: 'unknown_file.http',
        );

        final result = await loader.loadResponse();
        expect(result, isNull);
      });
    });

    group('saveCapture', () {
      test('should save snapshot in different file', () async {
        final snapshot = newSnapshot();
        when(requestSerializer.serialize(snapshot)).thenReturn('Capture');

        await loader.saveCapture(snapshot);

        const snapshotCaptureFilePath = '$snapshotFilePath.capture';
        final captureFile = File(snapshotCaptureFilePath);
        final result = await captureFile.readAsString();
        await captureFile.delete();

        expect(result, equals('Capture'));
      });
    });

    group('saveResponseCapture', () {
      test('should save snapshot in different file', () async {
        final snapshot = ResponseSnapshot(statusCode: 0, headers: {}, body: '');
        when(responseSerializer.serialize(snapshot)).thenReturn('Capture');

        await loader.saveResponseCapture(snapshot);

        const snapshotCaptureFilePath = '$snapshotFilePath.capture';
        final captureFile = File(snapshotCaptureFilePath);
        final result = await captureFile.readAsString();
        await captureFile.delete();

        expect(result, equals('Capture'));
      });
    });
  });
}
