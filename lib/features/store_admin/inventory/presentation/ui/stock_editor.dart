import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Stock number with - and + buttons.
/// "Save stock" shows when the number differs from [stock].
class StockEditor extends StatefulWidget {
  const StockEditor({required this.stock, required this.onSave, super.key});

  /// Saved stock.
  final int stock;
  final ValueChanged<int> onSave;

  @override
  State<StockEditor> createState() => _StockEditorState();
}

class _StockEditorState extends State<StockEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.stock}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Typed number. Null if empty.
  int? get _typed => int.tryParse(_controller.text);

  void _change(int by) {
    final next = (_typed ?? 0) + by;
    setState(() => _controller.text = '${next < 0 ? 0 : next}');
  }

  @override
  Widget build(BuildContext context) {
    final typed = _typed;
    final hasChanged = typed != null && typed != widget.stock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.outlined(
              tooltip: 'Remove one',
              icon: const Icon(Icons.remove_rounded),
              onPressed: () => _change(-1),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                // Digits only.
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              tooltip: 'Add one',
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _change(1),
            ),
          ],
        ),
        if (hasChanged) ...[
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => widget.onSave(typed),
            child: const Text('Save stock'),
          ),
        ],
      ],
    );
  }
}
