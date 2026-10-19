// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_tracking_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DriverTrackingState {

/// True once a position has been shared.
 bool get isSharing;/// What stops sharing (location off, permission refused, no connection),
/// or null when all is well.
 String? get error;
/// Create a copy of DriverTrackingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverTrackingStateCopyWith<DriverTrackingState> get copyWith => _$DriverTrackingStateCopyWithImpl<DriverTrackingState>(this as DriverTrackingState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DriverTrackingState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverTrackingState&&(identical(other.isSharing, _this.isSharing) || other.isSharing == _this.isSharing)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as DriverTrackingState;
  return Object.hash(runtimeType,_this.isSharing,_this.error);
}

@override
String toString() {
  final _this = this as DriverTrackingState;
  return 'DriverTrackingState(isSharing: ${_this.isSharing}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $DriverTrackingStateCopyWith<$Res>  {
  factory $DriverTrackingStateCopyWith(DriverTrackingState value, $Res Function(DriverTrackingState) _then) = _$DriverTrackingStateCopyWithImpl;
@useResult
$Res call({
 bool isSharing, String? error
});




}
/// @nodoc
class _$DriverTrackingStateCopyWithImpl<$Res>
    implements $DriverTrackingStateCopyWith<$Res> {
  _$DriverTrackingStateCopyWithImpl(this._self, this._then);

  final DriverTrackingState _self;
  final $Res Function(DriverTrackingState) _then;

/// Create a copy of DriverTrackingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSharing = null,Object? error = freezed,}) {
  return _then(DriverTrackingState(
isSharing: null == isSharing ? _self.isSharing : isSharing // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverTrackingState].
extension DriverTrackingStatePatterns on DriverTrackingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverTrackingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverTrackingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverTrackingState value)  $default,){
final _that = this;
switch (_that) {
case _DriverTrackingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverTrackingState value)?  $default,){
final _that = this;
switch (_that) {
case _DriverTrackingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSharing,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverTrackingState() when $default != null:
return $default(_that.isSharing,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSharing,  String? error)  $default,) {final _that = this;
switch (_that) {
case _DriverTrackingState():
return $default(_that.isSharing,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSharing,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _DriverTrackingState() when $default != null:
return $default(_that.isSharing,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _DriverTrackingState implements DriverTrackingState {
  const _DriverTrackingState({this.isSharing = false, this.error});
  

/// True once a position has been shared.
@override@JsonKey() final  bool isSharing;
/// What stops sharing (location off, permission refused, no connection),
/// or null when all is well.
@override final  String? error;

/// Create a copy of DriverTrackingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverTrackingStateCopyWith<_DriverTrackingState> get copyWith => __$DriverTrackingStateCopyWithImpl<_DriverTrackingState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverTrackingState&&(identical(other.isSharing, isSharing) || other.isSharing == isSharing)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isSharing,error);
}

@override
String toString() {
    return 'DriverTrackingState(isSharing: $isSharing, error: $error)';
}


}

/// @nodoc
abstract mixin class _$DriverTrackingStateCopyWith<$Res> implements $DriverTrackingStateCopyWith<$Res> {
  factory _$DriverTrackingStateCopyWith(_DriverTrackingState value, $Res Function(_DriverTrackingState) _then) = __$DriverTrackingStateCopyWithImpl;
@override @useResult
$Res call({
 bool isSharing, String? error
});




}
/// @nodoc
class __$DriverTrackingStateCopyWithImpl<$Res>
    implements _$DriverTrackingStateCopyWith<$Res> {
  __$DriverTrackingStateCopyWithImpl(this._self, this._then);

  final _DriverTrackingState _self;
  final $Res Function(_DriverTrackingState) _then;

/// Create a copy of DriverTrackingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSharing = null,Object? error = freezed,}) {
  return _then(_DriverTrackingState(
isSharing: null == isSharing ? _self.isSharing : isSharing // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
