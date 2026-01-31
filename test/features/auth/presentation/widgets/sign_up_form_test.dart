import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillswap/features/auth/presentation/widgets/sign_up_form.dart';
import 'package:skillswap/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:skillswap/features/auth/presentation/state/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillswap/core/services/storage/user_session_service.dart';

class TestAuthViewModelForRegister extends AuthViewModel {
  @override
  AuthState build() => const AuthState();

  @override
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String confirmPassword,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    state = const AuthState(status: AuthStatus.registered);
  }
}

late SharedPreferences prefs;

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('SignUpForm UI', () {
    testWidgets('shows fields and button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SignUpForm(),
                ),
              ),
            ),
          ),
        ),
      );

      // 5 fields: email, fullname, username, password, confirm password
      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.text('Sign Up'), findsOneWidget);
    });
  });

  group('SignUpForm validation', () {
    testWidgets('shows errors for empty fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SignUpForm(),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your fullname'), findsOneWidget);
      expect(find.text('Please enter your username'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });



  group('SignUpForm submission', () {
    testWidgets('shows loading then snackbar and calls onRegistered', (
      tester,
    ) async {
      final override = authViewModelProvider.overrideWith(
        () => TestAuthViewModelForRegister(),
      );

      bool called = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            override,
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SignUpForm(
                    onRegistered: () {
                      called = true;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'e@example.com'); // email
      await tester.enterText(fields.at(1), 'Full Name'); // fullname
      await tester.enterText(fields.at(2), 'username'); // username
      await tester.enterText(fields.at(3), 'password123'); // password
      await tester.enterText(fields.at(4), 'password123'); // confirm

      await tester.tap(find.text('Sign Up'));

      // allow loading state
      await tester.pump();
      expect(find.text('Signing Up...'), findsOneWidget);

      // wait for registered state and for SignUpForm delay before calling onRegistered
      await tester.pump(const Duration(milliseconds: 800));

      // snackbar message
      expect(
        find.text('Registration successful! Please login.'),
        findsOneWidget,
      );

      // onRegistered should have been called
      expect(called, isTrue);
    });
  });
}
