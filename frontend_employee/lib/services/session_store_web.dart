// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

const _sessionKey = 'staysmart.employee.auth.session.v1';

String? readStoredSession() => html.window.localStorage[_sessionKey];

void writeStoredSession(String value) {
  html.window.localStorage[_sessionKey] = value;
}

void clearStoredSession() {
  html.window.localStorage.remove(_sessionKey);
}
