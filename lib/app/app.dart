import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';

class GrocerlyApp extends ConsumerWidget {
  const GrocerlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Grocerly',
      debugShowCheckedModeBanner: false, //removes the debug banner from the app
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
