// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grocery_list_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddToCartResult {

/// How many list items went to the cart.
 int get added;/// Items that stayed on the list (not found or sold out here).
 int get left;/// Items added with a smaller quantity than asked for, because the store
/// has less in stock.
 int get reduced;
/// Create a copy of AddToCartResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddToCartResultCopyWith<AddToCartResult> get copyWith => _$AddToCartResultCopyWithImpl<AddToCartResult>(this as AddToCartResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AddToCartResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddToCartResult&&(identical(other.added, _this.added) || other.added == _this.added)&&(identical(other.left, _this.left) || other.left == _this.left)&&(identical(other.reduced, _this.reduced) || other.reduced == _this.reduced));
}


@override
int get hashCode {
  final _this = this as AddToCartResult;
  return Object.hash(runtimeType,_this.added,_this.left,_this.reduced);
}

@override
String toString() {
  final _this = this as AddToCartResult;
  return 'AddToCartResult(added: ${_this.added}, left: ${_this.left}, reduced: ${_this.reduced})';
}


}

/// @nodoc
abstract mixin class $AddToCartResultCopyWith<$Res>  {
  factory $AddToCartResultCopyWith(AddToCartResult value, $Res Function(AddToCartResult) _then) = _$AddToCartResultCopyWithImpl;
@useResult
$Res call({
 int added, int left, int reduced
});




}
/// @nodoc
class _$AddToCartResultCopyWithImpl<$Res>
    implements $AddToCartResultCopyWith<$Res> {
  _$AddToCartResultCopyWithImpl(this._self, this._then);

  final AddToCartResult _self;
  final $Res Function(AddToCartResult) _then;

/// Create a copy of AddToCartResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? added = null,Object? left = null,Object? reduced = null,}) {
  return _then(AddToCartResult(
added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int,left: null == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as int,reduced: null == reduced ? _self.reduced : reduced // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AddToCartResult].
extension AddToCartResultPatterns on AddToCartResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddToCartResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddToCartResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddToCartResult value)  $default,){
final _that = this;
switch (_that) {
case _AddToCartResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddToCartResult value)?  $default,){
final _that = this;
switch (_that) {
case _AddToCartResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int added,  int left,  int reduced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddToCartResult() when $default != null:
return $default(_that.added,_that.left,_that.reduced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int added,  int left,  int reduced)  $default,) {final _that = this;
switch (_that) {
case _AddToCartResult():
return $default(_that.added,_that.left,_that.reduced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int added,  int left,  int reduced)?  $default,) {final _that = this;
switch (_that) {
case _AddToCartResult() when $default != null:
return $default(_that.added,_that.left,_that.reduced);case _:
  return null;

}
}

}

/// @nodoc


class _AddToCartResult implements AddToCartResult {
  const _AddToCartResult({this.added = 0, this.left = 0, this.reduced = 0});
  

/// How many list items went to the cart.
@override@JsonKey() final  int added;
/// Items that stayed on the list (not found or sold out here).
@override@JsonKey() final  int left;
/// Items added with a smaller quantity than asked for, because the store
/// has less in stock.
@override@JsonKey() final  int reduced;

/// Create a copy of AddToCartResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddToCartResultCopyWith<_AddToCartResult> get copyWith => __$AddToCartResultCopyWithImpl<_AddToCartResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddToCartResult&&(identical(other.added, added) || other.added == added)&&(identical(other.left, left) || other.left == left)&&(identical(other.reduced, reduced) || other.reduced == reduced));
}


@override
int get hashCode {
    return Object.hash(runtimeType,added,left,reduced);
}

@override
String toString() {
    return 'AddToCartResult(added: $added, left: $left, reduced: $reduced)';
}


}

/// @nodoc
abstract mixin class _$AddToCartResultCopyWith<$Res> implements $AddToCartResultCopyWith<$Res> {
  factory _$AddToCartResultCopyWith(_AddToCartResult value, $Res Function(_AddToCartResult) _then) = __$AddToCartResultCopyWithImpl;
@override @useResult
$Res call({
 int added, int left, int reduced
});




}
/// @nodoc
class __$AddToCartResultCopyWithImpl<$Res>
    implements _$AddToCartResultCopyWith<$Res> {
  __$AddToCartResultCopyWithImpl(this._self, this._then);

  final _AddToCartResult _self;
  final $Res Function(_AddToCartResult) _then;

/// Create a copy of AddToCartResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? added = null,Object? left = null,Object? reduced = null,}) {
  return _then(_AddToCartResult(
added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int,left: null == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as int,reduced: null == reduced ? _self.reduced : reduced // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
