// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalogue_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CatalogueProduct {

 String get id; String get name; String get brand; String get categoryId;/// E.g. "1L" or "500g".
 String get packSize;/// Price at the customer's branch, in ringgit.
 double get price;/// Stock at the customer's branch.
 int get stock; String get description;/// Image URLs; the first is the cover. Empty shows a placeholder.
 List<String> get imageUrls;
/// Create a copy of CatalogueProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogueProductCopyWith<CatalogueProduct> get copyWith => _$CatalogueProductCopyWithImpl<CatalogueProduct>(this as CatalogueProduct, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CatalogueProduct;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogueProduct&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.packSize, _this.packSize) || other.packSize == _this.packSize)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.stock, _this.stock) || other.stock == _this.stock)&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.imageUrls, _this.imageUrls));
}


@override
int get hashCode {
  final _this = this as CatalogueProduct;
  return Object.hash(runtimeType,_this.id,_this.name,_this.brand,_this.categoryId,_this.packSize,_this.price,_this.stock,_this.description,const DeepCollectionEquality().hash(_this.imageUrls));
}

@override
String toString() {
  final _this = this as CatalogueProduct;
  return 'CatalogueProduct(id: ${_this.id}, name: ${_this.name}, brand: ${_this.brand}, categoryId: ${_this.categoryId}, packSize: ${_this.packSize}, price: ${_this.price}, stock: ${_this.stock}, description: ${_this.description}, imageUrls: ${_this.imageUrls})';
}


}

/// @nodoc
abstract mixin class $CatalogueProductCopyWith<$Res>  {
  factory $CatalogueProductCopyWith(CatalogueProduct value, $Res Function(CatalogueProduct) _then) = _$CatalogueProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, String brand, String categoryId, String packSize, double price, int stock, String description, List<String> imageUrls
});




}
/// @nodoc
class _$CatalogueProductCopyWithImpl<$Res>
    implements $CatalogueProductCopyWith<$Res> {
  _$CatalogueProductCopyWithImpl(this._self, this._then);

  final CatalogueProduct _self;
  final $Res Function(CatalogueProduct) _then;

/// Create a copy of CatalogueProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? brand = null,Object? categoryId = null,Object? packSize = null,Object? price = null,Object? stock = null,Object? description = null,Object? imageUrls = null,}) {
  return _then(CatalogueProduct(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,packSize: null == packSize ? _self.packSize : packSize // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogueProduct].
extension CatalogueProductPatterns on CatalogueProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogueProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogueProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogueProduct value)  $default,){
final _that = this;
switch (_that) {
case _CatalogueProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogueProduct value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogueProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String brand,  String categoryId,  String packSize,  double price,  int stock,  String description,  List<String> imageUrls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogueProduct() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.categoryId,_that.packSize,_that.price,_that.stock,_that.description,_that.imageUrls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String brand,  String categoryId,  String packSize,  double price,  int stock,  String description,  List<String> imageUrls)  $default,) {final _that = this;
switch (_that) {
case _CatalogueProduct():
return $default(_that.id,_that.name,_that.brand,_that.categoryId,_that.packSize,_that.price,_that.stock,_that.description,_that.imageUrls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String brand,  String categoryId,  String packSize,  double price,  int stock,  String description,  List<String> imageUrls)?  $default,) {final _that = this;
switch (_that) {
case _CatalogueProduct() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.categoryId,_that.packSize,_that.price,_that.stock,_that.description,_that.imageUrls);case _:
  return null;

}
}

}

/// @nodoc


class _CatalogueProduct extends CatalogueProduct {
  const _CatalogueProduct({required this.id, required this.name, required this.brand, required this.categoryId, required this.packSize, required this.price, required this.stock, this.description = '',  List<String> imageUrls = const <String>[]}): _imageUrls = imageUrls,super._();
  

@override final  String id;
@override final  String name;
@override final  String brand;
@override final  String categoryId;
/// E.g. "1L" or "500g".
@override final  String packSize;
/// Price at the customer's branch, in ringgit.
@override final  double price;
/// Stock at the customer's branch.
@override final  int stock;
@override@JsonKey() final  String description;
/// Image URLs; the first is the cover. Empty shows a placeholder.
 final  List<String> _imageUrls;
/// Image URLs; the first is the cover. Empty shows a placeholder.
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}


/// Create a copy of CatalogueProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogueProductCopyWith<_CatalogueProduct> get copyWith => __$CatalogueProductCopyWithImpl<_CatalogueProduct>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogueProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.packSize, packSize) || other.packSize == packSize)&&(identical(other.price, price) || other.price == price)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.imageUrls, _imageUrls));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,brand,categoryId,packSize,price,stock,description,const DeepCollectionEquality().hash(_imageUrls));
}

