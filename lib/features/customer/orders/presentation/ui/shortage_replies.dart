import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/orders/presentation/view_models/order_actions_view_model.dart';
import 'package:mae_assignment/features/customer/wallet/presentation/view_models/wallet_view_model.dart';
import 'package:mae_assignment/features/customer/wallet/presentation/views/wallet_view.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';

/// Items the packer could not find, each with the replacement offered. The
/// customer accepts it or removes the item. Shown only while the order is
/// being packed and has replies waiting; the order cannot be marked ready
/// until every one is answered.
class ShortageReplies extends ConsumerWidget {
  const ShortageReplies({required this.order, super.key});

  final Order order;

  /// True if [order] has a reply the customer still owes.
  static bool isNeeded(Order order) {
    return order.status == OrderStatus.packing && order.hasOpenShortage;
  }

  Future<void> _answer(
    BuildContext context,
    WidgetRef ref,
    OrderItem item, {
    required bool accept,
  }) async {
    // Taken before the answer is saved: the order updates live, which removes
    // this card, and the message must still be shown after that.
    final messenger = ScaffoldMessenger.of(context);
    final error = await ref
        .read(orderActionsViewModelProvider.notifier)
        .respondToShortage(order, item.lineId, accept: accept);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            error ??
                (accept
                    ? 'Replacement accepted.'
                    : '${item.name} was removed from your order.'),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isNeeded(order)) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    final busy = ref.watch(orderActionsViewModelProvider);
    // Null while the balance is loading or cannot be read; then the server's
    // settlement (which never goes below zero) is the only guard.
    final balance = ref.watch(walletBalanceProvider).value;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.yellow.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.yellow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.swap_horiz_rounded),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'Your reply is needed',
                  style: textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'The store could not find some items. Packing continues once you '
            'reply.',
            style: textTheme.bodyMedium,
          ),
          for (final item in order.items)
            if (order.shortageOf(item.lineId) case final shortage?)
              if (shortage.status == ShortageStatus.proposed &&
                  shortage.replacement != null) ...[
                const SizedBox(height: AppSpacing.l),
                _Offer(
                  original: item,
                  replacement: shortage.replacement!,
                  busy: busy,
                  balance: balance,
                  onAccept: () => _answer(context, ref, item, accept: true),
                  onRemove: () => _answer(context, ref, item, accept: false),
                ),
              ],
        ],
      ),
    );
  }
}

class _Offer extends StatelessWidget {
  const _Offer({
    required this.original,
    required this.replacement,
    required this.busy,
    required this.balance,
    required this.onAccept,
    required this.onRemove,
  });

  final OrderItem original;
  final OrderItem replacement;
  final bool busy;

  /// The wallet balance, or null if unknown.
  final double? balance;
  final VoidCallback onAccept;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final difference = replacement.lineTotal - original.lineTotal;
    // A dearer replacement is charged to the wallet, so it needs the money.
    final shortBy =
        balance != null && difference > 0.005 && balance! < difference
        ? difference - (balance! < 0 ? 0 : balance!)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${original.quantity}× ${original.name} is unavailable',
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              _Photo(url: replacement.imageUrl),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Offered instead', style: textTheme.bodySmall),
                    Text(replacement.name, style: textTheme.titleMedium),
                    Text(
                      '${replacement.brand} · ${replacement.packSize}',
                      style: textTheme.bodySmall,
                    ),
                    Text(
                      '${replacement.quantity}× '
                      '${Formatters.money(replacement.unitPrice)}',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(_differenceText(difference), style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.m),
          if (shortBy > 0) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Your wallet is ${Formatters.money(shortBy)} short for '
                    'this. Top up to accept it, or remove the item.',
                    key: const Key('replacement_short_text'),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                TextButton(
                  key: const Key('replacement_top_up'),
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (_) => const WalletView()),
                  ),
                  child: const Text('Top up'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
          ],
          FilledButton.icon(
            onPressed: busy || shortBy > 0 ? null : onAccept,
            icon: busy
                ? const ButtonLoadingIndicator()
                : const Icon(Icons.check_rounded),
            label: const Text('Accept replacement'),
          ),
          const SizedBox(height: AppSpacing.s),
          OutlinedButton(
            onPressed: busy ? null : onRemove,
            child: const Text('Remove item'),
          ),
        ],
      ),
    );
  }

  static String _differenceText(double difference) {
    if (difference.abs() < 0.005) return 'Same price as the original.';
    final amount = Formatters.money(difference.abs());
    return difference > 0
        ? '$amount more than the original.'
        : '$amount less than the original.';
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 56,
      height: 56,
      color: AppColors.softWhite,
      child: const Icon(
        Icons.shopping_basket_outlined,
        color: AppColors.textSecondary,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
            ),
    );
  }
}
