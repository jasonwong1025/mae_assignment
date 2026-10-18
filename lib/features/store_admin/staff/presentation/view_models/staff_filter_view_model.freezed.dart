// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_filter_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaffFilter {

 String get searchText;/// The first page is 1.
 int get page;
/// Create a copy of StaffFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffFilterCopyWith<StaffFilter> get copyWith => _$StaffFilterCopyWithImpl<StaffFilter>(this as StaffFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StaffFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffFilter&&(identical(other.searchText, _this.searchText) || other.searchText == _this.searchText)&&(identical(other.page, _this.page) || other.page == _this.page));
}


@override
int get hashCode {
  final _this = this as StaffFilter;
  return Object.hash(runtimeType,_this.searchText,_this.page);
}

@override
String toString() {
  final _this = this as StaffFilter;
  return 'StaffFilter(searchText: ${_this.searchText}, page: ${_this.page})';
}


}

/// @nodoc
abstract mixin class $StaffFilterCopyWith<$Res>  {
  factory $StaffFilterCopyWith(StaffFilter value, $Res Function(StaffFilter) _then) = _$StaffFilterCopyWithImpl;
@useResult
$Res call({
 String searchText, int page
});




}
/// @nodoc
class _$StaffFilterCopyWithImpl<$Res>
    implements $StaffFilterCopyWith<$Res> {
  _$StaffFilterCopyWithImpl(this._self, this._then);

  final StaffFilter _self;
  final $Res Function(StaffFilter) _then;

/// Create a copy of StaffFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchText = null,Object? page = null,}) {
  return _then(StaffFilter(
searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffFilter].
extension StaffFilterPatterns on StaffFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffFilter value)  $default,){
final _that = this;
switch (_that) {
case _StaffFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffFilter value)?  $default,){
final _that = this;
switch (_that) {
case _StaffFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchText,  int page)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffFilter() when $default != null:
return $default(_that.searchText,_that.page);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchText,  int page)  $default,) {final _that = this;
switch (_that) {
case _StaffFilter():
return $default(_that.searchText,_that.page);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchText,  int page)?  $default,) {final _that = this;
switch (_that) {
case _StaffFilter() when $default != null:
return $default(_that.searchText,_that.page);case _:
  return null;

}
}

}

/// @nodoc


class _StaffFilter extends StaffFilter {
  const _StaffFilter({this.searchText = '', this.page = 1}): super._();
  

@override@JsonKey() final  String searchText;
/// The first page is 1.
@override@JsonKey() final  int page;

/// Create a copy of StaffFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffFilterCopyWith<_StaffFilter> get copyWith => __$StaffFilterCopyWithImpl<_StaffFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffFilter&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.page, page) || other.page == page));
}


@override
int get hashCode {
    return Object.hash(runtimeType,searchText,page);
}

@override
String toString() {
    return 'StaffFilter(searchText: $searchText, page: $page)';
}


}

/// @nodoc
abstract mixin class _$StaffFilterCopyWith<$Res> implements $StaffFilterCopyWith<$Res> {
  factory _$StaffFilterCopyWith(_StaffFilter value, $Res Function(_StaffFilter) _then) = __$StaffFilterCopyWithImpl;
@override @useResult
$Res call({
 String searchText, int page
});




}
/// @nodoc
class __$StaffFilterCopyWithImpl<$Res>
    implements _$StaffFilterCopyWith<$Res> {
  __$StaffFilterCopyWithImpl(this._self, this._then);

  final _StaffFilter _self;
  final $Res Function(_StaffFilter) _then;

/// Create a copy of StaffFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchText = null,Object? page = null,}) {
  return _then(_StaffFilter(
searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
