String? _storedSession;

String? readStoredSession() => _storedSession;

void writeStoredSession(String value) {
  _storedSession = value;
}

void clearStoredSession() {
  _storedSession = null;
}
