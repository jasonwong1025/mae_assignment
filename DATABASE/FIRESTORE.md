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
| `refs.groceryList(uid)` | `users/{uid}/groceryList/current` |
| `refs.wallet(uid)` / `refs.walletTransactions(uid)` | `users/{uid}/wallet/current` / `users/{uid}/walletTransactions` |
| `refs.notifications(uid)` / `refs.device(uid, token)` | `users/{uid}/notifications` / `users/{uid}/devices/{token}` |
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

### `users/{uid}/groceryList/current`

The customer's grocery list (the Grocery tab): things they plan to buy, typed
or scanned from a written list. One document so every change is atomic. Dart:
`GroceryItem`. Service: `GroceryListService`. Owner only. Only the words, the
quantity and an optional chosen product id are stored; which product an item
means, its price and its stock are worked out from the catalogue each time the
list is shown (`GroceryRow`), so a saved list never goes stale.

| Field | Type | Notes |
| --- | --- | --- |
| `items` | array of map | `{id: string, name: string, quantity: int, productId?: string}`, at most 100. |
| `updatedAt` | timestamp | Server time. |

Rules: only the document id `current`; keys limited to the two above;
`updatedAt == request.time`. An empty list deletes the document.

Scanning a written list is not stored anywhere: ML Kit's document scanner
takes the photo and ML Kit text recognition reads it, both on the phone
(`ListScanService`, Android only). `GroceryTextParser` turns the text into
items and `GroceryMatcher` matches an item to a catalogue product by word
(plurals, word beginnings and small typos allowed). The customer reviews what
was read before it joins the list, and what was matched before it goes to the
cart.

### `users/{uid}/wallet/current` and `users/{uid}/walletTransactions/{id}`

The Grocerly Wallet, which pays for orders. **It is simulated**: a balance and
a history in Firestore, with no payment provider behind it, and the screens
say so. Dart: `WalletEntry`. Service: `WalletService`. The owner can read both;
**nobody can write them from the app** (`allow write: if false`). Only the
Cloud Functions change them, so a modified app cannot give itself money.

| Field (`wallet/current`) | Type | Notes |
| --- | --- | --- |
| `balance` | number | Ringgit. Never taken below zero by the Functions (see "Insufficient balance" below). |
| `updatedAt` | timestamp | Server time. |

| Field (`walletTransactions/{id}`) | Type | Notes |
| --- | --- | --- |
| `type` | string | `topUp`, `payment`, `refund` or `adjustment`. |
| `amount` | number | Signed: positive adds money, negative takes it. |
| `balanceAfter` | number | The balance once this entry applied. |
| `description` | string | E.g. "Payment for order #1001". |
| `orderId` | string | Payments, refunds and adjustments only. |
| `createdAt` | timestamp | Server time. |

How money moves (all in `functions/src/`):

- `topUpWallet` (callable): RM 1 to RM 500 at a time, at most RM 2000 held.
- `placeOrder` takes the order total from the wallet in the same transaction
  that reserves the stock and creates the order, and refuses with a clear
  message when the balance is too low. The order records `walletPaid`.
- `settleOrderWallet` (trigger on `orders`): when packing finishes (`ready`) it
  settles shortages, refunding removed or cheaper items or charging a dearer
  replacement, then sets `walletSettled`. When an order is cancelled (by the
  customer or the admin) it refunds `walletPaid` and puts reserved stock back.
  Both steps are idempotent, so a retried trigger never pays twice.
- **Insufficient balance.** A refund is always paid. A charge for a dearer
  replacement never takes the wallet below zero: it is limited to the balance
  (a balance that is already negative counts as empty), and the rest is
  waived. The waived amount is stored on the order as `walletWaived`, the
  charged part as `walletPaid`, and the history entry says so. The store
  absorbs the waived amount; nothing is left as debt. To make this rare, the
  customer app compares the wallet with the extra cost before it lets the
  customer accept a dearer replacement, and offers a top up (removing the
  item stays possible). Cancelling afterwards refunds only what was paid.

### `users/{uid}/notifications/{id}` and `users/{uid}/devices/{token}`

Notifications reach people two ways: a **push** through Firebase Cloud
Messaging, and an entry in the user's **inbox** (the Notifications screen), so
nothing is lost when a push is missed or turned off.

- `notifyOrderChanges` (trigger on `orders`) writes both when: an order moves
  to packing, ready, out for delivery, completed or cancelled (to the
  customer); a replacement needs a reply (customer); a packer or driver is
  assigned (to that worker). The inbox document id is derived from the order
  and the event, so a retried trigger never notifies twice. A push that fails
  does not fail the order update.
