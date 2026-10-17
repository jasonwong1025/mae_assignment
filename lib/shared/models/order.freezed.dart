// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderItem {

/// Unique within the order and never reused, so the same product can
/// appear on two lines and the worker's packing checklist keys on it.
 String get lineId; String get productId; String get name; String get brand; String get packSize; int get quantity;/// Price of one at the order's branch, in ringgit, at checkout.
 double get unitPrice;/// Cover image URL, or null if the product has none.
 String? get imageUrl;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.lineId, _this.lineId) || other.lineId == _this.lineId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.packSize, _this.packSize) || other.packSize == _this.packSize)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl));
}


@override
int get hashCode {
  final _this = this as OrderItem;
  return Object.hash(runtimeType,_this.lineId,_this.productId,_this.name,_this.brand,_this.packSize,_this.quantity,_this.unitPrice,_this.imageUrl);
}

@override
String toString() {
  final _this = this as OrderItem;
  return 'OrderItem(lineId: ${_this.lineId}, productId: ${_this.productId}, name: ${_this.name}, brand: ${_this.brand}, packSize: ${_this.packSize}, quantity: ${_this.quantity}, unitPrice: ${_this.unitPrice}, imageUrl: ${_this.imageUrl})';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
 String lineId, String productId, String name, String brand, String packSize, int quantity, double unitPrice, String? imageUrl
});




}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineId = null,Object? productId = null,Object? name = null,Object? brand = null,Object? packSize = null,Object? quantity = null,Object? unitPrice = null,Object? imageUrl = freezed,}) {
  return _then(OrderItem(
lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,packSize: null == packSize ? _self.packSize : packSize // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lineId,  String productId,  String name,  String brand,  String packSize,  int quantity,  double unitPrice,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.lineId,_that.productId,_that.name,_that.brand,_that.packSize,_that.quantity,_that.unitPrice,_that.imageUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lineId,  String productId,  String name,  String brand,  String packSize,  int quantity,  double unitPrice,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.lineId,_that.productId,_that.name,_that.brand,_that.packSize,_that.quantity,_that.unitPrice,_that.imageUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lineId,  String productId,  String name,  String brand,  String packSize,  int quantity,  double unitPrice,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.lineId,_that.productId,_that.name,_that.brand,_that.packSize,_that.quantity,_that.unitPrice,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc


class _OrderItem extends OrderItem {
  const _OrderItem({required this.lineId, required this.productId, required this.name, required this.brand, required this.packSize, required this.quantity, required this.unitPrice, this.imageUrl}): super._();
  

/// Unique within the order and never reused, so the same product can
/// appear on two lines and the worker's packing checklist keys on it.
@override final  String lineId;
@override final  String productId;
@override final  String name;
@override final  String brand;
@override final  String packSize;
@override final  int quantity;
/// Price of one at the order's branch, in ringgit, at checkout.
@override final  double unitPrice;
/// Cover image URL, or null if the product has none.
@override final  String? imageUrl;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.lineId, lineId) || other.lineId == lineId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.packSize, packSize) || other.packSize == packSize)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lineId,productId,name,brand,packSize,quantity,unitPrice,imageUrl);
}

@override
String toString() {
    return 'OrderItem(lineId: $lineId, productId: $productId, name: $name, brand: $brand, packSize: $packSize, quantity: $quantity, unitPrice: $unitPrice, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
 String lineId, String productId, String name, String brand, String packSize, int quantity, double unitPrice, String? imageUrl
});




}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineId = null,Object? productId = null,Object? name = null,Object? brand = null,Object? packSize = null,Object? quantity = null,Object? unitPrice = null,Object? imageUrl = freezed,}) {
  return _then(_OrderItem(
lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,packSize: null == packSize ? _self.packSize : packSize // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Order {

 String get id; int get number; String get customerId; String get customerName; String get customerPhone; String get branchId; String get branchName; bool get isDelivery; List<OrderItem> get items; double get subtotal; double get deliveryFee; double get discount; double get total; OrderStatus get status;/// Delivery address as readable text. Null/empty for pickup.
 String? get address;/// Delivery location pin, so the driver can navigate and the fee can be
/// worked out by distance. Null for pickup.
 LatLng? get addressLocation;/// Message the customer left with the order.
 String? get customerNote;/// Applied promo code, uppercased, or null.
 String? get promoCode;/// Null until Firestore has saved the server time.
 DateTime? get placedAt; DateTime? get statusSince;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Order;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.customerPhone, _this.customerPhone) || other.customerPhone == _this.customerPhone)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.branchName, _this.branchName) || other.branchName == _this.branchName)&&(identical(other.isDelivery, _this.isDelivery) || other.isDelivery == _this.isDelivery)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.deliveryFee, _this.deliveryFee) || other.deliveryFee == _this.deliveryFee)&&(identical(other.discount, _this.discount) || other.discount == _this.discount)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.addressLocation, _this.addressLocation) || other.addressLocation == _this.addressLocation)&&(identical(other.customerNote, _this.customerNote) || other.customerNote == _this.customerNote)&&(identical(other.promoCode, _this.promoCode) || other.promoCode == _this.promoCode)&&(identical(other.placedAt, _this.placedAt) || other.placedAt == _this.placedAt)&&(identical(other.statusSince, _this.statusSince) || other.statusSince == _this.statusSince));
}


