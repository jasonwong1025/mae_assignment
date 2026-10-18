// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalogue_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CatalogueState {

/// The store the customer is shopping from.
 Branch get branch; List<CatalogueCategory> get categories;/// Products after the category and search filters are applied.
 List<CatalogueProduct> get products;
/// Create a copy of CatalogueState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogueStateCopyWith<CatalogueState> get copyWith => _$CatalogueStateCopyWithImpl<CatalogueState>(this as CatalogueState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CatalogueState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogueState&&(identical(other.branch, _this.branch) || other.branch == _this.branch)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&const DeepCollectionEquality().equals(other.products, _this.products));
}


@override
int get hashCode {
  final _this = this as CatalogueState;
  return Object.hash(runtimeType,_this.branch,const DeepCollectionEquality().hash(_this.categories),const DeepCollectionEquality().hash(_this.products));
}

@override
String toString() {
  final _this = this as CatalogueState;
  return 'CatalogueState(branch: ${_this.branch}, categories: ${_this.categories}, products: ${_this.products})';
}


}

/// @nodoc
abstract mixin class $CatalogueStateCopyWith<$Res>  {
  factory $CatalogueStateCopyWith(CatalogueState value, $Res Function(CatalogueState) _then) = _$CatalogueStateCopyWithImpl;
@useResult
$Res call({
 Branch branch, List<CatalogueCategory> categories, List<CatalogueProduct> products
});


$BranchCopyWith<$Res> get branch;

}
/// @nodoc
class _$CatalogueStateCopyWithImpl<$Res>
    implements $CatalogueStateCopyWith<$Res> {
  _$CatalogueStateCopyWithImpl(this._self, this._then);

  final CatalogueState _self;
  final $Res Function(CatalogueState) _then;

/// Create a copy of CatalogueState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? branch = null,Object? categories = null,Object? products = null,}) {
  return _then(CatalogueState(
branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as Branch,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CatalogueCategory>,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<CatalogueProduct>,
  ));
}
/// Create a copy of CatalogueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchCopyWith<$Res> get branch {
  
  return $BranchCopyWith<$Res>(_self.branch, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}


/// Adds pattern-matching-related methods to [CatalogueState].
extension CatalogueStatePatterns on CatalogueState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogueState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogueState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogueState value)  $default,){
final _that = this;
switch (_that) {
case _CatalogueState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogueState value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogueState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Branch branch,  List<CatalogueCategory> categories,  List<CatalogueProduct> products)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogueState() when $default != null:
return $default(_that.branch,_that.categories,_that.products);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Branch branch,  List<CatalogueCategory> categories,  List<CatalogueProduct> products)  $default,) {final _that = this;
switch (_that) {
case _CatalogueState():
return $default(_that.branch,_that.categories,_that.products);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Branch branch,  List<CatalogueCategory> categories,  List<CatalogueProduct> products)?  $default,) {final _that = this;
switch (_that) {
case _CatalogueState() when $default != null:
return $default(_that.branch,_that.categories,_that.products);case _:
  return null;

}
}

}

/// @nodoc


class _CatalogueState extends CatalogueState {
  const _CatalogueState({required this.branch, required  List<CatalogueCategory> categories, required  List<CatalogueProduct> products}): _categories = categories,_products = products,super._();
  

/// The store the customer is shopping from.
@override final  Branch branch;
 final  List<CatalogueCategory> _categories;
@override List<CatalogueCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

/// Products after the category and search filters are applied.
 final  List<CatalogueProduct> _products;
/// Products after the category and search filters are applied.
@override List<CatalogueProduct> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}


/// Create a copy of CatalogueState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogueStateCopyWith<_CatalogueState> get copyWith => __$CatalogueStateCopyWithImpl<_CatalogueState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogueState&&(identical(other.branch, branch) || other.branch == branch)&&const DeepCollectionEquality().equals(other.categories, _categories)&&const DeepCollectionEquality().equals(other.products, _products));
}


@override
int get hashCode {
    return Object.hash(runtimeType,branch,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_products));
}

@override
String toString() {
    return 'CatalogueState(branch: $branch, categories: $categories, products: $products)';
}


}

/// @nodoc
abstract mixin class _$CatalogueStateCopyWith<$Res> implements $CatalogueStateCopyWith<$Res> {
  factory _$CatalogueStateCopyWith(_CatalogueState value, $Res Function(_CatalogueState) _then) = __$CatalogueStateCopyWithImpl;
@override @useResult
$Res call({
 Branch branch, List<CatalogueCategory> categories, List<CatalogueProduct> products
});


@override $BranchCopyWith<$Res> get branch;

}
/// @nodoc
class __$CatalogueStateCopyWithImpl<$Res>
    implements _$CatalogueStateCopyWith<$Res> {
  __$CatalogueStateCopyWithImpl(this._self, this._then);

  final _CatalogueState _self;
  final $Res Function(_CatalogueState) _then;

/// Create a copy of CatalogueState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? branch = null,Object? categories = null,Object? products = null,}) {
  return _then(_CatalogueState(
branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as Branch,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CatalogueCategory>,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<CatalogueProduct>,
  ));
}

/// Create a copy of CatalogueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchCopyWith<$Res> get branch {
  
  return $BranchCopyWith<$Res>(_self.branch, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}

// dart format on
