bool isOfflineMessage(String msg) {
  final m = msg.toLowerCase();
  return m.contains('no internet') ||
      m.contains('socket') ||
      m.contains('timeout') ||
      m.contains('timed out') ||
      m.contains('network');
}
