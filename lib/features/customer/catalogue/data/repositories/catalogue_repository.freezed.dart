// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalogue_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CatalogueData {

 List<CatalogueCategory> get categories; List<CatalogueProduct> get products;
/// Create a copy of CatalogueData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogueDataCopyWith<CatalogueData> get copyWith => _$CatalogueDataCopyWithImpl<CatalogueData>(this as CatalogueData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CatalogueData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogueData&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&const DeepCollectionEquality().equals(other.products, _this.products));
}


@override
int get hashCode {
  final _this = this as CatalogueData;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.categories),const DeepCollectionEquality().hash(_this.products));
}

@override
String toString() {
  final _this = this as CatalogueData;
  return 'CatalogueData(categories: ${_this.categories}, products: ${_this.products})';
}


}

/// @nodoc
abstract mixin class $CatalogueDataCopyWith<$Res>  {
  factory $CatalogueDataCopyWith(CatalogueData value, $Res Function(CatalogueData) _then) = _$CatalogueDataCopyWithImpl;
@useResult
$Res call({
 List<CatalogueCategory> categories, List<CatalogueProduct> products
});




}
/// @nodoc
class _$CatalogueDataCopyWithImpl<$Res>
    implements $CatalogueDataCopyWith<$Res> {
  _$CatalogueDataCopyWithImpl(this._self, this._then);

  final CatalogueData _self;
  final $Res Function(CatalogueData) _then;

/// Create a copy of CatalogueData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categories = null,Object? products = null,}) {
  return _then(CatalogueData(
categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CatalogueCategory>,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<CatalogueProduct>,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogueData].
extension CatalogueDataPatterns on CatalogueData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogueData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogueData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogueData value)  $default,){
final _that = this;
switch (_that) {
case _CatalogueData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogueData value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogueData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CatalogueCategory> categories,  List<CatalogueProduct> products)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogueData() when $default != null:
return $default(_that.categories,_that.products);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CatalogueCategory> categories,  List<CatalogueProduct> products)  $default,) {final _that = this;
switch (_that) {
case _CatalogueData():
return $default(_that.categories,_that.products);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CatalogueCategory> categories,  List<CatalogueProduct> products)?  $default,) {final _that = this;
switch (_that) {
case _CatalogueData() when $default != null:
return $default(_that.categories,_that.products);case _:
  return null;

}
}

}

/// @nodoc


class _CatalogueData extends CatalogueData {
  const _CatalogueData({required  List<CatalogueCategory> categories, required  List<CatalogueProduct> products}): _categories = categories,_products = products,super._();
  

 final  List<CatalogueCategory> _categories;
@override List<CatalogueCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<CatalogueProduct> _products;
@override List<CatalogueProduct> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of CatalogueData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogueDataCopyWith<_CatalogueData> get copyWith => __$CatalogueDataCopyWithImpl<_CatalogueData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogueData&&const DeepCollectionEquality().equals(other.categories, _categories)&&const DeepCollectionEquality().equals(other.products, _products));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_products));
}

@override
String toString() {
    return 'CatalogueData(categories: $categories, products: $products)';
}


}

/// @nodoc
abstract mixin class _$CatalogueDataCopyWith<$Res> implements $CatalogueDataCopyWith<$Res> {
  factory _$CatalogueDataCopyWith(_CatalogueData value, $Res Function(_CatalogueData) _then) = __$CatalogueDataCopyWithImpl;
@override @useResult
$Res call({
 List<CatalogueCategory> categories, List<CatalogueProduct> products
});




}
/// @nodoc
class __$CatalogueDataCopyWithImpl<$Res>
    implements _$CatalogueDataCopyWith<$Res> {
  __$CatalogueDataCopyWithImpl(this._self, this._then);

  final _CatalogueData _self;
  final $Res Function(_CatalogueData) _then;

/// Create a copy of CatalogueData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? products = null,}) {
  return _then(_CatalogueData(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CatalogueCategory>,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<CatalogueProduct>,
  ));
}


}

// dart format on
