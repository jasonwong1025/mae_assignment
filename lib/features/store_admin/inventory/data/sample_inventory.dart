import 'models/inventory_item.dart';
import 'models/product.dart';

/// Sample categories until the backend is connected.
/// TODO: delete once inventory comes from Firestore.
List<ProductCategory> sampleCategories() {
  return const [
    ProductCategory(id: 'fruits-vegetables', name: 'Fruits & Vegetables'),
    ProductCategory(id: 'meat-seafood', name: 'Meat & Seafood'),
    ProductCategory(id: 'dairy-eggs', name: 'Dairy & Eggs'),
    ProductCategory(id: 'bakery', name: 'Bakery'),
    ProductCategory(id: 'pantry', name: 'Pantry'),
    ProductCategory(id: 'drinks', name: 'Drinks'),
    ProductCategory(id: 'snacks', name: 'Snacks'),
    ProductCategory(id: 'frozen', name: 'Frozen'),
    ProductCategory(id: 'household', name: 'Household'),
    ProductCategory(id: 'baby', name: 'Baby'),
  ];
}

/// Branch order of the stock numbers below.
const sampleBranchIds = ['ss15', 'bukit-jalil', 'puchong'];

/// Sample products at every branch.
List<InventoryItem> sampleInventory() {
  return [
    ..._everywhere(
      'p1',
      'Fresh milk',
      'Farm Fresh',
      'dairy-eggs',
      '1L',
      7.90,
      stock: [42, 18, 25],
      description: 'Pasteurised full cream milk from local farms.',
    ),
    ..._everywhere(
      'p2',
      'Oat milk',
      'Oatside',
      'dairy-eggs',
      '1L',
      12.90,
      stock: [0, 9, 4],
      lowStockLevel: 5,
    ),
    ..._everywhere(
      'p3',
      'Eggs',
      'Nutriplus',
      'dairy-eggs',
      '10 pcs',
      6.80,
      stock: [6, 30, 12],
    ),
    ..._everywhere(
      'p4',
      'Greek yogurt',
      'Farm Fresh',
      'dairy-eggs',
      '120g',
      4.90,
      stock: [24, 15, 0],
      lowStockLevel: 8,
    ),
    ..._everywhere(
      'p5',
      'Wholemeal bread',
      'Gardenia',
      'bakery',
      '400g',
      4.50,
      stock: [15, 8, 11],
    ),
    ..._everywhere(
      'p6',
      'Croissants',
      'Bakers Lane',
      'bakery',
      '4 pcs',
      9.50,
      stock: [7, 0, 5],
      lowStockLevel: 6,
    ),
    ..._everywhere(
      'p7',
      'Bananas',
      'Local Farm',
      'fruits-vegetables',
      '1 bunch',
      5.20,
      stock: [20, 22, 9],
    ),
    ..._everywhere(
      'p8',
      'Broccoli',
      'Local Farm',
      'fruits-vegetables',
      '1 head',
      6.40,
      stock: [12, 14, 3],
      lowStockLevel: 5,
    ),
    ..._everywhere(
      'p9',
      'Tomatoes',
      'Cameron Fresh',
      'fruits-vegetables',
      '500g',
      3.60,
      stock: [31, 17, 20],
    ),
    ..._everywhere(
      'p10',
      'Chicken breast',
      'Ayamas',
      'meat-seafood',
      '500g',
      11.90,
      stock: [9, 13, 16],
    ),
    ..._everywhere(
      'p11',
      'Salmon fillet',
      'Ocean Catch',
      'meat-seafood',
      '200g',
      24.90,
      stock: [4, 6, 0],
      lowStockLevel: 4,
    ),
    ..._everywhere(
      'p12',
      'Jasmine rice',
      'Jasmine',
      'pantry',
      '5kg',
      28.90,
      stock: [38, 26, 19],
      // Puchong sells it cheaper.
      prices: [28.90, 28.90, 27.50],
    ),
    ..._everywhere(
      'p13',
      'Cooking oil',
      'Saji',
      'pantry',
      '2kg',
      17.50,
      stock: [22, 10, 14],
    ),
    ..._everywhere(
      'p14',
      'Soy sauce',
      'Kikkoman',
      'pantry',
      '600ml',
      5.90,
      stock: [18, 21, 8],
    ),
    ..._everywhere(
      'p15',
      'Mineral water',
      'Spritzer',
      'drinks',
      '1.5L',
      1.80,
      stock: [120, 96, 60],
      lowStockLevel: 24,
    ),
    ..._everywhere(
      'p16',
      'Orange juice',
      'Peel Fresh',
      'drinks',
      '1L',
      8.90,
      stock: [14, 5, 17],
      lowStockLevel: 6,
    ),
    ..._everywhere(
      'p17',
      'Potato chips',
      'Mister Potato',
      'snacks',
      '160g',
      5.50,
      stock: [45, 33, 28],
    ),
    ..._everywhere(
      'p18',
      'Dish soap',
      'Sunlight',
      'household',
      '900ml',
      6.90,
      stock: [16, 2, 13],
      lowStockLevel: 5,
    ),
    ..._everywhere(
      'p19',
      'Diapers (M)',
      'MamyPoko',
      'baby',
      '52 pcs',
      45.90,
      stock: [8, 11, 6],
      lowStockLevel: 4,
    ),
    ..._everywhere(
      'p20',
      'Mooncakes',
      'Bakers Lane',
      'bakery',
      '4 pcs',
      38.00,
      stock: [0, 0, 0],
      description: 'Seasonal. Back for the Mid-Autumn Festival.',
      hidden: true,
    ),
  ];
}

/// One product at all three branches.
/// [stock] and [prices] are in [sampleBranchIds] order.
List<InventoryItem> _everywhere(
  String id,
  String name,
  String brand,
  String categoryId,
  String packSize,
  double price, {
  required List<int> stock,
  List<double>? prices,
  int lowStockLevel = 10,
  String description = '',
  bool hidden = false,
}) {
  final product = Product(
    id: id,
    name: name,
    brand: brand,
    categoryId: categoryId,
    packSize: packSize,
    description: description,
    lowStockLevel: lowStockLevel,
  );

  return [
    for (var i = 0; i < sampleBranchIds.length; i++)
      InventoryItem(
        product: product,
        branchId: sampleBranchIds[i],
        price: prices == null ? price : prices[i],
        stock: stock[i],
        isHidden: hidden,
      ),
  ];
}
