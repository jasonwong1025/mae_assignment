// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'road_route.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoadRoute {

/// The line to draw on the map.
 List<LatLng> get points;/// Distance along the roads.
 double get metres;/// Driving time, without traffic.
 double get seconds;
/// Create a copy of RoadRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoadRouteCopyWith<RoadRoute> get copyWith => _$RoadRouteCopyWithImpl<RoadRoute>(this as RoadRoute, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RoadRoute;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoadRoute&&const DeepCollectionEquality().equals(other.points, _this.points)&&(identical(other.metres, _this.metres) || other.metres == _this.metres)&&(identical(other.seconds, _this.seconds) || other.seconds == _this.seconds));
}


@override
int get hashCode {
  final _this = this as RoadRoute;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.points),_this.metres,_this.seconds);
}

@override
String toString() {
  final _this = this as RoadRoute;
  return 'RoadRoute(points: ${_this.points}, metres: ${_this.metres}, seconds: ${_this.seconds})';
}


}

/// @nodoc
abstract mixin class $RoadRouteCopyWith<$Res>  {
  factory $RoadRouteCopyWith(RoadRoute value, $Res Function(RoadRoute) _then) = _$RoadRouteCopyWithImpl;
@useResult
$Res call({
 List<LatLng> points, double metres, double seconds
});




}
/// @nodoc
class _$RoadRouteCopyWithImpl<$Res>
    implements $RoadRouteCopyWith<$Res> {
  _$RoadRouteCopyWithImpl(this._self, this._then);

  final RoadRoute _self;
  final $Res Function(RoadRoute) _then;

/// Create a copy of RoadRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? points = null,Object? metres = null,Object? seconds = null,}) {
  return _then(RoadRoute(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<LatLng>,metres: null == metres ? _self.metres : metres // ignore: cast_nullable_to_non_nullable
as double,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RoadRoute].
extension RoadRoutePatterns on RoadRoute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoadRoute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoadRoute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoadRoute value)  $default,){
final _that = this;
switch (_that) {
case _RoadRoute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoadRoute value)?  $default,){
final _that = this;
switch (_that) {
case _RoadRoute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LatLng> points,  double metres,  double seconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoadRoute() when $default != null:
return $default(_that.points,_that.metres,_that.seconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LatLng> points,  double metres,  double seconds)  $default,) {final _that = this;
switch (_that) {
case _RoadRoute():
return $default(_that.points,_that.metres,_that.seconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LatLng> points,  double metres,  double seconds)?  $default,) {final _that = this;
switch (_that) {
case _RoadRoute() when $default != null:
return $default(_that.points,_that.metres,_that.seconds);case _:
  return null;

}
}

}

/// @nodoc


class _RoadRoute extends RoadRoute {
  const _RoadRoute({required  List<LatLng> points, required this.metres, required this.seconds}): _points = points,super._();
  

/// The line to draw on the map.
 final  List<LatLng> _points;
/// The line to draw on the map.
@override List<LatLng> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

/// Distance along the roads.
@override final  double metres;
/// Driving time, without traffic.
@override final  double seconds;

/// Create a copy of RoadRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoadRouteCopyWith<_RoadRoute> get copyWith => __$RoadRouteCopyWithImpl<_RoadRoute>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoadRoute&&const DeepCollectionEquality().equals(other.points, _points)&&(identical(other.metres, metres) || other.metres == metres)&&(identical(other.seconds, seconds) || other.seconds == seconds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_points),metres,seconds);
}

@override
String toString() {
    return 'RoadRoute(points: $points, metres: $metres, seconds: $seconds)';
}


}

/// @nodoc
abstract mixin class _$RoadRouteCopyWith<$Res> implements $RoadRouteCopyWith<$Res> {
  factory _$RoadRouteCopyWith(_RoadRoute value, $Res Function(_RoadRoute) _then) = __$RoadRouteCopyWithImpl;
@override @useResult
$Res call({
 List<LatLng> points, double metres, double seconds
});




}
/// @nodoc
class __$RoadRouteCopyWithImpl<$Res>
    implements _$RoadRouteCopyWith<$Res> {
  __$RoadRouteCopyWithImpl(this._self, this._then);

  final _RoadRoute _self;
  final $Res Function(_RoadRoute) _then;

/// Create a copy of RoadRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? points = null,Object? metres = null,Object? seconds = null,}) {
  return _then(_RoadRoute(
points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<LatLng>,metres: null == metres ? _self.metres : metres // ignore: cast_nullable_to_non_nullable
as double,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
