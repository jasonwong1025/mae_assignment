import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/shared/ui/bottom_action_bar.dart';
import 'package:mae_assignment/shared/ui/brand_header.dart';

/// Temporary page shown after signing in, so sign-in can be tested.
/// Will be replaced by the real Customer / Store Admin / Store Worker homes.
class HomePlaceholderView extends ConsumerWidget {
  const HomePlaceholderView({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BrandHeader(),
                        const SizedBox(height: 32),
                        currentUser.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stackTrace) => Text(
                            'Could not load your account.',
                            style: textTheme.bodyMedium,
                          ),
                          data: (user) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${user?.name ?? 'there'}',
                                style: textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Signed in as ${user?.role.label ?? '-'} '
                                '(${user?.email ?? '-'}).',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BottomActionBar(
                  children: [
                    OutlinedButton(
                      onPressed: () => _signOut(context, ref),
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
