import 'package:flutter_test/flutter_test.dart';

import 'package:xpiano_mobile/main.dart';

void main() {
  testWidgets('App loads without crashing smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const XPianoApp());

    // Just verify that the app pumps correctly.
    expect(find.byType(XPianoApp), findsOneWidget);
  });
}
