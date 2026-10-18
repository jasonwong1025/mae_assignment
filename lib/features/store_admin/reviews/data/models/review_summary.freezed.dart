// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReviewSummary {

 int get reviewCount;/// Reviews of delivery orders (pickup orders have no delivery score).
 int get deliveryCount;/// Averages out of 5. 0 if there are no reviews.
 double get shoppingAverage; double get productAverage; double get deliveryAverage;/// Reviews per overall star rating. Index 0 is 1 star.
 List<int> get starCounts;/// Drivers who delivered for the branch, best rated first.
 List<DriverRating> get drivers;
/// Create a copy of ReviewSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewSummaryCopyWith<ReviewSummary> get copyWith => _$ReviewSummaryCopyWithImpl<ReviewSummary>(this as ReviewSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReviewSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewSummary&&(identical(other.reviewCount, _this.reviewCount) || other.reviewCount == _this.reviewCount)&&(identical(other.deliveryCount, _this.deliveryCount) || other.deliveryCount == _this.deliveryCount)&&(identical(other.shoppingAverage, _this.shoppingAverage) || other.shoppingAverage == _this.shoppingAverage)&&(identical(other.productAverage, _this.productAverage) || other.productAverage == _this.productAverage)&&(identical(other.deliveryAverage, _this.deliveryAverage) || other.deliveryAverage == _this.deliveryAverage)&&const DeepCollectionEquality().equals(other.starCounts, _this.starCounts)&&const DeepCollectionEquality().equals(other.drivers, _this.drivers));
}


@override
int get hashCode {
  final _this = this as ReviewSummary;
  return Object.hash(runtimeType,_this.reviewCount,_this.deliveryCount,_this.shoppingAverage,_this.productAverage,_this.deliveryAverage,const DeepCollectionEquality().hash(_this.starCounts),const DeepCollectionEquality().hash(_this.drivers));
}

@override
String toString() {
  final _this = this as ReviewSummary;
  return 'ReviewSummary(reviewCount: ${_this.reviewCount}, deliveryCount: ${_this.deliveryCount}, shoppingAverage: ${_this.shoppingAverage}, productAverage: ${_this.productAverage}, deliveryAverage: ${_this.deliveryAverage}, starCounts: ${_this.starCounts}, drivers: ${_this.drivers})';
}


}

/// @nodoc
abstract mixin class $ReviewSummaryCopyWith<$Res>  {
  factory $ReviewSummaryCopyWith(ReviewSummary value, $Res Function(ReviewSummary) _then) = _$ReviewSummaryCopyWithImpl;
@useResult
$Res call({
 int reviewCount, int deliveryCount, double shoppingAverage, double productAverage, double deliveryAverage, List<int> starCounts, List<DriverRating> drivers
});




}
/// @nodoc
class _$ReviewSummaryCopyWithImpl<$Res>
    implements $ReviewSummaryCopyWith<$Res> {
  _$ReviewSummaryCopyWithImpl(this._self, this._then);

  final ReviewSummary _self;
  final $Res Function(ReviewSummary) _then;

/// Create a copy of ReviewSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reviewCount = null,Object? deliveryCount = null,Object? shoppingAverage = null,Object? productAverage = null,Object? deliveryAverage = null,Object? starCounts = null,Object? drivers = null,}) {
  return _then(ReviewSummary(
reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,deliveryCount: null == deliveryCount ? _self.deliveryCount : deliveryCount // ignore: cast_nullable_to_non_nullable
as int,shoppingAverage: null == shoppingAverage ? _self.shoppingAverage : shoppingAverage // ignore: cast_nullable_to_non_nullable
as double,productAverage: null == productAverage ? _self.productAverage : productAverage // ignore: cast_nullable_to_non_nullable
as double,deliveryAverage: null == deliveryAverage ? _self.deliveryAverage : deliveryAverage // ignore: cast_nullable_to_non_nullable
as double,starCounts: null == starCounts ? _self.starCounts : starCounts // ignore: cast_nullable_to_non_nullable
as List<int>,drivers: null == drivers ? _self.drivers : drivers // ignore: cast_nullable_to_non_nullable
as List<DriverRating>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewSummary].
extension ReviewSummaryPatterns on ReviewSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewSummary value)  $default,){
final _that = this;
switch (_that) {
case _ReviewSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int reviewCount,  int deliveryCount,  double shoppingAverage,  double productAverage,  double deliveryAverage,  List<int> starCounts,  List<DriverRating> drivers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewSummary() when $default != null:
return $default(_that.reviewCount,_that.deliveryCount,_that.shoppingAverage,_that.productAverage,_that.deliveryAverage,_that.starCounts,_that.drivers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int reviewCount,  int deliveryCount,  double shoppingAverage,  double productAverage,  double deliveryAverage,  List<int> starCounts,  List<DriverRating> drivers)  $default,) {final _that = this;
switch (_that) {
case _ReviewSummary():
return $default(_that.reviewCount,_that.deliveryCount,_that.shoppingAverage,_that.productAverage,_that.deliveryAverage,_that.starCounts,_that.drivers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int reviewCount,  int deliveryCount,  double shoppingAverage,  double productAverage,  double deliveryAverage,  List<int> starCounts,  List<DriverRating> drivers)?  $default,) {final _that = this;
switch (_that) {
case _ReviewSummary() when $default != null:
return $default(_that.reviewCount,_that.deliveryCount,_that.shoppingAverage,_that.productAverage,_that.deliveryAverage,_that.starCounts,_that.drivers);case _:
  return null;

}
}

}

/// @nodoc


class _ReviewSummary extends ReviewSummary {
  const _ReviewSummary({required this.reviewCount, required this.deliveryCount, required this.shoppingAverage, required this.productAverage, required this.deliveryAverage, required  List<int> starCounts, required  List<DriverRating> drivers}): _starCounts = starCounts,_drivers = drivers,super._();
  

@override final  int reviewCount;
/// Reviews of delivery orders (pickup orders have no delivery score).
@override final  int deliveryCount;
/// Averages out of 5. 0 if there are no reviews.
@override final  double shoppingAverage;
@override final  double productAverage;
@override final  double deliveryAverage;
/// Reviews per overall star rating. Index 0 is 1 star.
 final  List<int> _starCounts;
/// Reviews per overall star rating. Index 0 is 1 star.
@override List<int> get starCounts {
  if (_starCounts is EqualUnmodifiableListView) return _starCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_starCounts);
}

/// Drivers who delivered for the branch, best rated first.
 final  List<DriverRating> _drivers;
/// Drivers who delivered for the branch, best rated first.
@override List<DriverRating> get drivers {
  if (_drivers is EqualUnmodifiableListView) return _drivers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_drivers);
}


