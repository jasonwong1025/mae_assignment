// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reviews_filter_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReviewsFilter {

 String get searchText;/// Overall star rating, 1 to 5.
 int? get stars; String? get driverId; ReviewPeriod? get period; bool get commentsOnly;/// The first page is 1.
 int get page;
/// Create a copy of ReviewsFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewsFilterCopyWith<ReviewsFilter> get copyWith => _$ReviewsFilterCopyWithImpl<ReviewsFilter>(this as ReviewsFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReviewsFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewsFilter&&(identical(other.searchText, _this.searchText) || other.searchText == _this.searchText)&&(identical(other.stars, _this.stars) || other.stars == _this.stars)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.commentsOnly, _this.commentsOnly) || other.commentsOnly == _this.commentsOnly)&&(identical(other.page, _this.page) || other.page == _this.page));
}


@override
int get hashCode {
  final _this = this as ReviewsFilter;
  return Object.hash(runtimeType,_this.searchText,_this.stars,_this.driverId,_this.period,_this.commentsOnly,_this.page);
}

@override
String toString() {
  final _this = this as ReviewsFilter;
  return 'ReviewsFilter(searchText: ${_this.searchText}, stars: ${_this.stars}, driverId: ${_this.driverId}, period: ${_this.period}, commentsOnly: ${_this.commentsOnly}, page: ${_this.page})';
}


}

/// @nodoc
abstract mixin class $ReviewsFilterCopyWith<$Res>  {
  factory $ReviewsFilterCopyWith(ReviewsFilter value, $Res Function(ReviewsFilter) _then) = _$ReviewsFilterCopyWithImpl;
@useResult
$Res call({
 String searchText, int? stars, String? driverId, ReviewPeriod? period, bool commentsOnly, int page
});




}
/// @nodoc
class _$ReviewsFilterCopyWithImpl<$Res>
    implements $ReviewsFilterCopyWith<$Res> {
  _$ReviewsFilterCopyWithImpl(this._self, this._then);

  final ReviewsFilter _self;
  final $Res Function(ReviewsFilter) _then;

/// Create a copy of ReviewsFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchText = null,Object? stars = freezed,Object? driverId = freezed,Object? period = freezed,Object? commentsOnly = null,Object? page = null,}) {
  return _then(ReviewsFilter(
searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,stars: freezed == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ReviewPeriod?,commentsOnly: null == commentsOnly ? _self.commentsOnly : commentsOnly // ignore: cast_nullable_to_non_nullable
as bool,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewsFilter].
extension ReviewsFilterPatterns on ReviewsFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewsFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewsFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewsFilter value)  $default,){
final _that = this;
switch (_that) {
case _ReviewsFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewsFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewsFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchText,  int? stars,  String? driverId,  ReviewPeriod? period,  bool commentsOnly,  int page)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewsFilter() when $default != null:
return $default(_that.searchText,_that.stars,_that.driverId,_that.period,_that.commentsOnly,_that.page);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchText,  int? stars,  String? driverId,  ReviewPeriod? period,  bool commentsOnly,  int page)  $default,) {final _that = this;
switch (_that) {
case _ReviewsFilter():
return $default(_that.searchText,_that.stars,_that.driverId,_that.period,_that.commentsOnly,_that.page);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchText,  int? stars,  String? driverId,  ReviewPeriod? period,  bool commentsOnly,  int page)?  $default,) {final _that = this;
switch (_that) {
case _ReviewsFilter() when $default != null:
return $default(_that.searchText,_that.stars,_that.driverId,_that.period,_that.commentsOnly,_that.page);case _:
  return null;

}
}

}

/// @nodoc


class _ReviewsFilter extends ReviewsFilter {
  const _ReviewsFilter({this.searchText = '', this.stars, this.driverId, this.period, this.commentsOnly = false, this.page = 1}): super._();
  

@override@JsonKey() final  String searchText;
/// Overall star rating, 1 to 5.
@override final  int? stars;
@override final  String? driverId;
@override final  ReviewPeriod? period;
@override@JsonKey() final  bool commentsOnly;
/// The first page is 1.
@override@JsonKey() final  int page;

/// Create a copy of ReviewsFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewsFilterCopyWith<_ReviewsFilter> get copyWith => __$ReviewsFilterCopyWithImpl<_ReviewsFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewsFilter&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.period, period) || other.period == period)&&(identical(other.commentsOnly, commentsOnly) || other.commentsOnly == commentsOnly)&&(identical(other.page, page) || other.page == page));
}


@override
int get hashCode {
    return Object.hash(runtimeType,searchText,stars,driverId,period,commentsOnly,page);
}

@override
String toString() {
    return 'ReviewsFilter(searchText: $searchText, stars: $stars, driverId: $driverId, period: $period, commentsOnly: $commentsOnly, page: $page)';
}


}

/// @nodoc
abstract mixin class _$ReviewsFilterCopyWith<$Res> implements $ReviewsFilterCopyWith<$Res> {
  factory _$ReviewsFilterCopyWith(_ReviewsFilter value, $Res Function(_ReviewsFilter) _then) = __$ReviewsFilterCopyWithImpl;
@override @useResult
$Res call({
 String searchText, int? stars, String? driverId, ReviewPeriod? period, bool commentsOnly, int page
});




}
/// @nodoc
class __$ReviewsFilterCopyWithImpl<$Res>
    implements _$ReviewsFilterCopyWith<$Res> {
  __$ReviewsFilterCopyWithImpl(this._self, this._then);

  final _ReviewsFilter _self;
  final $Res Function(_ReviewsFilter) _then;

/// Create a copy of ReviewsFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchText = null,Object? stars = freezed,Object? driverId = freezed,Object? period = freezed,Object? commentsOnly = null,Object? page = null,}) {
  return _then(_ReviewsFilter(
searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,stars: freezed == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ReviewPeriod?,commentsOnly: null == commentsOnly ? _self.commentsOnly : commentsOnly // ignore: cast_nullable_to_non_nullable
as bool,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
