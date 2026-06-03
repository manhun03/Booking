void redirectToPaymentUrl(String url) {
  throw UnsupportedError(
    'Payment URL redirection is only available on the web build: $url',
  );
}