/// Create a copy of ReviewSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewSummaryCopyWith<_ReviewSummary> get copyWith => __$ReviewSummaryCopyWithImpl<_ReviewSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewSummary&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.deliveryCount, deliveryCount) || other.deliveryCount == deliveryCount)&&(identical(other.shoppingAverage, shoppingAverage) || other.shoppingAverage == shoppingAverage)&&(identical(other.productAverage, productAverage) || other.productAverage == productAverage)&&(identical(other.deliveryAverage, deliveryAverage) || other.deliveryAverage == deliveryAverage)&&const DeepCollectionEquality().equals(other.starCounts, _starCounts)&&const DeepCollectionEquality().equals(other.drivers, _drivers));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reviewCount,deliveryCount,shoppingAverage,productAverage,deliveryAverage,const DeepCollectionEquality().hash(_starCounts),const DeepCollectionEquality().hash(_drivers));
}

@override
String toString() {
    return 'ReviewSummary(reviewCount: $reviewCount, deliveryCount: $deliveryCount, shoppingAverage: $shoppingAverage, productAverage: $productAverage, deliveryAverage: $deliveryAverage, starCounts: $starCounts, drivers: $drivers)';
}


}

/// @nodoc
abstract mixin class _$ReviewSummaryCopyWith<$Res> implements $ReviewSummaryCopyWith<$Res> {
  factory _$ReviewSummaryCopyWith(_ReviewSummary value, $Res Function(_ReviewSummary) _then) = __$ReviewSummaryCopyWithImpl;
@override @useResult
$Res call({
 int reviewCount, int deliveryCount, double shoppingAverage, double productAverage, double deliveryAverage, List<int> starCounts, List<DriverRating> drivers
});




}
/// @nodoc
class __$ReviewSummaryCopyWithImpl<$Res>
    implements _$ReviewSummaryCopyWith<$Res> {
  __$ReviewSummaryCopyWithImpl(this._self, this._then);

  final _ReviewSummary _self;
  final $Res Function(_ReviewSummary) _then;

/// Create a copy of ReviewSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reviewCount = null,Object? deliveryCount = null,Object? shoppingAverage = null,Object? productAverage = null,Object? deliveryAverage = null,Object? starCounts = null,Object? drivers = null,}) {
  return _then(_ReviewSummary(
reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,deliveryCount: null == deliveryCount ? _self.deliveryCount : deliveryCount // ignore: cast_nullable_to_non_nullable
as int,shoppingAverage: null == shoppingAverage ? _self.shoppingAverage : shoppingAverage // ignore: cast_nullable_to_non_nullable
as double,productAverage: null == productAverage ? _self.productAverage : productAverage // ignore: cast_nullable_to_non_nullable
as double,deliveryAverage: null == deliveryAverage ? _self.deliveryAverage : deliveryAverage // ignore: cast_nullable_to_non_nullable
as double,starCounts: null == starCounts ? _self._starCounts : starCounts // ignore: cast_nullable_to_non_nullable
as List<int>,drivers: null == drivers ? _self._drivers : drivers // ignore: cast_nullable_to_non_nullable
as List<DriverRating>,
  ));
}


}

