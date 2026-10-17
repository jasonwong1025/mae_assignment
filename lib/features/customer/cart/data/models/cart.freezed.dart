// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CartLine {

 CatalogueProduct get product; int get quantity;
/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartLineCopyWith<CartLine> get copyWith => _$CartLineCopyWithImpl<CartLine>(this as CartLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CartLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartLine&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity));
}


@override
int get hashCode {
  final _this = this as CartLine;
  return Object.hash(runtimeType,_this.product,_this.quantity);
}

@override
String toString() {
  final _this = this as CartLine;
  return 'CartLine(product: ${_this.product}, quantity: ${_this.quantity})';
}


}

/// @nodoc
abstract mixin class $CartLineCopyWith<$Res>  {
  factory $CartLineCopyWith(CartLine value, $Res Function(CartLine) _then) = _$CartLineCopyWithImpl;
@useResult
$Res call({
 CatalogueProduct product, int quantity
});


$CatalogueProductCopyWith<$Res> get product;

}
/// @nodoc
class _$CartLineCopyWithImpl<$Res>
    implements $CartLineCopyWith<$Res> {
  _$CartLineCopyWithImpl(this._self, this._then);

  final CartLine _self;
  final $Res Function(CartLine) _then;

/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? product = null,Object? quantity = null,}) {
  return _then(CartLine(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as CatalogueProduct,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CatalogueProductCopyWith<$Res> get product {
  
  return $CatalogueProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [CartLine].
extension CartLinePatterns on CartLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartLine value)  $default,){
final _that = this;
switch (_that) {
case _CartLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartLine value)?  $default,){
final _that = this;
switch (_that) {
case _CartLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CatalogueProduct product,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartLine() when $default != null:
return $default(_that.product,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CatalogueProduct product,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _CartLine():
return $default(_that.product,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CatalogueProduct product,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _CartLine() when $default != null:
return $default(_that.product,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc


class _CartLine extends CartLine {
  const _CartLine({required this.product, required this.quantity}): super._();
  

@override final  CatalogueProduct product;
@override final  int quantity;

/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartLineCopyWith<_CartLine> get copyWith => __$CartLineCopyWithImpl<_CartLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartLine&&(identical(other.product, product) || other.product == product)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,product,quantity);
}

@override
String toString() {
    return 'CartLine(product: $product, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$CartLineCopyWith<$Res> implements $CartLineCopyWith<$Res> {
  factory _$CartLineCopyWith(_CartLine value, $Res Function(_CartLine) _then) = __$CartLineCopyWithImpl;
@override @useResult
$Res call({
 CatalogueProduct product, int quantity
});


@override $CatalogueProductCopyWith<$Res> get product;

}
/// @nodoc
class __$CartLineCopyWithImpl<$Res>
    implements _$CartLineCopyWith<$Res> {
  __$CartLineCopyWithImpl(this._self, this._then);

  final _CartLine _self;
  final $Res Function(_CartLine) _then;

/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? product = null,Object? quantity = null,}) {
  return _then(_CartLine(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as CatalogueProduct,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of CartLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CatalogueProductCopyWith<$Res> get product {
  
  return $CatalogueProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}

/// @nodoc
mixin _$Cart {

 List<CartLine> get lines; FulfilmentMethod get fulfilment;/// Applied promo code, uppercased, or null if none.
 String? get promoCode;
/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartCopyWith<Cart> get copyWith => _$CartCopyWithImpl<Cart>(this as Cart, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Cart;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cart&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.fulfilment, _this.fulfilment) || other.fulfilment == _this.fulfilment)&&(identical(other.promoCode, _this.promoCode) || other.promoCode == _this.promoCode));
}


@override
int get hashCode {
  final _this = this as Cart;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.lines),_this.fulfilment,_this.promoCode);
}

@override
String toString() {
  final _this = this as Cart;
  return 'Cart(lines: ${_this.lines}, fulfilment: ${_this.fulfilment}, promoCode: ${_this.promoCode})';
}


}

/// @nodoc
abstract mixin class $CartCopyWith<$Res>  {
  factory $CartCopyWith(Cart value, $Res Function(Cart) _then) = _$CartCopyWithImpl;
@useResult
$Res call({
 List<CartLine> lines, FulfilmentMethod fulfilment, String? promoCode
});




}
/// @nodoc
class _$CartCopyWithImpl<$Res>
    implements $CartCopyWith<$Res> {
  _$CartCopyWithImpl(this._self, this._then);

  final Cart _self;
  final $Res Function(Cart) _then;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lines = null,Object? fulfilment = null,Object? promoCode = freezed,}) {
  return _then(Cart(
lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<CartLine>,fulfilment: null == fulfilment ? _self.fulfilment : fulfilment // ignore: cast_nullable_to_non_nullable
as FulfilmentMethod,promoCode: freezed == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Cart].
extension CartPatterns on Cart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cart value)  $default,){
final _that = this;
switch (_that) {
case _Cart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cart value)?  $default,){
final _that = this;
switch (_that) {
case _Cart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CartLine> lines,  FulfilmentMethod fulfilment,  String? promoCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.lines,_that.fulfilment,_that.promoCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CartLine> lines,  FulfilmentMethod fulfilment,  String? promoCode)  $default,) {final _that = this;
switch (_that) {
case _Cart():
return $default(_that.lines,_that.fulfilment,_that.promoCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CartLine> lines,  FulfilmentMethod fulfilment,  String? promoCode)?  $default,) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.lines,_that.fulfilment,_that.promoCode);case _:
  return null;

}
}

}

/// @nodoc


class _Cart extends Cart {
  const _Cart({ List<CartLine> lines = const <CartLine>[], this.fulfilment = FulfilmentMethod.delivery, this.promoCode}): _lines = lines,super._();
  

 final  List<CartLine> _lines;
@override@JsonKey() List<CartLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override@JsonKey() final  FulfilmentMethod fulfilment;
/// Applied promo code, uppercased, or null if none.
@override final  String? promoCode;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartCopyWith<_Cart> get copyWith => __$CartCopyWithImpl<_Cart>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cart&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.fulfilment, fulfilment) || other.fulfilment == fulfilment)&&(identical(other.promoCode, promoCode) || other.promoCode == promoCode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_lines),fulfilment,promoCode);
}

@override
String toString() {
    return 'Cart(lines: $lines, fulfilment: $fulfilment, promoCode: $promoCode)';
}


}

/// @nodoc
abstract mixin class _$CartCopyWith<$Res> implements $CartCopyWith<$Res> {
  factory _$CartCopyWith(_Cart value, $Res Function(_Cart) _then) = __$CartCopyWithImpl;
@override @useResult
$Res call({
 List<CartLine> lines, FulfilmentMethod fulfilment, String? promoCode
});




}
/// @nodoc
class __$CartCopyWithImpl<$Res>
    implements _$CartCopyWith<$Res> {
  __$CartCopyWithImpl(this._self, this._then);

  final _Cart _self;
  final $Res Function(_Cart) _then;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lines = null,Object? fulfilment = null,Object? promoCode = freezed,}) {
  return _then(_Cart(
lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<CartLine>,fulfilment: null == fulfilment ? _self.fulfilment : fulfilment // ignore: cast_nullable_to_non_nullable
as FulfilmentMethod,promoCode: freezed == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
