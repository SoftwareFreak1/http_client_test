import 'dart:io';

import 'package:http_client_test/src/loader/snapshot_loader.dart';

class FileSnapshotLoader implements SnapshotLoader {
  final String _path;

  const FileSnapshotLoader(this._path);

  @override
  Future<String?> load() async {
    try {
      return await File(_path).readAsString();
    } catch (e) {
      return null;
    }
  }
}
