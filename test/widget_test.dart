import 'package:flutter_test/flutter_test.dart';
import 'package:clipzone/main.dart';

void main() {
  testWidgets('ClipZone app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ClipZoneApp());
    expect(find.text('ClipZone'), findsOneWidget);
  });
}
