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
mixin _$Order {

 int get number; String get customerName; String get customerPhone; OrderStatus get status;/// When the order entered its current status.
 DateTime get statusSince;/// Delivery/Pickup order
 bool get isDelivery; List<OrderItem> get items;/// Delivery fee
 double get deliveryFee;/// What has happened to the order so far, oldest first
 List<OrderEvent> get timeline;/// Address of the customer
 String? get address;/// Where the address is on the map. Delivery orders only.
 LatLng? get location;/// Message the customer left with the order
 String? get customerNote;/// Staff member packing or delivering the order
 String? get assignedWorker;/// Id of the driver delivering it. Null until a driver is assigned.
 String? get driverId;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Order;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.customerPhone, _this.customerPhone) || other.customerPhone == _this.customerPhone)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.statusSince, _this.statusSince) || other.statusSince == _this.statusSince)&&(identical(other.isDelivery, _this.isDelivery) || other.isDelivery == _this.isDelivery)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.deliveryFee, _this.deliveryFee) || other.deliveryFee == _this.deliveryFee)&&const DeepCollectionEquality().equals(other.timeline, _this.timeline)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.customerNote, _this.customerNote) || other.customerNote == _this.customerNote)&&(identical(other.assignedWorker, _this.assignedWorker) || other.assignedWorker == _this.assignedWorker)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId));
}


@override
int get hashCode {
  final _this = this as Order;
  return Object.hash(runtimeType,_this.number,_this.customerName,_this.customerPhone,_this.status,_this.statusSince,_this.isDelivery,const DeepCollectionEquality().hash(_this.items),_this.deliveryFee,const DeepCollectionEquality().hash(_this.timeline),_this.address,_this.location,_this.customerNote,_this.assignedWorker,_this.driverId);
}

@override
String toString() {
  final _this = this as Order;
  return 'Order(number: ${_this.number}, customerName: ${_this.customerName}, customerPhone: ${_this.customerPhone}, status: ${_this.status}, statusSince: ${_this.statusSince}, isDelivery: ${_this.isDelivery}, items: ${_this.items}, deliveryFee: ${_this.deliveryFee}, timeline: ${_this.timeline}, address: ${_this.address}, location: ${_this.location}, customerNote: ${_this.customerNote}, assignedWorker: ${_this.assignedWorker}, driverId: ${_this.driverId})';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 int number, String customerName, String customerPhone, OrderStatus status, DateTime statusSince, bool isDelivery, List<OrderItem> items, double deliveryFee, List<OrderEvent> timeline, String? address, LatLng? location, String? customerNote, String? assignedWorker, String? driverId
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
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? customerName = null,Object? customerPhone = null,Object? status = null,Object? statusSince = null,Object? isDelivery = null,Object? items = null,Object? deliveryFee = null,Object? timeline = null,Object? address = freezed,Object? location = freezed,Object? customerNote = freezed,Object? assignedWorker = freezed,Object? driverId = freezed,}) {
  return _then(Order(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,statusSince: null == statusSince ? _self.statusSince : statusSince // ignore: cast_nullable_to_non_nullable
as DateTime,isDelivery: null == isDelivery ? _self.isDelivery : isDelivery // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<OrderEvent>,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,assignedWorker: freezed == assignedWorker ? _self.assignedWorker : assignedWorker // ignore: cast_nullable_to_non_nullable
as String?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  String customerName,  String customerPhone,  OrderStatus status,  DateTime statusSince,  bool isDelivery,  List<OrderItem> items,  double deliveryFee,  List<OrderEvent> timeline,  String? address,  LatLng? location,  String? customerNote,  String? assignedWorker,  String? driverId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.number,_that.customerName,_that.customerPhone,_that.status,_that.statusSince,_that.isDelivery,_that.items,_that.deliveryFee,_that.timeline,_that.address,_that.location,_that.customerNote,_that.assignedWorker,_that.driverId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  String customerName,  String customerPhone,  OrderStatus status,  DateTime statusSince,  bool isDelivery,  List<OrderItem> items,  double deliveryFee,  List<OrderEvent> timeline,  String? address,  LatLng? location,  String? customerNote,  String? assignedWorker,  String? driverId)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.number,_that.customerName,_that.customerPhone,_that.status,_that.statusSince,_that.isDelivery,_that.items,_that.deliveryFee,_that.timeline,_that.address,_that.location,_that.customerNote,_that.assignedWorker,_that.driverId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  String customerName,  String customerPhone,  OrderStatus status,  DateTime statusSince,  bool isDelivery,  List<OrderItem> items,  double deliveryFee,  List<OrderEvent> timeline,  String? address,  LatLng? location,  String? customerNote,  String? assignedWorker,  String? driverId)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.number,_that.customerName,_that.customerPhone,_that.status,_that.statusSince,_that.isDelivery,_that.items,_that.deliveryFee,_that.timeline,_that.address,_that.location,_that.customerNote,_that.assignedWorker,_that.driverId);case _:
  return null;

}
}

}

