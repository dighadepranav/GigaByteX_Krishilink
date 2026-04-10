import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krishilink/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // Initialize SharedPreferences with mock values for testing
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // KrishiLinkApp requires initialLocale
    await tester.pumpWidget(const KrishiLinkApp(initialLocale: Locale('en', '')));

    // Verify that the app starts and shows KrishiLink text on SplashScreen
    expect(find.text('KrishiLink'), findsOneWidget);
    expect(find.byIcon(Icons.agriculture), findsOneWidget);
    
    // Verify that a CircularProgressIndicator is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
