import 'package:test/test.dart';
import 'package:http_client_test/http_client_test.dart';

// ignore: avoid_relative_lib_imports
import '../lib/example.dart';

void main() {
  group('UserClient', () {
    test('getById', () async {
      final result = await matchesRequestSnapshot(
        send: (endpoint) => UserClient(endpoint).getById(12),
        request: 'example/test/example_test.request.http',
        response: 'example/test/example_test.response.http',
      );

      expect(result.id, equals(12));
      expect(result.name, equals('Bob'));
    });
  });
}