/// @nodoc


class _Order extends Order {
  const _Order({required this.number, required this.customerName, required this.customerPhone, required this.status, required this.statusSince, required this.isDelivery, required  List<OrderItem> items, required this.deliveryFee, required  List<OrderEvent> timeline, this.address, this.location, this.customerNote, this.assignedWorker, this.driverId}): _items = items,_timeline = timeline,super._();
  

@override final  int number;
@override final  String customerName;
@override final  String customerPhone;
@override final  OrderStatus status;
/// When the order entered its current status.
@override final  DateTime statusSince;
/// Delivery/Pickup order
@override final  bool isDelivery;
 final  List<OrderItem> _items;
@override List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// Delivery fee
@override final  double deliveryFee;
/// What has happened to the order so far, oldest first
 final  List<OrderEvent> _timeline;
/// What has happened to the order so far, oldest first
@override List<OrderEvent> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}

/// Address of the customer
@override final  String? address;
/// Where the address is on the map. Delivery orders only.
@override final  LatLng? location;
/// Message the customer left with the order
@override final  String? customerNote;
/// Staff member packing or delivering the order
@override final  String? assignedWorker;
/// Id of the driver delivering it. Null until a driver is assigned.
@override final  String? driverId;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.number, number) || other.number == number)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusSince, statusSince) || other.statusSince == statusSince)&&(identical(other.isDelivery, isDelivery) || other.isDelivery == isDelivery)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&const DeepCollectionEquality().equals(other.timeline, _timeline)&&(identical(other.address, address) || other.address == address)&&(identical(other.location, location) || other.location == location)&&(identical(other.customerNote, customerNote) || other.customerNote == customerNote)&&(identical(other.assignedWorker, assignedWorker) || other.assignedWorker == assignedWorker)&&(identical(other.driverId, driverId) || other.driverId == driverId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,number,customerName,customerPhone,status,statusSince,isDelivery,const DeepCollectionEquality().hash(_items),deliveryFee,const DeepCollectionEquality().hash(_timeline),address,location,customerNote,assignedWorker,driverId);
}

@override
String toString() {
    return 'Order(number: $number, customerName: $customerName, customerPhone: $customerPhone, status: $status, statusSince: $statusSince, isDelivery: $isDelivery, items: $items, deliveryFee: $deliveryFee, timeline: $timeline, address: $address, location: $location, customerNote: $customerNote, assignedWorker: $assignedWorker, driverId: $driverId)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 int number, String customerName, String customerPhone, OrderStatus status, DateTime statusSince, bool isDelivery, List<OrderItem> items, double deliveryFee, List<OrderEvent> timeline, String? address, LatLng? location, String? customerNote, String? assignedWorker, String? driverId
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
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? customerName = null,Object? customerPhone = null,Object? status = null,Object? statusSince = null,Object? isDelivery = null,Object? items = null,Object? deliveryFee = null,Object? timeline = null,Object? address = freezed,Object? location = freezed,Object? customerNote = freezed,Object? assignedWorker = freezed,Object? driverId = freezed,}) {
  return _then(_Order(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,statusSince: null == statusSince ? _self.statusSince : statusSince // ignore: cast_nullable_to_non_nullable
as DateTime,isDelivery: null == isDelivery ? _self.isDelivery : isDelivery // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<OrderEvent>,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,assignedWorker: freezed == assignedWorker ? _self.assignedWorker : assignedWorker // ignore: cast_nullable_to_non_nullable
as String?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$OrderItem {

 String get name; int get quantity;/// Price of one, in ringgit.
 double get unitPrice;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice));
}


@override
int get hashCode {
  final _this = this as OrderItem;
  return Object.hash(runtimeType,_this.name,_this.quantity,_this.unitPrice);
}

@override
String toString() {
  final _this = this as OrderItem;
  return 'OrderItem(name: ${_this.name}, quantity: ${_this.quantity}, unitPrice: ${_this.unitPrice})';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
 String name, int quantity, double unitPrice
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? quantity = null,Object? unitPrice = null,}) {
  return _then(OrderItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int quantity,  double unitPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.name,_that.quantity,_that.unitPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int quantity,  double unitPrice)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.name,_that.quantity,_that.unitPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int quantity,  double unitPrice)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.name,_that.quantity,_that.unitPrice);case _:
  return null;

}
}

}

