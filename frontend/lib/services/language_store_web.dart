// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

const _languageKey = 'staysmart.language.v1';

String? readStoredLanguageCode() => html.window.localStorage[_languageKey];

void writeStoredLanguageCode(String value) {
  html.window.localStorage[_languageKey] = value;
}
