bool isOfflineMessage(String msg) {
  final s = msg.toLowerCase();

  return s.contains('socketexception') ||
      s.contains('failed host lookup') ||
      s.contains('no address associated with hostname') ||
      s.contains('network is unreachable') ||
      s.contains('connection error') ||
      s.contains('connection timed out') ||
      s.contains('timed out') ||
      s.contains('dns') ||
      s.contains('name not resolved') ||
      s.contains('errno = 7');
}
