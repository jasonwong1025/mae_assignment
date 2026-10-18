// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Worker {

/// Same id as the worker's Firebase login.
 String get id; String get name;/// Login email. Cannot be changed after the account is created.
 String get email; String get phone; WorkerRole get role;/// Packer's branch. Null for drivers (they work for every branch).
 String? get branchId;/// False if deactivated. Deactivated workers cannot sign in.
 bool get isActive; DateTime get joinedAt;
/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkerCopyWith<Worker> get copyWith => _$WorkerCopyWithImpl<Worker>(this as Worker, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Worker;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Worker&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.joinedAt, _this.joinedAt) || other.joinedAt == _this.joinedAt));
}


@override
int get hashCode {
  final _this = this as Worker;
  return Object.hash(runtimeType,_this.id,_this.name,_this.email,_this.phone,_this.role,_this.branchId,_this.isActive,_this.joinedAt);
}

@override
String toString() {
  final _this = this as Worker;
  return 'Worker(id: ${_this.id}, name: ${_this.name}, email: ${_this.email}, phone: ${_this.phone}, role: ${_this.role}, branchId: ${_this.branchId}, isActive: ${_this.isActive}, joinedAt: ${_this.joinedAt})';
}


}

/// @nodoc
abstract mixin class $WorkerCopyWith<$Res>  {
  factory $WorkerCopyWith(Worker value, $Res Function(Worker) _then) = _$WorkerCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String phone, WorkerRole role, String? branchId, bool isActive, DateTime joinedAt
});




}
/// @nodoc
class _$WorkerCopyWithImpl<$Res>
    implements $WorkerCopyWith<$Res> {
  _$WorkerCopyWithImpl(this._self, this._then);

  final Worker _self;
  final $Res Function(Worker) _then;

/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = null,Object? role = null,Object? branchId = freezed,Object? isActive = null,Object? joinedAt = null,}) {
  return _then(Worker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as WorkerRole,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Worker].
extension WorkerPatterns on Worker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Worker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Worker() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Worker value)  $default,){
final _that = this;
switch (_that) {
case _Worker():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Worker value)?  $default,){
final _that = this;
switch (_that) {
case _Worker() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String phone,  WorkerRole role,  String? branchId,  bool isActive,  DateTime joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Worker() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.role,_that.branchId,_that.isActive,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String phone,  WorkerRole role,  String? branchId,  bool isActive,  DateTime joinedAt)  $default,) {final _that = this;
switch (_that) {
case _Worker():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.role,_that.branchId,_that.isActive,_that.joinedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String phone,  WorkerRole role,  String? branchId,  bool isActive,  DateTime joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _Worker() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.role,_that.branchId,_that.isActive,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Worker extends Worker {
  const _Worker({required this.id, required this.name, required this.email, required this.phone, required this.role, required this.branchId, required this.isActive, required this.joinedAt}): super._();
  

/// Same id as the worker's Firebase login.
@override final  String id;
@override final  String name;
/// Login email. Cannot be changed after the account is created.
@override final  String email;
@override final  String phone;
@override final  WorkerRole role;
/// Packer's branch. Null for drivers (they work for every branch).
@override final  String? branchId;
/// False if deactivated. Deactivated workers cannot sign in.
@override final  bool isActive;
@override final  DateTime joinedAt;

/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkerCopyWith<_Worker> get copyWith => __$WorkerCopyWithImpl<_Worker>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Worker&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,email,phone,role,branchId,isActive,joinedAt);
}

@override
String toString() {
    return 'Worker(id: $id, name: $name, email: $email, phone: $phone, role: $role, branchId: $branchId, isActive: $isActive, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkerCopyWith<$Res> implements $WorkerCopyWith<$Res> {
  factory _$WorkerCopyWith(_Worker value, $Res Function(_Worker) _then) = __$WorkerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String phone, WorkerRole role, String? branchId, bool isActive, DateTime joinedAt
});




}
/// @nodoc
class __$WorkerCopyWithImpl<$Res>
    implements _$WorkerCopyWith<$Res> {
  __$WorkerCopyWithImpl(this._self, this._then);

  final _Worker _self;
  final $Res Function(_Worker) _then;

/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = null,Object? role = null,Object? branchId = freezed,Object? isActive = null,Object? joinedAt = null,}) {
  return _then(_Worker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as WorkerRole,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
