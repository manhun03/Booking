// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

const _sessionKey = 'staysmart.auth.session.v1';

String? readStoredSession() => html.window.localStorage[_sessionKey];

void writeStoredSession(String value) {
  html.window.localStorage[_sessionKey] = value;
}

void clearStoredSession() {
  html.window.localStorage.remove(_sessionKey);
}
