import 'package:flutter/material.dart';

/// A 4:3 photo with an expand button in the corner that opens it full
/// screen at its real proportions, with pinch to zoom.
class ExpandablePhoto extends StatelessWidget {
  const ExpandablePhoto({
    required this.image,
    super.key,
    this.borderRadius = 12,
  });

  /// A photo just taken (`MemoryImage`) or one already uploaded
  /// (`NetworkImage`).
  final ImageProvider image;
  final double borderRadius;

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => _FullScreenPhoto(image: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => _openFullScreen(context),
              child: Image(image: image, fit: BoxFit.cover),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: IconButton.filled(
                tooltip: 'View full size',
                onPressed: () => _openFullScreen(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.open_in_full_rounded, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The whole photo on black, uncropped. Pinch or double-tap to zoom.
class _FullScreenPhoto extends StatelessWidget {
  const _FullScreenPhoto({required this.image});

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Proof of delivery'),
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: Image(image: image, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
