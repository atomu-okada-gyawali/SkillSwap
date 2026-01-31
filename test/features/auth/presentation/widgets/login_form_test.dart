import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/presentation/widgets/login_form.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/auth/presentation/state/auth_state.dart';
import 'package:skillswap/features/auth/domain/entities/auth_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillswap/core/services/storage/user_session_service.dart';

// Mock ViewModel to control state transitions predictably
class TestAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState();

  @override
  Future<void> login({required String email, required String password}) async {
    // 1. Enter loading state
    state = const AuthState(status: AuthStatus.loading);

    // Simulate network delay to allow tester.pump() to catch the loading UI
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // 2. Enter authenticated state
    state = const AuthState(
      status: AuthStatus.authenticated,
      authEntity: AuthEntity(
        email: 'e@example.com',
        username: 'user',
        fullName: 'User',
      ),
    );
  }
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('LoginForm UI', () {
    testWidgets('Elements in LoginForm', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: Scaffold(body: LoginForm())),
        ),
      );

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Continue'), findsOneWidget);
    });
  });

  group('LoginForm validation', () {
    testWidgets('shows errors for empty fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: Scaffold(body: LoginForm())),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('catches invalid email and short password', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: Scaffold(body: LoginForm())),
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'not-an-email');
      await tester.enterText(fields.at(1), '123');

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });
  }); // Added missing closing brace here

  group('LoginForm submission', () {
    testWidgets('shows loading then navigates on success', (tester) async {
      final override = authViewModelProvider.overrideWith(
        () => TestAuthViewModel(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            override,
          ],
          child: const MaterialApp(home: Scaffold(body: LoginForm())),
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'e@example.com');
      await tester.enterText(fields.at(1), 'password123');

      await tester.tap(find.text('Continue'));

      // Check for loading state (emitted by TestAuthViewModel)
      await tester.pump();
      expect(find.text('Loading...'), findsOneWidget);

      // Wait for the Future.delayed and subsequent navigation/snackbars
      await tester.pumpAndSettle();

      // Verify success state
      expect(find.text('Login successful'), findsOneWidget);

      // Check for navigation target (BottomNavigationBar usually exists in HomeScreen)
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
