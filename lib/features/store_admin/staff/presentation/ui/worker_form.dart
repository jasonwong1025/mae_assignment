import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utilities/validators.dart';
import '../../../../../shared/ui/button_loading_indicator.dart';
import '../../../../../shared/ui/labeled_text_field.dart';
import '../../../../../shared/ui/password_field.dart';
import '../../../shell/data/models/branch.dart';
import '../../../shell/presentation/view_models/branch_view_model.dart';
import '../../data/models/worker.dart';
import '../view_models/staff_view_model.dart';

/// Form to add or edit a worker.
/// - [worker] is null: add (also asks for a temporary password)
/// - [worker] is given: edit that worker
class WorkerForm extends ConsumerStatefulWidget {
  const WorkerForm({
    super.key,
    this.worker,
    required this.onCancel,
    required this.onSaved,
  });

  final Worker? worker;
  final VoidCallback onCancel;

  /// Called with the saved name after saving.
  final ValueChanged<String> onSaved;

  @override
  ConsumerState<WorkerForm> createState() => _WorkerFormState();
}

class _WorkerFormState extends ConsumerState<WorkerForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _passwordController = TextEditingController();

  late WorkerRole _role;

  /// Packer's branch. Not used for drivers.
  String? _branchId;
  bool _isSaving = false;

  bool get _isAdding => widget.worker == null;

  @override
  void initState() {
    super.initState();
    final worker = widget.worker;
    _nameController = TextEditingController(text: worker?.name);
    _emailController = TextEditingController(text: worker?.email);
    _phoneController = TextEditingController(text: worker?.phone);
    _role = worker?.role ?? WorkerRole.packingStaff;

    // Default to the worker's branch, or the selected branch.
    final selectedBranch = ref.read(branchViewModelProvider).value?.selected;
    _branchId = worker?.branchId ?? selectedBranch?.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() => _isSaving = true);
    final viewModel = ref.read(staffViewModelProvider.notifier);
    final worker = widget.worker;

    final String? error;
    if (worker == null) {
      error = await viewModel.addWorker(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        temporaryPassword: _passwordController.text,
        role: _role,
        branchId: _branchId,
      );
    } else {
      error = await viewModel.updateDetails(
        worker,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        role: _role,
        branchId: _branchId,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    widget.onSaved(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final branches =
        ref.watch(branchViewModelProvider).value?.branches ?? const <Branch>[];

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LabeledTextField(
            label: 'Full name',
            hint: 'Daniel Lee',
            controller: _nameController,
            keyboardType: TextInputType.name,
            validator: Validators.name,
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: 'Email',
            hint: 'name@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: 'Phone number',
            hint: '012-345 6789',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
          ),
          if (_isAdding) ...[
            const SizedBox(height: 16),
            PasswordField(
              label: 'Temporary password',
              hint: 'At least 8 characters',
              controller: _passwordController,
              validator: Validators.newPassword,
              isNewPassword: true,
            ),
            const SizedBox(height: 6),
            Text(
              'Give this to the worker so they can sign in.',
              style: textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 20),
          const _FieldLabel('Role'),
          SegmentedButton<WorkerRole>(
            showSelectedIcon: false,
            segments: [
              for (final role in WorkerRole.values)
                ButtonSegment(value: role, label: Text(role.label)),
            ],
            selected: {_role},
            onSelectionChanged: (selection) {
              setState(() => _role = selection.first);
            },
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Branch'),
          if (_role == WorkerRole.packingStaff)
            DropdownButtonFormField<String>(
              initialValue: _branchId,
              items: [
                for (final branch in branches)
                  DropdownMenuItem(value: branch.id, child: Text(branch.name)),
              ],
              onChanged: (branchId) => setState(() => _branchId = branchId),
              validator: (branchId) {
                return branchId == null ? 'Please choose a branch' : null;
              },
            )
          else
            Text(
              'Delivery drivers move between branches, so they are not '
              'tied to one.',
              style: textTheme.bodyMedium,
            ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _isSaving ? null : _onSave,
            child: _isSaving
                ? const ButtonLoadingIndicator()
                : Text(_isAdding ? 'Add worker' : 'Save changes'),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: _isSaving ? null : widget.onCancel,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

/// Small uppercase label above a field.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
