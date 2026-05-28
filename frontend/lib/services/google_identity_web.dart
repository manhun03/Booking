// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

Future<void>? _googleScriptLoad;

Future<String> requestGoogleIdToken({required String clientId}) async {
  final trimmedClientId = clientId.trim();
  if (trimmedClientId.isEmpty) {
    throw StateError(
      'Google Client ID is not configured. Start Flutter with --dart-define=GOOGLE_CLIENT_ID=your-client-id.',
    );
  }

  await _ensureGoogleIdentityScript();

  final google = js.context['google'] as js.JsObject;
  final accounts = google['accounts'] as js.JsObject;
  final identity = accounts['id'] as js.JsObject;
  final completer = Completer<String>();
  late html.DivElement overlay;

  void completeWithError(Object error) {
    overlay.remove();
    if (!completer.isCompleted) {
      completer.completeError(error);
    }
  }

  void completeWithToken(String token) {
    overlay.remove();
    if (!completer.isCompleted) {
      completer.complete(token);
    }
  }

  overlay = _buildOverlay(onCancel: () {
    completeWithError(StateError('Google sign-in was cancelled.'));
  });
  final buttonHost = overlay.querySelector('.google-button-host');
  if (buttonHost == null) {
    throw StateError('Could not prepare Google sign-in button.');
  }
  html.document.body?.append(overlay);

  void callback(dynamic response) {
    final credential = response is js.JsObject ? response['credential'] : null;
    if (credential is String && credential.trim().isNotEmpty) {
      completeWithToken(credential.trim());
      return;
    }
    completeWithError(StateError('Google did not return an ID token.'));
  }

  identity.callMethod('initialize', [
    js.JsObject.jsify({
      'client_id': trimmedClientId,
      'callback': callback,
      'auto_select': false,
      'cancel_on_tap_outside': true,
    }),
  ]);

  identity.callMethod('renderButton', [
    buttonHost,
    js.JsObject.jsify({
      'theme': 'outline',
      'size': 'large',
      'type': 'standard',
      'shape': 'rectangular',
      'text': 'continue_with',
      'width': 320,
    }),
  ]);

  return completer.future.timeout(
    const Duration(minutes: 2),
    onTimeout: () {
      overlay.remove();
      throw TimeoutException('Google sign-in timed out.');
    },
  );
}

Future<void> _ensureGoogleIdentityScript() {
  if (js.context.hasProperty('google')) {
    return Future.value();
  }

  return _googleScriptLoad ??= (() {
    final existing = html.document.getElementById('google-identity-services');
    if (existing == null) {
      final script = html.ScriptElement()
        ..id = 'google-identity-services'
        ..src = 'https://accounts.google.com/gsi/client'
        ..async = true
        ..defer = true;

      html.document.head?.append(script);
    }

    return _waitForGoogleIdentity();
  })();
}

Future<void> _waitForGoogleIdentity() {
  final completer = Completer<void>();
  var attempts = 0;
  Timer.periodic(const Duration(milliseconds: 100), (timer) {
    attempts++;
    if (js.context.hasProperty('google')) {
      timer.cancel();
      if (!completer.isCompleted) completer.complete();
      return;
    }
    if (attempts >= 150) {
      timer.cancel();
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('Could not load Google Identity Services.'),
        );
      }
    }
  });
  return completer.future;
}

html.DivElement _buildOverlay({required void Function() onCancel}) {
  final overlay = html.DivElement()
    ..style.position = 'fixed'
    ..style.left = '0'
    ..style.top = '0'
    ..style.right = '0'
    ..style.bottom = '0'
    ..style.zIndex = '2147483647'
    ..style.background = 'rgba(15, 23, 42, 0.45)'
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center';

  final card = html.DivElement()
    ..style.width = '360px'
    ..style.maxWidth = 'calc(100vw - 32px)'
    ..style.padding = '24px'
    ..style.borderRadius = '16px'
    ..style.background = '#ffffff'
    ..style.boxShadow = '0 20px 50px rgba(15, 23, 42, 0.25)'
    ..style.fontFamily = 'Arial, sans-serif'
    ..style.textAlign = 'center';

  final closeButton = html.ButtonElement()
    ..text = '×'
    ..style.float = 'right'
    ..style.border = '0'
    ..style.background = 'transparent'
    ..style.fontSize = '24px'
    ..style.cursor = 'pointer'
    ..style.color = '#64748b';

  final title = html.HeadingElement.h3()
    ..text = 'Continue with Google'
    ..style.margin = '16px 0 8px'
    ..style.fontSize = '20px'
    ..style.color = '#0f172a';

  final subtitle = html.ParagraphElement()
    ..text = 'Choose your Google account to continue using StaySmart.'
    ..style.margin = '0 0 20px'
    ..style.fontSize = '14px'
    ..style.color = '#64748b'
    ..style.lineHeight = '1.5';

  final buttonHost = html.DivElement()
    ..className = 'google-button-host'
    ..style.display = 'flex'
    ..style.justifyContent = 'center';

  closeButton.onClick.listen((event) {
    event.preventDefault();
    event.stopPropagation();
    onCancel();
  });
  overlay.onClick.listen((event) {
    if (event.target == overlay) {
      onCancel();
    }
  });
  card.onClick.listen((event) => event.stopPropagation());

  card.children.addAll([closeButton, title, subtitle, buttonHost]);
  overlay.children.add(card);
  return overlay;
}