/// @nodoc
mixin _$DriverRating {

 String get driverId; String get name; double get average; int get reviewCount;
/// Create a copy of DriverRating
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverRatingCopyWith<DriverRating> get copyWith => _$DriverRatingCopyWithImpl<DriverRating>(this as DriverRating, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DriverRating;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverRating&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.average, _this.average) || other.average == _this.average)&&(identical(other.reviewCount, _this.reviewCount) || other.reviewCount == _this.reviewCount));
}


@override
int get hashCode {
  final _this = this as DriverRating;
  return Object.hash(runtimeType,_this.driverId,_this.name,_this.average,_this.reviewCount);
}

@override
String toString() {
  final _this = this as DriverRating;
  return 'DriverRating(driverId: ${_this.driverId}, name: ${_this.name}, average: ${_this.average}, reviewCount: ${_this.reviewCount})';
}


}

/// @nodoc
abstract mixin class $DriverRatingCopyWith<$Res>  {
  factory $DriverRatingCopyWith(DriverRating value, $Res Function(DriverRating) _then) = _$DriverRatingCopyWithImpl;
@useResult
$Res call({
 String driverId, String name, double average, int reviewCount
});




}
/// @nodoc
class _$DriverRatingCopyWithImpl<$Res>
    implements $DriverRatingCopyWith<$Res> {
  _$DriverRatingCopyWithImpl(this._self, this._then);

  final DriverRating _self;
  final $Res Function(DriverRating) _then;

/// Create a copy of DriverRating
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? driverId = null,Object? name = null,Object? average = null,Object? reviewCount = null,}) {
  return _then(DriverRating(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,average: null == average ? _self.average : average // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverRating].
extension DriverRatingPatterns on DriverRating {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverRating value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverRating() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverRating value)  $default,){
final _that = this;
switch (_that) {
case _DriverRating():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverRating value)?  $default,){
final _that = this;
switch (_that) {
case _DriverRating() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String driverId,  String name,  double average,  int reviewCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverRating() when $default != null:
return $default(_that.driverId,_that.name,_that.average,_that.reviewCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String driverId,  String name,  double average,  int reviewCount)  $default,) {final _that = this;
switch (_that) {
case _DriverRating():
return $default(_that.driverId,_that.name,_that.average,_that.reviewCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String driverId,  String name,  double average,  int reviewCount)?  $default,) {final _that = this;
switch (_that) {
case _DriverRating() when $default != null:
return $default(_that.driverId,_that.name,_that.average,_that.reviewCount);case _:
  return null;

}
}

}

/// @nodoc


class _DriverRating extends DriverRating {
  const _DriverRating({required this.driverId, required this.name, required this.average, required this.reviewCount}): super._();
  

@override final  String driverId;
@override final  String name;
@override final  double average;
@override final  int reviewCount;

/// Create a copy of DriverRating
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverRatingCopyWith<_DriverRating> get copyWith => __$DriverRatingCopyWithImpl<_DriverRating>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverRating&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.name, name) || other.name == name)&&(identical(other.average, average) || other.average == average)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,driverId,name,average,reviewCount);
}

@override
String toString() {
    return 'DriverRating(driverId: $driverId, name: $name, average: $average, reviewCount: $reviewCount)';
}


}

/// @nodoc
abstract mixin class _$DriverRatingCopyWith<$Res> implements $DriverRatingCopyWith<$Res> {
  factory _$DriverRatingCopyWith(_DriverRating value, $Res Function(_DriverRating) _then) = __$DriverRatingCopyWithImpl;
@override @useResult
$Res call({
 String driverId, String name, double average, int reviewCount
});




}
/// @nodoc
class __$DriverRatingCopyWithImpl<$Res>
    implements _$DriverRatingCopyWith<$Res> {
  __$DriverRatingCopyWithImpl(this._self, this._then);

  final _DriverRating _self;
  final $Res Function(_DriverRating) _then;

/// Create a copy of DriverRating
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? driverId = null,Object? name = null,Object? average = null,Object? reviewCount = null,}) {
  return _then(_DriverRating(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,average: null == average ? _self.average : average // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
