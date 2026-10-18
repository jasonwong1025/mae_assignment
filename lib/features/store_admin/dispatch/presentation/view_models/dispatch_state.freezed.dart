// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispatch_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DispatchDriver {

 Driver get worker;/// Null if the driver shares no location.
 DriverLocation? get location;/// Null if free or busy with another branch's order.
 Order? get order;
/// Create a copy of DispatchDriver
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DispatchDriverCopyWith<DispatchDriver> get copyWith => _$DispatchDriverCopyWithImpl<DispatchDriver>(this as DispatchDriver, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DispatchDriver;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DispatchDriver&&(identical(other.worker, _this.worker) || other.worker == _this.worker)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.order, _this.order) || other.order == _this.order));
}


@override
int get hashCode {
  final _this = this as DispatchDriver;
  return Object.hash(runtimeType,_this.worker,_this.location,_this.order);
}

@override
String toString() {
  final _this = this as DispatchDriver;
  return 'DispatchDriver(worker: ${_this.worker}, location: ${_this.location}, order: ${_this.order})';
}


}

/// @nodoc
abstract mixin class $DispatchDriverCopyWith<$Res>  {
  factory $DispatchDriverCopyWith(DispatchDriver value, $Res Function(DispatchDriver) _then) = _$DispatchDriverCopyWithImpl;
@useResult
$Res call({
 Driver worker, DriverLocation? location, Order? order
});


$DriverCopyWith<$Res> get worker;$DriverLocationCopyWith<$Res>? get location;$OrderCopyWith<$Res>? get order;

}
/// @nodoc
class _$DispatchDriverCopyWithImpl<$Res>
    implements $DispatchDriverCopyWith<$Res> {
  _$DispatchDriverCopyWithImpl(this._self, this._then);

  final DispatchDriver _self;
  final $Res Function(DispatchDriver) _then;

/// Create a copy of DispatchDriver
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? worker = null,Object? location = freezed,Object? order = freezed,}) {
  return _then(DispatchDriver(
worker: null == worker ? _self.worker : worker // ignore: cast_nullable_to_non_nullable
as Driver,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as DriverLocation?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as Order?,
  ));
}
/// Create a copy of DispatchDriver
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverCopyWith<$Res> get worker {
  
  return $DriverCopyWith<$Res>(_self.worker, (value) {
    return _then(_self.copyWith(worker: value));
  });
}/// Create a copy of DispatchDriver
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $DriverLocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of DispatchDriver
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderCopyWith<$Res>? get order {
    if (_self.order == null) {
    return null;
  }

  return $OrderCopyWith<$Res>(_self.order!, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}


/// Adds pattern-matching-related methods to [DispatchDriver].
extension DispatchDriverPatterns on DispatchDriver {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DispatchDriver value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DispatchDriver() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DispatchDriver value)  $default,){
final _that = this;
switch (_that) {
case _DispatchDriver():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DispatchDriver value)?  $default,){
final _that = this;
switch (_that) {
case _DispatchDriver() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Driver worker,  DriverLocation? location,  Order? order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DispatchDriver() when $default != null:
return $default(_that.worker,_that.location,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Driver worker,  DriverLocation? location,  Order? order)  $default,) {final _that = this;
switch (_that) {
case _DispatchDriver():
return $default(_that.worker,_that.location,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Driver worker,  DriverLocation? location,  Order? order)?  $default,) {final _that = this;
switch (_that) {
case _DispatchDriver() when $default != null:
return $default(_that.worker,_that.location,_that.order);case _:
  return null;

}
}

}

/// @nodoc


class _DispatchDriver extends DispatchDriver {
  const _DispatchDriver({required this.worker, this.location, this.order}): super._();
  

@override final  Driver worker;
/// Null if the driver shares no location.
@override final  DriverLocation? location;
/// Null if free or busy with another branch's order.
@override final  Order? order;

/// Create a copy of DispatchDriver
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DispatchDriverCopyWith<_DispatchDriver> get copyWith => __$DispatchDriverCopyWithImpl<_DispatchDriver>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DispatchDriver&&(identical(other.worker, worker) || other.worker == worker)&&(identical(other.location, location) || other.location == location)&&(identical(other.order, order) || other.order == order));
}


