import 'package:http_client_test/src/loader/response_snapshot_serializer.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';

class ResponseSnapshotSerializerImpl implements ResponseSnapshotSerializer {
  @override
  ResponseSnapshot parse(final String serializedSnapshot) => ResponseSnapshot(
        statusCode: _parseStatusCode(serializedSnapshot),
        headers: _parseHeaders(serializedSnapshot),
        body: _parseBody(serializedSnapshot),
      );

  @override
  String serialize(final ResponseSnapshot snapshot) {
    return [
      snapshot.statusCode,
      ...snapshot.headers.keys.map((key) => '$key: ${snapshot.headers[key]}'),
      '',
      snapshot.body,
    ].join('\n');
  }

  int _parseStatusCode(final String serializedSnapshot) =>
      int.parse(serializedSnapshot.split('\n')[0]);

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
