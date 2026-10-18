// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SalesTotals {

/// In ringgit.
 double get itemSales; double get deliveryFees; int get orderCount;
/// Create a copy of SalesTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesTotalsCopyWith<SalesTotals> get copyWith => _$SalesTotalsCopyWithImpl<SalesTotals>(this as SalesTotals, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SalesTotals;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesTotals&&(identical(other.itemSales, _this.itemSales) || other.itemSales == _this.itemSales)&&(identical(other.deliveryFees, _this.deliveryFees) || other.deliveryFees == _this.deliveryFees)&&(identical(other.orderCount, _this.orderCount) || other.orderCount == _this.orderCount));
}


@override
int get hashCode {
  final _this = this as SalesTotals;
  return Object.hash(runtimeType,_this.itemSales,_this.deliveryFees,_this.orderCount);
}

@override
String toString() {
  final _this = this as SalesTotals;
  return 'SalesTotals(itemSales: ${_this.itemSales}, deliveryFees: ${_this.deliveryFees}, orderCount: ${_this.orderCount})';
}


}

/// @nodoc
abstract mixin class $SalesTotalsCopyWith<$Res>  {
  factory $SalesTotalsCopyWith(SalesTotals value, $Res Function(SalesTotals) _then) = _$SalesTotalsCopyWithImpl;
@useResult
$Res call({
 double itemSales, double deliveryFees, int orderCount
});




}
/// @nodoc
class _$SalesTotalsCopyWithImpl<$Res>
    implements $SalesTotalsCopyWith<$Res> {
  _$SalesTotalsCopyWithImpl(this._self, this._then);

  final SalesTotals _self;
  final $Res Function(SalesTotals) _then;

/// Create a copy of SalesTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemSales = null,Object? deliveryFees = null,Object? orderCount = null,}) {
  return _then(SalesTotals(
itemSales: null == itemSales ? _self.itemSales : itemSales // ignore: cast_nullable_to_non_nullable
as double,deliveryFees: null == deliveryFees ? _self.deliveryFees : deliveryFees // ignore: cast_nullable_to_non_nullable
as double,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesTotals].
extension SalesTotalsPatterns on SalesTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesTotals value)  $default,){
final _that = this;
switch (_that) {
case _SalesTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesTotals value)?  $default,){
final _that = this;
switch (_that) {
case _SalesTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double itemSales,  double deliveryFees,  int orderCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesTotals() when $default != null:
return $default(_that.itemSales,_that.deliveryFees,_that.orderCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double itemSales,  double deliveryFees,  int orderCount)  $default,) {final _that = this;
switch (_that) {
case _SalesTotals():
return $default(_that.itemSales,_that.deliveryFees,_that.orderCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double itemSales,  double deliveryFees,  int orderCount)?  $default,) {final _that = this;
switch (_that) {
case _SalesTotals() when $default != null:
return $default(_that.itemSales,_that.deliveryFees,_that.orderCount);case _:
  return null;

}
}

}

/// @nodoc


class _SalesTotals extends SalesTotals {
  const _SalesTotals({required this.itemSales, required this.deliveryFees, required this.orderCount}): super._();
  

/// In ringgit.
@override final  double itemSales;
@override final  double deliveryFees;
@override final  int orderCount;

/// Create a copy of SalesTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesTotalsCopyWith<_SalesTotals> get copyWith => __$SalesTotalsCopyWithImpl<_SalesTotals>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesTotals&&(identical(other.itemSales, itemSales) || other.itemSales == itemSales)&&(identical(other.deliveryFees, deliveryFees) || other.deliveryFees == deliveryFees)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,itemSales,deliveryFees,orderCount);
}

@override
String toString() {
    return 'SalesTotals(itemSales: $itemSales, deliveryFees: $deliveryFees, orderCount: $orderCount)';
}


}

