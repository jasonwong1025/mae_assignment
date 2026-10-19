// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_tasks_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeliveryGroups {

/// On the way now; the driver's current job.
 List<Order> get outForDelivery;/// Packed and waiting at the branch for this driver.
 List<Order> get readyToCollect;/// Assigned but still being packed; visible, but cannot be collected yet.
 List<Order> get beingPacked;
/// Create a copy of DeliveryGroups
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryGroupsCopyWith<DeliveryGroups> get copyWith => _$DeliveryGroupsCopyWithImpl<DeliveryGroups>(this as DeliveryGroups, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DeliveryGroups;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeliveryGroups&&const DeepCollectionEquality().equals(other.outForDelivery, _this.outForDelivery)&&const DeepCollectionEquality().equals(other.readyToCollect, _this.readyToCollect)&&const DeepCollectionEquality().equals(other.beingPacked, _this.beingPacked));
}


@override
int get hashCode {
  final _this = this as DeliveryGroups;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.outForDelivery),const DeepCollectionEquality().hash(_this.readyToCollect),const DeepCollectionEquality().hash(_this.beingPacked));
}

@override
String toString() {
  final _this = this as DeliveryGroups;
  return 'DeliveryGroups(outForDelivery: ${_this.outForDelivery}, readyToCollect: ${_this.readyToCollect}, beingPacked: ${_this.beingPacked})';
}


}

/// @nodoc
abstract mixin class $DeliveryGroupsCopyWith<$Res>  {
  factory $DeliveryGroupsCopyWith(DeliveryGroups value, $Res Function(DeliveryGroups) _then) = _$DeliveryGroupsCopyWithImpl;
@useResult
$Res call({
 List<Order> outForDelivery, List<Order> readyToCollect, List<Order> beingPacked
});




}
/// @nodoc
class _$DeliveryGroupsCopyWithImpl<$Res>
    implements $DeliveryGroupsCopyWith<$Res> {
  _$DeliveryGroupsCopyWithImpl(this._self, this._then);

  final DeliveryGroups _self;
  final $Res Function(DeliveryGroups) _then;

/// Create a copy of DeliveryGroups
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? outForDelivery = null,Object? readyToCollect = null,Object? beingPacked = null,}) {
  return _then(DeliveryGroups(
outForDelivery: null == outForDelivery ? _self.outForDelivery : outForDelivery // ignore: cast_nullable_to_non_nullable
as List<Order>,readyToCollect: null == readyToCollect ? _self.readyToCollect : readyToCollect // ignore: cast_nullable_to_non_nullable
as List<Order>,beingPacked: null == beingPacked ? _self.beingPacked : beingPacked // ignore: cast_nullable_to_non_nullable
as List<Order>,
  ));
}

}


/// Adds pattern-matching-related methods to [DeliveryGroups].
extension DeliveryGroupsPatterns on DeliveryGroups {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeliveryGroups value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeliveryGroups() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeliveryGroups value)  $default,){
final _that = this;
switch (_that) {
case _DeliveryGroups():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeliveryGroups value)?  $default,){
final _that = this;
switch (_that) {
case _DeliveryGroups() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Order> outForDelivery,  List<Order> readyToCollect,  List<Order> beingPacked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeliveryGroups() when $default != null:
return $default(_that.outForDelivery,_that.readyToCollect,_that.beingPacked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Order> outForDelivery,  List<Order> readyToCollect,  List<Order> beingPacked)  $default,) {final _that = this;
switch (_that) {
case _DeliveryGroups():
return $default(_that.outForDelivery,_that.readyToCollect,_that.beingPacked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Order> outForDelivery,  List<Order> readyToCollect,  List<Order> beingPacked)?  $default,) {final _that = this;
switch (_that) {
case _DeliveryGroups() when $default != null:
return $default(_that.outForDelivery,_that.readyToCollect,_that.beingPacked);case _:
  return null;

}
}

}

/// @nodoc


class _DeliveryGroups extends DeliveryGroups {
  const _DeliveryGroups({ List<Order> outForDelivery = const <Order>[],  List<Order> readyToCollect = const <Order>[],  List<Order> beingPacked = const <Order>[]}): _outForDelivery = outForDelivery,_readyToCollect = readyToCollect,_beingPacked = beingPacked,super._();
  

/// On the way now; the driver's current job.
 final  List<Order> _outForDelivery;
/// On the way now; the driver's current job.
@override@JsonKey() List<Order> get outForDelivery {
  if (_outForDelivery is EqualUnmodifiableListView) return _outForDelivery;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_outForDelivery);
}

/// Packed and waiting at the branch for this driver.
 final  List<Order> _readyToCollect;
/// Packed and waiting at the branch for this driver.
@override@JsonKey() List<Order> get readyToCollect {
  if (_readyToCollect is EqualUnmodifiableListView) return _readyToCollect;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_readyToCollect);
}

/// Assigned but still being packed; visible, but cannot be collected yet.
 final  List<Order> _beingPacked;
/// Assigned but still being packed; visible, but cannot be collected yet.
@override@JsonKey() List<Order> get beingPacked {
  if (_beingPacked is EqualUnmodifiableListView) return _beingPacked;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_beingPacked);
}


/// Create a copy of DeliveryGroups
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryGroupsCopyWith<_DeliveryGroups> get copyWith => __$DeliveryGroupsCopyWithImpl<_DeliveryGroups>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeliveryGroups&&const DeepCollectionEquality().equals(other.outForDelivery, _outForDelivery)&&const DeepCollectionEquality().equals(other.readyToCollect, _readyToCollect)&&const DeepCollectionEquality().equals(other.beingPacked, _beingPacked));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_outForDelivery),const DeepCollectionEquality().hash(_readyToCollect),const DeepCollectionEquality().hash(_beingPacked));
}

@override
String toString() {
    return 'DeliveryGroups(outForDelivery: $outForDelivery, readyToCollect: $readyToCollect, beingPacked: $beingPacked)';
}


}

/// @nodoc
abstract mixin class _$DeliveryGroupsCopyWith<$Res> implements $DeliveryGroupsCopyWith<$Res> {
  factory _$DeliveryGroupsCopyWith(_DeliveryGroups value, $Res Function(_DeliveryGroups) _then) = __$DeliveryGroupsCopyWithImpl;
@override @useResult
$Res call({
 List<Order> outForDelivery, List<Order> readyToCollect, List<Order> beingPacked
});




}
/// @nodoc
class __$DeliveryGroupsCopyWithImpl<$Res>
    implements _$DeliveryGroupsCopyWith<$Res> {
  __$DeliveryGroupsCopyWithImpl(this._self, this._then);

  final _DeliveryGroups _self;
  final $Res Function(_DeliveryGroups) _then;

/// Create a copy of DeliveryGroups
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? outForDelivery = null,Object? readyToCollect = null,Object? beingPacked = null,}) {
  return _then(_DeliveryGroups(
outForDelivery: null == outForDelivery ? _self._outForDelivery : outForDelivery // ignore: cast_nullable_to_non_nullable
as List<Order>,readyToCollect: null == readyToCollect ? _self._readyToCollect : readyToCollect // ignore: cast_nullable_to_non_nullable
as List<Order>,beingPacked: null == beingPacked ? _self._beingPacked : beingPacked // ignore: cast_nullable_to_non_nullable
as List<Order>,
  ));
}


}

// dart format on
