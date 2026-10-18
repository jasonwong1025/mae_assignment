import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/cart/data/models/stored_cart.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_review.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/repositories/sample_branches.dart';

/// The Firestore mapping is written by hand, so these tests are its safety
/// net: every document model must read back what it writes, and must write
/// only the field names that `firestore_paths.dart` (and so `firestore.rules`
/// and `DATABASE/FIRESTORE.md`) defines.
void main() {
  void expectKeysWithin(Map<String, dynamic> map, Set<String> allowed) {
    expect(
      map.keys.toSet().difference(allowed),
      isEmpty,
      reason: 'fields written that firestore_paths.dart does not name',
    );
  }

  group('AppUser', () {
    const user = AppUser(
      uid: 'u1',
      name: 'Aisha',
      email: 'a@example.com',
      phone: '012',
      role: UserRole.customer,
    );

    test('writes exactly the fields the sign-up rule allows', () {
      expect(user.toFirestore().keys.toSet(), {
        UserFields.name,
        UserFields.email,
        UserFields.phone,
        UserFields.role,
      });
    });

    test('round-trips', () {
      expect(AppUser.fromFirestore('u1', user.toFirestore()), user);
    });

    test('an unknown role reads as customer', () {
      final read = AppUser.fromFirestore('u1', {UserFields.role: 'root'});
      expect(read.role, UserRole.customer);
    });
  });

  group('Branch', () {
    test('writes only named branch fields and round-trips', () {
      for (final branch in sampleBranches()) {
        final map = branch.toFirestore();
        expectKeysWithin(map, {
          BranchFields.name,
          BranchFields.address,
          BranchFields.phone,
          BranchFields.location,
          BranchFields.weeklyHours,
          BranchFields.maxDeliveryKm,
          BranchFields.baseDeliveryFee,
          BranchFields.feePerKm,
          BranchFields.isTemporarilyClosed,
        });
        expect(Branch.fromFirestore(branch.id, map), branch);
      }
    });

    test('DayHours writes only named fields and round-trips', () {
      const open = DayHours(opensAt: 480, closesAt: 1320);
      expectKeysWithin(open.toMap(), {
        DayHoursFields.opensAt,
        DayHoursFields.closesAt,
        DayHoursFields.isClosed,
      });
      expect(DayHours.fromMap(open.toMap()), open);
      expect(DayHours.fromMap(DayHours.closed.toMap()), DayHours.closed);
    });
  });

  group('CustomerAddress', () {
    const address = CustomerAddress(
      id: 'a1',
      label: 'Home',
      line: '1 Jalan',
      location: LatLng(3, 101),
      note: 'Ring',
      isDefault: true,
    );

    test('writes only named address fields and round-trips', () {
      final map = address.toFirestore();
      expectKeysWithin(map, {
        AddressFields.label,
        AddressFields.line,
        AddressFields.location,
        AddressFields.note,
        AddressFields.isDefault,
      });
      expect(CustomerAddress.fromFirestore('a1', map), address);
    });
  });

  group('Order', () {
    const order = Order(
      id: 'o1',
      number: 1001,
      customerId: 'u1',
      customerName: 'Aisha',
      customerPhone: '012',
      branchId: 'ss15',
      branchName: 'SS15',
      isDelivery: true,
      items: [
        OrderItem(
          lineId: 'l1',
          productId: 'p1',
          name: 'Rice',
          brand: 'B',
          packSize: '5kg',
          quantity: 2,
          unitPrice: 9.9,
          imageUrl: 'https://img/rice.png',
        ),
      ],
      subtotal: 19.8,
      deliveryFee: 3,
      discount: 5,
      total: 17.8,
      status: OrderStatus.packing,
      address: '1 Jalan',
      addressLocation: LatLng(3, 101),
      customerNote: 'Leave at the door',
      promoCode: 'FRESH5',
    );

    test('writes the fields the create rule requires and only named ones', () {
      final map = order.toFirestore();
      expectKeysWithin(map, {
        OrderFields.number,
        OrderFields.customerId,
        OrderFields.customerName,
        OrderFields.customerPhone,
        OrderFields.branchId,
        OrderFields.branchName,
        OrderFields.isDelivery,
        OrderFields.address,
        OrderFields.addressLocation,
        OrderFields.customerNote,
        OrderFields.items,
        OrderFields.promoCode,
        OrderFields.subtotal,
        OrderFields.deliveryFee,
        OrderFields.discount,
        OrderFields.total,
        OrderFields.status,
      });
      // firestore.rules requires these on create; placedAt is added by the
      // service with the server time.
      expect(
        map.keys,
        containsAll([
          OrderFields.number,
          OrderFields.customerId,
          OrderFields.branchId,
          OrderFields.items,
          OrderFields.total,
          OrderFields.status,
        ]),
      );
    });

    test('items write only named fields', () {
      expectKeysWithin(order.items.single.toMap(), {
        OrderItemFields.lineId,
        OrderItemFields.productId,
        OrderItemFields.name,
        OrderItemFields.brand,
        OrderItemFields.packSize,
        OrderItemFields.quantity,
        OrderItemFields.unitPrice,
        OrderItemFields.imageUrl,
      });
    });

    test('round-trips', () {
      expect(Order.fromFirestore('o1', order.toFirestore()), order);
    });

    test('reads the server times', () {
      final when = DateTime(2026, 3, 12, 18, 48);
      final read = Order.fromFirestore('o1', {
        ...order.toFirestore(),
        OrderFields.placedAt: Timestamp.fromDate(when),
        OrderFields.statusSince: Timestamp.fromDate(when),
      });
      expect(read.placedAt, when);
      expect(read.statusSince, when);
    });
  });

  group('StoredCart', () {
    const cart = StoredCart(
      lines: [
        StoredCartLine(productId: 'p1', quantity: 2),
        StoredCartLine(productId: 'p2', quantity: 1),
      ],
      fulfilment: FulfilmentMethod.pickup,
      promoCode: Cart.promoFresh5,
    );

    test('writes only named cart fields and round-trips', () {
      final map = cart.toMap();
      expectKeysWithin(map, {
        CartFields.lines,
        CartFields.fulfilment,
        CartFields.promoCode,
      });
      final line = (map[CartFields.lines] as List).first as Map;
      expect(line.keys.toSet(), {
        CartLineFields.productId,
        CartLineFields.quantity,
      });
      expect(StoredCart.fromMap(map), cart);
    });

    test('leaves the promo out when there is none', () {
      expect(
        const StoredCart().toMap().containsKey(CartFields.promoCode),
        isFalse,
      );
    });
  });

  group('Worker', () {
    final worker = Worker(
      id: 'w1',
      name: 'Daniel',
      email: 'd@example.com',
      phone: '012',
      role: WorkerRole.deliveryDriver,
      branchId: null,
      isActive: true,
      joinedAt: DateTime(2026),
    );

    test('writes only named user fields', () {
      expectKeysWithin(worker.toFirestore(), {
        UserFields.name,
        UserFields.email,
        UserFields.phone,
        UserFields.workerRole,
        UserFields.branchId,
        UserFields.isActive,
      });
    });

    test('round-trips, with joinedAt coming from the server time', () {
      final map = {
        ...worker.toFirestore(),
        UserFields.joinedAt: Timestamp.fromDate(worker.joinedAt),
      };
      expect(Worker.fromFirestore('w1', map), worker);
    });

    test('a driver is saved with a null branch so it is cleared on update', () {
      expect(worker.toFirestore()[UserFields.branchId], isNull);
      expect(worker.toFirestore().containsKey(UserFields.branchId), isTrue);
    });
  });

  group('OrderReview', () {
    const review = OrderReview(
      id: 'o1',
      orderNumber: 2301,
      branchId: 'ss15',
      customerId: 'u1',
      customerName: 'Aisha',
      shoppingScore: 5,
      productScore: 4,
      deliveryScore: 3,
      comment: 'Fast and fresh',
    );

    test('writes only the fields the create rule allows and round-trips', () {
      final map = review.toFirestore();
      expectKeysWithin(map, {
        ReviewFields.orderNumber,
        ReviewFields.branchId,
        ReviewFields.customerId,
        ReviewFields.customerName,
        ReviewFields.shoppingScore,
        ReviewFields.productScore,
        ReviewFields.deliveryScore,
        ReviewFields.comment,
      });
      expect(OrderReview.fromFirestore('o1', map), review);
    });

    test('leaves out a missing delivery score and an empty comment', () {
      final map = review
          .copyWith(deliveryScore: null, comment: '')
          .toFirestore();
      expect(map.containsKey(ReviewFields.deliveryScore), isFalse);
      expect(map.containsKey(ReviewFields.comment), isFalse);
    });

    test('is malformed without its scores', () {
      expect(
        () => OrderReview.fromFirestore('o1', {
          ReviewFields.orderNumber: 1,
          ReviewFields.branchId: 'ss15',
          ReviewFields.customerId: 'u1',
        }),
        throwsFormatException,
      );
    });

    test('averages the scores given', () {
      expect(review.averageScore, 4);
      expect(review.copyWith(deliveryScore: null).averageScore, 4.5);
    });
  });

  group('Admin product', () {
    const product = Product(
      id: 'p1',
      name: 'Fresh milk',
      brand: 'Farm',
      categoryId: 'dairy',
      packSize: '1L',
      description: 'Full cream',
      lowStockLevel: 6,
      photos: [ProductPhoto.stored('https://photos.test/a.jpg')],
    );

    test('writes only named product fields and round-trips', () {
      final map = product.toFirestore();
      expectKeysWithin(map, {
        ProductFields.name,
        ProductFields.brand,
        ProductFields.categoryId,
        ProductFields.packSize,
        ProductFields.description,
        ProductFields.imageUrls,
        ProductFields.lowStockLevel,
      });
      expect(Product.fromFirestore('p1', map), product);
    });

    test('writes only the photos that are already uploaded', () {
      final withPicked = product.copyWith(
        photos: [...product.photos, ProductPhoto.picked(Uint8List(2))],
      );
      expect(withPicked.toFirestore()[ProductFields.imageUrls], [
        'https://photos.test/a.jpg',
      ]);
    });

    test('a category round-trips and needs a name', () {
      const category = ProductCategory(id: 'c1', name: 'Dairy', sortOrder: 2);
      expect(
        ProductCategory.fromFirestore('c1', category.toFirestore()),
        category,
      );
      expect(
        () => ProductCategory.fromFirestore('c2', const {}),
        throwsFormatException,
      );
    });

    test('a branch row writes only the fields the inventory rule allows', () {
      const row = BranchStock(price: 8.9, stock: 4, isHidden: true);
      expect(row.toMap().keys.toSet(), {
        InventoryFields.price,
        InventoryFields.stock,
        InventoryFields.isHidden,
      });
      expect(BranchStock.fromMap(row.toMap()), row);
    });
  });

  group('Catalogue read models', () {
    test('CatalogueCategory reads and skips a nameless document', () {
      final category = CatalogueCategory.fromFirestore('c1', {
        CategoryFields.name: 'Dairy',
        CategoryFields.sortOrder: 2,
      });
      expect(
        category,
        const CatalogueCategory(id: 'c1', name: 'Dairy', sortOrder: 2),
      );
      expect(CatalogueCategory.fromFirestore('c2', const {}), isNull);
    });

    test('CatalogueProduct joins the product and inventory fields', () {
      final product = CatalogueProduct.fromFirestore(
        id: 'p1',
        product: {
          ProductFields.name: 'Milk',
          ProductFields.brand: 'Farm',
          ProductFields.categoryId: 'dairy',
          ProductFields.packSize: '1L',
          ProductFields.description: 'Fresh',
          ProductFields.imageUrls: ['https://img/a.png', '', 3],
        },
        inventory: {InventoryFields.price: 8, InventoryFields.stock: 4},
      );

      expect(product?.name, 'Milk');
      expect(product?.price, 8.0);
      expect(product?.stock, 4);
      expect(product?.imageUrls, ['https://img/a.png']);
    });
  });

  group('FieldReaders', () {
    test('plain readers fall back, required readers throw', () {
      const data = <String, dynamic>{'n': 'x'};
      expect(data.integer('n'), 0);
      expect(data.string('missing', fallback: 'none'), 'none');
      expect(() => data.requiredInteger('n'), throwsFormatException);
      expect(() => data.requiredString('missing'), throwsFormatException);
      expect(() => data.requiredLatLng('missing'), throwsFormatException);
    });

    test('maps keeps only map entries and strings keeps non-empty text', () {
      final data = <String, dynamic>{
        'maps': [
          {'a': 1},
          'junk',
        ],
        'strings': ['a', '', 2],
      };
      expect(data.maps('maps'), [
        {'a': 1},
      ]);
      expect(data.strings('strings'), ['a']);
    });
  });
}