- `notifications/{id}`: `title`, `body`, `orderId`, `read`, `createdAt`. The
  owner reads, marks read (only `read` can change) and deletes; only the
  Functions create.
- `devices/{token}`: the document id is the phone's FCM token; fields
  `platform` (`android`, `ios`, `web`) and `updatedAt` (server time). The app
  registers the phone after sign-in and removes it before sign-out, so the
  next person on a shared phone does not get the previous user's pushes.
  Phones whose token FCM rejects are removed by the Function.

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

One document per placed order: the single contract shared by the customer,
Store Worker and Store Admin apps. Dart: `Order`, `OrderItem`, `OrderEvent`,
`VerificationMethod` (all in `lib/shared/models/`). The customer app reads and
writes it through `OrderService`; Store Admin (`OrdersRepository`,
`DispatchRepository`, `SalesRepository`, `DashboardRepository`) and Store Worker
(`WorkerOrdersRepository`) read and update the same documents.

Every field belongs to one write group, and `firestore.rules` lets each role
write only its own group (`OrderFields.checkoutKeys`, `assignmentKeys`,
`fulfilmentKeys` mirror the lists in the rules):

| Group | Written by | When |
| --- | --- | --- |
| Checkout | Customer app | Once, when the order is created. Nobody changes it afterwards. |
| Assignment | Store Admin | Assigning a packer or driver, setting the due time. |
| Fulfilment | Store Worker | Packing, handover, delivery. |
| Shortage | Store Worker, then Customer | A packer reports an unavailable item; the customer answers. |

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
| `statusSince` | timestamp | Server time of the last status change. Written with `status` by whoever changes it. |
| `branchAddress` | string | Checkout. Where the bag is collected, shown to drivers. |

Assignment fields (Store Admin; all optional):

| Field | Type | Notes |
| --- | --- | --- |
| `dueAt` | timestamp | When the customer was promised the order. |
| `packerId`, `packerName`, `packerAssignedAt` | string, string, timestamp | A worker only sees a packing task when `packerId` is theirs. Store Admin assigns the packer from the order details (`OrdersRepository.assignPacker`). |
| `driverId`, `driverName`, `driverAssignedAt` | string, string, timestamp | Delivery orders only. |

Fulfilment fields (Store Worker; all optional):

| Field | Type | Notes |
| --- | --- | --- |
| `packedLineIds` | array of string | Line ids ticked off while packing. When the order is marked ready it also holds the ids of removed lines, so it has one id per line (the rules compare its size with `items`). |
| `packingStartedAt`, `readyAt` | timestamp | |
| `readyBy` | string | Worker id of the packer who marked it ready. |
| `pickupVerification` | string | `VerificationMethod` name: `qr` or `manual`. |
| `pickupCompletedBy`, `pickupCompletedByName` | string | Who handed a pickup order over. |
| `collectionVerification`, `collectionVerifiedBy`, `collectionVerifiedAt` | string, string, timestamp | The driver checking the bag. |
| `outForDeliveryAt` | timestamp | |
| `deliveredBy`, `deliveredByName` | string | |
| `proofPhotoUrl` | string | Download URL of the delivery photo, uploaded to Storage (`orders/{orderId}/proof.jpg`) by `DeliveryProofService` just before the order is completed. |
| `completedAt` | timestamp | Pickup or delivery done. |
| `walletPaid`, `walletSettled`, `walletWaived`, `walletRefundedAt`, `stockReserved`, `stockReleased` | number, bool, number, timestamp, bool, bool | Written only by the Cloud Functions (payment, refunds, stock). The app never writes them and the rules let no client change them. |
| `driverPosition`, `driverPositionAt` | geopoint, timestamp | Where the driver last was while the order is `outForDelivery`, and the server time of that fix. Written by the order's driver (`OrderService.updateDriverPosition`), so the customer, who may read only their own orders, can follow the delivery. The estimated arrival is not stored: `Order.etaAt` works it out. |

Shortage fields (see "Shortages" below):

| Field | Type | Notes |
| --- | --- | --- |
| `shortages` | map of lineId to map | One entry per unavailable line: `status` (`proposed`, `accepted`, `removed`), `replacement` (an `items`-shaped map with the same `lineId`, absent when none), `flaggedAt`, `decidedAt` (server times). |
| `shortageLineId` | string | The line this write is about. Only there so the rules know which `shortages` entry to check. Readers ignore it. |
| `openShortages` | int | Replacements waiting for the customer. Only there so the rules can see a count (they cannot count map entries); the app works the count out from `shortages`. |

Each `items` entry: `lineId` (unique in the order), `productId`, `name`,
`brand`, `packSize`, `quantity`, `unitPrice` (price at checkout), and
optional `categoryId`, `category` (name), `description` and `imageUrl`.

