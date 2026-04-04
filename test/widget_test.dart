// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:vehicle_marketplace_app/main.dart';

void main() {
  testWidgets('App shows auth selection screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify auth selection text is present.
    expect(find.text('Welcome to VehicleApp'), findsOneWidget);
    expect(find.text('Buy or Sell Your Vehicles Easily'), findsOneWidget);

    // Verify buttons exist and are tap-able.
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Sign Up'), findsWidgets);
  });
}
