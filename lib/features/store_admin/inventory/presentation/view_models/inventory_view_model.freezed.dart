// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InventoryState {

/// One page of the selected branch's products.
/// Only the page being shown is loaded.
 PageResult<InventoryItem> get page; List<ProductCategory> get categories;
/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryStateCopyWith<InventoryState> get copyWith => _$InventoryStateCopyWithImpl<InventoryState>(this as InventoryState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InventoryState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryState&&(identical(other.page, _this.page) || other.page == _this.page)&&const DeepCollectionEquality().equals(other.categories, _this.categories));
}


@override
int get hashCode {
  final _this = this as InventoryState;
  return Object.hash(runtimeType,_this.page,const DeepCollectionEquality().hash(_this.categories));
}

@override
String toString() {
  final _this = this as InventoryState;
  return 'InventoryState(page: ${_this.page}, categories: ${_this.categories})';
}


}

/// @nodoc
abstract mixin class $InventoryStateCopyWith<$Res>  {
  factory $InventoryStateCopyWith(InventoryState value, $Res Function(InventoryState) _then) = _$InventoryStateCopyWithImpl;
@useResult
$Res call({
 PageResult<InventoryItem> page, List<ProductCategory> categories
});


$PageResultCopyWith<InventoryItem, $Res> get page;

}
/// @nodoc
class _$InventoryStateCopyWithImpl<$Res>
    implements $InventoryStateCopyWith<$Res> {
  _$InventoryStateCopyWithImpl(this._self, this._then);

  final InventoryState _self;
  final $Res Function(InventoryState) _then;

/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? categories = null,}) {
  return _then(InventoryState(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as PageResult<InventoryItem>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<ProductCategory>,
  ));
}
/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageResultCopyWith<InventoryItem, $Res> get page {
  
  return $PageResultCopyWith<InventoryItem, $Res>(_self.page, (value) {
    return _then(_self.copyWith(page: value));
  });
}
}


/// Adds pattern-matching-related methods to [InventoryState].
extension InventoryStatePatterns on InventoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryState value)  $default,){
final _that = this;
switch (_that) {
case _InventoryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryState value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PageResult<InventoryItem> page,  List<ProductCategory> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryState() when $default != null:
return $default(_that.page,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PageResult<InventoryItem> page,  List<ProductCategory> categories)  $default,) {final _that = this;
switch (_that) {
case _InventoryState():
return $default(_that.page,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PageResult<InventoryItem> page,  List<ProductCategory> categories)?  $default,) {final _that = this;
switch (_that) {
case _InventoryState() when $default != null:
return $default(_that.page,_that.categories);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryState extends InventoryState {
  const _InventoryState({required this.page, required  List<ProductCategory> categories}): _categories = categories,super._();
  

/// One page of the selected branch's products.
/// Only the page being shown is loaded.
@override final  PageResult<InventoryItem> page;
 final  List<ProductCategory> _categories;
@override List<ProductCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryStateCopyWith<_InventoryState> get copyWith => __$InventoryStateCopyWithImpl<_InventoryState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryState&&(identical(other.page, page) || other.page == page)&&const DeepCollectionEquality().equals(other.categories, _categories));
}


@override
int get hashCode {
    return Object.hash(runtimeType,page,const DeepCollectionEquality().hash(_categories));
}

@override
String toString() {
    return 'InventoryState(page: $page, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$InventoryStateCopyWith<$Res> implements $InventoryStateCopyWith<$Res> {
  factory _$InventoryStateCopyWith(_InventoryState value, $Res Function(_InventoryState) _then) = __$InventoryStateCopyWithImpl;
@override @useResult
$Res call({
 PageResult<InventoryItem> page, List<ProductCategory> categories
});


@override $PageResultCopyWith<InventoryItem, $Res> get page;

}
/// @nodoc
class __$InventoryStateCopyWithImpl<$Res>
    implements _$InventoryStateCopyWith<$Res> {
  __$InventoryStateCopyWithImpl(this._self, this._then);

  final _InventoryState _self;
  final $Res Function(_InventoryState) _then;

/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? categories = null,}) {
  return _then(_InventoryState(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as PageResult<InventoryItem>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<ProductCategory>,
  ));
}

/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageResultCopyWith<InventoryItem, $Res> get page {
  
  return $PageResultCopyWith<InventoryItem, $Res>(_self.page, (value) {
    return _then(_self.copyWith(page: value));
  });
}
}

// dart format on