### Live delivery ETA

While a delivery is `outForDelivery`, the driver's delivery screen shares the
phone's GPS position (the `geolocator` package). A fix is saved when the
driver has moved 30 m or more and 10 s have passed, or after 30 s even if they
have not moved (`PositionThrottle`), in one batch that updates the order
(`driverPosition`, `driverPositionAt`) and `driverLocations/{driverId}` (the
admin's Dispatch map). Sharing stops when the screen is left or the delivery
is completed.

The customer's tracking page and the admin's order panel show "About 12m away,
arriving around 3:42pm" from `DeliveryEta`. It is an estimate: straight-line
distance times 1.3 for roads, at 25 km/h. No routing service is used (they are
third-party and rate-limited), so it is rough and wording says "about". A
position older than 2 minutes is flagged as possibly out of signal.

### Shortages

A packer who cannot find an item taps "Item unavailable?" on the packing
screen and either offers a replacement from the branch's stock or removes the
item.

- With a replacement the entry is `proposed`. The order cannot be marked ready
  while any entry is `proposed`. The customer sees the offer on the tracking
  page (and "Needs your reply" in the Orders list) and accepts it (`accepted`)
  or removes the item (`removed`). Nothing sends a push notification.
- With no replacement the entry is `removed` at once.
- The stored `subtotal`, `total` and `items` never change. `Order.effectiveItems`
  and `Order.adjustedTotal` work out what the customer pays after accepted
  replacements and removed items, so a refund or an extra amount is a
  difference of two numbers, never a stored value that could disagree with the
  items. Sales and the Dashboard use the adjusted values. Nothing moves money:
  there is no payment backend, so a refund is only shown.
- If the customer never answers, the order waits. Store Admin sees "Awaiting
  customer" in the order details and can cancel it (the only status change the
  admin can make).

Each write changes exactly one `shortages` entry, using a dotted field path
(`OrderService.flagShortage` / `respondToShortage`), together with
`shortageLineId` and, when it opens or closes a proposal, `openShortages`.

The admin timeline ("Packing started", "Driver Kumar assigned", ...) is not
stored: `Order.timeline` works it out from the timestamps above. The bag
label's `collectionCode` is also not stored. It is computed from the order id,
so it is a mock only and not secure; the real version needs a random code made
and checked on the server.

Queries and indexes (`firestore.indexes.json`): a branch's orders by
`branchId` + `placedAt` (admin board, Sales, packers), a driver's orders by
`driverId` + `placedAt`, a customer's by `customerId` + `placedAt`. Dispatch
reads every delivery that is `ready` or `outForDelivery` (`isDelivery` and
`status` equalities, no composite index needed). A worker's change is one
transaction (`OrderService.updateOrder`) that writes only the fields that
changed.

### Rules for orders

`WorkerOrderPolicy` (Flutter) decides what the worker screens offer;
`firestore.rules` enforces the same limits on the server, so a modified client
cannot do more. Staff checks also require the account to be active
(`users/{uid}.isActive` is not `false`), because a deactivated Store Worker
keeps a valid sign-in token for a while.

