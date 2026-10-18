import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/validators.dart';
import 'package:mae_assignment/features/store_admin/branches/presentation/ui/branch_labels.dart';
import 'package:mae_assignment/features/store_admin/branches/presentation/view_models/branches_view_model.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/repositories/geocoding_repository.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/labeled_text_field.dart';
import 'package:mae_assignment/shared/ui/location_map.dart';

/// Form to add a branch ([branch] is null) or edit one.
class BranchForm extends ConsumerStatefulWidget {
  const BranchForm({
    required this.onCancel,
    required this.onSaved,
    super.key,
    this.branch,
  });

  final Branch? branch;
  final VoidCallback onCancel;

  /// Called with the saved name after saving.
  final ValueChanged<String> onSaved;

  @override
  ConsumerState<BranchForm> createState() => _BranchFormState();
}

class _BranchFormState extends ConsumerState<BranchForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _maxKmController;
  late final TextEditingController _baseFeeController;
  late final TextEditingController _perKmController;
  final _searchController = TextEditingController();

  late LatLng _location;
  late List<DayHours> _hours;

  List<AddressResult> _searchResults = const [];
  String? _searchError;
  bool _isSearching = false;
  String? _hoursError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final branch = widget.branch;
    _nameController = TextEditingController(text: branch?.name);
    _addressController = TextEditingController(text: branch?.address);
    _phoneController = TextEditingController(text: branch?.phone);
    _maxKmController = TextEditingController(
      text: '${branch?.maxDeliveryKm ?? 8}',
    );
    _baseFeeController = TextEditingController(
      text: (branch?.baseDeliveryFee ?? 3).toStringAsFixed(2),
    );
    _perKmController = TextEditingController(
      text: (branch?.feePerKm ?? 0.5).toStringAsFixed(2),
    );

    // A new branch starts near the selected one, 8am to 9pm every day.
    final selected = ref.read(branchViewModelProvider).value?.selected;
    _location =
        branch?.location ?? selected?.location ?? const LatLng(3.139, 101.687);
    _hours = [
      ...(branch?.weeklyHours ??
          List.filled(7, const DayHours(opensAt: 8 * 60, closesAt: 21 * 60))),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _maxKmController.dispose();
    _baseFeeController.dispose();
    _perKmController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final text = _searchController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    try {
      final results = await ref
          .read(branchesViewModelProvider.notifier)
          .searchAddress(text);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        if (results.isEmpty) _searchError = 'No places found.';
      });
    } on Object catch (_) {
      if (!mounted) return;
      setState(() => _searchError = 'Could not search. Check your internet.');
    }
    if (mounted) setState(() => _isSearching = false);
  }

  void _useResult(AddressResult result) {
    setState(() {
      _location = result.location;
      _addressController.text = result.address;
      _searchResults = const [];
    });
  }

  /// Opens a time picker. Returns minutes after midnight, or null.
  Future<int?> _pickTime(int minutes) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    if (picked == null) return null;
    return picked.hour * 60 + picked.minute;
  }

  Future<void> _onSave() async {
    final isValid = _formKey.currentState!.validate();
    final badDay = _hours.indexWhere(
      (day) => !day.isClosed && day.closesAt <= day.opensAt,
    );
    setState(() {
      _hoursError = badDay == -1
          ? null
          : '${dayNames[badDay]}: closing time must be after opening time.';
    });
    if (!isValid || badDay != -1) return;

    setState(() => _isSaving = true);
    final old = widget.branch;
    final branch = Branch(
      // The repository gives new branches their id.
      id: old?.id ?? '',
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _location,
      weeklyHours: _hours,
      maxDeliveryKm: double.parse(_maxKmController.text.trim()),
      baseDeliveryFee: double.parse(_baseFeeController.text.trim()),
      feePerKm: double.parse(_perKmController.text.trim()),
      isTemporarilyClosed: old?.isTemporarilyClosed ?? false,
    );

    final viewModel = ref.read(branchesViewModelProvider.notifier);
    final error = old == null
        ? await viewModel.addBranch(branch)
        : await viewModel.updateBranch(branch);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    widget.onSaved(branch.name);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const gap = SizedBox(height: 16);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LabeledTextField(
            label: 'Branch name',
            controller: _nameController,
            hint: 'e.g. SS15 Subang',
            validator: Validators.required('Please enter a name'),
          ),
          gap,
          LabeledTextField(
            label: 'Phone',
            controller: _phoneController,
            hint: 'e.g. 03-5611 2201',
            keyboardType: TextInputType.phone,
            validator: Validators.required('Please enter a phone number'),
          ),

          const _SectionTitle('Location'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: const InputDecoration(
                    hintText: 'Search an address',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Search address',
                onPressed: _isSearching ? null : _search,
                icon: _isSearching
                    ? const ButtonLoadingIndicator()
                    : const Icon(Icons.search_rounded),
              ),
            ],
          ),
          if (_searchError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _searchError!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ),
          for (final result in _searchResults)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined),
              title: Text(
                result.address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _useResult(result),
            ),
          const SizedBox(height: 8),
          LocationMap(
            location: _location,
            onTap: (point) => setState(() => _location = point),
          ),
          const SizedBox(height: 4),
          Text('Tap the map to move the pin.', style: textTheme.bodySmall),
          gap,
          LabeledTextField(
            label: 'Address',
            controller: _addressController,
            validator: Validators.required('Please enter the address'),
          ),

          _SectionTitle(
            'Opening hours',
            trailing: TextButton(
              onPressed: () => setState(() {
                _hours = List.filled(7, _hours.first);
              }),
              child: const Text('Copy Monday to all'),
            ),
          ),
          for (var day = 0; day < 7; day++) _dayRow(day),
          if (_hoursError != null)
            Text(
              _hoursError!,
              style: textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),

          const _SectionTitle('Delivery'),
          LabeledTextField(
            label: 'Delivers up to (km by road)',
            controller: _maxKmController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: Validators.price,
          ),
          gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledTextField(
                  label: 'Base fee (RM)',
                  controller: _baseFeeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: Validators.amount,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabeledTextField(
                  label: 'Per km (RM)',
                  controller: _perKmController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: Validators.amount,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : widget.onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isSaving ? null : _onSave,
                  child: _isSaving
                      ? const ButtonLoadingIndicator()
                      : Text(widget.branch == null ? 'Add branch' : 'Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// "Monday [switch] 8:00am - 9:00pm". Times are tapped to change.
  Widget _dayRow(int day) {
    final hours = _hours[day];
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(dayNames[day], style: textTheme.bodyMedium),
        ),
        Switch(
          value: !hours.isClosed,
          onChanged: (open) => setState(() {
            _hours[day] = open
                ? const DayHours(opensAt: 8 * 60, closesAt: 21 * 60)
                : DayHours.closed;
          }),
        ),
        const SizedBox(width: 8),
        if (hours.isClosed)
          Text('Closed', style: textTheme.bodyMedium)
        else ...[
          TextButton(
            onPressed: () async {
              final time = await _pickTime(hours.opensAt);
              if (time == null) return;
              setState(() {
                _hours[day] = DayHours(opensAt: time, closesAt: hours.closesAt);
              });
            },
            child: Text(timeText(hours.opensAt)),
          ),
          const Text('-'),
          TextButton(
            onPressed: () async {
              final time = await _pickTime(hours.closesAt);
              if (time == null) return;
              setState(() {
                _hours[day] = DayHours(opensAt: hours.opensAt, closesAt: time);
              });
            },
            child: Text(timeText(hours.closesAt)),
          ),
        ],
      ],
    );
  }
}

/// Small uppercase heading, with an optional button on the right.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
