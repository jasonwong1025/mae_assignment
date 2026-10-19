import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';

/// A product that might be what a grocery list item means, with how well it
/// fits (0 to 1).
typedef ProductMatch = ({CatalogueProduct product, double score});

/// Finds the catalogue products a written grocery item probably means.
/// Plain code with no Flutter or Firebase.
///
/// This is deliberately simple and explainable: words are compared one by
/// one, allowing a plural ("eggs" for "egg"), a beginning ("choc" for
/// "chocolate") or a small typo ("tomatto"). It does not guess synonyms; an
/// item it cannot match is shown as not found and the customer picks the
/// product by hand.
class GroceryMatcher {
  GroceryMatcher._();

  /// Items scoring below this are not shown as a match.
  static const double minimumScore = 0.6;

  /// Products that could be what [query] means, best first. In-stock
  /// products come before out-of-stock ones with the same score.
  static List<ProductMatch> rank(
    String query,
    List<CatalogueProduct> products, {
    int limit = 5,
  }) {
    final wanted = _words(query);
    if (wanted.isEmpty) return const [];

    final scored = <ProductMatch>[];
    for (final product in products) {
      final nameWords = _words(product.name);
      final otherWords = [
        ..._words(product.brand),
        ..._words(product.packSize),
      ];
      final score = _score(wanted, nameWords, otherWords);
      if (score >= minimumScore) scored.add((product: product, score: score));
    }
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      if (a.product.isOutOfStock != b.product.isOutOfStock) {
        return a.product.isOutOfStock ? 1 : -1;
      }
      return a.product.name.compareTo(b.product.name);
    });
    return scored.take(limit).toList();
  }

  /// The best product to add for [query]: the top match that is in stock, or
  /// null if nothing fits or everything that fits is sold out.
  static CatalogueProduct? best(String query, List<CatalogueProduct> products) {
    for (final match in rank(query, products)) {
      if (!match.product.isOutOfStock) return match.product;
    }
    return null;
  }

  // How much of what was written the product covers (most of the score), and
  // how little of the product's name is left over (so "milk" prefers "Fresh
  // milk" over "Milk chocolate biscuits").
  static double _score(
    List<String> wanted,
    List<String> nameWords,
    List<String> otherWords,
  ) {
    var covered = 0.0;
    var usedNameWords = 0;
    for (final word in wanted) {
      var bestInName = 0.0;
      for (final candidate in nameWords) {
        final fit = _wordFit(word, candidate);
        if (fit > bestInName) bestInName = fit;
      }
      var bestElsewhere = 0.0;
      for (final candidate in otherWords) {
        final fit = _wordFit(word, candidate);
        if (fit > bestElsewhere) bestElsewhere = fit;
      }
      // A brand or pack size can satisfy a word, a little less than the name.
      final fit = bestInName >= bestElsewhere
          ? bestInName
          : bestElsewhere * 0.9;
      if (bestInName > 0) usedNameWords++;
      covered += fit;
    }
    final coverage = covered / wanted.length;
    if (coverage < minimumScore) return coverage * 0.5;
    final tidiness = nameWords.isEmpty
        ? 0.0
        : (usedNameWords / nameWords.length).clamp(0.0, 1.0);
    return coverage * 0.85 + tidiness * 0.15;
  }

  // 1 for the same word, less for a beginning or a near miss, 0 for none.
  static double _wordFit(String written, String product) {
    if (written == product) return 1;
    if (written.length >= 3 && product.startsWith(written)) return 0.8;
    if (product.length >= 3 && written.startsWith(product)) return 0.8;
    if (written.length >= 5 && product.length >= 5) {
      final allowed = written.length >= 8 ? 2 : 1;
      if (_distance(written, product) <= allowed) return 0.75;
    }
    return 0;
  }

  /// Lowercase words with punctuation removed and plurals made singular.
  static List<String> _words(String text) {
    return [
      for (final raw in text.toLowerCase().split(RegExp('[^a-z0-9]+')))
        if (raw.isNotEmpty) _singular(raw),
    ];
  }

  static String _singular(String word) {
    if (word.length > 4 && word.endsWith('ies')) {
      return '${word.substring(0, word.length - 3)}y';
    }
    if (word.length > 4 && word.endsWith('oes')) {
      return word.substring(0, word.length - 2);
    }
    if (word.length > 3 && word.endsWith('s') && !word.endsWith('ss')) {
      return word.substring(0, word.length - 1);
    }
    return word;
  }

  // Number of single-letter edits between two words.
  static int _distance(String a, String b) {
    var previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final current = List<int>.filled(b.length + 1, 0)..[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        final best = [
          previous[j] + 1,
          current[j - 1] + 1,
          previous[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
        current[j] = best;
      }
      previous = current;
    }
    return previous[b.length];
  }
}
