import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/shell/customer_routes.dart';
import 'package:mae_assignment/features/customer/shell/presentation/ui/customer_scaffold.dart';

/// Customer Account tab (wireframe 4): profile header plus the account
/// menu. Order history, saved addresses and payment methods arrive in
/// later slices; Sign out works now.
class CustomerAccountView extends ConsumerWidget {
  const CustomerAccountView({super.key});

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what is not connected yet.')));
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final currentUser = ref.watch(currentUserProvider);

    return CustomerScaffold(
      currentTab: CustomerTab.account,
      cartCount: ref.watch(cartCountProvider),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Profile header.
            Container(
              width: double.infinity,
              color: AppColors.greenTint,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.surface,
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: currentUser.when(
                      loading: () => Text('…', style: textTheme.titleLarge),
                      error: (error, stackTrace) => Text(
                        'Could not load your account.',
                        style: textTheme.bodyMedium,
                      ),
                      data: (user) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest',
                            style: textTheme.titleLarge,
                          ),
                          if (user?.email case final email?)
                            Text(email, style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            _MenuSection(
              title: 'ACCOUNT',
              children: [
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  label: 'Saved addresses',
                  onTap: () => _comingSoon(context, 'Saved addresses'),
                ),
                _MenuItem(
                  icon: Icons.credit_card_outlined,
                  label: 'Payment methods',
                  onTap: () => _comingSoon(context, 'Payment methods'),
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () => _comingSoon(context, 'Notifications'),
                ),
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign out',
                  onTap: () => _signOut(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.s,
            AppSpacing.l,
            AppSpacing.xs,
          ),
          child: Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
