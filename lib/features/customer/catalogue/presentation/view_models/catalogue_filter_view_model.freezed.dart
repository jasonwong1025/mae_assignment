// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalogue_filter_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CatalogueFilter {

/// Selected category id, or null for every category.
 String? get categoryId; String get searchText;
/// Create a copy of CatalogueFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogueFilterCopyWith<CatalogueFilter> get copyWith => _$CatalogueFilterCopyWithImpl<CatalogueFilter>(this as CatalogueFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CatalogueFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogueFilter&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.searchText, _this.searchText) || other.searchText == _this.searchText));
}


@override
int get hashCode {
  final _this = this as CatalogueFilter;
  return Object.hash(runtimeType,_this.categoryId,_this.searchText);
}

@override
String toString() {
  final _this = this as CatalogueFilter;
  return 'CatalogueFilter(categoryId: ${_this.categoryId}, searchText: ${_this.searchText})';
}


}

/// @nodoc
abstract mixin class $CatalogueFilterCopyWith<$Res>  {
  factory $CatalogueFilterCopyWith(CatalogueFilter value, $Res Function(CatalogueFilter) _then) = _$CatalogueFilterCopyWithImpl;
@useResult
$Res call({
 String? categoryId, String searchText
});




}
/// @nodoc
class _$CatalogueFilterCopyWithImpl<$Res>
    implements $CatalogueFilterCopyWith<$Res> {
  _$CatalogueFilterCopyWithImpl(this._self, this._then);

  final CatalogueFilter _self;
  final $Res Function(CatalogueFilter) _then;

/// Create a copy of CatalogueFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = freezed,Object? searchText = null,}) {
  return _then(CatalogueFilter(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogueFilter].
extension CatalogueFilterPatterns on CatalogueFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogueFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogueFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogueFilter value)  $default,){
final _that = this;
switch (_that) {
case _CatalogueFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogueFilter value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogueFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? categoryId,  String searchText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogueFilter() when $default != null:
return $default(_that.categoryId,_that.searchText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? categoryId,  String searchText)  $default,) {final _that = this;
switch (_that) {
case _CatalogueFilter():
return $default(_that.categoryId,_that.searchText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? categoryId,  String searchText)?  $default,) {final _that = this;
switch (_that) {
case _CatalogueFilter() when $default != null:
return $default(_that.categoryId,_that.searchText);case _:
  return null;

}
}

}

/// @nodoc


class _CatalogueFilter extends CatalogueFilter {
  const _CatalogueFilter({this.categoryId, this.searchText = ''}): super._();
  

/// Selected category id, or null for every category.
@override final  String? categoryId;
@override@JsonKey() final  String searchText;

/// Create a copy of CatalogueFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogueFilterCopyWith<_CatalogueFilter> get copyWith => __$CatalogueFilterCopyWithImpl<_CatalogueFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogueFilter&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.searchText, searchText) || other.searchText == searchText));
}


@override
int get hashCode {
    return Object.hash(runtimeType,categoryId,searchText);
}

@override
String toString() {
    return 'CatalogueFilter(categoryId: $categoryId, searchText: $searchText)';
}


}

/// @nodoc
abstract mixin class _$CatalogueFilterCopyWith<$Res> implements $CatalogueFilterCopyWith<$Res> {
  factory _$CatalogueFilterCopyWith(_CatalogueFilter value, $Res Function(_CatalogueFilter) _then) = __$CatalogueFilterCopyWithImpl;
@override @useResult
$Res call({
 String? categoryId, String searchText
});




}
/// @nodoc
class __$CatalogueFilterCopyWithImpl<$Res>
    implements _$CatalogueFilterCopyWith<$Res> {
  __$CatalogueFilterCopyWithImpl(this._self, this._then);

  final _CatalogueFilter _self;
  final $Res Function(_CatalogueFilter) _then;

/// Create a copy of CatalogueFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = freezed,Object? searchText = null,}) {
  return _then(_CatalogueFilter(
categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
