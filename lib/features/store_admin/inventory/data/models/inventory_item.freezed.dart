// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InventoryItem {

 Product get product; String get branchId;/// Price at this branch, in ringgit.
 double get price;/// Stock at this branch.
 int get stock;/// True if hidden from customers at this branch.
 bool get isHidden;
/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryItemCopyWith<InventoryItem> get copyWith => _$InventoryItemCopyWithImpl<InventoryItem>(this as InventoryItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryItem&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.stock, _this.stock) || other.stock == _this.stock)&&(identical(other.isHidden, _this.isHidden) || other.isHidden == _this.isHidden));
}


@override
int get hashCode {
  final _this = this as InventoryItem;
  return Object.hash(runtimeType,_this.product,_this.branchId,_this.price,_this.stock,_this.isHidden);
}

@override
String toString() {
  final _this = this as InventoryItem;
  return 'InventoryItem(product: ${_this.product}, branchId: ${_this.branchId}, price: ${_this.price}, stock: ${_this.stock}, isHidden: ${_this.isHidden})';
}


}

/// @nodoc
abstract mixin class $InventoryItemCopyWith<$Res>  {
  factory $InventoryItemCopyWith(InventoryItem value, $Res Function(InventoryItem) _then) = _$InventoryItemCopyWithImpl;
@useResult
$Res call({
 Product product, String branchId, double price, int stock, bool isHidden
});


$ProductCopyWith<$Res> get product;

}
/// @nodoc
class _$InventoryItemCopyWithImpl<$Res>
    implements $InventoryItemCopyWith<$Res> {
  _$InventoryItemCopyWithImpl(this._self, this._then);

  final InventoryItem _self;
  final $Res Function(InventoryItem) _then;

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = null,Object? branchId = null,Object? price = null,Object? stock = null,Object? isHidden = null,}) {
  return _then(InventoryItem(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [InventoryItem].
extension InventoryItemPatterns on InventoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryItem value)  $default,){
final _that = this;
switch (_that) {
case _InventoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Product product,  String branchId,  double price,  int stock,  bool isHidden)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryItem() when $default != null:
return $default(_that.product,_that.branchId,_that.price,_that.stock,_that.isHidden);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Product product,  String branchId,  double price,  int stock,  bool isHidden)  $default,) {final _that = this;
switch (_that) {
case _InventoryItem():
return $default(_that.product,_that.branchId,_that.price,_that.stock,_that.isHidden);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Product product,  String branchId,  double price,  int stock,  bool isHidden)?  $default,) {final _that = this;
switch (_that) {
case _InventoryItem() when $default != null:
return $default(_that.product,_that.branchId,_that.price,_that.stock,_that.isHidden);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryItem extends InventoryItem {
  const _InventoryItem({required this.product, required this.branchId, required this.price, required this.stock, required this.isHidden}): super._();
  

@override final  Product product;
@override final  String branchId;
/// Price at this branch, in ringgit.
@override final  double price;
/// Stock at this branch.
@override final  int stock;
/// True if hidden from customers at this branch.
@override final  bool isHidden;

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryItemCopyWith<_InventoryItem> get copyWith => __$InventoryItemCopyWithImpl<_InventoryItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryItem&&(identical(other.product, product) || other.product == product)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.price, price) || other.price == price)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden));
}


@override
int get hashCode {
    return Object.hash(runtimeType,product,branchId,price,stock,isHidden);
}

@override
String toString() {
    return 'InventoryItem(product: $product, branchId: $branchId, price: $price, stock: $stock, isHidden: $isHidden)';
}


}

/// @nodoc
abstract mixin class _$InventoryItemCopyWith<$Res> implements $InventoryItemCopyWith<$Res> {
  factory _$InventoryItemCopyWith(_InventoryItem value, $Res Function(_InventoryItem) _then) = __$InventoryItemCopyWithImpl;
@override @useResult
$Res call({
 Product product, String branchId, double price, int stock, bool isHidden
});


@override $ProductCopyWith<$Res> get product;

}
/// @nodoc
class __$InventoryItemCopyWithImpl<$Res>
    implements _$InventoryItemCopyWith<$Res> {
  __$InventoryItemCopyWithImpl(this._self, this._then);

  final _InventoryItem _self;
  final $Res Function(_InventoryItem) _then;

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = null,Object? branchId = null,Object? price = null,Object? stock = null,Object? isHidden = null,}) {
  return _then(_InventoryItem(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}

// dart format on
