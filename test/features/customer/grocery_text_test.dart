import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/grocery/data/grocery_matcher.dart';
import 'package:mae_assignment/features/customer/grocery/data/grocery_text_parser.dart';

CatalogueProduct _product(
  String id,
  String name, {
  String brand = 'Farm',
  String packSize = '1kg',
  int stock = 10,
}) {
  return CatalogueProduct(
    id: id,
    name: name,
    brand: brand,
    categoryId: 'c',
    packSize: packSize,
    price: 5,
    stock: stock,
  );
}

List<String> _lines(String text) {
  return [
    for (final item in GroceryTextParser.parse(text))
      '${item.quantity} ${item.name}',
  ];
}

void main() {
  group('GroceryTextParser', () {
    test('reads one item per line', () {
      expect(_lines('milk\neggs\nbread'), ['1 milk', '1 eggs', '1 bread']);
    });

    test('understands a quantity in front, with or without an x', () {
      expect(_lines('2x milk'), ['2 milk']);
      expect(_lines('2 x milk'), ['2 milk']);
      expect(_lines('3 × eggs'), ['3 eggs']);
      expect(_lines('3 eggs'), ['3 eggs']);
    });

    test('understands a quantity after the name', () {
      expect(_lines('milk x2'), ['2 milk']);
      expect(_lines('milk x 2'), ['2 milk']);
      expect(_lines('milk - 2'), ['2 milk']);
      expect(_lines('milk (2)'), ['2 milk']);
      expect(_lines('milk: 2'), ['2 milk']);
    });

    test('keeps a measure as part of the name, not a quantity', () {
      expect(_lines('500 g flour'), ['1 500 g flour']);
      expect(_lines('2 kg rice'), ['1 2 kg rice']);
      expect(_lines('milk 1l'), ['1 milk 1l']);
      expect(_lines('2x milk 1L'), ['2 milk 1L']);
    });

    test('drops bullets, ticks and list numbers', () {
      expect(_lines('- milk\n• eggs\n* bread'), [
        '1 milk',
        '1 eggs',
        '1 bread',
      ]);
      expect(_lines('☐ milk\n✓ eggs'), ['1 milk', '1 eggs']);
      expect(_lines('1. milk\n2) eggs'), ['1 milk', '1 eggs']);
    });

    test('splits a line of several items', () {
      expect(_lines('milk, 2 eggs; bread'), ['1 milk', '2 eggs', '1 bread']);
    });

    test('adds up the same item written twice', () {
      expect(_lines('milk\n2 Milk'), ['3 milk']);
    });

    test('ignores noise and blank lines', () {
      expect(_lines('\n  \n---\n7\nx\nmilk\n!!'), ['1 milk']);
    });

    test('ignores a line too long to be an item', () {
      final sentence = 'please remember to buy ${'something ' * 10}';

      expect(_lines(sentence), isEmpty);
    });

    test('keeps the quantity sensible', () {
      expect(_lines('500x milk'), ['99 milk']);
      expect(_lines('0 x milk'), ['1 milk']);
    });

    test('reads a typical scanned handwritten list', () {
      const scanned =
          'Shopping List\n'
          '1. Fresh milk x2\n'
          '2. Eggs (1 tray)\n'
          '- Bananas\n'
          '3 Tomatoes\n'
          'Rice 5kg';

      expect(_lines(scanned), [
        '1 Shopping List',
        '2 Fresh milk',
        '1 Eggs (1 tray)',
        '1 Bananas',
        '3 Tomatoes',
        '1 Rice 5kg',
      ]);
    });
  });

  group('GroceryMatcher', () {
    final products = [
      _product('milk', 'Fresh milk', packSize: '1L'),
      _product('choc', 'Milk chocolate biscuits', packSize: '200g'),
      _product('eggs', 'Grade A eggs', packSize: '10 pack'),
      _product('tomato', 'Roma tomato'),
      _product('oat', 'Oat milk', brand: 'Oatside', packSize: '1L'),
      _product('rice', 'Basmati rice', brand: 'Taj', packSize: '5kg'),
      _product('soldout', 'Brown bread', stock: 0),
      _product('bread', 'White bread'),
    ];

    String? bestId(String query) => GroceryMatcher.best(query, products)?.id;

    test('finds a product by its name', () {
      expect(bestId('tomato'), 'tomato');
      expect(bestId('basmati rice'), 'rice');
    });

    test(
      'prefers the plain product over one that merely contains the word',
      () {
        expect(bestId('milk'), 'milk');
      },
    );

    test('accepts a plural, a beginning and a small typo', () {
      expect(bestId('egg'), 'eggs');
      expect(bestId('tomatoes'), 'tomato');
      expect(bestId('basm rice'), 'rice');
      expect(bestId('tomatto'), 'tomato');
    });

    test('ignores capital letters and punctuation', () {
      expect(bestId('  FRESH, Milk! '), 'milk');
    });

    test('uses the brand and pack size to tell similar products apart', () {
      expect(bestId('oatside milk'), 'oat');
      expect(bestId('milk 1l'), 'milk');
      expect(bestId('rice 5kg'), 'rice');
    });

    test('finds nothing for an unrelated item', () {
      expect(bestId('dragon fruit'), isNull);
      expect(bestId('zzz'), isNull);
      expect(bestId(''), isNull);
    });

    test('skips a sold-out product when something in stock fits', () {
      // Brown bread is sold out; plain "bread" fits both, so the one in
      // stock wins.
      expect(bestId('bread'), 'bread');
      expect(bestId('brown bread'), isNull);
      final onlySoldOut = [_product('soldout', 'Brown bread', stock: 0)];
      expect(GroceryMatcher.best('brown bread', onlySoldOut), isNull);
      // It is still offered as a candidate, so the screen can say it is out.
      expect(
        GroceryMatcher.rank('brown bread', onlySoldOut).single.product.id,
        'soldout',
      );
    });

    test('rank lists the best candidates first, at most the limit', () {
      final ranked = GroceryMatcher.rank('milk', products, limit: 2);

      expect(ranked.map((m) => m.product.id), ['milk', 'oat']);
      expect(ranked.first.score, greaterThanOrEqualTo(ranked.last.score));
    });

    test('a word the product does not have is not a match', () {
      expect(GroceryMatcher.rank('chicken breast', products), isEmpty);
    });
  });
}
