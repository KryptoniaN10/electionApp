import 'package:flutter_test/flutter_test.dart';

import 'package:electionapp/main.dart';

void main() {
  testWidgets('shows authenticator screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Officer Authentication'), findsOneWidget);
    expect(find.text('Machine ID: 1'), findsOneWidget);
  });
}
