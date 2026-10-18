// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DayHours {

 int get opensAt; int get closesAt;/// True if the branch does not open on this day.
 bool get isClosed;
/// Create a copy of DayHours
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayHoursCopyWith<DayHours> get copyWith => _$DayHoursCopyWithImpl<DayHours>(this as DayHours, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DayHours;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayHours&&(identical(other.opensAt, _this.opensAt) || other.opensAt == _this.opensAt)&&(identical(other.closesAt, _this.closesAt) || other.closesAt == _this.closesAt)&&(identical(other.isClosed, _this.isClosed) || other.isClosed == _this.isClosed));
}


@override
int get hashCode {
  final _this = this as DayHours;
  return Object.hash(runtimeType,_this.opensAt,_this.closesAt,_this.isClosed);
}

@override
String toString() {
  final _this = this as DayHours;
  return 'DayHours(opensAt: ${_this.opensAt}, closesAt: ${_this.closesAt}, isClosed: ${_this.isClosed})';
}


}

/// @nodoc
abstract mixin class $DayHoursCopyWith<$Res>  {
  factory $DayHoursCopyWith(DayHours value, $Res Function(DayHours) _then) = _$DayHoursCopyWithImpl;
@useResult
$Res call({
 int opensAt, int closesAt, bool isClosed
});




}
/// @nodoc
class _$DayHoursCopyWithImpl<$Res>
    implements $DayHoursCopyWith<$Res> {
  _$DayHoursCopyWithImpl(this._self, this._then);

  final DayHours _self;
  final $Res Function(DayHours) _then;

/// Create a copy of DayHours
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? opensAt = null,Object? closesAt = null,Object? isClosed = null,}) {
  return _then(DayHours(
opensAt: null == opensAt ? _self.opensAt : opensAt // ignore: cast_nullable_to_non_nullable
as int,closesAt: null == closesAt ? _self.closesAt : closesAt // ignore: cast_nullable_to_non_nullable
as int,isClosed: null == isClosed ? _self.isClosed : isClosed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DayHours].
extension DayHoursPatterns on DayHours {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayHours value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayHours() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayHours value)  $default,){
final _that = this;
switch (_that) {
case _DayHours():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayHours value)?  $default,){
final _that = this;
switch (_that) {
case _DayHours() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int opensAt,  int closesAt,  bool isClosed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayHours() when $default != null:
return $default(_that.opensAt,_that.closesAt,_that.isClosed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int opensAt,  int closesAt,  bool isClosed)  $default,) {final _that = this;
switch (_that) {
case _DayHours():
return $default(_that.opensAt,_that.closesAt,_that.isClosed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int opensAt,  int closesAt,  bool isClosed)?  $default,) {final _that = this;
switch (_that) {
case _DayHours() when $default != null:
return $default(_that.opensAt,_that.closesAt,_that.isClosed);case _:
  return null;

}
}

}

/// @nodoc


class _DayHours extends DayHours {
  const _DayHours({required this.opensAt, required this.closesAt, this.isClosed = false}): super._();
  

@override final  int opensAt;
@override final  int closesAt;
/// True if the branch does not open on this day.
@override@JsonKey() final  bool isClosed;

/// Create a copy of DayHours
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayHoursCopyWith<_DayHours> get copyWith => __$DayHoursCopyWithImpl<_DayHours>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayHours&&(identical(other.opensAt, opensAt) || other.opensAt == opensAt)&&(identical(other.closesAt, closesAt) || other.closesAt == closesAt)&&(identical(other.isClosed, isClosed) || other.isClosed == isClosed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,opensAt,closesAt,isClosed);
}

@override
String toString() {
    return 'DayHours(opensAt: $opensAt, closesAt: $closesAt, isClosed: $isClosed)';
}


}

/// @nodoc
abstract mixin class _$DayHoursCopyWith<$Res> implements $DayHoursCopyWith<$Res> {
  factory _$DayHoursCopyWith(_DayHours value, $Res Function(_DayHours) _then) = __$DayHoursCopyWithImpl;
@override @useResult
$Res call({
 int opensAt, int closesAt, bool isClosed
});




}
/// @nodoc
class __$DayHoursCopyWithImpl<$Res>
    implements _$DayHoursCopyWith<$Res> {
  __$DayHoursCopyWithImpl(this._self, this._then);

  final _DayHours _self;
  final $Res Function(_DayHours) _then;

/// Create a copy of DayHours
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? opensAt = null,Object? closesAt = null,Object? isClosed = null,}) {
  return _then(_DayHours(
opensAt: null == opensAt ? _self.opensAt : opensAt // ignore: cast_nullable_to_non_nullable
as int,closesAt: null == closesAt ? _self.closesAt : closesAt // ignore: cast_nullable_to_non_nullable
as int,isClosed: null == isClosed ? _self.isClosed : isClosed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$Branch {

 String get id; String get name; String get address; String get phone;/// Where the store is on the map.
 LatLng get location;/// Hours for Monday to Sunday (7 items, Monday first).
 List<DayHours> get weeklyHours;/// Furthest road distance the branch delivers to.
 double get maxDeliveryKm;/// Delivery fee = base fee + fee per km (road distance), in ringgit.
 double get baseDeliveryFee; double get feePerKm;/// True if customers cannot place new orders here for now.
 bool get isTemporarilyClosed;
/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchCopyWith<Branch> get copyWith => _$BranchCopyWithImpl<Branch>(this as Branch, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Branch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Branch&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.location, _this.location) || other.location == _this.location)&&const DeepCollectionEquality().equals(other.weeklyHours, _this.weeklyHours)&&(identical(other.maxDeliveryKm, _this.maxDeliveryKm) || other.maxDeliveryKm == _this.maxDeliveryKm)&&(identical(other.baseDeliveryFee, _this.baseDeliveryFee) || other.baseDeliveryFee == _this.baseDeliveryFee)&&(identical(other.feePerKm, _this.feePerKm) || other.feePerKm == _this.feePerKm)&&(identical(other.isTemporarilyClosed, _this.isTemporarilyClosed) || other.isTemporarilyClosed == _this.isTemporarilyClosed));
}


@override
int get hashCode {
  final _this = this as Branch;
  return Object.hash(runtimeType,_this.id,_this.name,_this.address,_this.phone,_this.location,const DeepCollectionEquality().hash(_this.weeklyHours),_this.maxDeliveryKm,_this.baseDeliveryFee,_this.feePerKm,_this.isTemporarilyClosed);
}

@override
String toString() {
  final _this = this as Branch;
  return 'Branch(id: ${_this.id}, name: ${_this.name}, address: ${_this.address}, phone: ${_this.phone}, location: ${_this.location}, weeklyHours: ${_this.weeklyHours}, maxDeliveryKm: ${_this.maxDeliveryKm}, baseDeliveryFee: ${_this.baseDeliveryFee}, feePerKm: ${_this.feePerKm}, isTemporarilyClosed: ${_this.isTemporarilyClosed})';
}


}