| Who | Read | Write |
| --- | --- | --- |
| Customer | Their own orders | Creates their own order (below); cancels it while `pending`, changing only `status` and `statusSince`. While `packing`, answers a `proposed` shortage: `accepted` or `removed`, with `decidedAt` the server time, `openShortages` down by one, and the replacement and `flaggedAt` unchanged. |
| Admin | Every order | Assignment fields. `status` and `statusSince` together, only to `cancelled` and only from an order that is not `completed` or `cancelled`. Nothing else. |
| Packing Staff | Orders of their own branch (`branchId` equals their profile's) | Only on an order assigned to them (`packerId` is their uid) at their branch: `pending` to `packing` (sets `packingStartedAt`); ticking `packedLineIds` while `packing`; `packing` to `ready` once every line is ticked or removed and `openShortages` is 0 (sets `readyAt`, `readyBy` to their uid); reporting one unticked line unavailable while `packing` (a new `shortages` entry: `proposed` with a well-formed `replacement` and `openShortages` up by one, or `removed` with none). Handing over a `ready` pickup order at their branch, whoever packed it: `ready` to `completed` (sets `pickupVerification`, `pickupCompletedBy` to their uid, `completedAt`). |
| Delivery Driver | Only deliveries assigned to them (`driverId` is their uid) | Only on those: while `outForDelivery`, report `driverPosition` and `driverPositionAt` (the server time) and nothing else; while `ready`, record the bag check (`collectionVerifiedBy` is their uid); `ready` to `outForDelivery` once they have checked it; `outForDelivery` to `completed` with `deliveredBy` their uid and a `proofPhotoUrl`. |

Every write fits one of those actions exactly (the set of changed fields is
checked), so nobody can change checkout fields, skip a status, cancel from the
worker app or reopen a finished order. Every workflow time (`statusSince`,
`packingStartedAt`, `readyAt`, `collectionVerifiedAt`, `outForDeliveryAt`,
`completedAt`) and the admin's `packerAssignedAt` / `driverAssignedAt` must equal
`request.time`: the app sends `FieldValue.serverTimestamp()` for them
(`OrderFields.serverTimeKeys`), so a phone's clock never reaches the database.

A new order must be `pending`, belong to the customer, hold only checkout fields
plus `status` and `statusSince`, have `placedAt` and `statusSince` equal to
`request.time`, 1 to 100 lines, non-negative money, a discount no larger than
the subtotal, and `total` equal to `subtotal + deliveryFee - discount` (within
one cent). The rules cannot check prices against the catalogue (a shortage's
replacement price is supplied by the packer's app too) or recompute the
subtotal from the lines (rules cannot loop), so the amounts are still supplied
by the customer's app. Making them trustworthy needs server code (a Cloud
Function that creates the order), which is planned for after the minimum
requirements.

Nobody deletes. Index: `customerId` ascending + `placedAt` descending
(`firestore.indexes.json`).

## `reviews/{orderId}`

A customer's rating of one completed order. The document id is the order id,
so an order can be rated once. Reviews are immutable. Dart: `OrderReview`.
Service: `ReviewService`. The Store Admin Reviews tab reads a branch's reviews
(`branchId` + `createdAt` index).

| Field | Type | Notes |
| --- | --- | --- |
| `orderNumber` | int | Required. Equals the order's `number`. |
| `branchId` | string | Required. Equals the order's `branchId`. |
| `customerId` | string | Required. The auth uid of the customer. |
| `customerName` | string | Required. |
| `shoppingScore` | int | Required, 1 to 5. |
| `productScore` | int | Required, 1 to 5. |
| `deliveryScore` | int | 1 to 5. Present **only** for delivery orders. |
| `driverId`, `driverName` | string | Delivery orders only: the order's driver, copied so the admin can rate drivers. The rules require them to equal the order's. |
| `comment` | string | Optional, at most 500 characters. |
| `createdAt` | timestamp | Server time. |

Rules: the owner and the admin read (a customer may also read a review that does not
exist yet, to find out whether they have rated); a customer creates a review for
their own order only once its status is `completed`, with exactly the fields
above and `createdAt == request.time`; no update, no delete.

## `driverLocations/{driverId}`

Where a delivery driver is now, for the Dispatch map. The document id is the
driver's uid. Service: `DriverLocationService`. A driver without a document is
shown as offline. The driver's delivery screen writes its own document, with
the server time, together with the order's `driverPosition` while a delivery is
on the road (see "Live delivery ETA"). The seed also has positions for the
drivers.

| Field | Type | Notes |
| --- | --- | --- |
| `position` | geopoint | Required. Last known position. |
| `updatedAt` | timestamp | Required. Server time. |

A driver's route is not stored: Dispatch works out the stop ahead from the
order (the branch for a `ready` order, the customer for one `outForDelivery`).

Rules: only the admin reads; only an active Delivery Driver (`workerRole` is
`deliveryDriver`) writes, and only their own document, with a map location and
`updatedAt == request.time`; no delete.

## `counters/{name}`

Monotonic counters, incremented in a transaction because a customer cannot read
other customers' orders. Service: `OrderService.nextOrderNumber`.

| Field | Type | Notes |
| --- | --- | --- |
| `value` | int | The last number issued. `counters/orders` starts at 1000, so the first order is 1001. |

Rules: any signed-in user reads; a write must keep only `value`, be an int, and
move forward by exactly 1 (the first value is 1001).

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
| `orders/{orderId}/proof.jpg` | The admin and the order's own driver read; only that driver writes | The delivery proof photo, an image under 5 MB. `DeliveryProofService` uploads it. |

The default bucket must exist before photos work: enable Storage once in the
Firebase console (this needs the Blaze plan), then run
`firebase deploy --only storage`.

## Demo data

Nothing in the apps is hardcoded. The demo data lives in `test_firebase/`:
`seed.mjs` with `seed-data/staff.json` (Store Workers and the driver positions),
`seed-data/orders.json` (orders in every state) and `seed-data/history.mjs`
(about 35 days of completed orders and reviews for Sales, Reviews and the
dashboard). The Store Admin and Store Worker tests load the same JSON files
(`test/helpers/seed_data.dart`), so tests and the real project agree. See the
header of `seed.mjs` for the options and the worker logins.

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
