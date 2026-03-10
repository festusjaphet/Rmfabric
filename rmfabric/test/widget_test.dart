import 'package:flutter_test/flutter_test.dart';
import 'package:rmfabric/main.dart';

void main() {
  testWidgets('App basic initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RmFabricApp());
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