/// @nodoc
abstract mixin class _$SalesTotalsCopyWith<$Res> implements $SalesTotalsCopyWith<$Res> {
  factory _$SalesTotalsCopyWith(_SalesTotals value, $Res Function(_SalesTotals) _then) = __$SalesTotalsCopyWithImpl;
@override @useResult
$Res call({
 double itemSales, double deliveryFees, int orderCount
});




}
/// @nodoc
class __$SalesTotalsCopyWithImpl<$Res>
    implements _$SalesTotalsCopyWith<$Res> {
  __$SalesTotalsCopyWithImpl(this._self, this._then);

  final _SalesTotals _self;
  final $Res Function(_SalesTotals) _then;

/// Create a copy of SalesTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemSales = null,Object? deliveryFees = null,Object? orderCount = null,}) {
  return _then(_SalesTotals(
itemSales: null == itemSales ? _self.itemSales : itemSales // ignore: cast_nullable_to_non_nullable
as double,deliveryFees: null == deliveryFees ? _self.deliveryFees : deliveryFees // ignore: cast_nullable_to_non_nullable
as double,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SalesPoint {

/// Start of the hour, day or week.
 DateTime get start; double get revenue;
/// Create a copy of SalesPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesPointCopyWith<SalesPoint> get copyWith => _$SalesPointCopyWithImpl<SalesPoint>(this as SalesPoint, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SalesPoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesPoint&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.revenue, _this.revenue) || other.revenue == _this.revenue));
}


@override
int get hashCode {
  final _this = this as SalesPoint;
  return Object.hash(runtimeType,_this.start,_this.revenue);
}

@override
String toString() {
  final _this = this as SalesPoint;
  return 'SalesPoint(start: ${_this.start}, revenue: ${_this.revenue})';
}


}

/// @nodoc
abstract mixin class $SalesPointCopyWith<$Res>  {
  factory $SalesPointCopyWith(SalesPoint value, $Res Function(SalesPoint) _then) = _$SalesPointCopyWithImpl;
@useResult
$Res call({
 DateTime start, double revenue
});




}
/// @nodoc
class _$SalesPointCopyWithImpl<$Res>
    implements $SalesPointCopyWith<$Res> {
  _$SalesPointCopyWithImpl(this._self, this._then);

  final SalesPoint _self;
  final $Res Function(SalesPoint) _then;

/// Create a copy of SalesPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? revenue = null,}) {
  return _then(SalesPoint(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesPoint].
extension SalesPointPatterns on SalesPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesPoint value)  $default,){
final _that = this;
switch (_that) {
case _SalesPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesPoint value)?  $default,){
final _that = this;
switch (_that) {
case _SalesPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime start,  double revenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesPoint() when $default != null:
return $default(_that.start,_that.revenue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime start,  double revenue)  $default,) {final _that = this;
switch (_that) {
case _SalesPoint():
return $default(_that.start,_that.revenue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime start,  double revenue)?  $default,) {final _that = this;
switch (_that) {
case _SalesPoint() when $default != null:
return $default(_that.start,_that.revenue);case _:
  return null;

}
}

}

/// @nodoc


class _SalesPoint extends SalesPoint {
  const _SalesPoint({required this.start, required this.revenue}): super._();
  

/// Start of the hour, day or week.
@override final  DateTime start;
@override final  double revenue;

/// Create a copy of SalesPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesPointCopyWith<_SalesPoint> get copyWith => __$SalesPointCopyWithImpl<_SalesPoint>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesPoint&&(identical(other.start, start) || other.start == start)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}


@override
int get hashCode {
    return Object.hash(runtimeType,start,revenue);
}

@override
String toString() {
    return 'SalesPoint(start: $start, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class _$SalesPointCopyWith<$Res> implements $SalesPointCopyWith<$Res> {
  factory _$SalesPointCopyWith(_SalesPoint value, $Res Function(_SalesPoint) _then) = __$SalesPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime start, double revenue
});




}
/// @nodoc
class __$SalesPointCopyWithImpl<$Res>
    implements _$SalesPointCopyWith<$Res> {
  __$SalesPointCopyWithImpl(this._self, this._then);

  final _SalesPoint _self;
  final $Res Function(_SalesPoint) _then;

/// Create a copy of SalesPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? revenue = null,}) {
  return _then(_SalesPoint(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$CategorySales {

 String get categoryId; String get name; double get revenue;
/// Create a copy of CategorySales
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorySalesCopyWith<CategorySales> get copyWith => _$CategorySalesCopyWithImpl<CategorySales>(this as CategorySales, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategorySales;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorySales&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.revenue, _this.revenue) || other.revenue == _this.revenue));
}


@override
int get hashCode {
  final _this = this as CategorySales;
  return Object.hash(runtimeType,_this.categoryId,_this.name,_this.revenue);
}

@override
String toString() {
  final _this = this as CategorySales;
  return 'CategorySales(categoryId: ${_this.categoryId}, name: ${_this.name}, revenue: ${_this.revenue})';
}


}

/// @nodoc
abstract mixin class $CategorySalesCopyWith<$Res>  {
  factory $CategorySalesCopyWith(CategorySales value, $Res Function(CategorySales) _then) = _$CategorySalesCopyWithImpl;
@useResult
$Res call({
 String categoryId, String name, double revenue
});




}
/// @nodoc
class _$CategorySalesCopyWithImpl<$Res>
    implements $CategorySalesCopyWith<$Res> {
  _$CategorySalesCopyWithImpl(this._self, this._then);

  final CategorySales _self;
  final $Res Function(CategorySales) _then;

/// Create a copy of CategorySales
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? name = null,Object? revenue = null,}) {
  return _then(CategorySales(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CategorySales].
extension CategorySalesPatterns on CategorySales {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategorySales value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategorySales() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategorySales value)  $default,){
final _that = this;
switch (_that) {
case _CategorySales():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategorySales value)?  $default,){
final _that = this;
switch (_that) {
case _CategorySales() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  String name,  double revenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategorySales() when $default != null:
return $default(_that.categoryId,_that.name,_that.revenue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  String name,  double revenue)  $default,) {final _that = this;
switch (_that) {
case _CategorySales():
return $default(_that.categoryId,_that.name,_that.revenue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  String name,  double revenue)?  $default,) {final _that = this;
switch (_that) {
case _CategorySales() when $default != null:
return $default(_that.categoryId,_that.name,_that.revenue);case _:
  return null;

}
}

}

/// @nodoc


class _CategorySales extends CategorySales {
  const _CategorySales({required this.categoryId, required this.name, required this.revenue}): super._();
  

@override final  String categoryId;
@override final  String name;
@override final  double revenue;

/// Create a copy of CategorySales
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorySalesCopyWith<_CategorySales> get copyWith => __$CategorySalesCopyWithImpl<_CategorySales>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorySales&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}


@override
int get hashCode {
    return Object.hash(runtimeType,categoryId,name,revenue);
}

@override
String toString() {
    return 'CategorySales(categoryId: $categoryId, name: $name, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class _$CategorySalesCopyWith<$Res> implements $CategorySalesCopyWith<$Res> {
  factory _$CategorySalesCopyWith(_CategorySales value, $Res Function(_CategorySales) _then) = __$CategorySalesCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, String name, double revenue
});




}
/// @nodoc
class __$CategorySalesCopyWithImpl<$Res>
    implements _$CategorySalesCopyWith<$Res> {
  __$CategorySalesCopyWithImpl(this._self, this._then);

  final _CategorySales _self;
  final $Res Function(_CategorySales) _then;

/// Create a copy of CategorySales
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? name = null,Object? revenue = null,}) {
  return _then(_CategorySales(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$SalesReport {

 SalesPeriod get period; SalesTotals get totals;/// The period of the same length just before, for "+12%" labels.
 SalesTotals get previousTotals;/// Chart bars, oldest first. Grouped by [SalesPeriod.grouping].
 List<SalesPoint> get points;/// Categories with sales, highest revenue first.
 List<CategorySales> get categories;
/// Create a copy of SalesReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesReportCopyWith<SalesReport> get copyWith => _$SalesReportCopyWithImpl<SalesReport>(this as SalesReport, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SalesReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesReport&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.totals, _this.totals) || other.totals == _this.totals)&&(identical(other.previousTotals, _this.previousTotals) || other.previousTotals == _this.previousTotals)&&const DeepCollectionEquality().equals(other.points, _this.points)&&const DeepCollectionEquality().equals(other.categories, _this.categories));
}


@override
int get hashCode {
  final _this = this as SalesReport;
  return Object.hash(runtimeType,_this.period,_this.totals,_this.previousTotals,const DeepCollectionEquality().hash(_this.points),const DeepCollectionEquality().hash(_this.categories));
}

@override
String toString() {
  final _this = this as SalesReport;
  return 'SalesReport(period: ${_this.period}, totals: ${_this.totals}, previousTotals: ${_this.previousTotals}, points: ${_this.points}, categories: ${_this.categories})';
}


}

/// @nodoc
abstract mixin class $SalesReportCopyWith<$Res>  {
  factory $SalesReportCopyWith(SalesReport value, $Res Function(SalesReport) _then) = _$SalesReportCopyWithImpl;
@useResult
$Res call({
 SalesPeriod period, SalesTotals totals, SalesTotals previousTotals, List<SalesPoint> points, List<CategorySales> categories
});


$SalesPeriodCopyWith<$Res> get period;$SalesTotalsCopyWith<$Res> get totals;$SalesTotalsCopyWith<$Res> get previousTotals;

}
/// @nodoc
class _$SalesReportCopyWithImpl<$Res>
    implements $SalesReportCopyWith<$Res> {
  _$SalesReportCopyWithImpl(this._self, this._then);

  final SalesReport _self;
  final $Res Function(SalesReport) _then;

/// Create a copy of SalesReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? totals = null,Object? previousTotals = null,Object? points = null,Object? categories = null,}) {
  return _then(SalesReport(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as SalesPeriod,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as SalesTotals,previousTotals: null == previousTotals ? _self.previousTotals : previousTotals // ignore: cast_nullable_to_non_nullable
as SalesTotals,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<SalesPoint>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategorySales>,
  ));
}
/// Create a copy of SalesReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesPeriodCopyWith<$Res> get period {
  
  return $SalesPeriodCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}/// Create a copy of SalesReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesTotalsCopyWith<$Res> get totals {
  
  return $SalesTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}/// Create a copy of SalesReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesTotalsCopyWith<$Res> get previousTotals {
  
  return $SalesTotalsCopyWith<$Res>(_self.previousTotals, (value) {
    return _then(_self.copyWith(previousTotals: value));
  });
}
}


