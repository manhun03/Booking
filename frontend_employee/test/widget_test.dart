import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend_employee/main.dart';

void main() {
  testWidgets('App opens welcome screen for signed-out staff', (tester) async {
    await tester.pumpWidget(const StaySmartApp());
    await tester.pumpAndSettle();

    expect(find.text('StaySmart HOTEL'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
