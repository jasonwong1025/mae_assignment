// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_actions_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReorderResult {

/// A message for the screen when nothing could be added; null on success.
 String? get error;/// How many products were added to the cart.
 int get addedCount;/// Names of products that are no longer sold (or are out of stock) at the
/// order's store, so were left out.
 List<String> get unavailable;
/// Create a copy of ReorderResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReorderResultCopyWith<ReorderResult> get copyWith => _$ReorderResultCopyWithImpl<ReorderResult>(this as ReorderResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReorderResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReorderResult&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.addedCount, _this.addedCount) || other.addedCount == _this.addedCount)&&const DeepCollectionEquality().equals(other.unavailable, _this.unavailable));
}


@override
int get hashCode {
  final _this = this as ReorderResult;
  return Object.hash(runtimeType,_this.error,_this.addedCount,const DeepCollectionEquality().hash(_this.unavailable));
}

@override
String toString() {
  final _this = this as ReorderResult;
  return 'ReorderResult(error: ${_this.error}, addedCount: ${_this.addedCount}, unavailable: ${_this.unavailable})';
}


}

/// @nodoc
abstract mixin class $ReorderResultCopyWith<$Res>  {
  factory $ReorderResultCopyWith(ReorderResult value, $Res Function(ReorderResult) _then) = _$ReorderResultCopyWithImpl;
@useResult
$Res call({
 String? error, int addedCount, List<String> unavailable
});




}
/// @nodoc
class _$ReorderResultCopyWithImpl<$Res>
    implements $ReorderResultCopyWith<$Res> {
  _$ReorderResultCopyWithImpl(this._self, this._then);

  final ReorderResult _self;
  final $Res Function(ReorderResult) _then;

/// Create a copy of ReorderResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? error = freezed,Object? addedCount = null,Object? unavailable = null,}) {
  return _then(ReorderResult(
error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,addedCount: null == addedCount ? _self.addedCount : addedCount // ignore: cast_nullable_to_non_nullable
as int,unavailable: null == unavailable ? _self.unavailable : unavailable // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReorderResult].
extension ReorderResultPatterns on ReorderResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReorderResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReorderResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReorderResult value)  $default,){
final _that = this;
switch (_that) {
case _ReorderResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReorderResult value)?  $default,){
final _that = this;
switch (_that) {
case _ReorderResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? error,  int addedCount,  List<String> unavailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReorderResult() when $default != null:
return $default(_that.error,_that.addedCount,_that.unavailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? error,  int addedCount,  List<String> unavailable)  $default,) {final _that = this;
switch (_that) {
case _ReorderResult():
return $default(_that.error,_that.addedCount,_that.unavailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? error,  int addedCount,  List<String> unavailable)?  $default,) {final _that = this;
switch (_that) {
case _ReorderResult() when $default != null:
return $default(_that.error,_that.addedCount,_that.unavailable);case _:
  return null;

}
}

}

/// @nodoc


class _ReorderResult extends ReorderResult {
  const _ReorderResult({this.error, this.addedCount = 0,  List<String> unavailable = const <String>[]}): _unavailable = unavailable,super._();
  

/// A message for the screen when nothing could be added; null on success.
@override final  String? error;
/// How many products were added to the cart.
@override@JsonKey() final  int addedCount;
/// Names of products that are no longer sold (or are out of stock) at the
/// order's store, so were left out.
 final  List<String> _unavailable;
/// Names of products that are no longer sold (or are out of stock) at the
/// order's store, so were left out.
@override@JsonKey() List<String> get unavailable {
  if (_unavailable is EqualUnmodifiableListView) return _unavailable;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unavailable);
}


/// Create a copy of ReorderResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReorderResultCopyWith<_ReorderResult> get copyWith => __$ReorderResultCopyWithImpl<_ReorderResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReorderResult&&(identical(other.error, error) || other.error == error)&&(identical(other.addedCount, addedCount) || other.addedCount == addedCount)&&const DeepCollectionEquality().equals(other.unavailable, _unavailable));
}


@override
int get hashCode {
    return Object.hash(runtimeType,error,addedCount,const DeepCollectionEquality().hash(_unavailable));
}

@override
String toString() {
    return 'ReorderResult(error: $error, addedCount: $addedCount, unavailable: $unavailable)';
}


}

/// @nodoc
abstract mixin class _$ReorderResultCopyWith<$Res> implements $ReorderResultCopyWith<$Res> {
  factory _$ReorderResultCopyWith(_ReorderResult value, $Res Function(_ReorderResult) _then) = __$ReorderResultCopyWithImpl;
@override @useResult
$Res call({
 String? error, int addedCount, List<String> unavailable
});




}
/// @nodoc
class __$ReorderResultCopyWithImpl<$Res>
    implements _$ReorderResultCopyWith<$Res> {
  __$ReorderResultCopyWithImpl(this._self, this._then);

  final _ReorderResult _self;
  final $Res Function(_ReorderResult) _then;

/// Create a copy of ReorderResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? error = freezed,Object? addedCount = null,Object? unavailable = null,}) {
  return _then(_ReorderResult(
error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,addedCount: null == addedCount ? _self.addedCount : addedCount // ignore: cast_nullable_to_non_nullable
as int,unavailable: null == unavailable ? _self._unavailable : unavailable // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
