// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Sale {

 int get orderNumber; String get branchId; DateTime get paidAt; bool get isDelivery;/// In ringgit. 0 for pickup orders.
 double get deliveryFee; List<SaleItem> get items;
/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleCopyWith<Sale> get copyWith => _$SaleCopyWithImpl<Sale>(this as Sale, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Sale;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sale&&(identical(other.orderNumber, _this.orderNumber) || other.orderNumber == _this.orderNumber)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.paidAt, _this.paidAt) || other.paidAt == _this.paidAt)&&(identical(other.isDelivery, _this.isDelivery) || other.isDelivery == _this.isDelivery)&&(identical(other.deliveryFee, _this.deliveryFee) || other.deliveryFee == _this.deliveryFee)&&const DeepCollectionEquality().equals(other.items, _this.items));
}


@override
int get hashCode {
  final _this = this as Sale;
  return Object.hash(runtimeType,_this.orderNumber,_this.branchId,_this.paidAt,_this.isDelivery,_this.deliveryFee,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as Sale;
  return 'Sale(orderNumber: ${_this.orderNumber}, branchId: ${_this.branchId}, paidAt: ${_this.paidAt}, isDelivery: ${_this.isDelivery}, deliveryFee: ${_this.deliveryFee}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $SaleCopyWith<$Res>  {
  factory $SaleCopyWith(Sale value, $Res Function(Sale) _then) = _$SaleCopyWithImpl;
@useResult
$Res call({
 int orderNumber, String branchId, DateTime paidAt, bool isDelivery, double deliveryFee, List<SaleItem> items
});




}
/// @nodoc
class _$SaleCopyWithImpl<$Res>
    implements $SaleCopyWith<$Res> {
  _$SaleCopyWithImpl(this._self, this._then);

  final Sale _self;
  final $Res Function(Sale) _then;

/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderNumber = null,Object? branchId = null,Object? paidAt = null,Object? isDelivery = null,Object? deliveryFee = null,Object? items = null,}) {
  return _then(Sale(
orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDelivery: null == isDelivery ? _self.isDelivery : isDelivery // ignore: cast_nullable_to_non_nullable
as bool,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SaleItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Sale].
extension SalePatterns on Sale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sale value)  $default,){
final _that = this;
switch (_that) {
case _Sale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sale value)?  $default,){
final _that = this;
switch (_that) {
case _Sale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int orderNumber,  String branchId,  DateTime paidAt,  bool isDelivery,  double deliveryFee,  List<SaleItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sale() when $default != null:
return $default(_that.orderNumber,_that.branchId,_that.paidAt,_that.isDelivery,_that.deliveryFee,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int orderNumber,  String branchId,  DateTime paidAt,  bool isDelivery,  double deliveryFee,  List<SaleItem> items)  $default,) {final _that = this;
switch (_that) {
case _Sale():
return $default(_that.orderNumber,_that.branchId,_that.paidAt,_that.isDelivery,_that.deliveryFee,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int orderNumber,  String branchId,  DateTime paidAt,  bool isDelivery,  double deliveryFee,  List<SaleItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Sale() when $default != null:
return $default(_that.orderNumber,_that.branchId,_that.paidAt,_that.isDelivery,_that.deliveryFee,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _Sale extends Sale {
  const _Sale({required this.orderNumber, required this.branchId, required this.paidAt, required this.isDelivery, required this.deliveryFee, required  List<SaleItem> items}): _items = items,super._();
  

@override final  int orderNumber;
@override final  String branchId;
@override final  DateTime paidAt;
@override final  bool isDelivery;
/// In ringgit. 0 for pickup orders.
@override final  double deliveryFee;
 final  List<SaleItem> _items;
@override List<SaleItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleCopyWith<_Sale> get copyWith => __$SaleCopyWithImpl<_Sale>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sale&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.isDelivery, isDelivery) || other.isDelivery == isDelivery)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&const DeepCollectionEquality().equals(other.items, _items));
}


@override
int get hashCode {
    return Object.hash(runtimeType,orderNumber,branchId,paidAt,isDelivery,deliveryFee,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'Sale(orderNumber: $orderNumber, branchId: $branchId, paidAt: $paidAt, isDelivery: $isDelivery, deliveryFee: $deliveryFee, items: $items)';
}


}

/// @nodoc
abstract mixin class _$SaleCopyWith<$Res> implements $SaleCopyWith<$Res> {
  factory _$SaleCopyWith(_Sale value, $Res Function(_Sale) _then) = __$SaleCopyWithImpl;
@override @useResult
$Res call({
 int orderNumber, String branchId, DateTime paidAt, bool isDelivery, double deliveryFee, List<SaleItem> items
});




}
/// @nodoc
class __$SaleCopyWithImpl<$Res>
    implements _$SaleCopyWith<$Res> {
  __$SaleCopyWithImpl(this._self, this._then);

  final _Sale _self;
  final $Res Function(_Sale) _then;

/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderNumber = null,Object? branchId = null,Object? paidAt = null,Object? isDelivery = null,Object? deliveryFee = null,Object? items = null,}) {
  return _then(_Sale(
orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDelivery: null == isDelivery ? _self.isDelivery : isDelivery // ignore: cast_nullable_to_non_nullable
as bool,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SaleItem>,
  ));
}


}

