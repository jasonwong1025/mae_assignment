// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DriverLocation {

 LatLng get position;/// Places still to visit, in order. Empty if the driver has no trip.
 List<LatLng> get stops;
/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverLocationCopyWith<DriverLocation> get copyWith => _$DriverLocationCopyWithImpl<DriverLocation>(this as DriverLocation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DriverLocation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverLocation&&(identical(other.position, _this.position) || other.position == _this.position)&&const DeepCollectionEquality().equals(other.stops, _this.stops));
}


@override
int get hashCode {
  final _this = this as DriverLocation;
  return Object.hash(runtimeType,_this.position,const DeepCollectionEquality().hash(_this.stops));
}

@override
String toString() {
  final _this = this as DriverLocation;
  return 'DriverLocation(position: ${_this.position}, stops: ${_this.stops})';
}


}

/// @nodoc
abstract mixin class $DriverLocationCopyWith<$Res>  {
  factory $DriverLocationCopyWith(DriverLocation value, $Res Function(DriverLocation) _then) = _$DriverLocationCopyWithImpl;
@useResult
$Res call({
 LatLng position, List<LatLng> stops
});




}
/// @nodoc
class _$DriverLocationCopyWithImpl<$Res>
    implements $DriverLocationCopyWith<$Res> {
  _$DriverLocationCopyWithImpl(this._self, this._then);

  final DriverLocation _self;
  final $Res Function(DriverLocation) _then;

/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? position = null,Object? stops = null,}) {
  return _then(DriverLocation(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as LatLng,stops: null == stops ? _self.stops : stops // ignore: cast_nullable_to_non_nullable
as List<LatLng>,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverLocation].
extension DriverLocationPatterns on DriverLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverLocation value)  $default,){
final _that = this;
switch (_that) {
case _DriverLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverLocation value)?  $default,){
final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LatLng position,  List<LatLng> stops)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
return $default(_that.position,_that.stops);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LatLng position,  List<LatLng> stops)  $default,) {final _that = this;
switch (_that) {
case _DriverLocation():
return $default(_that.position,_that.stops);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LatLng position,  List<LatLng> stops)?  $default,) {final _that = this;
switch (_that) {
case _DriverLocation() when $default != null:
return $default(_that.position,_that.stops);case _:
  return null;

}
}

}

/// @nodoc


class _DriverLocation extends DriverLocation {
  const _DriverLocation({required this.position,  List<LatLng> stops = const <LatLng>[]}): _stops = stops,super._();
  

@override final  LatLng position;
/// Places still to visit, in order. Empty if the driver has no trip.
 final  List<LatLng> _stops;
/// Places still to visit, in order. Empty if the driver has no trip.
@override@JsonKey() List<LatLng> get stops {
  if (_stops is EqualUnmodifiableListView) return _stops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stops);
}


/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverLocationCopyWith<_DriverLocation> get copyWith => __$DriverLocationCopyWithImpl<_DriverLocation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverLocation&&(identical(other.position, position) || other.position == position)&&const DeepCollectionEquality().equals(other.stops, _stops));
}


@override
int get hashCode {
    return Object.hash(runtimeType,position,const DeepCollectionEquality().hash(_stops));
}

@override
String toString() {
    return 'DriverLocation(position: $position, stops: $stops)';
}


}

/// @nodoc
abstract mixin class _$DriverLocationCopyWith<$Res> implements $DriverLocationCopyWith<$Res> {
  factory _$DriverLocationCopyWith(_DriverLocation value, $Res Function(_DriverLocation) _then) = __$DriverLocationCopyWithImpl;
@override @useResult
$Res call({
 LatLng position, List<LatLng> stops
});




}
/// @nodoc
class __$DriverLocationCopyWithImpl<$Res>
    implements _$DriverLocationCopyWith<$Res> {
  __$DriverLocationCopyWithImpl(this._self, this._then);

  final _DriverLocation _self;
  final $Res Function(_DriverLocation) _then;

/// Create a copy of DriverLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? position = null,Object? stops = null,}) {
  return _then(_DriverLocation(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as LatLng,stops: null == stops ? _self._stops : stops // ignore: cast_nullable_to_non_nullable
as List<LatLng>,
  ));
}


}

// dart format on