@override
String toString() {
    return 'CatalogueProduct(id: $id, name: $name, brand: $brand, categoryId: $categoryId, packSize: $packSize, price: $price, stock: $stock, description: $description, imageUrls: $imageUrls)';
}


}

/// @nodoc
abstract mixin class _$CatalogueProductCopyWith<$Res> implements $CatalogueProductCopyWith<$Res> {
  factory _$CatalogueProductCopyWith(_CatalogueProduct value, $Res Function(_CatalogueProduct) _then) = __$CatalogueProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String brand, String categoryId, String packSize, double price, int stock, String description, List<String> imageUrls
});




}
/// @nodoc
class __$CatalogueProductCopyWithImpl<$Res>
    implements _$CatalogueProductCopyWith<$Res> {
  __$CatalogueProductCopyWithImpl(this._self, this._then);

  final _CatalogueProduct _self;
  final $Res Function(_CatalogueProduct) _then;

/// Create a copy of CatalogueProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? brand = null,Object? categoryId = null,Object? packSize = null,Object? price = null,Object? stock = null,Object? description = null,Object? imageUrls = null,}) {
  return _then(_CatalogueProduct(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,packSize: null == packSize ? _self.packSize : packSize // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$CatalogueCategory {

 String get id; String get name;/// Lower sorts first in the category tabs.
 int get sortOrder;
/// Create a copy of CatalogueCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogueCategoryCopyWith<CatalogueCategory> get copyWith => _$CatalogueCategoryCopyWithImpl<CatalogueCategory>(this as CatalogueCategory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CatalogueCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogueCategory&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder));
}


@override
int get hashCode {
  final _this = this as CatalogueCategory;
  return Object.hash(runtimeType,_this.id,_this.name,_this.sortOrder);
}

@override
String toString() {
  final _this = this as CatalogueCategory;
  return 'CatalogueCategory(id: ${_this.id}, name: ${_this.name}, sortOrder: ${_this.sortOrder})';
}


}

/// @nodoc
abstract mixin class $CatalogueCategoryCopyWith<$Res>  {
  factory $CatalogueCategoryCopyWith(CatalogueCategory value, $Res Function(CatalogueCategory) _then) = _$CatalogueCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, int sortOrder
});




}
/// @nodoc
class _$CatalogueCategoryCopyWithImpl<$Res>
    implements $CatalogueCategoryCopyWith<$Res> {
  _$CatalogueCategoryCopyWithImpl(this._self, this._then);

  final CatalogueCategory _self;
  final $Res Function(CatalogueCategory) _then;

/// Create a copy of CatalogueCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sortOrder = null,}) {
  return _then(CatalogueCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogueCategory].
extension CatalogueCategoryPatterns on CatalogueCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogueCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogueCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogueCategory value)  $default,){
final _that = this;
switch (_that) {
case _CatalogueCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogueCategory value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogueCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogueCategory() when $default != null:
return $default(_that.id,_that.name,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _CatalogueCategory():
return $default(_that.id,_that.name,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _CatalogueCategory() when $default != null:
return $default(_that.id,_that.name,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc


class _CatalogueCategory extends CatalogueCategory {
  const _CatalogueCategory({required this.id, required this.name, this.sortOrder = 0}): super._();
  

@override final  String id;
@override final  String name;
/// Lower sorts first in the category tabs.
@override@JsonKey() final  int sortOrder;

/// Create a copy of CatalogueCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogueCategoryCopyWith<_CatalogueCategory> get copyWith => __$CatalogueCategoryCopyWithImpl<_CatalogueCategory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogueCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,sortOrder);
}

@override
String toString() {
    return 'CatalogueCategory(id: $id, name: $name, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$CatalogueCategoryCopyWith<$Res> implements $CatalogueCategoryCopyWith<$Res> {
  factory _$CatalogueCategoryCopyWith(_CatalogueCategory value, $Res Function(_CatalogueCategory) _then) = __$CatalogueCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int sortOrder
});




}
/// @nodoc
class __$CatalogueCategoryCopyWithImpl<$Res>
    implements _$CatalogueCategoryCopyWith<$Res> {
  __$CatalogueCategoryCopyWithImpl(this._self, this._then);

  final _CatalogueCategory _self;
  final $Res Function(_CatalogueCategory) _then;

/// Create a copy of CatalogueCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sortOrder = null,}) {
  return _then(_CatalogueCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
