import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_item.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_list.dart';
import 'package:mae_assignment/features/customer/grocery/data/services/grocery_list_service.dart';
import 'package:mae_assignment/features/customer/grocery/data/services/list_scan_service.dart';
import 'package:mae_assignment/features/customer/grocery/data/services/recipe_ai_service.dart';
import 'package:mae_assignment/features/customer/grocery/presentation/views/grocery_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/services/address_service.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';

import '../../helpers/fake_address_service.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';

/// Stands in for the phone's document scanner.
class _FakeScanner implements ListScanService {
  @override
  bool isSupported = true;

  /// What the "photo" says. Null: the user closed the scanner.
  String? text;
  ScanProblem? problem;
  int scans = 0;

  @override
  Future<String?> scanText() async {
    scans++;
    if (!isSupported) throw const ScanException(ScanProblem.unsupported);
    final failure = problem;
    if (failure != null) throw ScanException(failure);
    return text;
  }
}

/// Stands in for Gemini.
class _FakeRecipeAi implements RecipeAiService {
  String answer = '{"ingredients": []}';
  RecipeAiException? failure;
  final dishes = <String>[];

  @override
  Future<String> ingredientsJson({
    required String dish,
    required int servings,
  }) async {
    dishes.add('$dish x$servings');
    if (failure case final error?) throw error;
    return answer;
  }
}

class _FakeCatalogue implements CatalogueRepository {
  _FakeCatalogue(this.products);

  final List<CatalogueProduct> products;

  @override
  Future<bool> hasProducts(String branchId) async => true;

  @override
  Future<CatalogueData> loadCatalogue(String branchId) async =>
      CatalogueData(categories: const [], products: products);
}

CatalogueProduct _product(
  String id,
  String name, {
  String brand = 'Farm',
  String packSize = '1kg',
  double price = 4,
  int stock = 20,
}) {
  return CatalogueProduct(
    id: id,
    name: name,
    brand: brand,
    categoryId: 'c',
    packSize: packSize,
    price: price,
    stock: stock,
  );
}

