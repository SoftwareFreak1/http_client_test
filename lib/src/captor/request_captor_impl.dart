import 'package:http_client_test/src/captor/mock_http_server.dart';
import 'package:http_client_test/src/captor/request_captor.dart';

class RequestCaptorImpl implements RequestCaptor {
  final MockHttpServer _server;

  const RequestCaptorImpl(this._server);

  @override
  Future<String?> capture(final RequestSender sendRequest) async {
    final endpoint = await _server.createEndpoint();
    await sendRequest(endpoint);
    return await _server.getCapturedRequest();
  }
}
