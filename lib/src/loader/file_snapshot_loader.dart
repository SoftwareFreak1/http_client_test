import 'dart:io';

import 'package:http_client_test/src/loader/request_snapshot_serializer.dart';
import 'package:http_client_test/src/loader/response_snapshot_serializer.dart';
import 'package:http_client_test/src/loader/snapshot_loader.dart';
import 'package:http_client_test/src/snapshot/request_snapshot.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';

class FileSnapshotLoader implements SnapshotLoader {
  final RequestSnapshotSerializer _requestSerializer;
  final ResponseSnapshotSerializer _responseSerializer;
  final String _path;

  const FileSnapshotLoader({
    required final RequestSnapshotSerializer requestSerializer,
    required final ResponseSnapshotSerializer responseSerializer,
    required final String path,
  })  : _requestSerializer = requestSerializer,
        _responseSerializer = responseSerializer,
        _path = path;

  @override
  Future<RequestSnapshot?> load() async {
    try {
      final content = await File(_path).readAsString();
      return _requestSerializer.parse(content);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ResponseSnapshot?> loadResponse() async {
    try {
      final content = await File(_path).readAsString();
      return _responseSerializer.parse(content);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveCapture(final RequestSnapshot snapshot) async {
    final content = _requestSerializer.serialize(snapshot);
    await File('$_path.capture').writeAsString(content);
  }

  @override
  Future<void> saveResponseCapture(final ResponseSnapshot snapshot) async {
    final content = _responseSerializer.serialize(snapshot);
    await File('$_path.capture').writeAsString(content);
  }
}