/// Adds pattern-matching-related methods to [SalesReport].
extension SalesReportPatterns on SalesReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesReport value)  $default,){
final _that = this;
switch (_that) {
case _SalesReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesReport value)?  $default,){
final _that = this;
switch (_that) {
case _SalesReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SalesPeriod period,  SalesTotals totals,  SalesTotals previousTotals,  List<SalesPoint> points,  List<CategorySales> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesReport() when $default != null:
return $default(_that.period,_that.totals,_that.previousTotals,_that.points,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SalesPeriod period,  SalesTotals totals,  SalesTotals previousTotals,  List<SalesPoint> points,  List<CategorySales> categories)  $default,) {final _that = this;
switch (_that) {
case _SalesReport():
return $default(_that.period,_that.totals,_that.previousTotals,_that.points,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SalesPeriod period,  SalesTotals totals,  SalesTotals previousTotals,  List<SalesPoint> points,  List<CategorySales> categories)?  $default,) {final _that = this;
switch (_that) {
case _SalesReport() when $default != null:
return $default(_that.period,_that.totals,_that.previousTotals,_that.points,_that.categories);case _:
  return null;

}
}

}

/// @nodoc


class _SalesReport extends SalesReport {
  const _SalesReport({required this.period, required this.totals, required this.previousTotals, required  List<SalesPoint> points, required  List<CategorySales> categories}): _points = points,_categories = categories,super._();
  

@override final  SalesPeriod period;
@override final  SalesTotals totals;
/// The period of the same length just before, for "+12%" labels.
@override final  SalesTotals previousTotals;
/// Chart bars, oldest first. Grouped by [SalesPeriod.grouping].
 final  List<SalesPoint> _points;
/// Chart bars, oldest first. Grouped by [SalesPeriod.grouping].
@override List<SalesPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

/// Categories with sales, highest revenue first.
 final  List<CategorySales> _categories;
/// Categories with sales, highest revenue first.
@override List<CategorySales> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of SalesReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesReportCopyWith<_SalesReport> get copyWith => __$SalesReportCopyWithImpl<_SalesReport>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesReport&&(identical(other.period, period) || other.period == period)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.previousTotals, previousTotals) || other.previousTotals == previousTotals)&&const DeepCollectionEquality().equals(other.points, _points)&&const DeepCollectionEquality().equals(other.categories, _categories));
}