/// @nodoc
mixin _$SaleItem {

 String get productId; String get productName; String get categoryId; int get quantity;/// Price of one when it was sold, in ringgit.
 double get unitPrice;
/// Create a copy of SaleItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleItemCopyWith<SaleItem> get copyWith => _$SaleItemCopyWithImpl<SaleItem>(this as SaleItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SaleItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleItem&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice));
}


@override
int get hashCode {
  final _this = this as SaleItem;
  return Object.hash(runtimeType,_this.productId,_this.productName,_this.categoryId,_this.quantity,_this.unitPrice);
}

@override
String toString() {
  final _this = this as SaleItem;
  return 'SaleItem(productId: ${_this.productId}, productName: ${_this.productName}, categoryId: ${_this.categoryId}, quantity: ${_this.quantity}, unitPrice: ${_this.unitPrice})';
}


}

/// @nodoc
abstract mixin class $SaleItemCopyWith<$Res>  {
  factory $SaleItemCopyWith(SaleItem value, $Res Function(SaleItem) _then) = _$SaleItemCopyWithImpl;
@useResult
$Res call({
 String productId, String productName, String categoryId, int quantity, double unitPrice
});




}
/// @nodoc
class _$SaleItemCopyWithImpl<$Res>
    implements $SaleItemCopyWith<$Res> {
  _$SaleItemCopyWithImpl(this._self, this._then);

  final SaleItem _self;
  final $Res Function(SaleItem) _then;

/// Create a copy of SaleItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productName = null,Object? categoryId = null,Object? quantity = null,Object? unitPrice = null,}) {
  return _then(SaleItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleItem].
extension SaleItemPatterns on SaleItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleItem value)  $default,){
final _that = this;
switch (_that) {
case _SaleItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleItem value)?  $default,){
final _that = this;
switch (_that) {
case _SaleItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  String productName,  String categoryId,  int quantity,  double unitPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleItem() when $default != null:
return $default(_that.productId,_that.productName,_that.categoryId,_that.quantity,_that.unitPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  String productName,  String categoryId,  int quantity,  double unitPrice)  $default,) {final _that = this;
switch (_that) {
case _SaleItem():
return $default(_that.productId,_that.productName,_that.categoryId,_that.quantity,_that.unitPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  String productName,  String categoryId,  int quantity,  double unitPrice)?  $default,) {final _that = this;
switch (_that) {
case _SaleItem() when $default != null:
return $default(_that.productId,_that.productName,_that.categoryId,_that.quantity,_that.unitPrice);case _:
  return null;

}
}

}

/// @nodoc


class _SaleItem extends SaleItem {
  const _SaleItem({required this.productId, required this.productName, required this.categoryId, required this.quantity, required this.unitPrice}): super._();
  

@override final  String productId;
@override final  String productName;
@override final  String categoryId;
@override final  int quantity;
/// Price of one when it was sold, in ringgit.
@override final  double unitPrice;

/// Create a copy of SaleItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleItemCopyWith<_SaleItem> get copyWith => __$SaleItemCopyWithImpl<_SaleItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,productName,categoryId,quantity,unitPrice);
}

@override
String toString() {
    return 'SaleItem(productId: $productId, productName: $productName, categoryId: $categoryId, quantity: $quantity, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class _$SaleItemCopyWith<$Res> implements $SaleItemCopyWith<$Res> {
  factory _$SaleItemCopyWith(_SaleItem value, $Res Function(_SaleItem) _then) = __$SaleItemCopyWithImpl;
@override @useResult
$Res call({
 String productId, String productName, String categoryId, int quantity, double unitPrice
});




}
/// @nodoc
class __$SaleItemCopyWithImpl<$Res>
    implements _$SaleItemCopyWith<$Res> {
  __$SaleItemCopyWithImpl(this._self, this._then);

  final _SaleItem _self;
  final $Res Function(_SaleItem) _then;

/// Create a copy of SaleItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productName = null,Object? categoryId = null,Object? quantity = null,Object? unitPrice = null,}) {
  return _then(_SaleItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
