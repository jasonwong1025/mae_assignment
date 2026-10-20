import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/customer/grocery/data/grocery_text_parser.dart';
import 'package:mae_assignment/features/customer/grocery/data/services/recipe_ai_service.dart';

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(ref.watch(recipeAiServiceProvider));
});

/// Error with a message that is safe to show on screen.
class RecipeException extends AppException {
  const RecipeException(super.message);
}

/// Suggests ingredients for a recipe.
///
/// The model is an assistant, not a source of truth: its answer is checked
/// field by field here, and what survives is only a list of words and
/// quantities. The customer reviews and edits that list, and the products in
/// the cart still come from the store's own catalogue (`GroceryMatcher`).
class RecipeRepository {
  RecipeRepository(this._ai);

  /// Longest dish description sent to the model.
  static const int maxLength = 500;
  static const int maxServings = 20;
  static const int maxIngredients = 25;

  final RecipeAiService _ai;

  /// The ingredients for [dish] for [servings] people, as list items.
  /// Throws a [RecipeException] with a message to show if the request is not
  /// valid, the model cannot be reached, or its answer is unusable.
  Future<List<ParsedLine>> suggest(String dish, {int servings = 2}) async {
    final text = dish.trim();
    if (text.length < 3) {
      throw const RecipeException('Describe the dish or paste a recipe first.');
    }
    if (text.length > maxLength) {
      throw const RecipeException(
        'That is too long. Use $maxLength characters or fewer.',
      );
    }
    if (servings < 1 || servings > maxServings) {
      throw const RecipeException('Choose between 1 and 20 servings.');
    }

    final String answer;
    try {
      answer = await _ai.ingredientsJson(dish: text, servings: servings);
    } on RecipeAiException catch (error) {
      debugPrint('Recipe suggestion failed: $error');
      throw RecipeException(_messageFor(error.reason));
    }

    final lines = parse(answer);
    if (lines.isEmpty) {
      throw const RecipeException(
        'No ingredients could be found. Try describing the dish in a '
        'different way.',
      );
    }
    return lines;
  }

  /// Turns the model's JSON into list items, dropping anything that is not a
  /// sensible ingredient. Never throws; returns an empty list for nonsense.
  @visibleForTesting
  static List<ParsedLine> parse(String json) {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      return const [];
    }
    final ingredients = decoded is Map ? decoded['ingredients'] : null;
    if (ingredients is! List) return const [];

    final seen = <String>{};
    final lines = <ParsedLine>[];
    for (final entry in ingredients) {
      if (entry is! Map) continue;
      final name = entry['name'];
      if (name is! String) continue;
      final clean = name.replaceAll(RegExp(r'\s+'), ' ').trim();
      final letters = RegExp('[A-Za-z]').allMatches(clean).length;
      if (letters < 2 || clean.length > GroceryTextParser.maxNameLength) {
        continue;
      }
      if (!seen.add(clean.toLowerCase())) continue;
      final quantity = entry['quantity'];
      lines.add((
        name: clean,
        quantity: quantity is num
            ? quantity.round().clamp(1, GroceryTextParser.maxQuantity)
            : 1,
      ));
      if (lines.length == maxIngredients) break;
    }
    return lines;
  }

  static String _messageFor(String reason) {
    final text = reason.toLowerCase();
    if (text.contains('quota') ||
        text.contains('429') ||
        text.contains('rate')) {
      return 'Recipe suggestions are busy right now. Please try again in a '
          'minute.';
    }
    if (text.contains('timeout')) {
      return 'That took too long. Please try again.';
    }
    return 'Recipe suggestions are not available right now. You can type the '
        'ingredients instead.';
  }
}
