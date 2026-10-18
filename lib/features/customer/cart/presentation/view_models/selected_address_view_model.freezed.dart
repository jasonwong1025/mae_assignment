// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'selected_address_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeliveryQuote {

/// Distance from the branch to the address, in kilometres.
 double get distanceKm;/// Delivery fee in ringgit. Zero when out of range (then [inRange] is
/// false and checkout is blocked).
 double get fee;/// False when the address is beyond the branch's delivery radius.
 bool get inRange;
/// Create a copy of DeliveryQuote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryQuoteCopyWith<DeliveryQuote> get copyWith => _$DeliveryQuoteCopyWithImpl<DeliveryQuote>(this as DeliveryQuote, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeliveryQuote;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryQuote&&(identical(other.distanceKm, _this.distanceKm) || other.distanceKm == _this.distanceKm)&&(identical(other.fee, _this.fee) || other.fee == _this.fee)&&(identical(other.inRange, _this.inRange) || other.inRange == _this.inRange));
}


@override
int get hashCode {
  final _this = this as DeliveryQuote;
  return Object.hash(runtimeType,_this.distanceKm,_this.fee,_this.inRange);
}

@override
String toString() {
  final _this = this as DeliveryQuote;
  return 'DeliveryQuote(distanceKm: ${_this.distanceKm}, fee: ${_this.fee}, inRange: ${_this.inRange})';
}


}

/// @nodoc
abstract mixin class $DeliveryQuoteCopyWith<$Res>  {
  factory $DeliveryQuoteCopyWith(DeliveryQuote value, $Res Function(DeliveryQuote) _then) = _$DeliveryQuoteCopyWithImpl;
@useResult
$Res call({
 double distanceKm, double fee, bool inRange
});




}
/// @nodoc
class _$DeliveryQuoteCopyWithImpl<$Res>
    implements $DeliveryQuoteCopyWith<$Res> {
  _$DeliveryQuoteCopyWithImpl(this._self, this._then);

  final DeliveryQuote _self;
  final $Res Function(DeliveryQuote) _then;

/// Create a copy of DeliveryQuote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? distanceKm = null,Object? fee = null,Object? inRange = null,}) {
  return _then(DeliveryQuote(
distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double,inRange: null == inRange ? _self.inRange : inRange // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryQuote].
extension DeliveryQuotePatterns on DeliveryQuote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryQuote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryQuote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryQuote value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryQuote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryQuote value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryQuote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double distanceKm,  double fee,  bool inRange)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryQuote() when $default != null:
return $default(_that.distanceKm,_that.fee,_that.inRange);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double distanceKm,  double fee,  bool inRange)  $default,) {final _that = this;
switch (_that) {
case _DeliveryQuote():
return $default(_that.distanceKm,_that.fee,_that.inRange);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double distanceKm,  double fee,  bool inRange)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryQuote() when $default != null:
return $default(_that.distanceKm,_that.fee,_that.inRange);case _:
  return null;

}
}

}

/// @nodoc


class _DeliveryQuote extends DeliveryQuote {
  const _DeliveryQuote({required this.distanceKm, required this.fee, required this.inRange}): super._();
  

/// Distance from the branch to the address, in kilometres.
@override final  double distanceKm;
/// Delivery fee in ringgit. Zero when out of range (then [inRange] is
/// false and checkout is blocked).
@override final  double fee;
/// False when the address is beyond the branch's delivery radius.
@override final  bool inRange;

/// Create a copy of DeliveryQuote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryQuoteCopyWith<_DeliveryQuote> get copyWith => __$DeliveryQuoteCopyWithImpl<_DeliveryQuote>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryQuote&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.fee, fee) || other.fee == fee)&&(identical(other.inRange, inRange) || other.inRange == inRange));
}


@override
int get hashCode {
    return Object.hash(runtimeType,distanceKm,fee,inRange);
}

@override
String toString() {
    return 'DeliveryQuote(distanceKm: $distanceKm, fee: $fee, inRange: $inRange)';
}


}

/// @nodoc
abstract mixin class _$DeliveryQuoteCopyWith<$Res> implements $DeliveryQuoteCopyWith<$Res> {
  factory _$DeliveryQuoteCopyWith(_DeliveryQuote value, $Res Function(_DeliveryQuote) _then) = __$DeliveryQuoteCopyWithImpl;
@override @useResult
$Res call({
 double distanceKm, double fee, bool inRange
});




}
/// @nodoc
class __$DeliveryQuoteCopyWithImpl<$Res>
    implements _$DeliveryQuoteCopyWith<$Res> {
  __$DeliveryQuoteCopyWithImpl(this._self, this._then);

  final _DeliveryQuote _self;
  final $Res Function(_DeliveryQuote) _then;

/// Create a copy of DeliveryQuote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? distanceKm = null,Object? fee = null,Object? inRange = null,}) {
  return _then(_DeliveryQuote(
distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,fee: null == fee ? _self.fee : fee // ignore: cast_nullable_to_non_nullable
as double,inRange: null == inRange ? _self.inRange : inRange // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
