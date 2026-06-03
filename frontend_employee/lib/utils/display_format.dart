String formatMoney(dynamic value) {
  final amount = value is num
      ? value.round()
      : double.tryParse(value?.toString() ?? '')?.round() ?? 0;
  final negative = amount < 0;
  final digits = amount.abs().toString();
  final result = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final left = digits.length - i;
    result.write(digits[i]);
    if (left > 1 && left % 3 == 1) result.write('.');
  }
  return '${negative ? '-' : ''}$result VND';
}

String formatDate(dynamic value, {bool withTime = false}) {
  final parsed = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (parsed == null) return '-';
  String two(int part) => part.toString().padLeft(2, '0');
  final date = '${two(parsed.day)}/${two(parsed.month)}/${parsed.year}';
  if (!withTime) return date;
  return '$date ${two(parsed.hour)}:${two(parsed.minute)}';
}

String textValue(dynamic value, [String fallback = '-']) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
}

int intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double doubleValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
