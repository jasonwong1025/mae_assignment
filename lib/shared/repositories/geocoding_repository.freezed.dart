// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'geocoding_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddressResult implements DiagnosticableTreeMixin {

 String get address; LatLng get location;
/// Create a copy of AddressResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressResultCopyWith<AddressResult> get copyWith => _$AddressResultCopyWithImpl<AddressResult>(this as AddressResult, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as AddressResult;
  properties
    ..add(DiagnosticsProperty('type', 'AddressResult'))
    ..add(DiagnosticsProperty('address', _this.address))..add(DiagnosticsProperty('location', _this.location));
}

@override
bool operator ==(Object other) {
  final _this = this as AddressResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressResult&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.location, _this.location) || other.location == _this.location));
}


@override
int get hashCode {
  final _this = this as AddressResult;
  return Object.hash(runtimeType,_this.address,_this.location);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as AddressResult;
  return 'AddressResult(address: ${_this.address}, location: ${_this.location})';
}


}

/// @nodoc
abstract mixin class $AddressResultCopyWith<$Res>  {
  factory $AddressResultCopyWith(AddressResult value, $Res Function(AddressResult) _then) = _$AddressResultCopyWithImpl;
@useResult
$Res call({
 String address, LatLng location
});




}
/// @nodoc
class _$AddressResultCopyWithImpl<$Res>
    implements $AddressResultCopyWith<$Res> {
  _$AddressResultCopyWithImpl(this._self, this._then);

  final AddressResult _self;
  final $Res Function(AddressResult) _then;

/// Create a copy of AddressResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,Object? location = null,}) {
  return _then(AddressResult(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressResult].
extension AddressResultPatterns on AddressResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressResult value)  $default,){
final _that = this;
switch (_that) {
case _AddressResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressResult value)?  $default,){
final _that = this;
switch (_that) {
case _AddressResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String address,  LatLng location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressResult() when $default != null:
return $default(_that.address,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String address,  LatLng location)  $default,) {final _that = this;
switch (_that) {
case _AddressResult():
return $default(_that.address,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String address,  LatLng location)?  $default,) {final _that = this;
switch (_that) {
case _AddressResult() when $default != null:
return $default(_that.address,_that.location);case _:
  return null;

}
}

}

/// @nodoc


class _AddressResult extends AddressResult with DiagnosticableTreeMixin {
  const _AddressResult({required this.address, required this.location}): super._();
  

@override final  String address;
@override final  LatLng location;

/// Create a copy of AddressResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressResultCopyWith<_AddressResult> get copyWith => __$AddressResultCopyWithImpl<_AddressResult>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'AddressResult'))
    ..add(DiagnosticsProperty('address', address))..add(DiagnosticsProperty('location', location));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressResult&&(identical(other.address, address) || other.address == address)&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode {
    return Object.hash(runtimeType,address,location);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'AddressResult(address: $address, location: $location)';
}


}

/// @nodoc
abstract mixin class _$AddressResultCopyWith<$Res> implements $AddressResultCopyWith<$Res> {
  factory _$AddressResultCopyWith(_AddressResult value, $Res Function(_AddressResult) _then) = __$AddressResultCopyWithImpl;
@override @useResult
$Res call({
 String address, LatLng location
});




}
/// @nodoc
class __$AddressResultCopyWithImpl<$Res>
    implements _$AddressResultCopyWith<$Res> {
  __$AddressResultCopyWithImpl(this._self, this._then);

  final _AddressResult _self;
  final $Res Function(_AddressResult) _then;

/// Create a copy of AddressResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? location = null,}) {
  return _then(_AddressResult(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng,
  ));
}


}

// dart format on