@override
int get hashCode {
  final _this = this as Order;
  return Object.hashAll([runtimeType,_this.id,_this.number,_this.customerId,_this.customerName,_this.customerPhone,_this.branchId,_this.branchName,_this.isDelivery,const DeepCollectionEquality().hash(_this.items),_this.subtotal,_this.deliveryFee,_this.discount,_this.total,_this.status,_this.address,_this.addressLocation,_this.customerNote,_this.promoCode,_this.placedAt,_this.statusSince]);
}

@override
String toString() {
  final _this = this as Order;
  return 'Order(id: ${_this.id}, number: ${_this.number}, customerId: ${_this.customerId}, customerName: ${_this.customerName}, customerPhone: ${_this.customerPhone}, branchId: ${_this.branchId}, branchName: ${_this.branchName}, isDelivery: ${_this.isDelivery}, items: ${_this.items}, subtotal: ${_this.subtotal}, deliveryFee: ${_this.deliveryFee}, discount: ${_this.discount}, total: ${_this.total}, status: ${_this.status}, address: ${_this.address}, addressLocation: ${_this.addressLocation}, customerNote: ${_this.customerNote}, promoCode: ${_this.promoCode}, placedAt: ${_this.placedAt}, statusSince: ${_this.statusSince})';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, int number, String customerId, String customerName, String customerPhone, String branchId, String branchName, bool isDelivery, List<OrderItem> items, double subtotal, double deliveryFee, double discount, double total, OrderStatus status, String? address, LatLng? addressLocation, String? customerNote, String? promoCode, DateTime? placedAt, DateTime? statusSince
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? customerId = null,Object? customerName = null,Object? customerPhone = null,Object? branchId = null,Object? branchName = null,Object? isDelivery = null,Object? items = null,Object? subtotal = null,Object? deliveryFee = null,Object? discount = null,Object? total = null,Object? status = null,Object? address = freezed,Object? addressLocation = freezed,Object? customerNote = freezed,Object? promoCode = freezed,Object? placedAt = freezed,Object? statusSince = freezed,}) {
  return _then(Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,isDelivery: null == isDelivery ? _self.isDelivery : isDelivery // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,addressLocation: freezed == addressLocation ? _self.addressLocation : addressLocation // ignore: cast_nullable_to_non_nullable
as LatLng?,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,promoCode: freezed == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String?,placedAt: freezed == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,statusSince: freezed == statusSince ? _self.statusSince : statusSince // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  String customerId,  String customerName,  String customerPhone,  String branchId,  String branchName,  bool isDelivery,  List<OrderItem> items,  double subtotal,  double deliveryFee,  double discount,  double total,  OrderStatus status,  String? address,  LatLng? addressLocation,  String? customerNote,  String? promoCode,  DateTime? placedAt,  DateTime? statusSince)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.number,_that.customerId,_that.customerName,_that.customerPhone,_that.branchId,_that.branchName,_that.isDelivery,_that.items,_that.subtotal,_that.deliveryFee,_that.discount,_that.total,_that.status,_that.address,_that.addressLocation,_that.customerNote,_that.promoCode,_that.placedAt,_that.statusSince);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  String customerId,  String customerName,  String customerPhone,  String branchId,  String branchName,  bool isDelivery,  List<OrderItem> items,  double subtotal,  double deliveryFee,  double discount,  double total,  OrderStatus status,  String? address,  LatLng? addressLocation,  String? customerNote,  String? promoCode,  DateTime? placedAt,  DateTime? statusSince)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.number,_that.customerId,_that.customerName,_that.customerPhone,_that.branchId,_that.branchName,_that.isDelivery,_that.items,_that.subtotal,_that.deliveryFee,_that.discount,_that.total,_that.status,_that.address,_that.addressLocation,_that.customerNote,_that.promoCode,_that.placedAt,_that.statusSince);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  String customerId,  String customerName,  String customerPhone,  String branchId,  String branchName,  bool isDelivery,  List<OrderItem> items,  double subtotal,  double deliveryFee,  double discount,  double total,  OrderStatus status,  String? address,  LatLng? addressLocation,  String? customerNote,  String? promoCode,  DateTime? placedAt,  DateTime? statusSince)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.number,_that.customerId,_that.customerName,_that.customerPhone,_that.branchId,_that.branchName,_that.isDelivery,_that.items,_that.subtotal,_that.deliveryFee,_that.discount,_that.total,_that.status,_that.address,_that.addressLocation,_that.customerNote,_that.promoCode,_that.placedAt,_that.statusSince);case _:
  return null;

}
}

}

