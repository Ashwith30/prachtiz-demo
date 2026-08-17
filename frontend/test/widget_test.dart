import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prachtiz_flutter/app/app.dart';

void main() {
  testWidgets('Clinic Dashboard app smoke test', (WidgetTester tester) async {
    // Configure a standard desktop viewport size for the dashboard smoke test
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    
    // Reset viewport size back to default after test run finishes
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Allow entry animations to run and complete
    await tester.pump(const Duration(seconds: 2));

    // Verify today's schedule header renders
    expect(find.text("Today's Schedule"), findsOneWidget);

    // Verify metrics exist
    expect(find.text('TOTAL APPOINTMENTS TODAY'), findsOneWidget);
    expect(find.text('UPCOMING THIS WEEK'), findsOneWidget);

    // Verify calendar renders
    expect(find.text('June 2026'), findsOneWidget);

    // Verify patient queue list item renders
    expect(find.text('Adrian Marshall'), findsOneWidget);
  });
}
