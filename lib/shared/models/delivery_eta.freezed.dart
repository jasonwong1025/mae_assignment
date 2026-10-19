// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_eta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeliveryEta {

/// Estimated distance still to drive, in kilometres.
 double get distanceKm;/// Estimated time still to drive. Never below one minute.
 Duration get remaining;/// When the driver is expected at the door.
 DateTime get arrivalAt;/// How long ago the driver's position was reported.
 Duration get positionAge;
/// Create a copy of DeliveryEta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryEtaCopyWith<DeliveryEta> get copyWith => _$DeliveryEtaCopyWithImpl<DeliveryEta>(this as DeliveryEta, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeliveryEta;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryEta&&(identical(other.distanceKm, _this.distanceKm) || other.distanceKm == _this.distanceKm)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining)&&(identical(other.arrivalAt, _this.arrivalAt) || other.arrivalAt == _this.arrivalAt)&&(identical(other.positionAge, _this.positionAge) || other.positionAge == _this.positionAge));
}


@override
int get hashCode {
  final _this = this as DeliveryEta;
  return Object.hash(runtimeType,_this.distanceKm,_this.remaining,_this.arrivalAt,_this.positionAge);
}

@override
String toString() {
  final _this = this as DeliveryEta;
  return 'DeliveryEta(distanceKm: ${_this.distanceKm}, remaining: ${_this.remaining}, arrivalAt: ${_this.arrivalAt}, positionAge: ${_this.positionAge})';
}


}

/// @nodoc
abstract mixin class $DeliveryEtaCopyWith<$Res>  {
  factory $DeliveryEtaCopyWith(DeliveryEta value, $Res Function(DeliveryEta) _then) = _$DeliveryEtaCopyWithImpl;
@useResult
$Res call({
 double distanceKm, Duration remaining, DateTime arrivalAt, Duration positionAge
});




}
/// @nodoc
class _$DeliveryEtaCopyWithImpl<$Res>
    implements $DeliveryEtaCopyWith<$Res> {
  _$DeliveryEtaCopyWithImpl(this._self, this._then);

  final DeliveryEta _self;
  final $Res Function(DeliveryEta) _then;

/// Create a copy of DeliveryEta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? distanceKm = null,Object? remaining = null,Object? arrivalAt = null,Object? positionAge = null,}) {
  return _then(DeliveryEta(
distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as Duration,arrivalAt: null == arrivalAt ? _self.arrivalAt : arrivalAt // ignore: cast_nullable_to_non_nullable
as DateTime,positionAge: null == positionAge ? _self.positionAge : positionAge // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryEta].
extension DeliveryEtaPatterns on DeliveryEta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryEta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryEta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryEta value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryEta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryEta value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryEta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double distanceKm,  Duration remaining,  DateTime arrivalAt,  Duration positionAge)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryEta() when $default != null:
return $default(_that.distanceKm,_that.remaining,_that.arrivalAt,_that.positionAge);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double distanceKm,  Duration remaining,  DateTime arrivalAt,  Duration positionAge)  $default,) {final _that = this;
switch (_that) {
case _DeliveryEta():
return $default(_that.distanceKm,_that.remaining,_that.arrivalAt,_that.positionAge);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double distanceKm,  Duration remaining,  DateTime arrivalAt,  Duration positionAge)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryEta() when $default != null:
return $default(_that.distanceKm,_that.remaining,_that.arrivalAt,_that.positionAge);case _:
  return null;

}
}

}

/// @nodoc


class _DeliveryEta extends DeliveryEta {
  const _DeliveryEta({required this.distanceKm, required this.remaining, required this.arrivalAt, required this.positionAge}): super._();
  

/// Estimated distance still to drive, in kilometres.
@override final  double distanceKm;
/// Estimated time still to drive. Never below one minute.
@override final  Duration remaining;
/// When the driver is expected at the door.
@override final  DateTime arrivalAt;
/// How long ago the driver's position was reported.
@override final  Duration positionAge;

/// Create a copy of DeliveryEta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryEtaCopyWith<_DeliveryEta> get copyWith => __$DeliveryEtaCopyWithImpl<_DeliveryEta>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryEta&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.arrivalAt, arrivalAt) || other.arrivalAt == arrivalAt)&&(identical(other.positionAge, positionAge) || other.positionAge == positionAge));
}


@override
int get hashCode {
    return Object.hash(runtimeType,distanceKm,remaining,arrivalAt,positionAge);
}

@override
String toString() {
    return 'DeliveryEta(distanceKm: $distanceKm, remaining: $remaining, arrivalAt: $arrivalAt, positionAge: $positionAge)';
}


}

/// @nodoc
abstract mixin class _$DeliveryEtaCopyWith<$Res> implements $DeliveryEtaCopyWith<$Res> {
  factory _$DeliveryEtaCopyWith(_DeliveryEta value, $Res Function(_DeliveryEta) _then) = __$DeliveryEtaCopyWithImpl;
@override @useResult
$Res call({
 double distanceKm, Duration remaining, DateTime arrivalAt, Duration positionAge
});




}
/// @nodoc
class __$DeliveryEtaCopyWithImpl<$Res>
    implements _$DeliveryEtaCopyWith<$Res> {
  __$DeliveryEtaCopyWithImpl(this._self, this._then);

  final _DeliveryEta _self;
  final $Res Function(_DeliveryEta) _then;

/// Create a copy of DeliveryEta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? distanceKm = null,Object? remaining = null,Object? arrivalAt = null,Object? positionAge = null,}) {
  return _then(_DeliveryEta(
distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as Duration,arrivalAt: null == arrivalAt ? _self.arrivalAt : arrivalAt // ignore: cast_nullable_to_non_nullable
as DateTime,positionAge: null == positionAge ? _self.positionAge : positionAge // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on
