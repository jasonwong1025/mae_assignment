import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/customer/grocery/data/grocery_text_parser.dart';
import 'package:mae_assignment/features/customer/grocery/data/repositories/recipe_repository.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';

/// Asks for a dish or recipe and the number of servings, then fetches the
/// suggested ingredients with [suggest]. Returns them for review, or null if
/// the sheet is closed.
Future<List<ParsedLine>?> showRecipeSheet(
  BuildContext context, {
  required Future<List<ParsedLine>> Function(String dish, int servings) suggest,
}) {
  return showModalBottomSheet<List<ParsedLine>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => _RecipeSheet(suggest: suggest),
  );
}

class _RecipeSheet extends StatefulWidget {
  const _RecipeSheet({required this.suggest});

  final Future<List<ParsedLine>> Function(String dish, int servings) suggest;

  @override
  State<_RecipeSheet> createState() => _RecipeSheetState();
}

class _RecipeSheetState extends State<_RecipeSheet> {
  final _controller = TextEditingController();
  int _servings = 2;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final lines = await widget.suggest(_controller.text, _servings);
      if (mounted) Navigator.of(context).pop(lines);
    } on AppException catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = error.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          0,
          AppSpacing.l,
          AppSpacing.l,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ingredients from a recipe', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Name a dish or paste a recipe. An AI model suggests what to '
              'buy; you check the list before anything is added.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              key: const Key('recipe_input'),
              controller: _controller,
              enabled: !_isLoading,
              minLines: 3,
              maxLines: 6,
              maxLength: RecipeRepository.maxLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'e.g. nasi lemak, or paste a recipe',
              ),
            ),
            Row(
              children: [
                Text('Servings', style: textTheme.titleSmall),
                const Spacer(),
                IconButton(
                  tooltip: 'Fewer servings',
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _isLoading || _servings <= 1
                      ? null
                      : () => setState(() => _servings--),
                ),
                Text('$_servings', style: textTheme.titleMedium),
                IconButton(
                  tooltip: 'More servings',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _isLoading || _servings >= 20
                      ? null
                      : () => setState(() => _servings++),
                ),
              ],
            ),
            if (_error != null) ...[
              Text(
                _error!,
                key: const Key('recipe_error'),
                style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.s),
            ],
            FilledButton.icon(
              key: const Key('recipe_submit'),
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const ButtonLoadingIndicator()
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_isLoading ? 'Thinking…' : 'Suggest ingredients'),
            ),
          ],
        ),
      ),
    );
  }
}
