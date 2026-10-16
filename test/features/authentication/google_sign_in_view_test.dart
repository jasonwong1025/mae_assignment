import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/app.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

import '../../helpers/fake_auth_repository.dart';

const _customer = AppUser(
  uid: 'customer-1',
  name: 'May',
  email: 'may@example.com',
  phone: '',
  role: UserRole.customer,
);

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository()..googleUserToSignIn = _customer;
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const GrocerlyApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Google button on sign-in opens the customer home', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(repository.googleSignInCalls, 1);
    expect(find.text('Hi, May'), findsOneWidget);

    container.read(appRouterProvider).go(AppRoutes.adminDashboard);
    await tester.pumpAndSettle();
    expect(find.text('Hi, May'), findsOneWidget);
  });

  testWidgets('Google button on registration opens the customer home', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(repository.googleSignInCalls, 1);
    expect(find.text('Hi, May'), findsOneWidget);
  });
}
