/// One line read from a written list: the words and how many.
typedef ParsedLine = ({String name, int quantity});

/// Turns the text read from a photo of a written list (or pasted text) into
/// items. Plain code with no Flutter or Firebase, so it is easy to test.
///
/// A written list is rarely tidy, so it copes with the common shapes:
/// bullets and ticks in front, "2x milk", "2 milk", "milk x2", "milk - 2",
/// "milk (2)", and several items on one line separated by commas. It does
/// not understand sentences; anything it cannot make sense of is left for
/// the customer to fix in the review step.
class GroceryTextParser {
  GroceryTextParser._();

  /// No list item is longer than this; a longer line is a sentence or noise.
  static const int maxNameLength = 60;

  /// The most of one thing that can be asked for.
  static const int maxQuantity = 99;

  // Bullets, dashes, ticks and checkbox marks at the start of a line.
  static final RegExp _leadingMarks = RegExp(r'^[\s\-–—•*·●○▪■□☐☑✓✔>\[\]()]+');

  // "1." or "2)" list numbering (a plain "2 eggs" is a quantity, not this).
  static final RegExp _numbering = RegExp(r'^\d{1,2}[.)]\s+');

  // A quantity then an x: "2x milk", "2 x milk", "2 × milk".
  static final RegExp _quantityTimes = RegExp(
    r'^(\d{1,3})\s*[x×*]\s*(\D.*)$',
    caseSensitive: false,
  );

  // "milk x2", "milk x 2", "milk - 2", "milk: 2".
  static final RegExp _trailingQuantity = RegExp(
    r'^(.*\D)\s*(?:[x×*]|[-–—:])\s*(\d{1,3})$',
    caseSensitive: false,
  );

  // "milk (2)".
  static final RegExp _bracketQuantity = RegExp(r'^(.*\D)\s*\((\d{1,3})\)$');

  // "2 eggs", but not "500 g flour" or "2 kg rice" (a measure, part of the
  // name).
  static final RegExp _leadingQuantity = RegExp(r'^(\d{1,2})\s+(\D.*)$');

  static final RegExp _measure = RegExp(
    '^(?:g|gm|gram|grams|kg|ml|l|ltr|litre|litres|liter|liters|oz|lb|lbs|'
    r'pack|packs|pcs|pc)\b',
    caseSensitive: false,
  );

  /// The items in [text], one per line or comma-separated piece, in order.
  /// The same item twice is added up.
  static List<ParsedLine> parse(String text) {
    final merged = <String, ParsedLine>{};
    for (final line in text.split(RegExp(r'[\r\n]+'))) {
      for (final piece in line.split(RegExp('[,;]'))) {
        final item = _parsePiece(piece);
        if (item == null) continue;
        final key = item.name.toLowerCase();
        final earlier = merged[key];
        merged[key] = earlier == null
            ? item
            : (
                name: earlier.name,
                quantity: _clamp(earlier.quantity + item.quantity),
              );
      }
    }
    return merged.values.toList();
  }

  static ParsedLine? _parsePiece(String raw) {
    var text = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    text = text.replaceFirst(_leadingMarks, '');
    text = text.replaceFirst(_numbering, '');
    text = text.trim();
    if (text.isEmpty) return null;

    var quantity = 1;
    var name = text;

    final times = _quantityTimes.firstMatch(text);
    final trailing = _trailingQuantity.firstMatch(text);
    final bracket = _bracketQuantity.firstMatch(text);
    final leading = _leadingQuantity.firstMatch(text);
    if (times != null) {
      quantity = int.parse(times.group(1)!);
      name = times.group(2)!;
    } else if (leading != null && !_measure.hasMatch(leading.group(2)!)) {
      quantity = int.parse(leading.group(1)!);
      name = leading.group(2)!;
    } else if (trailing != null) {
      quantity = int.parse(trailing.group(2)!);
      name = trailing.group(1)!;
    } else if (bracket != null) {
      quantity = int.parse(bracket.group(2)!);
      name = bracket.group(1)!;
    }

    name = name
        .replaceAll(RegExp(r'[\s\-–—:.]+$'), '')
        .replaceFirst(RegExp(r'^[\s\-–—:.]+'), '')
        .trim();
    // Needs real words: a stray mark, a number or a single letter is noise.
    final letters = RegExp('[A-Za-z]').allMatches(name).length;
    if (letters < 2 || name.length > maxNameLength) return null;
    return (name: name, quantity: _clamp(quantity));
  }

  static int _clamp(int quantity) {
    if (quantity < 1) return 1;
    return quantity > maxQuantity ? maxQuantity : quantity;
  }
}
