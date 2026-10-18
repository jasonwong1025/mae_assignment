// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_filter_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SalesFilter {

 SalesPeriod get period;/// Page of the top products table. The first page is 1.
 int get page;
/// Create a copy of SalesFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesFilterCopyWith<SalesFilter> get copyWith => _$SalesFilterCopyWithImpl<SalesFilter>(this as SalesFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SalesFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesFilter&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.page, _this.page) || other.page == _this.page));
}


@override
int get hashCode {
  final _this = this as SalesFilter;
  return Object.hash(runtimeType,_this.period,_this.page);
}

@override
String toString() {
  final _this = this as SalesFilter;
  return 'SalesFilter(period: ${_this.period}, page: ${_this.page})';
}


}

/// @nodoc
abstract mixin class $SalesFilterCopyWith<$Res>  {
  factory $SalesFilterCopyWith(SalesFilter value, $Res Function(SalesFilter) _then) = _$SalesFilterCopyWithImpl;
@useResult
$Res call({
 SalesPeriod period, int page
});


$SalesPeriodCopyWith<$Res> get period;

}
/// @nodoc
class _$SalesFilterCopyWithImpl<$Res>
    implements $SalesFilterCopyWith<$Res> {
  _$SalesFilterCopyWithImpl(this._self, this._then);

  final SalesFilter _self;
  final $Res Function(SalesFilter) _then;

/// Create a copy of SalesFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? page = null,}) {
  return _then(SalesFilter(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as SalesPeriod,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SalesFilter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesPeriodCopyWith<$Res> get period {
  
  return $SalesPeriodCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// Adds pattern-matching-related methods to [SalesFilter].
extension SalesFilterPatterns on SalesFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesFilter value)  $default,){
final _that = this;
switch (_that) {
case _SalesFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesFilter value)?  $default,){
final _that = this;
switch (_that) {
case _SalesFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SalesPeriod period,  int page)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesFilter() when $default != null:
return $default(_that.period,_that.page);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SalesPeriod period,  int page)  $default,) {final _that = this;
switch (_that) {
case _SalesFilter():
return $default(_that.period,_that.page);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SalesPeriod period,  int page)?  $default,) {final _that = this;
switch (_that) {
case _SalesFilter() when $default != null:
return $default(_that.period,_that.page);case _:
  return null;

}
}

}

/// @nodoc


class _SalesFilter extends SalesFilter {
  const _SalesFilter({required this.period, this.page = 1}): super._();
  

@override final  SalesPeriod period;
/// Page of the top products table. The first page is 1.
@override@JsonKey() final  int page;

/// Create a copy of SalesFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesFilterCopyWith<_SalesFilter> get copyWith => __$SalesFilterCopyWithImpl<_SalesFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesFilter&&(identical(other.period, period) || other.period == period)&&(identical(other.page, page) || other.page == page));
}


@override
int get hashCode {
    return Object.hash(runtimeType,period,page);
}

@override
String toString() {
    return 'SalesFilter(period: $period, page: $page)';
}


}

/// @nodoc
abstract mixin class _$SalesFilterCopyWith<$Res> implements $SalesFilterCopyWith<$Res> {
  factory _$SalesFilterCopyWith(_SalesFilter value, $Res Function(_SalesFilter) _then) = __$SalesFilterCopyWithImpl;
@override @useResult
$Res call({
 SalesPeriod period, int page
});


@override $SalesPeriodCopyWith<$Res> get period;

}
/// @nodoc
class __$SalesFilterCopyWithImpl<$Res>
    implements _$SalesFilterCopyWith<$Res> {
  __$SalesFilterCopyWithImpl(this._self, this._then);

  final _SalesFilter _self;
  final $Res Function(_SalesFilter) _then;

/// Create a copy of SalesFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? page = null,}) {
  return _then(_SalesFilter(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as SalesPeriod,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SalesFilter
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesPeriodCopyWith<$Res> get period {
  
  return $SalesPeriodCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}

// dart format on
