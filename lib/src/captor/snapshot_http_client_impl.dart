import 'dart:convert';
import 'dart:io';

import 'package:http_client_test/src/captor/snapshot_http_client.dart';
import 'package:http_client_test/src/snapshot/request_snapshot.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';

class SnapshotHttpClientImpl implements SnapshotHttpClient {
  @override
  Future<ResponseSnapshot> send(
    final Uri endpoint,
    final RequestSnapshot request,
  ) =>
      _sendRequest(endpoint, request).then(_parseResponse);

  Future<HttpClientResponse> _sendRequest(
    final Uri endpoint,
    final RequestSnapshot request,
  ) async {
    final httpRequest = await HttpClient()
        .openUrl(request.method, endpoint.resolve(request.path));

    request.headers.forEach(httpRequest.headers.add);
    httpRequest.write(request.body);

    return await httpRequest.close();
  }

  Future<ResponseSnapshot> _parseResponse(
      final HttpClientResponse response) async {
    final body = await utf8.decodeStream(response);

    final headers = <String, String>{};
    response.headers.forEach((name, values) => headers[name] = values[0]);

    return ResponseSnapshot(
      statusCode: response.statusCode,
      headers: headers,
      body: body,
    );
  }
}
