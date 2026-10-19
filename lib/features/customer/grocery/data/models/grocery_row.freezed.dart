// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grocery_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GroceryRow {

 GroceryItem get item;/// The product that would be added to the cart: the one the customer
/// picked, or the best match in stock. Null when there is none.
 CatalogueProduct? get product;/// True when something fits the item but it is sold out here.
 bool get soldOut;/// Other products that might be what the customer meant, best first.
 List<CatalogueProduct> get candidates;
/// Create a copy of GroceryRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroceryRowCopyWith<GroceryRow> get copyWith => _$GroceryRowCopyWithImpl<GroceryRow>(this as GroceryRow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GroceryRow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroceryRow&&(identical(other.item, _this.item) || other.item == _this.item)&&(identical(other.product, _this.product) || other.product == _this.product)&&(identical(other.soldOut, _this.soldOut) || other.soldOut == _this.soldOut)&&const DeepCollectionEquality().equals(other.candidates, _this.candidates));
}


@override
int get hashCode {
  final _this = this as GroceryRow;
  return Object.hash(runtimeType,_this.item,_this.product,_this.soldOut,const DeepCollectionEquality().hash(_this.candidates));
}

@override
String toString() {
  final _this = this as GroceryRow;
  return 'GroceryRow(item: ${_this.item}, product: ${_this.product}, soldOut: ${_this.soldOut}, candidates: ${_this.candidates})';
}


}

/// @nodoc
abstract mixin class $GroceryRowCopyWith<$Res>  {
  factory $GroceryRowCopyWith(GroceryRow value, $Res Function(GroceryRow) _then) = _$GroceryRowCopyWithImpl;
@useResult
$Res call({
 GroceryItem item, CatalogueProduct? product, bool soldOut, List<CatalogueProduct> candidates
});


$GroceryItemCopyWith<$Res> get item;$CatalogueProductCopyWith<$Res>? get product;

}
/// @nodoc
class _$GroceryRowCopyWithImpl<$Res>
    implements $GroceryRowCopyWith<$Res> {
  _$GroceryRowCopyWithImpl(this._self, this._then);

  final GroceryRow _self;
  final $Res Function(GroceryRow) _then;

/// Create a copy of GroceryRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? item = null,Object? product = freezed,Object? soldOut = null,Object? candidates = null,}) {
  return _then(GroceryRow(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as GroceryItem,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as CatalogueProduct?,soldOut: null == soldOut ? _self.soldOut : soldOut // ignore: cast_nullable_to_non_nullable
as bool,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<CatalogueProduct>,
  ));
}
/// Create a copy of GroceryRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroceryItemCopyWith<$Res> get item {
  
  return $GroceryItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}/// Create a copy of GroceryRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CatalogueProductCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $CatalogueProductCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroceryRow].
extension GroceryRowPatterns on GroceryRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroceryRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroceryRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroceryRow value)  $default,){
final _that = this;
switch (_that) {
case _GroceryRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroceryRow value)?  $default,){
final _that = this;
switch (_that) {
case _GroceryRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GroceryItem item,  CatalogueProduct? product,  bool soldOut,  List<CatalogueProduct> candidates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroceryRow() when $default != null:
return $default(_that.item,_that.product,_that.soldOut,_that.candidates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GroceryItem item,  CatalogueProduct? product,  bool soldOut,  List<CatalogueProduct> candidates)  $default,) {final _that = this;
switch (_that) {
case _GroceryRow():
return $default(_that.item,_that.product,_that.soldOut,_that.candidates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GroceryItem item,  CatalogueProduct? product,  bool soldOut,  List<CatalogueProduct> candidates)?  $default,) {final _that = this;
switch (_that) {
case _GroceryRow() when $default != null:
return $default(_that.item,_that.product,_that.soldOut,_that.candidates);case _:
  return null;

}
}

}

/// @nodoc


class _GroceryRow extends GroceryRow {
  const _GroceryRow({required this.item, this.product, this.soldOut = false,  List<CatalogueProduct> candidates = const <CatalogueProduct>[]}): _candidates = candidates,super._();
  

@override final  GroceryItem item;
/// The product that would be added to the cart: the one the customer
/// picked, or the best match in stock. Null when there is none.
@override final  CatalogueProduct? product;
/// True when something fits the item but it is sold out here.
@override@JsonKey() final  bool soldOut;
/// Other products that might be what the customer meant, best first.
 final  List<CatalogueProduct> _candidates;
/// Other products that might be what the customer meant, best first.
@override@JsonKey() List<CatalogueProduct> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}


/// Create a copy of GroceryRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroceryRowCopyWith<_GroceryRow> get copyWith => __$GroceryRowCopyWithImpl<_GroceryRow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroceryRow&&(identical(other.item, item) || other.item == item)&&(identical(other.product, product) || other.product == product)&&(identical(other.soldOut, soldOut) || other.soldOut == soldOut)&&const DeepCollectionEquality().equals(other.candidates, _candidates));
}


@override
int get hashCode {
    return Object.hash(runtimeType,item,product,soldOut,const DeepCollectionEquality().hash(_candidates));
}

@override
String toString() {
    return 'GroceryRow(item: $item, product: $product, soldOut: $soldOut, candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class _$GroceryRowCopyWith<$Res> implements $GroceryRowCopyWith<$Res> {
  factory _$GroceryRowCopyWith(_GroceryRow value, $Res Function(_GroceryRow) _then) = __$GroceryRowCopyWithImpl;
@override @useResult
$Res call({
 GroceryItem item, CatalogueProduct? product, bool soldOut, List<CatalogueProduct> candidates
});


@override $GroceryItemCopyWith<$Res> get item;@override $CatalogueProductCopyWith<$Res>? get product;

}
/// @nodoc
class __$GroceryRowCopyWithImpl<$Res>
    implements _$GroceryRowCopyWith<$Res> {
  __$GroceryRowCopyWithImpl(this._self, this._then);

  final _GroceryRow _self;
  final $Res Function(_GroceryRow) _then;

/// Create a copy of GroceryRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? item = null,Object? product = freezed,Object? soldOut = null,Object? candidates = null,}) {
  return _then(_GroceryRow(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as GroceryItem,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as CatalogueProduct?,soldOut: null == soldOut ? _self.soldOut : soldOut // ignore: cast_nullable_to_non_nullable
as bool,candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<CatalogueProduct>,
  ));
}

/// Create a copy of GroceryRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroceryItemCopyWith<$Res> get item {
  
  return $GroceryItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}/// Create a copy of GroceryRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CatalogueProductCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $CatalogueProductCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}

// dart format on
