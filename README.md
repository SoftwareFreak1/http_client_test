This package provides an easy way to write tests for API clients communicating over HTTP (REST, GraphQL, ...).

## Usage

```dart
import 'package:test/test.dart';
import 'package:http_client_test/http_client_test.dart';

void main() {
  group('UserClient', () {
    test('getById', () async {
      // fails when the request sent doesn't match the specified request.
      // The return value of the send function will be returned.
      final result = await matchesRequestSnapshot(
        // invoke the client with the provided server endpoint.
        send: (endpoint) => UserClient(endpoint).getById(12),
        // file path containing a snapshot of the expected request.
        request: 'user_client_test.request.http',
        // (optional) file path containing a snapshot of the simulated response.
        response: 'user_client_test.response.http',
      );

      // return value of the client can be tested against the simulated response.
      expect(result.id, equals(12));
      expect(result.name, equals('Bob'));
    });
  });
}
```
