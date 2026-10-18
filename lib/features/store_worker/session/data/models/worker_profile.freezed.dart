// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worker_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkerProfile {

 String get id; String get name; String get email; String get phone;/// Exactly one role. A worker is never both.
 WorkerRole get role;/// False if HQ deactivated the worker. Inactive workers cannot use the
/// Store Worker app.
 bool get isActive;/// The one branch a Packing Staff member is permanently assigned to.
/// Null for Delivery Drivers: they are not tied to a branch and can be
/// given deliveries from any branch.
 String? get branchId; String? get branchName;
/// Create a copy of WorkerProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkerProfileCopyWith<WorkerProfile> get copyWith => _$WorkerProfileCopyWithImpl<WorkerProfile>(this as WorkerProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkerProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkerProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.branchName, _this.branchName) || other.branchName == _this.branchName));
}


@override
int get hashCode {
  final _this = this as WorkerProfile;
  return Object.hash(runtimeType,_this.id,_this.name,_this.email,_this.phone,_this.role,_this.isActive,_this.branchId,_this.branchName);
}

@override
String toString() {
  final _this = this as WorkerProfile;
  return 'WorkerProfile(id: ${_this.id}, name: ${_this.name}, email: ${_this.email}, phone: ${_this.phone}, role: ${_this.role}, isActive: ${_this.isActive}, branchId: ${_this.branchId}, branchName: ${_this.branchName})';
}


}

/// @nodoc
abstract mixin class $WorkerProfileCopyWith<$Res>  {
  factory $WorkerProfileCopyWith(WorkerProfile value, $Res Function(WorkerProfile) _then) = _$WorkerProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String phone, WorkerRole role, bool isActive, String? branchId, String? branchName
});




}
/// @nodoc
class _$WorkerProfileCopyWithImpl<$Res>
    implements $WorkerProfileCopyWith<$Res> {
  _$WorkerProfileCopyWithImpl(this._self, this._then);

  final WorkerProfile _self;
  final $Res Function(WorkerProfile) _then;

/// Create a copy of WorkerProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = null,Object? role = null,Object? isActive = null,Object? branchId = freezed,Object? branchName = freezed,}) {
  return _then(WorkerProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as WorkerRole,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkerProfile].
extension WorkerProfilePatterns on WorkerProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkerProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkerProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkerProfile value)  $default,){
final _that = this;
switch (_that) {
case _WorkerProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkerProfile value)?  $default,){
final _that = this;
switch (_that) {
case _WorkerProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String phone,  WorkerRole role,  bool isActive,  String? branchId,  String? branchName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkerProfile() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.role,_that.isActive,_that.branchId,_that.branchName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String phone,  WorkerRole role,  bool isActive,  String? branchId,  String? branchName)  $default,) {final _that = this;
switch (_that) {
case _WorkerProfile():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.role,_that.isActive,_that.branchId,_that.branchName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String phone,  WorkerRole role,  bool isActive,  String? branchId,  String? branchName)?  $default,) {final _that = this;
switch (_that) {
case _WorkerProfile() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.role,_that.isActive,_that.branchId,_that.branchName);case _:
  return null;

}
}

}

/// @nodoc


class _WorkerProfile extends WorkerProfile {
  const _WorkerProfile({required this.id, required this.name, required this.email, required this.phone, required this.role, required this.isActive, this.branchId, this.branchName}): super._();
  

@override final  String id;
@override final  String name;
@override final  String email;
@override final  String phone;
/// Exactly one role. A worker is never both.
@override final  WorkerRole role;
/// False if HQ deactivated the worker. Inactive workers cannot use the
/// Store Worker app.
@override final  bool isActive;
/// The one branch a Packing Staff member is permanently assigned to.
/// Null for Delivery Drivers: they are not tied to a branch and can be
/// given deliveries from any branch.
@override final  String? branchId;
@override final  String? branchName;

/// Create a copy of WorkerProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkerProfileCopyWith<_WorkerProfile> get copyWith => __$WorkerProfileCopyWithImpl<_WorkerProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkerProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,email,phone,role,isActive,branchId,branchName);
}

@override
String toString() {
    return 'WorkerProfile(id: $id, name: $name, email: $email, phone: $phone, role: $role, isActive: $isActive, branchId: $branchId, branchName: $branchName)';
}


}

/// @nodoc
abstract mixin class _$WorkerProfileCopyWith<$Res> implements $WorkerProfileCopyWith<$Res> {
  factory _$WorkerProfileCopyWith(_WorkerProfile value, $Res Function(_WorkerProfile) _then) = __$WorkerProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String phone, WorkerRole role, bool isActive, String? branchId, String? branchName
});




}
/// @nodoc
class __$WorkerProfileCopyWithImpl<$Res>
    implements _$WorkerProfileCopyWith<$Res> {
  __$WorkerProfileCopyWithImpl(this._self, this._then);

  final _WorkerProfile _self;
  final $Res Function(_WorkerProfile) _then;

/// Create a copy of WorkerProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = null,Object? role = null,Object? isActive = null,Object? branchId = freezed,Object? branchName = freezed,}) {
  return _then(_WorkerProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as WorkerRole,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
