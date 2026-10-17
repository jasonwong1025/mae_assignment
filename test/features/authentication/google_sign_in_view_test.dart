import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/app.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

import '../../helpers/fake_auth_repository.dart';

const _customer = AppUser(
  uid: 'customer-1',
  name: 'May',
  email: 'may@example.com',
  phone: '',
  role: UserRole.customer,
);

/// Loads an empty catalogue instantly, so landing on the customer home in
/// these auth tests does not reach Firestore.
class _EmptyCatalogueRepository implements CatalogueRepository {
  @override
  Future<CatalogueData> loadCatalogue(String branchId) async {
    return const CatalogueData(categories: [], products: []);
  }
}

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository()..googleUserToSignIn = _customer;
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        catalogueRepositoryProvider.overrideWithValue(
          _EmptyCatalogueRepository(),
        ),
      ],
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
    // Lands on the customer catalogue (its content needs Firestore, so we
    // check the route, not the products).
    expect(routerLocation(container), AppRoutes.customerCatalogue);

    // A customer cannot reach the admin dashboard; the guard sends them
    // back to the customer home.
    container.read(appRouterProvider).go(AppRoutes.adminDashboard);
    await tester.pumpAndSettle();
    expect(routerLocation(container), isNot(AppRoutes.adminDashboard));
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
    expect(routerLocation(container), AppRoutes.customerCatalogue);
  });
}

/// The base path the router is at.
String routerLocation(ProviderContainer container) {
  return container
      .read(appRouterProvider)
      .routerDelegate
      .currentConfiguration
      .uri
      .path;
}
