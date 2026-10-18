// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SalesState {

 SalesReport get report;/// One page of the best-selling products.
 PageResult<ProductSales> get topProducts;
/// Create a copy of SalesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesStateCopyWith<SalesState> get copyWith => _$SalesStateCopyWithImpl<SalesState>(this as SalesState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SalesState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesState&&(identical(other.report, _this.report) || other.report == _this.report)&&(identical(other.topProducts, _this.topProducts) || other.topProducts == _this.topProducts));
}


@override
int get hashCode {
  final _this = this as SalesState;
  return Object.hash(runtimeType,_this.report,_this.topProducts);
}

@override
String toString() {
  final _this = this as SalesState;
  return 'SalesState(report: ${_this.report}, topProducts: ${_this.topProducts})';
}


}

/// @nodoc
abstract mixin class $SalesStateCopyWith<$Res>  {
  factory $SalesStateCopyWith(SalesState value, $Res Function(SalesState) _then) = _$SalesStateCopyWithImpl;
@useResult
$Res call({
 SalesReport report, PageResult<ProductSales> topProducts
});


$SalesReportCopyWith<$Res> get report;$PageResultCopyWith<ProductSales, $Res> get topProducts;

}
/// @nodoc
class _$SalesStateCopyWithImpl<$Res>
    implements $SalesStateCopyWith<$Res> {
  _$SalesStateCopyWithImpl(this._self, this._then);

  final SalesState _self;
  final $Res Function(SalesState) _then;

/// Create a copy of SalesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? report = null,Object? topProducts = null,}) {
  return _then(SalesState(
report: null == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as SalesReport,topProducts: null == topProducts ? _self.topProducts : topProducts // ignore: cast_nullable_to_non_nullable
as PageResult<ProductSales>,
  ));
}
/// Create a copy of SalesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesReportCopyWith<$Res> get report {
  
  return $SalesReportCopyWith<$Res>(_self.report, (value) {
    return _then(_self.copyWith(report: value));
  });
}/// Create a copy of SalesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageResultCopyWith<ProductSales, $Res> get topProducts {
  
  return $PageResultCopyWith<ProductSales, $Res>(_self.topProducts, (value) {
    return _then(_self.copyWith(topProducts: value));
  });
}
}


/// Adds pattern-matching-related methods to [SalesState].
extension SalesStatePatterns on SalesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesState value)  $default,){
final _that = this;
switch (_that) {
case _SalesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesState value)?  $default,){
final _that = this;
switch (_that) {
case _SalesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SalesReport report,  PageResult<ProductSales> topProducts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesState() when $default != null:
return $default(_that.report,_that.topProducts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SalesReport report,  PageResult<ProductSales> topProducts)  $default,) {final _that = this;
switch (_that) {
case _SalesState():
return $default(_that.report,_that.topProducts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SalesReport report,  PageResult<ProductSales> topProducts)?  $default,) {final _that = this;
switch (_that) {
case _SalesState() when $default != null:
return $default(_that.report,_that.topProducts);case _:
  return null;

}
}

}

/// @nodoc


class _SalesState extends SalesState {
  const _SalesState({required this.report, required this.topProducts}): super._();
  

@override final  SalesReport report;
/// One page of the best-selling products.
@override final  PageResult<ProductSales> topProducts;

/// Create a copy of SalesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesStateCopyWith<_SalesState> get copyWith => __$SalesStateCopyWithImpl<_SalesState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesState&&(identical(other.report, report) || other.report == report)&&(identical(other.topProducts, topProducts) || other.topProducts == topProducts));
}


@override
int get hashCode {
    return Object.hash(runtimeType,report,topProducts);
}

@override
String toString() {
    return 'SalesState(report: $report, topProducts: $topProducts)';
}


}

/// @nodoc
abstract mixin class _$SalesStateCopyWith<$Res> implements $SalesStateCopyWith<$Res> {
  factory _$SalesStateCopyWith(_SalesState value, $Res Function(_SalesState) _then) = __$SalesStateCopyWithImpl;
@override @useResult
$Res call({
 SalesReport report, PageResult<ProductSales> topProducts
});


@override $SalesReportCopyWith<$Res> get report;@override $PageResultCopyWith<ProductSales, $Res> get topProducts;

}
/// @nodoc
class __$SalesStateCopyWithImpl<$Res>
    implements _$SalesStateCopyWith<$Res> {
  __$SalesStateCopyWithImpl(this._self, this._then);

  final _SalesState _self;
  final $Res Function(_SalesState) _then;

/// Create a copy of SalesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? report = null,Object? topProducts = null,}) {
  return _then(_SalesState(
report: null == report ? _self.report : report // ignore: cast_nullable_to_non_nullable
as SalesReport,topProducts: null == topProducts ? _self.topProducts : topProducts // ignore: cast_nullable_to_non_nullable
as PageResult<ProductSales>,
  ));
}

/// Create a copy of SalesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesReportCopyWith<$Res> get report {
  
  return $SalesReportCopyWith<$Res>(_self.report, (value) {
    return _then(_self.copyWith(report: value));
  });
}/// Create a copy of SalesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageResultCopyWith<ProductSales, $Res> get topProducts {
  
  return $PageResultCopyWith<ProductSales, $Res>(_self.topProducts, (value) {
    return _then(_self.copyWith(topProducts: value));
  });
}
}

// dart format on