@override
int get hashCode {
    return Object.hash(runtimeType,period,totals,previousTotals,const DeepCollectionEquality().hash(_points),const DeepCollectionEquality().hash(_categories));
}

@override
String toString() {
    return 'SalesReport(period: $period, totals: $totals, previousTotals: $previousTotals, points: $points, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$SalesReportCopyWith<$Res> implements $SalesReportCopyWith<$Res> {
  factory _$SalesReportCopyWith(_SalesReport value, $Res Function(_SalesReport) _then) = __$SalesReportCopyWithImpl;
@override @useResult
$Res call({
 SalesPeriod period, SalesTotals totals, SalesTotals previousTotals, List<SalesPoint> points, List<CategorySales> categories
});


@override $SalesPeriodCopyWith<$Res> get period;@override $SalesTotalsCopyWith<$Res> get totals;@override $SalesTotalsCopyWith<$Res> get previousTotals;

}
/// @nodoc
class __$SalesReportCopyWithImpl<$Res>
    implements _$SalesReportCopyWith<$Res> {
  __$SalesReportCopyWithImpl(this._self, this._then);

  final _SalesReport _self;
  final $Res Function(_SalesReport) _then;

/// Create a copy of SalesReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? totals = null,Object? previousTotals = null,Object? points = null,Object? categories = null,}) {
  return _then(_SalesReport(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as SalesPeriod,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as SalesTotals,previousTotals: null == previousTotals ? _self.previousTotals : previousTotals // ignore: cast_nullable_to_non_nullable
as SalesTotals,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<SalesPoint>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategorySales>,
  ));
}

