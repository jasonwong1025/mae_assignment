// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grocery_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GroceryList {

 String get id; String get name; List<GroceryItem> get items;/// When the list was made. Null for the default list made before lists
/// had names, which always sorts first anyway.
 DateTime? get createdAt;
/// Create a copy of GroceryList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroceryListCopyWith<GroceryList> get copyWith => _$GroceryListCopyWithImpl<GroceryList>(this as GroceryList, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GroceryList;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroceryList&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as GroceryList;
  return Object.hash(runtimeType,_this.id,_this.name,const DeepCollectionEquality().hash(_this.items),_this.createdAt);
}

@override
String toString() {
  final _this = this as GroceryList;
  return 'GroceryList(id: ${_this.id}, name: ${_this.name}, items: ${_this.items}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $GroceryListCopyWith<$Res>  {
  factory $GroceryListCopyWith(GroceryList value, $Res Function(GroceryList) _then) = _$GroceryListCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<GroceryItem> items, DateTime? createdAt
});




}
/// @nodoc
class _$GroceryListCopyWithImpl<$Res>
    implements $GroceryListCopyWith<$Res> {
  _$GroceryListCopyWithImpl(this._self, this._then);

  final GroceryList _self;
  final $Res Function(GroceryList) _then;

/// Create a copy of GroceryList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? items = null,Object? createdAt = freezed,}) {
  return _then(GroceryList(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GroceryItem>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GroceryList].
extension GroceryListPatterns on GroceryList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroceryList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroceryList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroceryList value)  $default,){
final _that = this;
switch (_that) {
case _GroceryList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroceryList value)?  $default,){
final _that = this;
switch (_that) {
case _GroceryList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<GroceryItem> items,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroceryList() when $default != null:
return $default(_that.id,_that.name,_that.items,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<GroceryItem> items,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _GroceryList():
return $default(_that.id,_that.name,_that.items,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<GroceryItem> items,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GroceryList() when $default != null:
return $default(_that.id,_that.name,_that.items,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _GroceryList extends GroceryList {
  const _GroceryList({required this.id, required this.name,  List<GroceryItem> items = const <GroceryItem>[], this.createdAt}): _items = items,super._();
  

@override final  String id;
@override final  String name;
 final  List<GroceryItem> _items;
@override@JsonKey() List<GroceryItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// When the list was made. Null for the default list made before lists
/// had names, which always sorts first anyway.
@override final  DateTime? createdAt;

/// Create a copy of GroceryList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroceryListCopyWith<_GroceryList> get copyWith => __$GroceryListCopyWithImpl<_GroceryList>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroceryList&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_items),createdAt);
}

@override
String toString() {
    return 'GroceryList(id: $id, name: $name, items: $items, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GroceryListCopyWith<$Res> implements $GroceryListCopyWith<$Res> {
  factory _$GroceryListCopyWith(_GroceryList value, $Res Function(_GroceryList) _then) = __$GroceryListCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<GroceryItem> items, DateTime? createdAt
});




}
/// @nodoc
class __$GroceryListCopyWithImpl<$Res>
    implements _$GroceryListCopyWith<$Res> {
  __$GroceryListCopyWithImpl(this._self, this._then);

  final _GroceryList _self;
  final $Res Function(_GroceryList) _then;

/// Create a copy of GroceryList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? items = null,Object? createdAt = freezed,}) {
  return _then(_GroceryList(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GroceryItem>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$GroceryLists {

/// The default list first, then the others oldest first.
 List<GroceryList> get lists; String get selectedId;
/// Create a copy of GroceryLists
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroceryListsCopyWith<GroceryLists> get copyWith => _$GroceryListsCopyWithImpl<GroceryLists>(this as GroceryLists, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GroceryLists;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroceryLists&&const DeepCollectionEquality().equals(other.lists, _this.lists)&&(identical(other.selectedId, _this.selectedId) || other.selectedId == _this.selectedId));
}


@override
int get hashCode {
  final _this = this as GroceryLists;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.lists),_this.selectedId);
}

@override
String toString() {
  final _this = this as GroceryLists;
  return 'GroceryLists(lists: ${_this.lists}, selectedId: ${_this.selectedId})';
}


}

/// @nodoc
abstract mixin class $GroceryListsCopyWith<$Res>  {
  factory $GroceryListsCopyWith(GroceryLists value, $Res Function(GroceryLists) _then) = _$GroceryListsCopyWithImpl;
@useResult
$Res call({
 List<GroceryList> lists, String selectedId
});




}
/// @nodoc
class _$GroceryListsCopyWithImpl<$Res>
    implements $GroceryListsCopyWith<$Res> {
  _$GroceryListsCopyWithImpl(this._self, this._then);

  final GroceryLists _self;
  final $Res Function(GroceryLists) _then;

/// Create a copy of GroceryLists
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lists = null,Object? selectedId = null,}) {
  return _then(GroceryLists(
lists: null == lists ? _self.lists : lists // ignore: cast_nullable_to_non_nullable
as List<GroceryList>,selectedId: null == selectedId ? _self.selectedId : selectedId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GroceryLists].
extension GroceryListsPatterns on GroceryLists {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroceryLists value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroceryLists() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroceryLists value)  $default,){
final _that = this;
switch (_that) {
case _GroceryLists():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroceryLists value)?  $default,){
final _that = this;
switch (_that) {
case _GroceryLists() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GroceryList> lists,  String selectedId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroceryLists() when $default != null:
return $default(_that.lists,_that.selectedId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GroceryList> lists,  String selectedId)  $default,) {final _that = this;
switch (_that) {
case _GroceryLists():
return $default(_that.lists,_that.selectedId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GroceryList> lists,  String selectedId)?  $default,) {final _that = this;
switch (_that) {
case _GroceryLists() when $default != null:
return $default(_that.lists,_that.selectedId);case _:
  return null;

}
}

}

/// @nodoc


class _GroceryLists extends GroceryLists {
  const _GroceryLists({required  List<GroceryList> lists, required this.selectedId}): _lists = lists,super._();
  

/// The default list first, then the others oldest first.
 final  List<GroceryList> _lists;
/// The default list first, then the others oldest first.
@override List<GroceryList> get lists {
  if (_lists is EqualUnmodifiableListView) return _lists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lists);
}

@override final  String selectedId;

/// Create a copy of GroceryLists
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroceryListsCopyWith<_GroceryLists> get copyWith => __$GroceryListsCopyWithImpl<_GroceryLists>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroceryLists&&const DeepCollectionEquality().equals(other.lists, _lists)&&(identical(other.selectedId, selectedId) || other.selectedId == selectedId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_lists),selectedId);
}

@override
String toString() {
    return 'GroceryLists(lists: $lists, selectedId: $selectedId)';
}


}

/// @nodoc
abstract mixin class _$GroceryListsCopyWith<$Res> implements $GroceryListsCopyWith<$Res> {
  factory _$GroceryListsCopyWith(_GroceryLists value, $Res Function(_GroceryLists) _then) = __$GroceryListsCopyWithImpl;
@override @useResult
$Res call({
 List<GroceryList> lists, String selectedId
});




}
/// @nodoc
class __$GroceryListsCopyWithImpl<$Res>
    implements _$GroceryListsCopyWith<$Res> {
  __$GroceryListsCopyWithImpl(this._self, this._then);

  final _GroceryLists _self;
  final $Res Function(_GroceryLists) _then;

/// Create a copy of GroceryLists
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lists = null,Object? selectedId = null,}) {
  return _then(_GroceryLists(
lists: null == lists ? _self._lists : lists // ignore: cast_nullable_to_non_nullable
as List<GroceryList>,selectedId: null == selectedId ? _self.selectedId : selectedId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
