import 'dart:convert';
import 'dart:io';

class UserClient {
  final Uri _endpoint;

  const UserClient(this._endpoint);

  Future<User> getById(final int id) async {
    final response = await HttpClient()
        .getUrl(_endpoint.resolve('/api/v1/users/$id'))
        .then((request) => request.close());

    final body = jsonDecode(await utf8.decodeStream(response));

    return User(
      id: body['id'],
      name: body['name'],
    );
  }
}

class User {
  final int id;
  final String name;

  const User({
    required this.id,
    required this.name,
  });
}
