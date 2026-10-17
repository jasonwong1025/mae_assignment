import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/repositories/address_repository.dart';
import 'package:mae_assignment/shared/repositories/geocoding_repository.dart';

/// Add or edit a saved delivery address: search for a place or tap the map
/// to drop the pin, then give it a label and an optional note. Saving writes
/// to Firestore and pops. Built on flutter_map + OpenStreetMap, matching the
/// admin branch form.
class AddressPickerView extends ConsumerStatefulWidget {
  const AddressPickerView({super.key, this.existing});

  /// The address being edited, or null when adding a new one.
  final CustomerAddress? existing;

  @override
  ConsumerState<AddressPickerView> createState() => _AddressPickerViewState();
}

class _AddressPickerViewState extends ConsumerState<AddressPickerView> {
  /// Falls back to central Kuala Lumpur until a place is chosen.
  static const LatLng _klCentre = LatLng(3.139, 101.6869);

  final _mapController = MapController();
  final _labelController = TextEditingController();
  final _lineController = TextEditingController();
  final _noteController = TextEditingController();
  final _searchController = TextEditingController();

  late LatLng _location;
  List<AddressResult> _searchResults = const [];
  String? _searchError;
  bool _isSearching = false;
  bool _isLocating = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _location = existing?.location ?? _klCentre;
    _labelController.text = existing?.label ?? '';
    _lineController.text = existing?.line ?? '';
    _noteController.text = existing?.note ?? '';
  }

  @override
  void dispose() {
    _mapController.dispose();
    _labelController.dispose();
    _lineController.dispose();
    _noteController.dispose();
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
      final results = await ref.read(geocodingRepositoryProvider).search(text);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        if (results.isEmpty) _searchError = 'No places found.';
      });
    } on Object {
      if (!mounted) return;
      setState(() => _searchError = 'Could not search. Check your internet.');
    }
    if (mounted) setState(() => _isSearching = false);
  }

  void _useResult(AddressResult result) {
    setState(() {
      _location = result.location;
      _lineController.text = result.address;
      _searchResults = const [];
      _searchController.clear();
    });
    _mapController.move(result.location, 16);
  }

  /// When the customer taps the map, drop the pin there and look up the
  /// address text for it (reverse geocoding), filling the line field.
  Future<void> _onMapTap(LatLng point) async {
    setState(() {
      _location = point;
      _isLocating = true;
    });
    try {
      final line = await ref.read(geocodingRepositoryProvider).addressAt(point);
      if (!mounted) return;
      if (line != null && line.isNotEmpty) _lineController.text = line;
    } on Object {
      // Keep the pin; the customer can still type the line by hand.
    }
    if (mounted) setState(() => _isLocating = false);
  }

  Future<void> _save() async {
    final label = _labelController.text.trim();
    final line = _lineController.text.trim();
    if (label.isEmpty || line.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please add a label and an address line.'),
          ),
        );
      return;
    }

    setState(() => _isSaving = true);
    final repository = ref.read(addressRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final existing = widget.existing;
      final address = CustomerAddress(
        id: existing?.id ?? '',
        label: label,
        line: line,
        location: _location,
        note: _noteController.text.trim(),
        isDefault: existing?.isDefault ?? false,
      );
      if (existing == null) {
        await repository.addAddress(address);
      } else {
        await repository.updateAddress(address);
      }
      ref.invalidate(savedAddressesProvider);
      if (!mounted) return;
      navigator.pop(true);
    } on AddressException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit address' : 'Add address')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            _SearchField(
              controller: _searchController,
              isSearching: _isSearching,
              onSearch: _search,
            ),
            if (_searchError != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                _searchError!,
                style: textTheme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ],
            for (final result in _searchResults)
              ListTile(
                dense: true,
                leading: const Icon(Icons.place_outlined),
                title: Text(result.address, style: textTheme.bodyMedium),
                onTap: () => _useResult(result),
              ),
            const SizedBox(height: AppSpacing.m),
            _PickerMap(
              controller: _mapController,
              location: _location,
              isLocating: _isLocating,
              onTap: _onMapTap,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap the map to drop the pin, or search above.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.l),
            _Field(
              controller: _labelController,
              label: 'LABEL',
              hint: 'Home, Office, Mum’s place…',
            ),
            const SizedBox(height: AppSpacing.l),
            _Field(
              controller: _lineController,
              label: 'ADDRESS',
              hint: 'Unit, street, postcode',
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.l),
            _Field(
              controller: _noteController,
              label: 'DELIVERY NOTE (OPTIONAL)',
              hint: 'e.g. leave at the guardhouse',
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save address'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.isSearching,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool isSearching;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSearch(),
      decoration: InputDecoration(
        hintText: 'Search an address or place',
        prefixIcon: const Icon(Icons.search_rounded),
        isDense: true,
        suffixIcon: isSearching
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.m),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_forward_rounded),
                onPressed: onSearch,
              ),
      ),
    );
  }
}

class _PickerMap extends StatelessWidget {
  const _PickerMap({
    required this.controller,
    required this.location,
    required this.isLocating,
    required this.onTap,
  });

  final MapController controller;
  final LatLng location;
  final bool isLocating;
  final ValueChanged<LatLng> onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 240,
        child: Stack(
          children: [
            FlutterMap(
              mapController: controller,
              options: MapOptions(
                initialCenter: location,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onTap: (_, point) => onTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mae_assignment',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location,
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 40,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: ColoredBox(
                    color: Colors.white70,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '© OpenStreetMap contributors',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isLocating)
              const Positioned(
                top: AppSpacing.s,
                left: AppSpacing.s,
                child: Chip(
                  label: Text('Finding address…'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint, isDense: true),
        ),
      ],
    );
  }
}
