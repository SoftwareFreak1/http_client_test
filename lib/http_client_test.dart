import 'package:http_client_test/src/captor/mock_http_server_impl.dart';
import 'package:http_client_test/src/captor/request_captor_impl.dart';
import 'package:http_client_test/src/loader/request_snapshot_serializer_impl.dart';
import 'package:http_client_test/src/request_snapshot_comparator_impl.dart';
import 'package:http_client_test/src/loader/file_snapshot_loader.dart';
import 'package:http_client_test/src/matcher/request_snapshot_matcher.dart';
import 'package:http_client_test/src/snapshot/response_snapshot.dart';
import 'package:test/test.dart';

Matcher matchesRequestSnapshot(final String snapshotPath) =>
    RequestSnapshotMatcher(
      RequestSnapshotComparatorImpl(
        RequestCaptorImpl(
          MockHttpServerImpl(
            port: 8080,
            response: ResponseSnapshot(
              statusCode: 200,
              headers: {},
              body: '',
            ),
          ),
        ),
        FileSnapshotLoader(RequestSnapshotSerializerImpl(), snapshotPath),
      ),
    );
