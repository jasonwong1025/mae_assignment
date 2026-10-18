// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stored_cart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoredCartLine {

 String get productId; int get quantity;
/// Create a copy of StoredCartLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoredCartLineCopyWith<StoredCartLine> get copyWith => _$StoredCartLineCopyWithImpl<StoredCartLine>(this as StoredCartLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StoredCartLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoredCartLine&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity));
}


@override
int get hashCode {
  final _this = this as StoredCartLine;
  return Object.hash(runtimeType,_this.productId,_this.quantity);
}

@override
String toString() {
  final _this = this as StoredCartLine;
  return 'StoredCartLine(productId: ${_this.productId}, quantity: ${_this.quantity})';
}


}

/// @nodoc
abstract mixin class $StoredCartLineCopyWith<$Res>  {
  factory $StoredCartLineCopyWith(StoredCartLine value, $Res Function(StoredCartLine) _then) = _$StoredCartLineCopyWithImpl;
@useResult
$Res call({
 String productId, int quantity
});




}
/// @nodoc
class _$StoredCartLineCopyWithImpl<$Res>
    implements $StoredCartLineCopyWith<$Res> {
  _$StoredCartLineCopyWithImpl(this._self, this._then);

  final StoredCartLine _self;
  final $Res Function(StoredCartLine) _then;

/// Create a copy of StoredCartLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? quantity = null,}) {
  return _then(StoredCartLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StoredCartLine].
extension StoredCartLinePatterns on StoredCartLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoredCartLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoredCartLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoredCartLine value)  $default,){
final _that = this;
switch (_that) {
case _StoredCartLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoredCartLine value)?  $default,){
final _that = this;
switch (_that) {
case _StoredCartLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoredCartLine() when $default != null:
return $default(_that.productId,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _StoredCartLine():
return $default(_that.productId,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _StoredCartLine() when $default != null:
return $default(_that.productId,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc


class _StoredCartLine implements StoredCartLine {
  const _StoredCartLine({required this.productId, required this.quantity});
  

@override final  String productId;
@override final  int quantity;

/// Create a copy of StoredCartLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoredCartLineCopyWith<_StoredCartLine> get copyWith => __$StoredCartLineCopyWithImpl<_StoredCartLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoredCartLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,quantity);
}

@override
String toString() {
    return 'StoredCartLine(productId: $productId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$StoredCartLineCopyWith<$Res> implements $StoredCartLineCopyWith<$Res> {
  factory _$StoredCartLineCopyWith(_StoredCartLine value, $Res Function(_StoredCartLine) _then) = __$StoredCartLineCopyWithImpl;
@override @useResult
$Res call({
 String productId, int quantity
});




}
/// @nodoc
class __$StoredCartLineCopyWithImpl<$Res>
    implements _$StoredCartLineCopyWith<$Res> {
  __$StoredCartLineCopyWithImpl(this._self, this._then);

  final _StoredCartLine _self;
  final $Res Function(_StoredCartLine) _then;

/// Create a copy of StoredCartLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? quantity = null,}) {
  return _then(_StoredCartLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$StoredCart {

 List<StoredCartLine> get lines; FulfilmentMethod get fulfilment; String? get promoCode;
/// Create a copy of StoredCart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoredCartCopyWith<StoredCart> get copyWith => _$StoredCartCopyWithImpl<StoredCart>(this as StoredCart, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StoredCart;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoredCart&&const DeepCollectionEquality().equals(other.lines, _this.lines)&&(identical(other.fulfilment, _this.fulfilment) || other.fulfilment == _this.fulfilment)&&(identical(other.promoCode, _this.promoCode) || other.promoCode == _this.promoCode));
}


@override
int get hashCode {
  final _this = this as StoredCart;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.lines),_this.fulfilment,_this.promoCode);
}

@override
String toString() {
  final _this = this as StoredCart;
  return 'StoredCart(lines: ${_this.lines}, fulfilment: ${_this.fulfilment}, promoCode: ${_this.promoCode})';
}


}

/// @nodoc
abstract mixin class $StoredCartCopyWith<$Res>  {
  factory $StoredCartCopyWith(StoredCart value, $Res Function(StoredCart) _then) = _$StoredCartCopyWithImpl;
@useResult
$Res call({
 List<StoredCartLine> lines, FulfilmentMethod fulfilment, String? promoCode
});




}
/// @nodoc
class _$StoredCartCopyWithImpl<$Res>
    implements $StoredCartCopyWith<$Res> {
  _$StoredCartCopyWithImpl(this._self, this._then);

  final StoredCart _self;
  final $Res Function(StoredCart) _then;

/// Create a copy of StoredCart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lines = null,Object? fulfilment = null,Object? promoCode = freezed,}) {
  return _then(StoredCart(
lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<StoredCartLine>,fulfilment: null == fulfilment ? _self.fulfilment : fulfilment // ignore: cast_nullable_to_non_nullable
as FulfilmentMethod,promoCode: freezed == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoredCart].
extension StoredCartPatterns on StoredCart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoredCart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoredCart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoredCart value)  $default,){
final _that = this;
switch (_that) {
case _StoredCart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoredCart value)?  $default,){
final _that = this;
switch (_that) {
case _StoredCart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<StoredCartLine> lines,  FulfilmentMethod fulfilment,  String? promoCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoredCart() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<StoredCartLine> lines,  FulfilmentMethod fulfilment,  String? promoCode)  $default,) {final _that = this;
switch (_that) {
case _StoredCart():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<StoredCartLine> lines,  FulfilmentMethod fulfilment,  String? promoCode)?  $default,) {final _that = this;
switch (_that) {
case _StoredCart() when $default != null:
return $default(_that.lines,_that.fulfilment,_that.promoCode);case _:
  return null;

}
}

}

/// @nodoc


class _StoredCart extends StoredCart {
  const _StoredCart({ List<StoredCartLine> lines = const <StoredCartLine>[], this.fulfilment = FulfilmentMethod.delivery, this.promoCode}): _lines = lines,super._();
  

 final  List<StoredCartLine> _lines;
@override@JsonKey() List<StoredCartLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}

@override@JsonKey() final  FulfilmentMethod fulfilment;
@override final  String? promoCode;

/// Create a copy of StoredCart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoredCartCopyWith<_StoredCart> get copyWith => __$StoredCartCopyWithImpl<_StoredCart>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoredCart&&const DeepCollectionEquality().equals(other.lines, _lines)&&(identical(other.fulfilment, fulfilment) || other.fulfilment == fulfilment)&&(identical(other.promoCode, promoCode) || other.promoCode == promoCode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_lines),fulfilment,promoCode);
}

@override
String toString() {
    return 'StoredCart(lines: $lines, fulfilment: $fulfilment, promoCode: $promoCode)';
}


}

/// @nodoc
abstract mixin class _$StoredCartCopyWith<$Res> implements $StoredCartCopyWith<$Res> {
  factory _$StoredCartCopyWith(_StoredCart value, $Res Function(_StoredCart) _then) = __$StoredCartCopyWithImpl;
@override @useResult
$Res call({
 List<StoredCartLine> lines, FulfilmentMethod fulfilment, String? promoCode
});




}
/// @nodoc
class __$StoredCartCopyWithImpl<$Res>
    implements _$StoredCartCopyWith<$Res> {
  __$StoredCartCopyWithImpl(this._self, this._then);

  final _StoredCart _self;
  final $Res Function(_StoredCart) _then;

/// Create a copy of StoredCart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lines = null,Object? fulfilment = null,Object? promoCode = freezed,}) {
  return _then(_StoredCart(
lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<StoredCartLine>,fulfilment: null == fulfilment ? _self.fulfilment : fulfilment // ignore: cast_nullable_to_non_nullable
as FulfilmentMethod,promoCode: freezed == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
