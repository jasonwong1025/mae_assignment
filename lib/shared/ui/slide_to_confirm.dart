import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';

/// A button the user confirms by sliding the round handle all the way to
/// the right. Used instead of a confirmation dialog for actions that
/// cannot be undone: one motion, but hard to trigger by an accidental tap.
///
/// Letting go before the end slides the handle back. While [onConfirmed]
/// runs, the handle shows a spinner. If it returns true, the handle shows
/// a tick for a moment and then [onCompleted] runs (e.g. to leave the
/// screen); if it returns false (it failed), the handle slides back.
class SlideToConfirm extends StatefulWidget {
  const SlideToConfirm({
    required this.label,
    required this.onConfirmed,
    super.key,
    this.onCompleted,
  });

  /// Text on the track, e.g. "Slide to hand over".
  final String label;

  /// Does the action and returns true if it worked. Null disables the
  /// slider.
  final Future<bool> Function()? onConfirmed;

  /// Runs after the tick has been shown, when [onConfirmed] worked.
  final VoidCallback? onCompleted;

  /// How long the tick shows before [onCompleted].
  static const tickDuration = Duration(milliseconds: 500);

  /// Key of the round handle, so tests can drag it.
  static const handleKey = ValueKey('slide-to-confirm-handle');

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  static const double _height = 56;
  static const double _handleSize = 48;
  static const double _padding = (_height - _handleSize) / 2;

  /// How far the handle has moved from the left, in pixels.
  double _offset = 0;

  /// True while the finger is on the handle (no animation then).
  bool _isDragging = false;

  /// True while onConfirmed runs.
  bool _isRunning = false;

  /// True once onConfirmed worked: shows the tick.
  bool _isDone = false;

  bool get _enabled => widget.onConfirmed != null && !_isRunning && !_isDone;

  Future<void> _onDragEnd(double maxOffset) async {
    // Most of the way counts, so the last few pixels are not fiddly.
    final reachedEnd = _offset >= maxOffset * 0.9;
    setState(() {
      _isDragging = false;
      _offset = reachedEnd ? maxOffset : 0;
      _isRunning = reachedEnd;
    });
    if (!reachedEnd) return;

    final worked = await widget.onConfirmed!();
    if (!mounted) return;
    if (!worked) {
      setState(() {
        _isRunning = false;
        _offset = 0;
      });
      return;
    }
    setState(() {
      _isRunning = false;
      _isDone = true;
    });
    await Future<void>.delayed(SlideToConfirm.tickDuration);
    if (mounted) widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onConfirmed != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxOffset = constraints.maxWidth - _handleSize - _padding * 2;
        final progress = maxOffset <= 0 ? 0.0 : _offset / maxOffset;

        return Semantics(
          button: true,
          enabled: _enabled,
          label: widget.label,
          child: Container(
            height: _height,
            decoration: BoxDecoration(
              color: enabled ? AppColors.darkGreen : AppColors.border,
              borderRadius: BorderRadius.circular(_height / 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The label fades as the handle covers it.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _handleSize + _padding * 2,
                  ),
                  child: Opacity(
                    opacity: (1 - progress * 1.5).clamp(0.0, 1.0),
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: enabled ? Colors.white : AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: _isDragging
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  left: _padding + _offset,
                  top: _padding,
                  child: GestureDetector(
                    key: SlideToConfirm.handleKey,
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: _enabled
                        ? (_) => setState(() => _isDragging = true)
                        : null,
                    onHorizontalDragUpdate: _enabled
                        ? (details) => setState(() {
                            _offset = (_offset + details.delta.dx).clamp(
                              0.0,
                              maxOffset,
                            );
                          })
                        : null,
                    onHorizontalDragEnd: _enabled
                        ? (_) => _onDragEnd(maxOffset)
                        : null,
                    child: Container(
                      width: _handleSize,
                      height: _handleSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _isDone
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.darkGreen,
                              )
                            : _isRunning
                            ? const DefaultTextStyle(
                                style: TextStyle(color: AppColors.darkGreen),
                                child: ButtonLoadingIndicator(),
                              )
                            : Icon(
                                Icons.arrow_forward_rounded,
                                color: enabled
                                    ? AppColors.darkGreen
                                    : AppColors.textSecondary,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