/// @nodoc
abstract mixin class $BranchCopyWith<$Res>  {
  factory $BranchCopyWith(Branch value, $Res Function(Branch) _then) = _$BranchCopyWithImpl;
@useResult
$Res call({
 String id, String name, String address, String phone, LatLng location, List<DayHours> weeklyHours, double maxDeliveryKm, double baseDeliveryFee, double feePerKm, bool isTemporarilyClosed
});




}
/// @nodoc
class _$BranchCopyWithImpl<$Res>
    implements $BranchCopyWith<$Res> {
  _$BranchCopyWithImpl(this._self, this._then);

  final Branch _self;
  final $Res Function(Branch) _then;

/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? address = null,Object? phone = null,Object? location = null,Object? weeklyHours = null,Object? maxDeliveryKm = null,Object? baseDeliveryFee = null,Object? feePerKm = null,Object? isTemporarilyClosed = null,}) {
  return _then(Branch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng,weeklyHours: null == weeklyHours ? _self.weeklyHours : weeklyHours // ignore: cast_nullable_to_non_nullable
as List<DayHours>,maxDeliveryKm: null == maxDeliveryKm ? _self.maxDeliveryKm : maxDeliveryKm // ignore: cast_nullable_to_non_nullable
as double,baseDeliveryFee: null == baseDeliveryFee ? _self.baseDeliveryFee : baseDeliveryFee // ignore: cast_nullable_to_non_nullable
as double,feePerKm: null == feePerKm ? _self.feePerKm : feePerKm // ignore: cast_nullable_to_non_nullable
as double,isTemporarilyClosed: null == isTemporarilyClosed ? _self.isTemporarilyClosed : isTemporarilyClosed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Branch].
extension BranchPatterns on Branch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Branch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Branch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Branch value)  $default,){
final _that = this;
switch (_that) {
case _Branch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Branch value)?  $default,){
final _that = this;
switch (_that) {
case _Branch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String phone,  LatLng location,  List<DayHours> weeklyHours,  double maxDeliveryKm,  double baseDeliveryFee,  double feePerKm,  bool isTemporarilyClosed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Branch() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.phone,_that.location,_that.weeklyHours,_that.maxDeliveryKm,_that.baseDeliveryFee,_that.feePerKm,_that.isTemporarilyClosed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String address,  String phone,  LatLng location,  List<DayHours> weeklyHours,  double maxDeliveryKm,  double baseDeliveryFee,  double feePerKm,  bool isTemporarilyClosed)  $default,) {final _that = this;
switch (_that) {
case _Branch():
return $default(_that.id,_that.name,_that.address,_that.phone,_that.location,_that.weeklyHours,_that.maxDeliveryKm,_that.baseDeliveryFee,_that.feePerKm,_that.isTemporarilyClosed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String address,  String phone,  LatLng location,  List<DayHours> weeklyHours,  double maxDeliveryKm,  double baseDeliveryFee,  double feePerKm,  bool isTemporarilyClosed)?  $default,) {final _that = this;
switch (_that) {
case _Branch() when $default != null:
return $default(_that.id,_that.name,_that.address,_that.phone,_that.location,_that.weeklyHours,_that.maxDeliveryKm,_that.baseDeliveryFee,_that.feePerKm,_that.isTemporarilyClosed);case _:
  return null;

}
}

}

