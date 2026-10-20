import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/wallet/data/models/wallet_entry.dart';
import 'package:mae_assignment/features/customer/wallet/data/repositories/wallet_repository.dart';
import 'package:mae_assignment/features/customer/wallet/presentation/view_models/wallet_view_model.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// The Grocerly Wallet: balance, top up, and history. Orders are paid from
/// it. It is a simulation (no real money moves), and the screen says so.
class WalletView extends ConsumerStatefulWidget {
  const WalletView({super.key});

  @override
  ConsumerState<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends ConsumerState<WalletView> {
  static const List<int> _presets = [20, 50, 100, 200];

  final _custom = TextEditingController();
  int? _preset = 50;

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  /// The amount chosen: a typed amount wins over a preset chip.
  double? get _amount {
    final typed = _custom.text.trim();
    if (typed.isNotEmpty) return double.tryParse(typed);
    return _preset?.toDouble();
  }

  Future<void> _topUp() async {
    final amount = _amount;
    if (amount == null || amount < 1 || amount > WalletRepository.maxTopUp) {
      _say('Enter an amount between RM 1 and RM 500.');
      return;
    }
    final error = await ref
        .read(walletTopUpViewModelProvider.notifier)
        .topUp(amount);
    if (!mounted) return;
    if (error == null) _custom.clear();
    _say(error ?? '${Formatters.money(amount)} added to your wallet.');
  }

  void _say(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final balance = ref.watch(walletBalanceProvider);
    final entries = ref.watch(walletEntriesProvider);
    final isBusy = ref.watch(walletTopUpViewModelProvider);
    final amount = _amount;

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  decoration: BoxDecoration(
                    color: AppColors.greenTint,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Grocerly Wallet', style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        balance.when(
                          data: Formatters.money,
                          loading: () => '…',
                          error: (_, _) => 'Unavailable',
                        ),
                        key: const Key('wallet_balance'),
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'A simulated wallet for this project. No real money '
                        'moves.',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Text('Top up', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s),
                Wrap(
                  spacing: AppSpacing.s,
                  children: [
                    for (final preset in _presets)
                      ChoiceChip(
                        label: Text('RM $preset'),
                        selected:
                            _preset == preset && _custom.text.trim().isEmpty,
                        onSelected: (_) => setState(() {
                          _preset = preset;
                          _custom.clear();
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                TextField(
                  key: const Key('wallet_custom_amount'),
                  controller: _custom,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                    LengthLimitingTextInputFormatter(7),
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Other amount (RM)',
                    hintText: 'Up to RM 500',
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                FilledButton.icon(
                  key: const Key('wallet_top_up_button'),
                  onPressed: isBusy || amount == null ? null : _topUp,
                  icon: isBusy
                      ? const ButtonLoadingIndicator()
                      : const Icon(Icons.add_card_rounded),
                  label: Text(
                    amount == null
                        ? 'Top up'
                        : 'Top up ${Formatters.money(amount)}',
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('History', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s),
                entries.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.l),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => const Text('Could not load your history.'),
                  data: (list) => list.isEmpty
                      ? const SizedBox(
                          height: 200,
                          child: EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'No transactions yet',
                            message:
                                'Top ups, payments and refunds will show '
                                'here.',
                          ),
                        )
                      : Column(
                          children: [
                            for (final entry in list) _EntryTile(entry: entry),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final WalletEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final created = entry.createdAt;
    final icon = switch (entry.type) {
      WalletEntryType.topUp => Icons.add_card_rounded,
      WalletEntryType.payment => Icons.shopping_bag_outlined,
      WalletEntryType.refund => Icons.replay_rounded,
      WalletEntryType.adjustment => Icons.swap_vert_rounded,
    };
    final sign = entry.isCredit ? '+' : '−';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.darkGreen),
      title: Text(entry.description),
      subtitle: Text(
        created == null
            ? 'Just now'
            : '${Formatters.dayMonth(created)}, ${Formatters.time(created)}',
      ),
      trailing: Text(
        '$sign${Formatters.money(entry.amount.abs())}',
        style: textTheme.titleMedium?.copyWith(
          color: entry.isCredit ? AppColors.success : null,
        ),
      ),
    );
  }
}
