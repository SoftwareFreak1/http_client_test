abstract class SnapshotLoader {
  Future<String?> load();
  Future<void> saveCapture(String snapshot);
}
