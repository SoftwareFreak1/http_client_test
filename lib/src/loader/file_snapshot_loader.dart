import 'dart:io';

import 'package:http_client_test/src/loader/request_snapshot_serializer.dart';
import 'package:http_client_test/src/loader/snapshot_loader.dart';
import 'package:http_client_test/src/snapshot/request_snapshot.dart';

class FileSnapshotLoader implements SnapshotLoader {
  final RequestSnapshotSerializer _serializer;
  final String _path;

  const FileSnapshotLoader(this._serializer, this._path);

  @override
  Future<RequestSnapshot?> load() async {
    try {
      final content = await File(_path).readAsString();
      return _serializer.parse(content);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveCapture(final RequestSnapshot snapshot) async {
    final content = _serializer.serialize(snapshot);
    await File('$_path.capture').writeAsString(content);
  }
}