@override
int get hashCode {
    return Object.hash(runtimeType,worker,location,order);
}

@override
String toString() {
    return 'DispatchDriver(worker: $worker, location: $location, order: $order)';
}


}

/// @nodoc
abstract mixin class _$DispatchDriverCopyWith<$Res> implements $DispatchDriverCopyWith<$Res> {
  factory _$DispatchDriverCopyWith(_DispatchDriver value, $Res Function(_DispatchDriver) _then) = __$DispatchDriverCopyWithImpl;
@override @useResult
$Res call({
 Driver worker, DriverLocation? location, Order? order
});


@override $DriverCopyWith<$Res> get worker;@override $DriverLocationCopyWith<$Res>? get location;@override $OrderCopyWith<$Res>? get order;

}
/// @nodoc
class __$DispatchDriverCopyWithImpl<$Res>
    implements _$DispatchDriverCopyWith<$Res> {
  __$DispatchDriverCopyWithImpl(this._self, this._then);

  final _DispatchDriver _self;
  final $Res Function(_DispatchDriver) _then;

/// Create a copy of DispatchDriver
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? worker = null,Object? location = freezed,Object? order = freezed,}) {
  return _then(_DispatchDriver(
worker: null == worker ? _self.worker : worker // ignore: cast_nullable_to_non_nullable
as Driver,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as DriverLocation?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as Order?,
  ));
}

/// Create a copy of DispatchDriver
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverCopyWith<$Res> get worker {
  
  return $DriverCopyWith<$Res>(_self.worker, (value) {
    return _then(_self.copyWith(worker: value));
  });
}/// Create a copy of DispatchDriver
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $DriverLocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of DispatchDriver
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderCopyWith<$Res>? get order {
    if (_self.order == null) {
    return null;
  }

  return $OrderCopyWith<$Res>(_self.order!, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}

/// @nodoc
mixin _$DispatchState {

 Branch get branch;/// This branch's delivery orders that are ready or on the road.
 List<Order> get deliveries;/// All active drivers.
 List<DispatchDriver> get drivers;
/// Create a copy of DispatchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DispatchStateCopyWith<DispatchState> get copyWith => _$DispatchStateCopyWithImpl<DispatchState>(this as DispatchState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DispatchState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DispatchState&&(identical(other.branch, _this.branch) || other.branch == _this.branch)&&const DeepCollectionEquality().equals(other.deliveries, _this.deliveries)&&const DeepCollectionEquality().equals(other.drivers, _this.drivers));
}


@override
int get hashCode {
  final _this = this as DispatchState;
  return Object.hash(runtimeType,_this.branch,const DeepCollectionEquality().hash(_this.deliveries),const DeepCollectionEquality().hash(_this.drivers));
}

@override
String toString() {
  final _this = this as DispatchState;
  return 'DispatchState(branch: ${_this.branch}, deliveries: ${_this.deliveries}, drivers: ${_this.drivers})';
}


}

/// @nodoc
abstract mixin class $DispatchStateCopyWith<$Res>  {
  factory $DispatchStateCopyWith(DispatchState value, $Res Function(DispatchState) _then) = _$DispatchStateCopyWithImpl;
@useResult
$Res call({
 Branch branch, List<Order> deliveries, List<DispatchDriver> drivers
});


$BranchCopyWith<$Res> get branch;

}
/// @nodoc
class _$DispatchStateCopyWithImpl<$Res>
    implements $DispatchStateCopyWith<$Res> {
  _$DispatchStateCopyWithImpl(this._self, this._then);

  final DispatchState _self;
  final $Res Function(DispatchState) _then;

/// Create a copy of DispatchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? branch = null,Object? deliveries = null,Object? drivers = null,}) {
  return _then(DispatchState(
branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as Branch,deliveries: null == deliveries ? _self.deliveries : deliveries // ignore: cast_nullable_to_non_nullable
as List<Order>,drivers: null == drivers ? _self.drivers : drivers // ignore: cast_nullable_to_non_nullable
as List<DispatchDriver>,
  ));
}
/// Create a copy of DispatchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchCopyWith<$Res> get branch {
  
  return $BranchCopyWith<$Res>(_self.branch, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}


