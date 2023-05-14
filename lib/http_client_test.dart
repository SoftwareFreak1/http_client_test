import 'package:http_client_test/src/captor/mock_http_server_impl.dart';
import 'package:http_client_test/src/captor/request_captor_impl.dart';
import 'package:http_client_test/src/captor/request_serializer_impl.dart';
import 'package:http_client_test/src/request_snapshot_comparator_impl.dart';
import 'package:http_client_test/src/loader/file_snapshot_loader.dart';
import 'package:http_client_test/src/matcher/request_snapshot_matcher.dart';
import 'package:matcher/src/expect/async_matcher.dart';

AsyncMatcher matchesRequestSnapshot(final String snapshotPath) =>
    RequestSnapshotMatcher(
      RequestSnapshotComparatorImpl(
        RequestCaptorImpl(MockHttpServerImpl(RequestSerializerImpl())),
        FileSnapshotLoader(snapshotPath),
      ),
    );
