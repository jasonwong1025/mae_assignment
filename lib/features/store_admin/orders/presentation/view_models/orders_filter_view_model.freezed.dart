// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'orders_filter_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrdersFilter {

 String get searchText; FulfilmentFilter get fulfilment;
/// Create a copy of OrdersFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrdersFilterCopyWith<OrdersFilter> get copyWith => _$OrdersFilterCopyWithImpl<OrdersFilter>(this as OrdersFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrdersFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrdersFilter&&(identical(other.searchText, _this.searchText) || other.searchText == _this.searchText)&&(identical(other.fulfilment, _this.fulfilment) || other.fulfilment == _this.fulfilment));
}


@override
int get hashCode {
  final _this = this as OrdersFilter;
  return Object.hash(runtimeType,_this.searchText,_this.fulfilment);
}

@override
String toString() {
  final _this = this as OrdersFilter;
  return 'OrdersFilter(searchText: ${_this.searchText}, fulfilment: ${_this.fulfilment})';
}


}

/// @nodoc
abstract mixin class $OrdersFilterCopyWith<$Res>  {
  factory $OrdersFilterCopyWith(OrdersFilter value, $Res Function(OrdersFilter) _then) = _$OrdersFilterCopyWithImpl;
@useResult
$Res call({
 String searchText, FulfilmentFilter fulfilment
});




}
/// @nodoc
class _$OrdersFilterCopyWithImpl<$Res>
    implements $OrdersFilterCopyWith<$Res> {
  _$OrdersFilterCopyWithImpl(this._self, this._then);

  final OrdersFilter _self;
  final $Res Function(OrdersFilter) _then;

/// Create a copy of OrdersFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchText = null,Object? fulfilment = null,}) {
  return _then(OrdersFilter(
searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,fulfilment: null == fulfilment ? _self.fulfilment : fulfilment // ignore: cast_nullable_to_non_nullable
as FulfilmentFilter,
  ));
}

}


/// Adds pattern-matching-related methods to [OrdersFilter].
extension OrdersFilterPatterns on OrdersFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrdersFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrdersFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrdersFilter value)  $default,){
final _that = this;
switch (_that) {
case _OrdersFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrdersFilter value)?  $default,){
final _that = this;
switch (_that) {
case _OrdersFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchText,  FulfilmentFilter fulfilment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrdersFilter() when $default != null:
return $default(_that.searchText,_that.fulfilment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchText,  FulfilmentFilter fulfilment)  $default,) {final _that = this;
switch (_that) {
case _OrdersFilter():
return $default(_that.searchText,_that.fulfilment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchText,  FulfilmentFilter fulfilment)?  $default,) {final _that = this;
switch (_that) {
case _OrdersFilter() when $default != null:
return $default(_that.searchText,_that.fulfilment);case _:
  return null;

}
}

}

/// @nodoc


class _OrdersFilter extends OrdersFilter {
  const _OrdersFilter({this.searchText = '', this.fulfilment = FulfilmentFilter.all}): super._();
  

@override@JsonKey() final  String searchText;
@override@JsonKey() final  FulfilmentFilter fulfilment;

/// Create a copy of OrdersFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrdersFilterCopyWith<_OrdersFilter> get copyWith => __$OrdersFilterCopyWithImpl<_OrdersFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrdersFilter&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.fulfilment, fulfilment) || other.fulfilment == fulfilment));
}


@override
int get hashCode {
    return Object.hash(runtimeType,searchText,fulfilment);
}

@override
String toString() {
    return 'OrdersFilter(searchText: $searchText, fulfilment: $fulfilment)';
}


}

/// @nodoc
abstract mixin class _$OrdersFilterCopyWith<$Res> implements $OrdersFilterCopyWith<$Res> {
  factory _$OrdersFilterCopyWith(_OrdersFilter value, $Res Function(_OrdersFilter) _then) = __$OrdersFilterCopyWithImpl;
@override @useResult
$Res call({
 String searchText, FulfilmentFilter fulfilment
});




}
/// @nodoc
class __$OrdersFilterCopyWithImpl<$Res>
    implements _$OrdersFilterCopyWith<$Res> {
  __$OrdersFilterCopyWithImpl(this._self, this._then);

  final _OrdersFilter _self;
  final $Res Function(_OrdersFilter) _then;

/// Create a copy of OrdersFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchText = null,Object? fulfilment = null,}) {
  return _then(_OrdersFilter(
searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,fulfilment: null == fulfilment ? _self.fulfilment : fulfilment // ignore: cast_nullable_to_non_nullable
as FulfilmentFilter,
  ));
}


}

// dart format on