/// @nodoc


class _OrderItem extends OrderItem {
  const _OrderItem({required this.name, required this.quantity, required this.unitPrice}): super._();
  

@override final  String name;
@override final  int quantity;
/// Price of one, in ringgit.
@override final  double unitPrice;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,quantity,unitPrice);
}

@override
String toString() {
    return 'OrderItem(name: $name, quantity: $quantity, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
 String name, int quantity, double unitPrice
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? quantity = null,Object? unitPrice = null,}) {
  return _then(_OrderItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$OrderEvent {

 String get title; DateTime get time;/// Staff member who did it. Null for things the customer did.
 String? get by;
/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderEventCopyWith<OrderEvent> get copyWith => _$OrderEventCopyWithImpl<OrderEvent>(this as OrderEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderEvent&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.by, _this.by) || other.by == _this.by));
}


@override
int get hashCode {
  final _this = this as OrderEvent;
  return Object.hash(runtimeType,_this.title,_this.time,_this.by);
}

@override
String toString() {
  final _this = this as OrderEvent;
  return 'OrderEvent(title: ${_this.title}, time: ${_this.time}, by: ${_this.by})';
}


}

/// @nodoc
abstract mixin class $OrderEventCopyWith<$Res>  {
  factory $OrderEventCopyWith(OrderEvent value, $Res Function(OrderEvent) _then) = _$OrderEventCopyWithImpl;
@useResult
$Res call({
 String title, DateTime time, String? by
});




}
/// @nodoc
class _$OrderEventCopyWithImpl<$Res>
    implements $OrderEventCopyWith<$Res> {
  _$OrderEventCopyWithImpl(this._self, this._then);

  final OrderEvent _self;
  final $Res Function(OrderEvent) _then;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? time = null,Object? by = freezed,}) {
  return _then(OrderEvent(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,by: freezed == by ? _self.by : by // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderEvent].
extension OrderEventPatterns on OrderEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderEvent value)  $default,){
final _that = this;
switch (_that) {
case _OrderEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderEvent value)?  $default,){
final _that = this;
switch (_that) {
case _OrderEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  DateTime time,  String? by)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderEvent() when $default != null:
return $default(_that.title,_that.time,_that.by);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  DateTime time,  String? by)  $default,) {final _that = this;
switch (_that) {
case _OrderEvent():
return $default(_that.title,_that.time,_that.by);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  DateTime time,  String? by)?  $default,) {final _that = this;
switch (_that) {
case _OrderEvent() when $default != null:
return $default(_that.title,_that.time,_that.by);case _:
  return null;

}
}

}

/// @nodoc


class _OrderEvent extends OrderEvent {
  const _OrderEvent({required this.title, required this.time, this.by}): super._();
  

@override final  String title;
@override final  DateTime time;
/// Staff member who did it. Null for things the customer did.
@override final  String? by;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderEventCopyWith<_OrderEvent> get copyWith => __$OrderEventCopyWithImpl<_OrderEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderEvent&&(identical(other.title, title) || other.title == title)&&(identical(other.time, time) || other.time == time)&&(identical(other.by, by) || other.by == by));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,time,by);
}

@override
String toString() {
    return 'OrderEvent(title: $title, time: $time, by: $by)';
}


}

/// @nodoc
abstract mixin class _$OrderEventCopyWith<$Res> implements $OrderEventCopyWith<$Res> {
  factory _$OrderEventCopyWith(_OrderEvent value, $Res Function(_OrderEvent) _then) = __$OrderEventCopyWithImpl;
@override @useResult
$Res call({
 String title, DateTime time, String? by
});




}
/// @nodoc
class __$OrderEventCopyWithImpl<$Res>
    implements _$OrderEventCopyWith<$Res> {
  __$OrderEventCopyWithImpl(this._self, this._then);

  final _OrderEvent _self;
  final $Res Function(_OrderEvent) _then;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? time = null,Object? by = freezed,}) {
  return _then(_OrderEvent(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,by: freezed == by ? _self.by : by // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
