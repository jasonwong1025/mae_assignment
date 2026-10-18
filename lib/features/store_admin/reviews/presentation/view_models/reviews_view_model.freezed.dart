// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reviews_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReviewsState {

/// Averages over all of the branch's reviews (not filtered).
 ReviewSummary get summary;/// One page of the filtered reviews.
 PageResult<Review> get page;
/// Create a copy of ReviewsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewsStateCopyWith<ReviewsState> get copyWith => _$ReviewsStateCopyWithImpl<ReviewsState>(this as ReviewsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReviewsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewsState&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.page, _this.page) || other.page == _this.page));
}


@override
int get hashCode {
  final _this = this as ReviewsState;
  return Object.hash(runtimeType,_this.summary,_this.page);
}

@override
String toString() {
  final _this = this as ReviewsState;
  return 'ReviewsState(summary: ${_this.summary}, page: ${_this.page})';
}


}

/// @nodoc
abstract mixin class $ReviewsStateCopyWith<$Res>  {
  factory $ReviewsStateCopyWith(ReviewsState value, $Res Function(ReviewsState) _then) = _$ReviewsStateCopyWithImpl;
@useResult
$Res call({
 ReviewSummary summary, PageResult<Review> page
});


$ReviewSummaryCopyWith<$Res> get summary;$PageResultCopyWith<Review, $Res> get page;

}
/// @nodoc
class _$ReviewsStateCopyWithImpl<$Res>
    implements $ReviewsStateCopyWith<$Res> {
  _$ReviewsStateCopyWithImpl(this._self, this._then);

  final ReviewsState _self;
  final $Res Function(ReviewsState) _then;

/// Create a copy of ReviewsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? page = null,}) {
  return _then(ReviewsState(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as ReviewSummary,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as PageResult<Review>,
  ));
}
/// Create a copy of ReviewsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewSummaryCopyWith<$Res> get summary {
  
  return $ReviewSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}/// Create a copy of ReviewsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageResultCopyWith<Review, $Res> get page {
  
  return $PageResultCopyWith<Review, $Res>(_self.page, (value) {
    return _then(_self.copyWith(page: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReviewsState].
extension ReviewsStatePatterns on ReviewsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewsState value)  $default,){
final _that = this;
switch (_that) {
case _ReviewsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewsState value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReviewSummary summary,  PageResult<Review> page)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewsState() when $default != null:
return $default(_that.summary,_that.page);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReviewSummary summary,  PageResult<Review> page)  $default,) {final _that = this;
switch (_that) {
case _ReviewsState():
return $default(_that.summary,_that.page);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReviewSummary summary,  PageResult<Review> page)?  $default,) {final _that = this;
switch (_that) {
case _ReviewsState() when $default != null:
return $default(_that.summary,_that.page);case _:
  return null;

}
}

}

/// @nodoc


class _ReviewsState extends ReviewsState {
  const _ReviewsState({required this.summary, required this.page}): super._();
  

/// Averages over all of the branch's reviews (not filtered).
@override final  ReviewSummary summary;
/// One page of the filtered reviews.
@override final  PageResult<Review> page;

/// Create a copy of ReviewsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewsStateCopyWith<_ReviewsState> get copyWith => __$ReviewsStateCopyWithImpl<_ReviewsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewsState&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.page, page) || other.page == page));
}


@override
int get hashCode {
    return Object.hash(runtimeType,summary,page);
}

@override
String toString() {
    return 'ReviewsState(summary: $summary, page: $page)';
}


}

/// @nodoc
abstract mixin class _$ReviewsStateCopyWith<$Res> implements $ReviewsStateCopyWith<$Res> {
  factory _$ReviewsStateCopyWith(_ReviewsState value, $Res Function(_ReviewsState) _then) = __$ReviewsStateCopyWithImpl;
@override @useResult
$Res call({
 ReviewSummary summary, PageResult<Review> page
});


@override $ReviewSummaryCopyWith<$Res> get summary;@override $PageResultCopyWith<Review, $Res> get page;

}
/// @nodoc
class __$ReviewsStateCopyWithImpl<$Res>
    implements _$ReviewsStateCopyWith<$Res> {
  __$ReviewsStateCopyWithImpl(this._self, this._then);

  final _ReviewsState _self;
  final $Res Function(_ReviewsState) _then;

/// Create a copy of ReviewsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? page = null,}) {
  return _then(_ReviewsState(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as ReviewSummary,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as PageResult<Review>,
  ));
}

/// Create a copy of ReviewsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReviewSummaryCopyWith<$Res> get summary {
  
  return $ReviewSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}/// Create a copy of ReviewsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PageResultCopyWith<Review, $Res> get page {
  
  return $PageResultCopyWith<Review, $Res>(_self.page, (value) {
    return _then(_self.copyWith(page: value));
  });
}
}

// dart format on
