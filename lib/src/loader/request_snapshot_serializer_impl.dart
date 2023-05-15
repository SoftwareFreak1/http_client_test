import 'package:http_client_test/src/loader/request_snapshot_serializer.dart';
import 'package:http_client_test/src/snapshot/request_snapshot.dart';

class RequestSnapshotSerializerImpl implements RequestSnapshotSerializer {
  @override
  RequestSnapshot parse(final String serializedSnapshot) {
    final firstLine = _parseFirstLine(serializedSnapshot);

    return RequestSnapshot(
      method: firstLine[0],
      path: firstLine[1],
      headers: _parseHeaders(serializedSnapshot),
      body: _parseBody(serializedSnapshot),
    );
  }

  @override
  String serialize(final RequestSnapshot snapshot) => [
        '${snapshot.method} ${snapshot.path}',
        ...snapshot.headers.keys.map((key) => '$key: ${snapshot.headers[key]}'),
        '',
        snapshot.body,
      ].join('\n');

  List<String> _parseFirstLine(final String serializedSnapshot) =>
      serializedSnapshot.split('\n')[0].split(' ');

  Map<String, String> _parseHeaders(final String serializedSnapshot) {
    final Map<String, String> headers = {};

    serializedSnapshot
        .split('\n')
        .skip(1)
        .takeWhile((line) => line.isNotEmpty)
        .map((line) => line.split(': '))
        .forEach((lineTuple) => headers[lineTuple[0]] = lineTuple[1]);

    return headers;
  }

  String _parseBody(final String serializedSnapshot) => serializedSnapshot
      .split('\n')
      .skipWhile((line) => line.isNotEmpty)
      .skip(1)
      .join('\n');
}
