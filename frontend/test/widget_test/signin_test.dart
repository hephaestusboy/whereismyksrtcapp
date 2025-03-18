import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bus/pages/signin.dart';
import 'package:go_router/go_router.dart';
import '../mocks/api_service_mock.mocks.dart';
import 'dart:async';

void main() {
  group('SignIn Widget Tests', () {
    late Widget testWidget;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      final router = GoRouter(
        initialLocation: SignInWidget.routePath,
        routes: [
          GoRoute(
            path: SignInWidget.routePath,
            name: SignInWidget.routeName,
            builder: (context, state) => SignInWidget(apiService: mockApiService),
          ),
        ],
      );

      testWidget = MaterialApp.router(
        routerConfig: router,
      );
    });

    testWidgets('renders sign in form', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify form elements are present
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text("Don't have an account? Create one"), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Find and tap the sign in button
      final signInButton = find.text('Sign In');
      expect(signInButton, findsOneWidget);
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Verify validation messages
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Find email and password fields
      final emailField = find.ancestor(
        of: find.text('Email'),
        matching: find.byType(Column),
      ).first;
      final passwordField = find.ancestor(
        of: find.text('Password'),
        matching: find.byType(Column),
      ).first;

      // Enter invalid email and password
      await tester.enterText(find.descendant(
        of: emailField,
        matching: find.byType(TextFormField),
      ), 'invalid-email');
      await tester.enterText(find.descendant(
        of: passwordField,
        matching: find.byType(TextFormField),
      ), 'password123');

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify validation message
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('shows loading indicator when signing in', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(testWidget);

      // Setup mock response with a delay
      final completer = Completer<Map<String, dynamic>>();
      when(mockApiService.signIn(any, any)).thenAnswer((_) => completer.future);

      // Enter valid credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pump();

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pump(); // Rebuild after tap

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future
      completer.complete({'token': 'fake-token'});
      await tester.pumpAndSettle();
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Initially password should be obscured (visibility icon should be off)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      // Find and tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      // Password should now be visible (visibility icon should be on)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
    });
  });
} 