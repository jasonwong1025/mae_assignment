// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductCategory {

 String get id; String get name;
/// Create a copy of ProductCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCategoryCopyWith<ProductCategory> get copyWith => _$ProductCategoryCopyWithImpl<ProductCategory>(this as ProductCategory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProductCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductCategory&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as ProductCategory;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as ProductCategory;
  return 'ProductCategory(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $ProductCategoryCopyWith<$Res>  {
  factory $ProductCategoryCopyWith(ProductCategory value, $Res Function(ProductCategory) _then) = _$ProductCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$ProductCategoryCopyWithImpl<$Res>
    implements $ProductCategoryCopyWith<$Res> {
  _$ProductCategoryCopyWithImpl(this._self, this._then);

  final ProductCategory _self;
  final $Res Function(ProductCategory) _then;

/// Create a copy of ProductCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(ProductCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductCategory].
extension ProductCategoryPatterns on ProductCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductCategory value)  $default,){
final _that = this;
switch (_that) {
case _ProductCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductCategory value)?  $default,){
final _that = this;
switch (_that) {
case _ProductCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductCategory() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _ProductCategory():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _ProductCategory() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _ProductCategory extends ProductCategory {
  const _ProductCategory({required this.id, required this.name}): super._();
  

@override final  String id;
@override final  String name;

/// Create a copy of ProductCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCategoryCopyWith<_ProductCategory> get copyWith => __$ProductCategoryCopyWithImpl<_ProductCategory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'ProductCategory(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ProductCategoryCopyWith<$Res> implements $ProductCategoryCopyWith<$Res> {
  factory _$ProductCategoryCopyWith(_ProductCategory value, $Res Function(_ProductCategory) _then) = __$ProductCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$ProductCategoryCopyWithImpl<$Res>
    implements _$ProductCategoryCopyWith<$Res> {
  __$ProductCategoryCopyWithImpl(this._self, this._then);

  final _ProductCategory _self;
  final $Res Function(_ProductCategory) _then;

/// Create a copy of ProductCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_ProductCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Product {

 String get id; String get name; String get brand; String get categoryId;/// E.g. "1L" or "500g".
 String get packSize;/// Can be empty.
 String get description;/// Stock at or below this counts as low.
 int get lowStockLevel;/// Up to [maxPhotos]. The first is the cover.
/// Image data for now. Firebase Storage links later.
 List<Uint8List> get photos;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Product;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.packSize, _this.packSize) || other.packSize == _this.packSize)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.lowStockLevel, _this.lowStockLevel) || other.lowStockLevel == _this.lowStockLevel)&&const DeepCollectionEquality().equals(other.photos, _this.photos));
}


@override
int get hashCode {
  final _this = this as Product;
  return Object.hash(runtimeType,_this.id,_this.name,_this.brand,_this.categoryId,_this.packSize,_this.description,_this.lowStockLevel,const DeepCollectionEquality().hash(_this.photos));
}

@override
String toString() {
  final _this = this as Product;
  return 'Product(id: ${_this.id}, name: ${_this.name}, brand: ${_this.brand}, categoryId: ${_this.categoryId}, packSize: ${_this.packSize}, description: ${_this.description}, lowStockLevel: ${_this.lowStockLevel}, photos: ${_this.photos})';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, String brand, String categoryId, String packSize, String description, int lowStockLevel, List<Uint8List> photos
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? brand = null,Object? categoryId = null,Object? packSize = null,Object? description = null,Object? lowStockLevel = null,Object? photos = null,}) {
  return _then(Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,packSize: null == packSize ? _self.packSize : packSize // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,lowStockLevel: null == lowStockLevel ? _self.lowStockLevel : lowStockLevel // ignore: cast_nullable_to_non_nullable
as int,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<Uint8List>,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String brand,  String categoryId,  String packSize,  String description,  int lowStockLevel,  List<Uint8List> photos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.categoryId,_that.packSize,_that.description,_that.lowStockLevel,_that.photos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String brand,  String categoryId,  String packSize,  String description,  int lowStockLevel,  List<Uint8List> photos)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.name,_that.brand,_that.categoryId,_that.packSize,_that.description,_that.lowStockLevel,_that.photos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String brand,  String categoryId,  String packSize,  String description,  int lowStockLevel,  List<Uint8List> photos)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.categoryId,_that.packSize,_that.description,_that.lowStockLevel,_that.photos);case _:
  return null;

}
}

}

/// @nodoc


class _Product extends Product {
  const _Product({required this.id, required this.name, required this.brand, required this.categoryId, required this.packSize, required this.description, required this.lowStockLevel,  List<Uint8List> photos = const <Uint8List>[]}): _photos = photos,super._();
  

@override final  String id;
@override final  String name;
@override final  String brand;
@override final  String categoryId;
/// E.g. "1L" or "500g".
@override final  String packSize;
/// Can be empty.
@override final  String description;
/// Stock at or below this counts as low.
@override final  int lowStockLevel;
/// Up to [maxPhotos]. The first is the cover.
/// Image data for now. Firebase Storage links later.
 final  List<Uint8List> _photos;
/// Up to [maxPhotos]. The first is the cover.
/// Image data for now. Firebase Storage links later.
@override@JsonKey() List<Uint8List> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}


/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.packSize, packSize) || other.packSize == packSize)&&(identical(other.description, description) || other.description == description)&&(identical(other.lowStockLevel, lowStockLevel) || other.lowStockLevel == lowStockLevel)&&const DeepCollectionEquality().equals(other.photos, _photos));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,brand,categoryId,packSize,description,lowStockLevel,const DeepCollectionEquality().hash(_photos));
}

@override
String toString() {
    return 'Product(id: $id, name: $name, brand: $brand, categoryId: $categoryId, packSize: $packSize, description: $description, lowStockLevel: $lowStockLevel, photos: $photos)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String brand, String categoryId, String packSize, String description, int lowStockLevel, List<Uint8List> photos
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? brand = null,Object? categoryId = null,Object? packSize = null,Object? description = null,Object? lowStockLevel = null,Object? photos = null,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,packSize: null == packSize ? _self.packSize : packSize // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,lowStockLevel: null == lowStockLevel ? _self.lowStockLevel : lowStockLevel // ignore: cast_nullable_to_non_nullable
as int,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<Uint8List>,
  ));
}


}

// dart format on
