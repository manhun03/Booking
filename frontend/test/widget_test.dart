import 'package:flutter_test/flutter_test.dart';

import 'package:staysmart_app/main.dart';

void main() {
  testWidgets('App opens and navigates to welcome screen', (tester) async {
    await tester.pumpWidget(const StaySmartApp());

    expect(find.text('StaySmart'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('StaySmart'), findsWidgets);
  });
}
