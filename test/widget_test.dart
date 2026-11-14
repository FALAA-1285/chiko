import 'package:flutter_test/flutter_test.dart';
import 'package:chiko/app/app.dart';

void main() {
  testWidgets('ChikoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ChikoApp());
    expect(find.byType(ChikoApp), findsOneWidget);
  });
}