/// @nodoc


class _Branch extends Branch {
  const _Branch({required this.id, required this.name, required this.address, required this.phone, required this.location, required  List<DayHours> weeklyHours, required this.maxDeliveryKm, required this.baseDeliveryFee, required this.feePerKm, this.isTemporarilyClosed = false}): _weeklyHours = weeklyHours,super._();
  

@override final  String id;
@override final  String name;
@override final  String address;
@override final  String phone;
/// Where the store is on the map.
@override final  LatLng location;
/// Hours for Monday to Sunday (7 items, Monday first).
 final  List<DayHours> _weeklyHours;
/// Hours for Monday to Sunday (7 items, Monday first).
@override List<DayHours> get weeklyHours {
  if (_weeklyHours is EqualUnmodifiableListView) return _weeklyHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weeklyHours);
}

/// Furthest road distance the branch delivers to.
@override final  double maxDeliveryKm;
/// Delivery fee = base fee + fee per km (road distance), in ringgit.
@override final  double baseDeliveryFee;
@override final  double feePerKm;
/// True if customers cannot place new orders here for now.
@override@JsonKey() final  bool isTemporarilyClosed;

/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BranchCopyWith<_Branch> get copyWith => __$BranchCopyWithImpl<_Branch>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Branch&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.weeklyHours, _weeklyHours)&&(identical(other.maxDeliveryKm, maxDeliveryKm) || other.maxDeliveryKm == maxDeliveryKm)&&(identical(other.baseDeliveryFee, baseDeliveryFee) || other.baseDeliveryFee == baseDeliveryFee)&&(identical(other.feePerKm, feePerKm) || other.feePerKm == feePerKm)&&(identical(other.isTemporarilyClosed, isTemporarilyClosed) || other.isTemporarilyClosed == isTemporarilyClosed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,address,phone,location,const DeepCollectionEquality().hash(_weeklyHours),maxDeliveryKm,baseDeliveryFee,feePerKm,isTemporarilyClosed);
}

@override
String toString() {
    return 'Branch(id: $id, name: $name, address: $address, phone: $phone, location: $location, weeklyHours: $weeklyHours, maxDeliveryKm: $maxDeliveryKm, baseDeliveryFee: $baseDeliveryFee, feePerKm: $feePerKm, isTemporarilyClosed: $isTemporarilyClosed)';
}


}

/// @nodoc
abstract mixin class _$BranchCopyWith<$Res> implements $BranchCopyWith<$Res> {
  factory _$BranchCopyWith(_Branch value, $Res Function(_Branch) _then) = __$BranchCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String address, String phone, LatLng location, List<DayHours> weeklyHours, double maxDeliveryKm, double baseDeliveryFee, double feePerKm, bool isTemporarilyClosed
});




}
/// @nodoc
class __$BranchCopyWithImpl<$Res>
    implements _$BranchCopyWith<$Res> {
  __$BranchCopyWithImpl(this._self, this._then);

  final _Branch _self;
  final $Res Function(_Branch) _then;

/// Create a copy of Branch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? address = null,Object? phone = null,Object? location = null,Object? weeklyHours = null,Object? maxDeliveryKm = null,Object? baseDeliveryFee = null,Object? feePerKm = null,Object? isTemporarilyClosed = null,}) {
  return _then(_Branch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng,weeklyHours: null == weeklyHours ? _self._weeklyHours : weeklyHours // ignore: cast_nullable_to_non_nullable
as List<DayHours>,maxDeliveryKm: null == maxDeliveryKm ? _self.maxDeliveryKm : maxDeliveryKm // ignore: cast_nullable_to_non_nullable
as double,baseDeliveryFee: null == baseDeliveryFee ? _self.baseDeliveryFee : baseDeliveryFee // ignore: cast_nullable_to_non_nullable
as double,feePerKm: null == feePerKm ? _self.feePerKm : feePerKm // ignore: cast_nullable_to_non_nullable
as double,isTemporarilyClosed: null == isTemporarilyClosed ? _self.isTemporarilyClosed : isTemporarilyClosed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
