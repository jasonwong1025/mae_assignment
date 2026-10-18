# Firestore schema

The single reference for what is stored in Cloud Firestore (project
`mae-assignment-grocerly`), who may read and write it, and where the Dart code
that touches it lives. Keep it in step with the four things that also describe
the schema:

| Source of truth for | File |
| --- | --- |
| Collection names and field-name constants | `lib/core/firebase/firestore_paths.dart` |
| How every path is built | `lib/core/firebase/firestore_refs.dart` (`FirestoreRefs`) |
| Who may read/write and what shape is accepted | `firestore.rules` |
| Query indexes | `firestore.indexes.json` |

`tool/check_firestore_paths.dart` (run in CI) fails if a path is built anywhere
except `FirestoreRefs`, and `test/core/model_mapping_test.dart` fails if a model
writes a field that `firestore_paths.dart` does not name, or does not read back
what it writes.

## Path construction

All paths are built in `FirestoreRefs`; services call it and never chain
`.collection().doc()` themselves.

| Helper | Path |
| --- | --- |
| `refs.users` / `refs.user(uid)` | `users` / `users/{uid}` |
| `refs.addresses(uid)` / `refs.address(uid, id)` | `users/{uid}/addresses` / `users/{uid}/addresses/{id}` |
| `refs.cart(uid)` | `users/{uid}/cart/current` |
| `refs.products` / `refs.product(id)` | `products` / `products/{id}` |
| `refs.categories` | `categories` |
| `refs.branches` / `refs.branch(id)` | `branches` / `branches/{id}` |
| `refs.inventory(branchId)` | `branches/{branchId}/inventory` |
| `refs.orders` / `refs.order(id)` | `orders` / `orders/{id}` |
| `refs.reviews` / `refs.review(orderId)` | `reviews` / `reviews/{orderId}` |
| `refs.counter(name)` | `counters/{name}` |

## Conventions

- **Field names come from `firestore_paths.dart`.** Each model maps its
  fields by hand with those constants (`fromFirestore`/`toFirestore`, or
  `fromMap`/`toMap` for nested values), so the constants *are* the schema.
- **The document id is never a field.** Models carry it as `id` (`uid` for
  users); `toModel`/`toModels` pass it in when reading.
- **Server times** (`createdAt`, `placedAt`, `statusSince`, `joinedAt`,
  `updatedAt`) are written with `FieldValue.serverTimestamp()` by the service,
  never from the client clock, and read as `DateTime?`.