/// @nodoc


class _Order extends Order {
  const _Order({required this.id, required this.number, required this.customerId, required this.customerName, required this.customerPhone, required this.branchId, required this.branchName, required this.isDelivery, required  List<OrderItem> items, required this.subtotal, required this.deliveryFee, required this.discount, required this.total, required this.status, this.address, this.addressLocation, this.customerNote, this.promoCode, this.placedAt, this.statusSince}): _items = items,super._();
  

@override final  String id;
@override final  int number;
@override final  String customerId;
@override final  String customerName;
@override final  String customerPhone;
@override final  String branchId;
@override final  String branchName;
@override final  bool isDelivery;
 final  List<OrderItem> _items;
@override List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  double subtotal;
@override final  double deliveryFee;
@override final  double discount;
@override final  double total;
@override final  OrderStatus status;
/// Delivery address as readable text. Null/empty for pickup.
@override final  String? address;
/// Delivery location pin, so the driver can navigate and the fee can be
/// worked out by distance. Null for pickup.
@override final  LatLng? addressLocation;
/// Message the customer left with the order.
@override final  String? customerNote;
/// Applied promo code, uppercased, or null.
@override final  String? promoCode;
/// Null until Firestore has saved the server time.
@override final  DateTime? placedAt;
@override final  DateTime? statusSince;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.isDelivery, isDelivery) || other.isDelivery == isDelivery)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.total, total) || other.total == total)&&(identical(other.status, status) || other.status == status)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressLocation, addressLocation) || other.addressLocation == addressLocation)&&(identical(other.customerNote, customerNote) || other.customerNote == customerNote)&&(identical(other.promoCode, promoCode) || other.promoCode == promoCode)&&(identical(other.placedAt, placedAt) || other.placedAt == placedAt)&&(identical(other.statusSince, statusSince) || other.statusSince == statusSince));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,number,customerId,customerName,customerPhone,branchId,branchName,isDelivery,const DeepCollectionEquality().hash(_items),subtotal,deliveryFee,discount,total,status,address,addressLocation,customerNote,promoCode,placedAt,statusSince]);
}

@override
String toString() {
    return 'Order(id: $id, number: $number, customerId: $customerId, customerName: $customerName, customerPhone: $customerPhone, branchId: $branchId, branchName: $branchName, isDelivery: $isDelivery, items: $items, subtotal: $subtotal, deliveryFee: $deliveryFee, discount: $discount, total: $total, status: $status, address: $address, addressLocation: $addressLocation, customerNote: $customerNote, promoCode: $promoCode, placedAt: $placedAt, statusSince: $statusSince)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, String customerId, String customerName, String customerPhone, String branchId, String branchName, bool isDelivery, List<OrderItem> items, double subtotal, double deliveryFee, double discount, double total, OrderStatus status, String? address, LatLng? addressLocation, String? customerNote, String? promoCode, DateTime? placedAt, DateTime? statusSince
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? customerId = null,Object? customerName = null,Object? customerPhone = null,Object? branchId = null,Object? branchName = null,Object? isDelivery = null,Object? items = null,Object? subtotal = null,Object? deliveryFee = null,Object? discount = null,Object? total = null,Object? status = null,Object? address = freezed,Object? addressLocation = freezed,Object? customerNote = freezed,Object? promoCode = freezed,Object? placedAt = freezed,Object? statusSince = freezed,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,isDelivery: null == isDelivery ? _self.isDelivery : isDelivery // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,addressLocation: freezed == addressLocation ? _self.addressLocation : addressLocation // ignore: cast_nullable_to_non_nullable
as LatLng?,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,promoCode: freezed == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String?,placedAt: freezed == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,statusSince: freezed == statusSince ? _self.statusSince : statusSince // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
