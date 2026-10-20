// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WalletEntry {

 String get id; WalletEntryType get type;/// Signed: positive adds money, negative takes it.
 double get amount; double get balanceAfter; String get description; String? get orderId;/// Null until Firestore has saved the server time.
 DateTime? get createdAt;
/// Create a copy of WalletEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletEntryCopyWith<WalletEntry> get copyWith => _$WalletEntryCopyWithImpl<WalletEntry>(this as WalletEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WalletEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.balanceAfter, _this.balanceAfter) || other.balanceAfter == _this.balanceAfter)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as WalletEntry;
  return Object.hash(runtimeType,_this.id,_this.type,_this.amount,_this.balanceAfter,_this.description,_this.orderId,_this.createdAt);
}

@override
String toString() {
  final _this = this as WalletEntry;
  return 'WalletEntry(id: ${_this.id}, type: ${_this.type}, amount: ${_this.amount}, balanceAfter: ${_this.balanceAfter}, description: ${_this.description}, orderId: ${_this.orderId}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $WalletEntryCopyWith<$Res>  {
  factory $WalletEntryCopyWith(WalletEntry value, $Res Function(WalletEntry) _then) = _$WalletEntryCopyWithImpl;
@useResult
$Res call({
 String id, WalletEntryType type, double amount, double balanceAfter, String description, String? orderId, DateTime? createdAt
});




}
/// @nodoc
class _$WalletEntryCopyWithImpl<$Res>
    implements $WalletEntryCopyWith<$Res> {
  _$WalletEntryCopyWithImpl(this._self, this._then);

  final WalletEntry _self;
  final $Res Function(WalletEntry) _then;

/// Create a copy of WalletEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? balanceAfter = null,Object? description = null,Object? orderId = freezed,Object? createdAt = freezed,}) {
  return _then(WalletEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WalletEntryType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,balanceAfter: null == balanceAfter ? _self.balanceAfter : balanceAfter // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletEntry].
extension WalletEntryPatterns on WalletEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletEntry value)  $default,){
final _that = this;
switch (_that) {
case _WalletEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletEntry value)?  $default,){
final _that = this;
switch (_that) {
case _WalletEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  WalletEntryType type,  double amount,  double balanceAfter,  String description,  String? orderId,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletEntry() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.balanceAfter,_that.description,_that.orderId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  WalletEntryType type,  double amount,  double balanceAfter,  String description,  String? orderId,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _WalletEntry():
return $default(_that.id,_that.type,_that.amount,_that.balanceAfter,_that.description,_that.orderId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  WalletEntryType type,  double amount,  double balanceAfter,  String description,  String? orderId,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WalletEntry() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.balanceAfter,_that.description,_that.orderId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _WalletEntry extends WalletEntry {
  const _WalletEntry({required this.id, required this.type, required this.amount, required this.balanceAfter, required this.description, this.orderId, this.createdAt}): super._();
  

@override final  String id;
@override final  WalletEntryType type;
/// Signed: positive adds money, negative takes it.
@override final  double amount;
@override final  double balanceAfter;
@override final  String description;
@override final  String? orderId;
/// Null until Firestore has saved the server time.
@override final  DateTime? createdAt;

/// Create a copy of WalletEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletEntryCopyWith<_WalletEntry> get copyWith => __$WalletEntryCopyWithImpl<_WalletEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.balanceAfter, balanceAfter) || other.balanceAfter == balanceAfter)&&(identical(other.description, description) || other.description == description)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,type,amount,balanceAfter,description,orderId,createdAt);
}

@override
String toString() {
    return 'WalletEntry(id: $id, type: $type, amount: $amount, balanceAfter: $balanceAfter, description: $description, orderId: $orderId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WalletEntryCopyWith<$Res> implements $WalletEntryCopyWith<$Res> {
  factory _$WalletEntryCopyWith(_WalletEntry value, $Res Function(_WalletEntry) _then) = __$WalletEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, WalletEntryType type, double amount, double balanceAfter, String description, String? orderId, DateTime? createdAt
});




}
/// @nodoc
class __$WalletEntryCopyWithImpl<$Res>
    implements _$WalletEntryCopyWith<$Res> {
  __$WalletEntryCopyWithImpl(this._self, this._then);

  final _WalletEntry _self;
  final $Res Function(_WalletEntry) _then;

/// Create a copy of WalletEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? balanceAfter = null,Object? description = null,Object? orderId = freezed,Object? createdAt = freezed,}) {
  return _then(_WalletEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WalletEntryType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,balanceAfter: null == balanceAfter ? _self.balanceAfter : balanceAfter // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
