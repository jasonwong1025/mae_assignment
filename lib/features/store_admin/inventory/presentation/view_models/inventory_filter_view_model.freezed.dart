// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_filter_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InventoryFilter {

 String get searchText; String? get categoryId; StockStatus? get stockStatus; VisibilityFilter? get visibility;/// The first page is 1.
 int get page;
/// Create a copy of InventoryFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryFilterCopyWith<InventoryFilter> get copyWith => _$InventoryFilterCopyWithImpl<InventoryFilter>(this as InventoryFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryFilter&&(identical(other.searchText, _this.searchText) || other.searchText == _this.searchText)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.stockStatus, _this.stockStatus) || other.stockStatus == _this.stockStatus)&&(identical(other.visibility, _this.visibility) || other.visibility == _this.visibility)&&(identical(other.page, _this.page) || other.page == _this.page));
}


@override
int get hashCode {
  final _this = this as InventoryFilter;
  return Object.hash(runtimeType,_this.searchText,_this.categoryId,_this.stockStatus,_this.visibility,_this.page);
}

@override
String toString() {
  final _this = this as InventoryFilter;
  return 'InventoryFilter(searchText: ${_this.searchText}, categoryId: ${_this.categoryId}, stockStatus: ${_this.stockStatus}, visibility: ${_this.visibility}, page: ${_this.page})';
}


}

/// @nodoc
abstract mixin class $InventoryFilterCopyWith<$Res>  {
  factory $InventoryFilterCopyWith(InventoryFilter value, $Res Function(InventoryFilter) _then) = _$InventoryFilterCopyWithImpl;
@useResult
$Res call({
 String searchText, String? categoryId, StockStatus? stockStatus, VisibilityFilter? visibility, int page
});




}
/// @nodoc
class _$InventoryFilterCopyWithImpl<$Res>
    implements $InventoryFilterCopyWith<$Res> {
  _$InventoryFilterCopyWithImpl(this._self, this._then);

  final InventoryFilter _self;
  final $Res Function(InventoryFilter) _then;

/// Create a copy of InventoryFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchText = null,Object? categoryId = freezed,Object? stockStatus = freezed,Object? visibility = freezed,Object? page = null,}) {
  return _then(InventoryFilter(
searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,stockStatus: freezed == stockStatus ? _self.stockStatus : stockStatus // ignore: cast_nullable_to_non_nullable
as StockStatus?,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as VisibilityFilter?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryFilter].
extension InventoryFilterPatterns on InventoryFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryFilter value)  $default,){
final _that = this;
switch (_that) {
case _InventoryFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryFilter value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchText,  String? categoryId,  StockStatus? stockStatus,  VisibilityFilter? visibility,  int page)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryFilter() when $default != null:
return $default(_that.searchText,_that.categoryId,_that.stockStatus,_that.visibility,_that.page);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchText,  String? categoryId,  StockStatus? stockStatus,  VisibilityFilter? visibility,  int page)  $default,) {final _that = this;
switch (_that) {
case _InventoryFilter():
return $default(_that.searchText,_that.categoryId,_that.stockStatus,_that.visibility,_that.page);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchText,  String? categoryId,  StockStatus? stockStatus,  VisibilityFilter? visibility,  int page)?  $default,) {final _that = this;
switch (_that) {
case _InventoryFilter() when $default != null:
return $default(_that.searchText,_that.categoryId,_that.stockStatus,_that.visibility,_that.page);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryFilter extends InventoryFilter {
  const _InventoryFilter({this.searchText = '', this.categoryId, this.stockStatus, this.visibility, this.page = 1}): super._();
  

@override@JsonKey() final  String searchText;
@override final  String? categoryId;
@override final  StockStatus? stockStatus;
@override final  VisibilityFilter? visibility;
/// The first page is 1.
@override@JsonKey() final  int page;

/// Create a copy of InventoryFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryFilterCopyWith<_InventoryFilter> get copyWith => __$InventoryFilterCopyWithImpl<_InventoryFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryFilter&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.stockStatus, stockStatus) || other.stockStatus == stockStatus)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.page, page) || other.page == page));
}


@override
int get hashCode {
    return Object.hash(runtimeType,searchText,categoryId,stockStatus,visibility,page);
}

@override
String toString() {
    return 'InventoryFilter(searchText: $searchText, categoryId: $categoryId, stockStatus: $stockStatus, visibility: $visibility, page: $page)';
}


}

/// @nodoc
abstract mixin class _$InventoryFilterCopyWith<$Res> implements $InventoryFilterCopyWith<$Res> {
  factory _$InventoryFilterCopyWith(_InventoryFilter value, $Res Function(_InventoryFilter) _then) = __$InventoryFilterCopyWithImpl;
@override @useResult
$Res call({
 String searchText, String? categoryId, StockStatus? stockStatus, VisibilityFilter? visibility, int page
});




}
/// @nodoc
class __$InventoryFilterCopyWithImpl<$Res>
    implements _$InventoryFilterCopyWith<$Res> {
  __$InventoryFilterCopyWithImpl(this._self, this._then);

  final _InventoryFilter _self;
  final $Res Function(_InventoryFilter) _then;

/// Create a copy of InventoryFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchText = null,Object? categoryId = freezed,Object? stockStatus = freezed,Object? visibility = freezed,Object? page = null,}) {
  return _then(_InventoryFilter(
searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,stockStatus: freezed == stockStatus ? _self.stockStatus : stockStatus // ignore: cast_nullable_to_non_nullable
as StockStatus?,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as VisibilityFilter?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
