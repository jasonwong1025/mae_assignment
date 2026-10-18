// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Review {

 String get id; int get orderNumber; String get branchId; String get customerName; DateTime get createdAt;/// Scores from 1 to 5.
 int get shoppingScore; int get productScore;/// Null for pickup orders.
 int? get deliveryScore;/// Driver who delivered it. Null for pickup orders.
 String? get driverId; String? get driverName;/// Written feedback. Null if the customer left none.
 String? get comment;
/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewCopyWith<Review> get copyWith => _$ReviewCopyWithImpl<Review>(this as Review, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Review;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Review&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.orderNumber, _this.orderNumber) || other.orderNumber == _this.orderNumber)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.shoppingScore, _this.shoppingScore) || other.shoppingScore == _this.shoppingScore)&&(identical(other.productScore, _this.productScore) || other.productScore == _this.productScore)&&(identical(other.deliveryScore, _this.deliveryScore) || other.deliveryScore == _this.deliveryScore)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.driverName, _this.driverName) || other.driverName == _this.driverName)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}


@override
int get hashCode {
  final _this = this as Review;
  return Object.hash(runtimeType,_this.id,_this.orderNumber,_this.branchId,_this.customerName,_this.createdAt,_this.shoppingScore,_this.productScore,_this.deliveryScore,_this.driverId,_this.driverName,_this.comment);
}

@override
String toString() {
  final _this = this as Review;
  return 'Review(id: ${_this.id}, orderNumber: ${_this.orderNumber}, branchId: ${_this.branchId}, customerName: ${_this.customerName}, createdAt: ${_this.createdAt}, shoppingScore: ${_this.shoppingScore}, productScore: ${_this.productScore}, deliveryScore: ${_this.deliveryScore}, driverId: ${_this.driverId}, driverName: ${_this.driverName}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $ReviewCopyWith<$Res>  {
  factory $ReviewCopyWith(Review value, $Res Function(Review) _then) = _$ReviewCopyWithImpl;
@useResult
$Res call({
 String id, int orderNumber, String branchId, String customerName, DateTime createdAt, int shoppingScore, int productScore, int? deliveryScore, String? driverId, String? driverName, String? comment
});




}
/// @nodoc
class _$ReviewCopyWithImpl<$Res>
    implements $ReviewCopyWith<$Res> {
  _$ReviewCopyWithImpl(this._self, this._then);

  final Review _self;
  final $Res Function(Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? branchId = null,Object? customerName = null,Object? createdAt = null,Object? shoppingScore = null,Object? productScore = null,Object? deliveryScore = freezed,Object? driverId = freezed,Object? driverName = freezed,Object? comment = freezed,}) {
  return _then(Review(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,shoppingScore: null == shoppingScore ? _self.shoppingScore : shoppingScore // ignore: cast_nullable_to_non_nullable
as int,productScore: null == productScore ? _self.productScore : productScore // ignore: cast_nullable_to_non_nullable
as int,deliveryScore: freezed == deliveryScore ? _self.deliveryScore : deliveryScore // ignore: cast_nullable_to_non_nullable
as int?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Review].
extension ReviewPatterns on Review {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Review value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Review value)  $default,){
final _that = this;
switch (_that) {
case _Review():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Review value)?  $default,){
final _that = this;
switch (_that) {
case _Review() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int orderNumber,  String branchId,  String customerName,  DateTime createdAt,  int shoppingScore,  int productScore,  int? deliveryScore,  String? driverId,  String? driverName,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.id,_that.orderNumber,_that.branchId,_that.customerName,_that.createdAt,_that.shoppingScore,_that.productScore,_that.deliveryScore,_that.driverId,_that.driverName,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int orderNumber,  String branchId,  String customerName,  DateTime createdAt,  int shoppingScore,  int productScore,  int? deliveryScore,  String? driverId,  String? driverName,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _Review():
return $default(_that.id,_that.orderNumber,_that.branchId,_that.customerName,_that.createdAt,_that.shoppingScore,_that.productScore,_that.deliveryScore,_that.driverId,_that.driverName,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int orderNumber,  String branchId,  String customerName,  DateTime createdAt,  int shoppingScore,  int productScore,  int? deliveryScore,  String? driverId,  String? driverName,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _Review() when $default != null:
return $default(_that.id,_that.orderNumber,_that.branchId,_that.customerName,_that.createdAt,_that.shoppingScore,_that.productScore,_that.deliveryScore,_that.driverId,_that.driverName,_that.comment);case _:
  return null;

}
}

}

/// @nodoc


class _Review extends Review {
  const _Review({required this.id, required this.orderNumber, required this.branchId, required this.customerName, required this.createdAt, required this.shoppingScore, required this.productScore, this.deliveryScore, this.driverId, this.driverName, this.comment}): super._();
  

@override final  String id;
@override final  int orderNumber;
@override final  String branchId;
@override final  String customerName;
@override final  DateTime createdAt;
/// Scores from 1 to 5.
@override final  int shoppingScore;
@override final  int productScore;
/// Null for pickup orders.
@override final  int? deliveryScore;
/// Driver who delivered it. Null for pickup orders.
@override final  String? driverId;
@override final  String? driverName;
/// Written feedback. Null if the customer left none.
@override final  String? comment;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewCopyWith<_Review> get copyWith => __$ReviewCopyWithImpl<_Review>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Review&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.shoppingScore, shoppingScore) || other.shoppingScore == shoppingScore)&&(identical(other.productScore, productScore) || other.productScore == productScore)&&(identical(other.deliveryScore, deliveryScore) || other.deliveryScore == deliveryScore)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.comment, comment) || other.comment == comment));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,orderNumber,branchId,customerName,createdAt,shoppingScore,productScore,deliveryScore,driverId,driverName,comment);
}

@override
String toString() {
    return 'Review(id: $id, orderNumber: $orderNumber, branchId: $branchId, customerName: $customerName, createdAt: $createdAt, shoppingScore: $shoppingScore, productScore: $productScore, deliveryScore: $deliveryScore, driverId: $driverId, driverName: $driverName, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$ReviewCopyWith<$Res> implements $ReviewCopyWith<$Res> {
  factory _$ReviewCopyWith(_Review value, $Res Function(_Review) _then) = __$ReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, int orderNumber, String branchId, String customerName, DateTime createdAt, int shoppingScore, int productScore, int? deliveryScore, String? driverId, String? driverName, String? comment
});




}
/// @nodoc
class __$ReviewCopyWithImpl<$Res>
    implements _$ReviewCopyWith<$Res> {
  __$ReviewCopyWithImpl(this._self, this._then);

  final _Review _self;
  final $Res Function(_Review) _then;

/// Create a copy of Review
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? branchId = null,Object? customerName = null,Object? createdAt = null,Object? shoppingScore = null,Object? productScore = null,Object? deliveryScore = freezed,Object? driverId = freezed,Object? driverName = freezed,Object? comment = freezed,}) {
  return _then(_Review(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,shoppingScore: null == shoppingScore ? _self.shoppingScore : shoppingScore // ignore: cast_nullable_to_non_nullable
as int,productScore: null == productScore ? _self.productScore : productScore // ignore: cast_nullable_to_non_nullable
as int,deliveryScore: freezed == deliveryScore ? _self.deliveryScore : deliveryScore // ignore: cast_nullable_to_non_nullable
as int?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