/// Create a copy of SalesReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesPeriodCopyWith<$Res> get period {
  
  return $SalesPeriodCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}/// Create a copy of SalesReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesTotalsCopyWith<$Res> get totals {
  
  return $SalesTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}/// Create a copy of SalesReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesTotalsCopyWith<$Res> get previousTotals {
  
  return $SalesTotalsCopyWith<$Res>(_self.previousTotals, (value) {
    return _then(_self.copyWith(previousTotals: value));
  });
}
}

/// @nodoc
mixin _$ProductSales {

 String get productId; String get name; String get categoryName; int get quantity; double get revenue;
/// Create a copy of ProductSales
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductSalesCopyWith<ProductSales> get copyWith => _$ProductSalesCopyWithImpl<ProductSales>(this as ProductSales, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductSales;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductSales&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.categoryName, _this.categoryName) || other.categoryName == _this.categoryName)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.revenue, _this.revenue) || other.revenue == _this.revenue));
}


@override
int get hashCode {
  final _this = this as ProductSales;
  return Object.hash(runtimeType,_this.productId,_this.name,_this.categoryName,_this.quantity,_this.revenue);
}

@override
String toString() {
  final _this = this as ProductSales;
  return 'ProductSales(productId: ${_this.productId}, name: ${_this.name}, categoryName: ${_this.categoryName}, quantity: ${_this.quantity}, revenue: ${_this.revenue})';
}


}

/// @nodoc
abstract mixin class $ProductSalesCopyWith<$Res>  {
  factory $ProductSalesCopyWith(ProductSales value, $Res Function(ProductSales) _then) = _$ProductSalesCopyWithImpl;
@useResult
$Res call({
 String productId, String name, String categoryName, int quantity, double revenue
});




}
/// @nodoc
class _$ProductSalesCopyWithImpl<$Res>
    implements $ProductSalesCopyWith<$Res> {
  _$ProductSalesCopyWithImpl(this._self, this._then);

  final ProductSales _self;
  final $Res Function(ProductSales) _then;

/// Create a copy of ProductSales
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? name = null,Object? categoryName = null,Object? quantity = null,Object? revenue = null,}) {
  return _then(ProductSales(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductSales].
extension ProductSalesPatterns on ProductSales {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductSales value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductSales() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductSales value)  $default,){
final _that = this;
switch (_that) {
case _ProductSales():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductSales value)?  $default,){
final _that = this;
switch (_that) {
case _ProductSales() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  String name,  String categoryName,  int quantity,  double revenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductSales() when $default != null:
return $default(_that.productId,_that.name,_that.categoryName,_that.quantity,_that.revenue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  String name,  String categoryName,  int quantity,  double revenue)  $default,) {final _that = this;
switch (_that) {
case _ProductSales():
return $default(_that.productId,_that.name,_that.categoryName,_that.quantity,_that.revenue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  String name,  String categoryName,  int quantity,  double revenue)?  $default,) {final _that = this;
switch (_that) {
case _ProductSales() when $default != null:
return $default(_that.productId,_that.name,_that.categoryName,_that.quantity,_that.revenue);case _:
  return null;

}
}

}

/// @nodoc


class _ProductSales extends ProductSales {
  const _ProductSales({required this.productId, required this.name, required this.categoryName, required this.quantity, required this.revenue}): super._();
  

@override final  String productId;
@override final  String name;
@override final  String categoryName;
@override final  int quantity;
@override final  double revenue;

/// Create a copy of ProductSales
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductSalesCopyWith<_ProductSales> get copyWith => __$ProductSalesCopyWithImpl<_ProductSales>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductSales&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,name,categoryName,quantity,revenue);
}

@override
String toString() {
    return 'ProductSales(productId: $productId, name: $name, categoryName: $categoryName, quantity: $quantity, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class _$ProductSalesCopyWith<$Res> implements $ProductSalesCopyWith<$Res> {
  factory _$ProductSalesCopyWith(_ProductSales value, $Res Function(_ProductSales) _then) = __$ProductSalesCopyWithImpl;
@override @useResult
$Res call({
 String productId, String name, String categoryName, int quantity, double revenue
});




}
/// @nodoc
class __$ProductSalesCopyWithImpl<$Res>
    implements _$ProductSalesCopyWith<$Res> {
  __$ProductSalesCopyWithImpl(this._self, this._then);

  final _ProductSales _self;
  final $Res Function(_ProductSales) _then;

/// Create a copy of ProductSales
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? name = null,Object? categoryName = null,Object? quantity = null,Object? revenue = null,}) {
  return _then(_ProductSales(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