void main() {
  final products = [
    _product('milk', 'Fresh milk', packSize: '1L', price: 6.9),
    _product('oat', 'Oat milk', brand: 'Oatside', packSize: '1L', price: 9.5),
    _product('eggs', 'Grade A eggs', packSize: '10 pack', price: 8, stock: 10),
    _product('tomato', 'Roma tomato', price: 5),
  ];

  late FakeFirebaseFirestore firestore;
  late _FakeScanner scanner;
  late _FakeRecipeAi recipeAi;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    scanner = _FakeScanner();
    recipeAi = _FakeRecipeAi();
  });

  Future<ProviderContainer> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = FakeAuthRepository()
      ..signedIn = true
      ..uidStream = Stream.value('u1')
      ..userToSignIn = const AppUser(
        uid: 'u1',
        name: 'Aisha',
        email: 'a@example.com',
        phone: '012',
        role: UserRole.customer,
      );
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        addressServiceProvider.overrideWithValue(FakeAddressService()),
        branchServiceProvider.overrideWithValue(FakeBranchService()),
        catalogueRepositoryProvider.overrideWithValue(_FakeCatalogue(products)),
        groceryListServiceProvider.overrideWithValue(
          GroceryListService(firestore),
        ),
        listScanServiceProvider.overrideWithValue(scanner),
        recipeAiServiceProvider.overrideWithValue(recipeAi),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: AppRoutes.customerGrocery,
      routes: [
        GoRoute(
          path: AppRoutes.customerGrocery,
          builder: (context, state) => const GroceryView(),
        ),
        GoRoute(
          path: AppRoutes.customerCart,
          builder: (context, state) => const Scaffold(body: Text('CART PAGE')),
        ),
        GoRoute(
          path: AppRoutes.customerCatalogue,
          builder: (context, state) => const Scaffold(body: Text('HOME')),
        ),
        GoRoute(
          path: AppRoutes.customerOrders,
          builder: (context, state) => const Scaffold(body: Text('ORDERS')),
        ),
        GoRoute(
          path: AppRoutes.customerAccount,
          builder: (context, state) => const Scaffold(body: Text('ACCOUNT')),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const Key('grocery_input')), text);
    await tester.tap(find.byKey(const Key('grocery_add_button')));
    await tester.pumpAndSettle();
  }

  /// The items saved in "My list".
  Future<List<GroceryItem>> saved() async {
    final lists = await GroceryListService(firestore).getLists('u1');
    return lists.where((list) => list.isDefault).firstOrNull?.items ?? const [];
  }

  group('the list', () {
    testWidgets('starts empty with a hint', (tester) async {
      await pump(tester);

      expect(find.text('My list is empty'), findsOneWidget);
      expect(find.text('Grocery list'), findsOneWidget);
    });

    testWidgets('typing items adds them, matched to products', (tester) async {
      await pump(tester);

      await type(tester, '2 fresh milk, eggs');

      expect(find.text('fresh milk'), findsOneWidget);
      expect(find.text('eggs'), findsOneWidget);
      expect(
        find.textContaining('Fresh milk · Farm · 1L · RM 6.90'),
        findsOneWidget,
      );
      expect(find.textContaining('Grade A eggs'), findsOneWidget);
      expect(find.text('Add 2 items to cart'), findsOneWidget);
    });

    testWidgets('an item with no match says so and does not count', (
      tester,
    ) async {
      await pump(tester);

      await type(tester, 'dragon fruit, tomato');

      expect(find.text('No match at this store'), findsOneWidget);
      expect(find.text('Add 1 item to cart'), findsOneWidget);
      expect(
        find.text('1 item has no match and will stay on your list.'),
        findsOneWidget,
      );
    });

    testWidgets('the list is saved and comes back', (tester) async {
      await pump(tester);

      await type(tester, '3 roma tomato');

      final items = await saved();
      expect(items.single.name, 'roma tomato');
      expect(items.single.quantity, 3);
    });

    testWidgets('a saved list is loaded when the tab opens', (tester) async {
      await GroceryListService(firestore).saveList(
        'u1',
        const GroceryList(
          id: GroceryList.defaultId,
          name: GroceryList.defaultName,
          items: [GroceryItem(id: 'a', name: 'tomato')],
        ),
      );

      await pump(tester);

      expect(find.text('tomato'), findsOneWidget);
      expect(find.text('My list is empty'), findsNothing);
    });

    testWidgets('quantity buttons change it, and remove deletes the item', (
      tester,
    ) async {
      await pump(tester);
      await type(tester, 'tomato');

      await tester.tap(find.byTooltip('More tomato'));
      await tester.pumpAndSettle();
      expect((await saved()).single.quantity, 2);

      await tester.tap(find.byTooltip('Fewer tomato'));
      await tester.pumpAndSettle();
      expect((await saved()).single.quantity, 1);

      await tester.tap(find.byTooltip('Remove tomato'));
      await tester.pumpAndSettle();
      expect(await saved(), isEmpty);
      expect(find.text('My list is empty'), findsOneWidget);
    });

    testWidgets('writing an item twice adds the quantities', (tester) async {
      await pump(tester);

      await type(tester, '2 tomato');
      await type(tester, 'tomato');

      final items = await saved();
      expect(items.single.quantity, 3);
    });

    testWidgets('the customer can pick a different product', (tester) async {
      await pump(tester);
      await type(tester, 'milk');
      expect(find.textContaining('Fresh milk · Farm'), findsOneWidget);

      await tester.tap(find.text('Tap to change'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a product'), findsOneWidget);
      await tester.tap(find.text('Oat milk'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Oat milk · Oatside · 1L · RM 9.50'),
        findsOneWidget,
      );
      expect((await saved()).single.productId, 'oat');
    });

    testWidgets('an unmatched item can be matched by searching', (
      tester,
    ) async {
      await pump(tester);
      await type(tester, 'yoghurt');
      expect(find.text('No match at this store'), findsOneWidget);

      await tester.tap(find.text('Tap to choose a product'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'tomato');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Roma tomato'));
      await tester.pumpAndSettle();

      expect(find.text('No match at this store'), findsNothing);
      expect(find.textContaining('Roma tomato'), findsOneWidget);
    });
  });

  group('adding to the cart', () {
    testWidgets('puts matched items in the cart and keeps the rest', (
      tester,
    ) async {
      final container = await pump(tester);
      await type(tester, '2 fresh milk, dragon fruit');

      await tester.tap(find.byKey(const Key('grocery_add_to_cart_button')));
      await tester.pumpAndSettle();

      final cart = container.read(cartViewModelProvider);
      expect(cart.quantityOf('milk'), 2);
      expect(cart.lines, hasLength(1));
      expect(
        find.text('1 item added to your cart. 1 stayed on your list.'),
        findsOneWidget,
      );
      // The matched item left the list, the other stayed.
      expect(find.text('fresh milk'), findsNothing);
      expect(find.text('dragon fruit'), findsOneWidget);
      expect((await saved()).map((i) => i.name), ['dragon fruit']);
    });

    testWidgets('never asks for more than the store has', (tester) async {
      final container = await pump(tester);
      await type(tester, '30 eggs');
      expect(find.text('Only 10 in stock'), findsOneWidget);

      await tester.tap(find.byKey(const Key('grocery_add_to_cart_button')));
      await tester.pumpAndSettle();

      expect(container.read(cartViewModelProvider).quantityOf('eggs'), 10);
      expect(
        find.textContaining('had less stock than you asked'),
        findsOneWidget,
      );
    });

    testWidgets('adds to what is already in the cart', (tester) async {
      final container = await pump(tester);
      container.read(cartViewModelProvider.notifier).add(products.last);
      await type(tester, '2 tomato');

      await tester.tap(find.byKey(const Key('grocery_add_to_cart_button')));
      await tester.pumpAndSettle();

      expect(container.read(cartViewModelProvider).quantityOf('tomato'), 3);
    });

    testWidgets('View cart opens the cart page', (tester) async {
      await pump(tester);
      await type(tester, 'tomato');
      await tester.tap(find.byKey(const Key('grocery_add_to_cart_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('View cart'));
      await tester.pumpAndSettle();

      expect(find.text('CART PAGE'), findsOneWidget);
    });

    testWidgets('nothing to add when nothing matches', (tester) async {
      await pump(tester);
      await type(tester, 'dragon fruit');

      final button = tester.widget<ButtonStyleButton>(
        find.byKey(const Key('grocery_add_to_cart_button')),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('scanning a written list', () {
    testWidgets('shows what was read for review, then adds the ticked '
        'lines', (tester) async {
      scanner.text = 'SHOPPING LIST\n2x fresh milk\neggs\n';
      await pump(tester);

      await tester.tap(find.byKey(const Key('grocery_scan_button')));
      await tester.pumpAndSettle();
      expect(find.text('Check your list'), findsOneWidget);
      expect(find.text('Add 3 items'), findsOneWidget);

      // The title is not an item: untick it.
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(find.text('Add 2 items'), findsOneWidget);
      await tester.tap(find.byKey(const Key('scan_review_add_button')));
      await tester.pumpAndSettle();
      // Then choose where the items go: the open list.
      await tester.tap(find.text('Add to My list'));
      await tester.pumpAndSettle();

      expect(find.text('2 items added to My list.'), findsOneWidget);
      final items = await saved();
      expect(items.map((i) => '${i.quantity} ${i.name}'), [
        '2 fresh milk',
        '1 eggs',
      ]);
    });

    testWidgets('a misread word can be corrected before adding', (
      tester,
    ) async {
      scanner.text = 'tomatto';
      await pump(tester);

      await tester.tap(find.byKey(const Key('grocery_scan_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'roma tomato');
      await tester.tap(find.byKey(const Key('scan_review_add_button')));
      await tester.pumpAndSettle();
      // Then choose where the items go: the open list.
      await tester.tap(find.text('Add to My list'));
      await tester.pumpAndSettle();

      expect((await saved()).single.name, 'roma tomato');
    });

    testWidgets('closing the scanner changes nothing', (tester) async {
      scanner.text = null;
      await pump(tester);

      await tester.tap(find.byKey(const Key('grocery_scan_button')));
      await tester.pumpAndSettle();

      expect(find.text('Check your list'), findsNothing);
      expect(await saved(), isEmpty);
    });

    testWidgets('a photo with no readable items says so', (tester) async {
      scanner.text = '   \n--\n7\n';
      await pump(tester);

      await tester.tap(find.byKey(const Key('grocery_scan_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('No items could be read'), findsOneWidget);
      expect(find.text('Check your list'), findsNothing);
    });

    testWidgets('a phone that cannot scan offers manual entry', (tester) async {
      scanner.isSupported = false;
      await pump(tester);

      expect(find.byKey(const Key('grocery_scan_button')), findsNothing);
      expect(find.byKey(const Key('grocery_input')), findsOneWidget);
      expect(find.textContaining('Type what you need'), findsWidgets);
    });

    testWidgets('a scanner failure shows a friendly message', (tester) async {
      scanner.problem = ScanProblem.failed;
      await pump(tester);

      await tester.tap(find.byKey(const Key('grocery_scan_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('could not be scanned'), findsOneWidget);
    });
  });

  group('saving scanned items as a new list', () {
    testWidgets('a scan can become its own named list', (tester) async {
      scanner.text = '2x fresh milk\neggs';
      await pump(tester);

      await tester.tap(find.byKey(const Key('grocery_scan_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('scan_review_add_button')));
      await tester.pumpAndSettle();
      expect(find.text('Save these items'), findsOneWidget);
      await tester.tap(find.text('Save as new list'));
      await tester.pumpAndSettle();

      final lists = await GroceryListService(firestore).getLists('u1');
      final made = lists.singleWhere((list) => !list.isDefault);
      expect(made.items.map((i) => '${i.quantity} ${i.name}'), [
        '2 fresh milk',
        '1 eggs',
      ]);
      // "My list" was left alone.
      expect(await saved(), isEmpty);
    });
  });

  group('ingredients from a recipe', () {
    Future<void> ask(WidgetTester tester, String dish) async {
      await tester.tap(find.byKey(const Key('grocery_recipe_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('recipe_input')), dish);
      await tester.tap(find.byKey(const Key('recipe_submit')));
      await tester.pumpAndSettle();
    }

    testWidgets('suggests ingredients for review, then adds the ticked ones', (
      tester,
    ) async {
      recipeAi.answer =
          '{"ingredients": [{"name": "roma tomato", "quantity": 3},'
          ' {"name": "eggs", "quantity": 6}, {"name": "dragon fruit"}]}';
      await pump(tester);

      await ask(tester, 'shakshuka');
      expect(recipeAi.dishes, ['shakshuka x2']);
      expect(find.text('Suggested ingredients'), findsOneWidget);
      expect(find.textContaining('can be wrong'), findsOneWidget);
      expect(find.text('Add 3 items'), findsOneWidget);

      // Not wanted: untick the dragon fruit (the third row).
      await tester.tap(find.byType(Checkbox).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('scan_review_add_button')));
      await tester.pumpAndSettle();
      // Then choose where the items go: the open list.
      await tester.tap(find.text('Add to My list'));
      await tester.pumpAndSettle();

      final items = await saved();
      expect(items.map((i) => '${i.quantity} ${i.name}'), [
        '3 roma tomato',
        '6 eggs',
      ]);
      // And they are matched to the store's products like any other item.
      expect(find.textContaining('Roma tomato · Farm'), findsOneWidget);
    });

    testWidgets('the servings are sent', (tester) async {
      recipeAi.answer = '{"ingredients": [{"name": "eggs"}]}';
      await pump(tester);
      await tester.tap(find.byKey(const Key('grocery_recipe_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('More servings'));
      await tester.tap(find.byTooltip('More servings'));
      await tester.enterText(find.byKey(const Key('recipe_input')), 'omelette');
      await tester.tap(find.byKey(const Key('recipe_submit')));
      await tester.pumpAndSettle();

      expect(recipeAi.dishes, ['omelette x4']);
    });

    testWidgets('a failure is shown in the sheet, which stays open', (
      tester,
    ) async {
      recipeAi.failure = const RecipeAiException('429 quota');
      await pump(tester);

      await ask(tester, 'laksa');

      expect(find.byKey(const Key('recipe_error')), findsOneWidget);
      expect(find.textContaining('busy right now'), findsOneWidget);
      expect(find.byKey(const Key('recipe_input')), findsOneWidget);
      expect(await saved(), isEmpty);
    });

    testWidgets('an empty description is refused before asking the model', (
      tester,
    ) async {
      await pump(tester);

      await ask(tester, '');

      expect(
        find.text('Describe the dish or paste a recipe first.'),
        findsOneWidget,
      );
      expect(recipeAi.dishes, isEmpty);
    });

    testWidgets('unticking everything leaves the list alone', (tester) async {
      recipeAi.answer = '{"ingredients": [{"name": "eggs"}]}';
      await pump(tester);
      await ask(tester, 'omelette');

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      final button = tester.widget<ButtonStyleButton>(
        find.byKey(const Key('scan_review_add_button')),
      );
      expect(button.onPressed, isNull);
      expect(await saved(), isEmpty);
    });
  });

  group('bottom navigation', () {
    testWidgets('is Home, Grocery, Orders and Account', (tester) async {
      await pump(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Grocery'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Cart'), findsNothing);
    });

    testWidgets('the tabs go to their pages', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.text('ORDERS'), findsOneWidget);
    });
  });
}
