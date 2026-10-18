// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Driver {

 String get id; String get name; bool get isOnDuty;/// Order being delivered now. Null if free.
 int? get currentOrderNumber;
/// Create a copy of Driver
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverCopyWith<Driver> get copyWith => _$DriverCopyWithImpl<Driver>(this as Driver, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Driver;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Driver&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isOnDuty, _this.isOnDuty) || other.isOnDuty == _this.isOnDuty)&&(identical(other.currentOrderNumber, _this.currentOrderNumber) || other.currentOrderNumber == _this.currentOrderNumber));
}


@override
int get hashCode {
  final _this = this as Driver;
  return Object.hash(runtimeType,_this.id,_this.name,_this.isOnDuty,_this.currentOrderNumber);
}

@override
String toString() {
  final _this = this as Driver;
  return 'Driver(id: ${_this.id}, name: ${_this.name}, isOnDuty: ${_this.isOnDuty}, currentOrderNumber: ${_this.currentOrderNumber})';
}


}

/// @nodoc
abstract mixin class $DriverCopyWith<$Res>  {
  factory $DriverCopyWith(Driver value, $Res Function(Driver) _then) = _$DriverCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool isOnDuty, int? currentOrderNumber
});




}
/// @nodoc
class _$DriverCopyWithImpl<$Res>
    implements $DriverCopyWith<$Res> {
  _$DriverCopyWithImpl(this._self, this._then);

  final Driver _self;
  final $Res Function(Driver) _then;

/// Create a copy of Driver
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isOnDuty = null,Object? currentOrderNumber = freezed,}) {
  return _then(Driver(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isOnDuty: null == isOnDuty ? _self.isOnDuty : isOnDuty // ignore: cast_nullable_to_non_nullable
as bool,currentOrderNumber: freezed == currentOrderNumber ? _self.currentOrderNumber : currentOrderNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Driver].
extension DriverPatterns on Driver {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Driver value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Driver() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Driver value)  $default,){
final _that = this;
switch (_that) {
case _Driver():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Driver value)?  $default,){
final _that = this;
switch (_that) {
case _Driver() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool isOnDuty,  int? currentOrderNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Driver() when $default != null:
return $default(_that.id,_that.name,_that.isOnDuty,_that.currentOrderNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool isOnDuty,  int? currentOrderNumber)  $default,) {final _that = this;
switch (_that) {
case _Driver():
return $default(_that.id,_that.name,_that.isOnDuty,_that.currentOrderNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool isOnDuty,  int? currentOrderNumber)?  $default,) {final _that = this;
switch (_that) {
case _Driver() when $default != null:
return $default(_that.id,_that.name,_that.isOnDuty,_that.currentOrderNumber);case _:
  return null;

}
}

}

/// @nodoc


class _Driver extends Driver {
  const _Driver({required this.id, required this.name, required this.isOnDuty, this.currentOrderNumber}): super._();
  

@override final  String id;
@override final  String name;
@override final  bool isOnDuty;
/// Order being delivered now. Null if free.
@override final  int? currentOrderNumber;

/// Create a copy of Driver
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverCopyWith<_Driver> get copyWith => __$DriverCopyWithImpl<_Driver>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Driver&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isOnDuty, isOnDuty) || other.isOnDuty == isOnDuty)&&(identical(other.currentOrderNumber, currentOrderNumber) || other.currentOrderNumber == currentOrderNumber));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,isOnDuty,currentOrderNumber);
}

@override
String toString() {
    return 'Driver(id: $id, name: $name, isOnDuty: $isOnDuty, currentOrderNumber: $currentOrderNumber)';
}


}

/// @nodoc
abstract mixin class _$DriverCopyWith<$Res> implements $DriverCopyWith<$Res> {
  factory _$DriverCopyWith(_Driver value, $Res Function(_Driver) _then) = __$DriverCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool isOnDuty, int? currentOrderNumber
});




}
/// @nodoc
class __$DriverCopyWithImpl<$Res>
    implements _$DriverCopyWith<$Res> {
  __$DriverCopyWithImpl(this._self, this._then);

  final _Driver _self;
  final $Res Function(_Driver) _then;

/// Create a copy of Driver
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isOnDuty = null,Object? currentOrderNumber = freezed,}) {
  return _then(_Driver(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isOnDuty: null == isOnDuty ? _self.isOnDuty : isOnDuty // ignore: cast_nullable_to_non_nullable
as bool,currentOrderNumber: freezed == currentOrderNumber ? _self.currentOrderNumber : currentOrderNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