- **Optional values are left out**, not stored as `null`, when they have no
  value (left out of the map), unless the field must be cleared on update
  (a worker's `branchId`).
- **Map locations** are Firestore `GeoPoint`s (Dart `LatLng`).
- **Enums** are stored by name (`OrderStatus.packing` is `"packing"`).
- **Money** is a number in ringgit (`double`).
- **A malformed document is skipped**, not fatal, when reading a list
  (`toModels`); a model marks the fields a document cannot do without with the
  `required...` readers in `FieldReaders`, which throw.
- Reads use `FirestoreConfig.readTimeout` (15 s) so a screen never spins
  forever offline.

## `users/{uid}`

One profile per Firebase Authentication account. The document id is the auth
uid. Dart: `AppUser` (all roles), `Worker` (Store Worker projection). Service:
`UserService`, `StaffService`.

| Field | Type | Notes |
| --- | --- | --- |
| `name` | string | |
| `email` | string | Equals the auth email on sign-up. Never changed afterwards. |
| `phone` | string | |
| `role` | string | `customer`, `storeAdmin` or `storeWorker`. Unknown reads as `customer`. |
| `createdAt` | timestamp | Server time. |
| `isActive` | bool | Store Workers only. `false` blocks sign-in. |
| `workerRole` | string | Store Workers only: `packingStaff` or `deliveryDriver`. |
| `branchId` | string or null | Store Workers only. A packer's branch; `null` for drivers. |
| `joinedAt` | timestamp | Store Workers only. Server time the account was created. |

Rules: the owner and the admin read; sign-up may only create a `customer` with
exactly `name, email, phone, role, createdAt`; the admin creates and edits
Store Workers (not their email, `createdAt` or `joinedAt`); owners edit their
own details but never `role, email, createdAt, workerRole, branchId, isActive,
joinedAt`; nobody deletes.

### `users/{uid}/addresses/{addressId}`

A customer's saved delivery addresses. Dart: `CustomerAddress`. Service:
`AddressService`. Owner only (not even the admin).

| Field | Type | Notes |
| --- | --- | --- |
| `label` | string | Required. "Home", "Office"... |
| `line` | string | Required. Readable address. |
| `location` | geopoint | Required. Delivery pin. |
| `note` | string | Delivery note. Default `""`. |
| `isDefault` | bool | At most one `true`; the service flips them in one batch. |
| `createdAt` | timestamp | Server time; the list is newest first. |

### `users/{uid}/cart/current`

The customer's saved cart, one document so every change is atomic. Dart:
`StoredCart` (`Cart` is the in-memory form). Service: `CartService`. Owner
only. Only ids and quantities are stored; names, prices and stock are looked up
in the catalogue when the cart loads, so a saved cart never shows stale
prices.

| Field | Type | Notes |
| --- | --- | --- |
| `lines` | array of map | `{productId: string, quantity: int}`, at most 100. |
| `fulfilment` | string | `delivery` or `pickup`. |
| `promoCode` | string | Optional, uppercased. |
| `updatedAt` | timestamp | Server time. |

Rules: only the document id `current`; keys limited to the four above;
`updatedAt == request.time`. An empty cart deletes the document.

## `products/{productId}`

The shared catalogue, the same for every branch. Dart: `Product` (the admin's
editable model) and `CatalogueProduct` (the customer's read model, see below).
Services: `InventoryService` (admin) and `CatalogueService` (customer). Any
signed-in user reads; **only the admin writes**, from the Inventory tab.

| Field | Type | Notes |
| --- | --- | --- |
| `name` | string | Required. |
| `brand` | string | |
| `categoryId` | string | A `categories` document id. |
| `packSize` | string | "1L", "500g"... |
| `description` | string | Optional. |
| `imageUrls` | array of string | Firebase Storage download URLs, at most 5. First is the cover. |
| `lowStockLevel` | int | Optional. Stock at or below this is "Low" in the Inventory tab (the customer app ignores it). Reads as 10 when absent. |

Rules: the admin creates and updates a product with only the fields above, a
non-empty `name` (at most 120 characters) and a `categoryId`; nobody deletes.
The seed script writes products without `lowStockLevel`.

## `categories/{categoryId}`

Dart: `CatalogueCategory` (customer) and `ProductCategory` (admin). Any
signed-in user reads; the admin creates a category (a name and a sort order);
nobody deletes.

| Field | Type | Notes |
| --- | --- | --- |
| `name` | string | Required. |
| `sortOrder` | int | Lower first. Default `0`. |

## `branches/{branchId}`

Store locations. Dart: `Branch`, `DayHours`. Service: `BranchService`. Any
signed-in user reads; only the admin creates and edits; branches are closed,
never deleted.

| Field | Type | Notes |
| --- | --- | --- |
| `name`, `address`, `phone` | string | |
| `location` | geopoint | The store on the map. |
| `weeklyHours` | array of map | 7 entries, Monday first: `{opensAt, closesAt, isClosed}`, minutes after midnight. |
| `maxDeliveryKm` | number | Furthest delivery distance. |
| `baseDeliveryFee`, `feePerKm` | number | Fee = base + `ceil(km)` x per km. |
| `isTemporarilyClosed` | bool | Customers cannot order while `true`. |
| `createdAt` | timestamp | Server time; branches are listed oldest first. |

### `branches/{branchId}/inventory/{productId}`

Price and stock of a product at one branch; the document id is the product id.
Any signed-in user reads; **only the admin writes** (`price >= 0`, an int
`stock >= 0`, a bool `isHidden`, nothing else); nobody deletes. A product is only
sold at a branch that has a row here. The Inventory tab lists a product the
branch has no row for as hidden with no stock, so the admin can set it up, and
creating a product or a branch writes a row for every branch (stock 0 except where
the admin chose). Dart: `BranchStock`. Service: `InventoryService`.

| Field | Type | Notes |
| --- | --- | --- |
| `price` | number | Required. Ringgit. |
| `stock` | int | Required. |
| `isHidden` | bool | `true` hides it from customers at this branch. |

## `orders/{orderId}`

One document per placed order; the shared contract between the customer,
Store Worker and Store Admin apps. Dart: `Order`, `OrderItem` (the customer
side; the admin and worker apps still use sample-backed models). Service:
`OrderService`.

| Field | Type | Notes |
| --- | --- | --- |
| `number` | int | Required. Shown as "#2301". Comes from `counters/orders`. |
| `customerId` | string | Required. The auth uid of the customer. |
| `customerName`, `customerPhone` | string | |
| `branchId`, `branchName` | string | |
| `isDelivery` | bool | `false` is self-pickup. |
| `address` | string | Delivery only. |
| `addressLocation` | geopoint | Delivery only. |
| `customerNote` | string | Optional. |
| `items` | array of map | See below. |
| `promoCode` | string | Optional, uppercased. |
| `subtotal`, `deliveryFee`, `discount`, `total` | number | Captured at checkout so totals never drift. |
| `status` | string | `pending`, `packing`, `ready`, `outForDelivery`, `completed`, `cancelled`. |
| `placedAt` | timestamp | Server time. |
| `statusSince` | timestamp | Server time of the last status change. |

Each `items` entry: `lineId` (unique in the order), `productId`, `name`,
`brand`, `packSize`, `quantity`, `unitPrice` (price at checkout), and an
optional `imageUrl`.

Rules: the owner reads their orders and staff read all; a customer creates only
their own order, starting `pending`, with `number, customerId, branchId, items,
total, status, placedAt` and `placedAt == request.time`; staff update (advance
status); **a customer may cancel their own order only while it is `pending`**,
changing nothing but `status` (to `cancelled`) and `statusSince`
(`== request.time`), which `OrderService.cancelOrder` does in a transaction;
nobody deletes. Index: `customerId` ascending + `placedAt` descending
(`firestore.indexes.json`).

## `reviews/{orderId}`

A customer's rating of one completed order. The document id is the order id,
so an order can be rated once. Reviews are immutable. Dart: `OrderReview`.
Service: `ReviewService`. This is the contract the Store Admin Reviews tab will
read when it is connected (driver attribution comes from the order).

| Field | Type | Notes |
| --- | --- | --- |
| `orderNumber` | int | Required. Equals the order's `number`. |
| `branchId` | string | Required. Equals the order's `branchId`. |
| `customerId` | string | Required. The auth uid of the customer. |
| `customerName` | string | Required. |
| `shoppingScore` | int | Required, 1 to 5. |
| `productScore` | int | Required, 1 to 5. |
| `deliveryScore` | int | 1 to 5. Present **only** for delivery orders. |
| `comment` | string | Optional, at most 500 characters. |
| `createdAt` | timestamp | Server time. |

Rules: the owner and staff read (a customer may also read a review that does not
exist yet, to find out whether they have rated); a customer creates a review for
their own order only once its status is `completed`, with exactly the fields
above and `createdAt == request.time`; no update, no delete.

## `counters/{name}`

Monotonic counters, incremented in a transaction because a customer cannot read
other customers' orders. Service: `OrderService.nextOrderNumber`.

| Field | Type | Notes |
| --- | --- | --- |
| `value` | int | The last number issued. `counters/orders` starts at 1000, so the first order is 1001. |

Rules: any signed-in user reads; a write must keep only `value`, be an int, and
only increase.

## Read models (not stored as such)

`CatalogueProduct` is built from two documents, `products/{id}` and
`branches/{branchId}/inventory/{id}`, by `CatalogueProduct.fromFirestore`. It
is never written back. `Cart` is the in-memory cart; `StoredCart` is what is
saved.

## Firebase Storage

Product photos live in Storage, not Firestore; a product keeps only their
download URLs in `imageUrls`. Rules are in `storage.rules` (tested in
`test_firebase/storage.rules.test.js`); paths are built in
`lib/core/firebase/storage_paths.dart`.

| Path | Who | Notes |
| --- | --- | --- |
| `products/{productId}/{fileName}` | Any signed-in user reads; only the admin uploads or deletes | An image under 5 MB. `ProductPhotoService` names files by time, so a photo is never overwritten. |

The default bucket must exist before photos work: enable Storage once in the
Firebase console (this needs the Blaze plan), then run
`firebase deploy --only storage`.

## Not stored yet

The Store Admin and Store Worker screens for dispatch, drivers, reviews, sales,
dashboard, orders, packing and delivery still run on sample data (`sample_*.dart`,
`mock_*.dart`). When one is connected, add its collection here first, then
follow the checklist below.

## Adding or changing a collection

1. Add the collection name to `FirestoreCollections` and field names to a
   `*Fields` class in `firestore_paths.dart`.
2. Add the path helper to `FirestoreRefs`.
3. Write or change the model (Freezed with hand-written mapping, see the README "Code
   conventions") and generate the feature with the Mason brick.
4. Update `firestore.rules` **and** its test in `test_firebase/`.
5. Add an index to `firestore.indexes.json` if a query needs one.
6. Update this file.
7. Deploy when rules or indexes changed:
   `firebase deploy --only firestore:rules,firestore:indexes`.