/// Adds pattern-matching-related methods to [DispatchState].
extension DispatchStatePatterns on DispatchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DispatchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DispatchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DispatchState value)  $default,){
final _that = this;
switch (_that) {
case _DispatchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DispatchState value)?  $default,){
final _that = this;
switch (_that) {
case _DispatchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Branch branch,  List<Order> deliveries,  List<DispatchDriver> drivers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DispatchState() when $default != null:
return $default(_that.branch,_that.deliveries,_that.drivers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Branch branch,  List<Order> deliveries,  List<DispatchDriver> drivers)  $default,) {final _that = this;
switch (_that) {
case _DispatchState():
return $default(_that.branch,_that.deliveries,_that.drivers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Branch branch,  List<Order> deliveries,  List<DispatchDriver> drivers)?  $default,) {final _that = this;
switch (_that) {
case _DispatchState() when $default != null:
return $default(_that.branch,_that.deliveries,_that.drivers);case _:
  return null;

}
}

}

/// @nodoc


class _DispatchState extends DispatchState {
  const _DispatchState({required this.branch, required  List<Order> deliveries, required  List<DispatchDriver> drivers}): _deliveries = deliveries,_drivers = drivers,super._();
  

@override final  Branch branch;
/// This branch's delivery orders that are ready or on the road.
 final  List<Order> _deliveries;
/// This branch's delivery orders that are ready or on the road.
@override List<Order> get deliveries {
  if (_deliveries is EqualUnmodifiableListView) return _deliveries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deliveries);
}

/// All active drivers.
 final  List<DispatchDriver> _drivers;
/// All active drivers.
@override List<DispatchDriver> get drivers {
  if (_drivers is EqualUnmodifiableListView) return _drivers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_drivers);
}


/// Create a copy of DispatchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DispatchStateCopyWith<_DispatchState> get copyWith => __$DispatchStateCopyWithImpl<_DispatchState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DispatchState&&(identical(other.branch, branch) || other.branch == branch)&&const DeepCollectionEquality().equals(other.deliveries, _deliveries)&&const DeepCollectionEquality().equals(other.drivers, _drivers));
}


@override
int get hashCode {
    return Object.hash(runtimeType,branch,const DeepCollectionEquality().hash(_deliveries),const DeepCollectionEquality().hash(_drivers));
}

@override
String toString() {
    return 'DispatchState(branch: $branch, deliveries: $deliveries, drivers: $drivers)';
}


}

/// @nodoc
abstract mixin class _$DispatchStateCopyWith<$Res> implements $DispatchStateCopyWith<$Res> {
  factory _$DispatchStateCopyWith(_DispatchState value, $Res Function(_DispatchState) _then) = __$DispatchStateCopyWithImpl;
@override @useResult
$Res call({
 Branch branch, List<Order> deliveries, List<DispatchDriver> drivers
});


@override $BranchCopyWith<$Res> get branch;

}
/// @nodoc
class __$DispatchStateCopyWithImpl<$Res>
    implements _$DispatchStateCopyWith<$Res> {
  __$DispatchStateCopyWithImpl(this._self, this._then);

  final _DispatchState _self;
  final $Res Function(_DispatchState) _then;

/// Create a copy of DispatchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? branch = null,Object? deliveries = null,Object? drivers = null,}) {
  return _then(_DispatchState(
branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as Branch,deliveries: null == deliveries ? _self._deliveries : deliveries // ignore: cast_nullable_to_non_nullable
as List<Order>,drivers: null == drivers ? _self._drivers : drivers // ignore: cast_nullable_to_non_nullable
as List<DispatchDriver>,
  ));
}

/// Create a copy of DispatchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchCopyWith<$Res> get branch {
  
  return $BranchCopyWith<$Res>(_self.branch, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}

// dart format on
