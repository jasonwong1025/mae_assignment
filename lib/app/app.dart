import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_sync.dart';
import 'package:mae_assignment/features/notifications/presentation/view_models/push_sync.dart';

class GrocerlyApp extends ConsumerWidget {
  const GrocerlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Saves the customer's cart and restores it after sign-in or a restart.
    ref
      ..watch(cartSyncProvider)
      // Registers the phone for push notifications and opens tapped ones.
      ..watch(pushSyncProvider);
    return MaterialApp.router(
      title: 'Grocerly',
      debugShowCheckedModeBanner: false, //removes the debug banner from the app
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
