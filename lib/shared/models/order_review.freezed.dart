// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderReview {

/// The order this rates (also the document id).
 String get id; int get orderNumber; String get branchId; String get customerId; String get customerName;/// How the shopping experience went.
 int get shoppingScore;/// Quality of the products.
 int get productScore;/// Null for pickup orders.
 int? get deliveryScore;/// Driver who delivered it. Null for pickup orders.
 String? get driverId; String? get driverName;/// Written feedback. Null if the customer left none.
 String? get comment;/// Null until Firestore has saved the server time.
 DateTime? get createdAt;
/// Create a copy of OrderReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderReviewCopyWith<OrderReview> get copyWith => _$OrderReviewCopyWithImpl<OrderReview>(this as OrderReview, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderReview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderReview&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.orderNumber, _this.orderNumber) || other.orderNumber == _this.orderNumber)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.shoppingScore, _this.shoppingScore) || other.shoppingScore == _this.shoppingScore)&&(identical(other.productScore, _this.productScore) || other.productScore == _this.productScore)&&(identical(other.deliveryScore, _this.deliveryScore) || other.deliveryScore == _this.deliveryScore)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.driverName, _this.driverName) || other.driverName == _this.driverName)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as OrderReview;
  return Object.hash(runtimeType,_this.id,_this.orderNumber,_this.branchId,_this.customerId,_this.customerName,_this.shoppingScore,_this.productScore,_this.deliveryScore,_this.driverId,_this.driverName,_this.comment,_this.createdAt);
}

@override
String toString() {
  final _this = this as OrderReview;
  return 'OrderReview(id: ${_this.id}, orderNumber: ${_this.orderNumber}, branchId: ${_this.branchId}, customerId: ${_this.customerId}, customerName: ${_this.customerName}, shoppingScore: ${_this.shoppingScore}, productScore: ${_this.productScore}, deliveryScore: ${_this.deliveryScore}, driverId: ${_this.driverId}, driverName: ${_this.driverName}, comment: ${_this.comment}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $OrderReviewCopyWith<$Res>  {
  factory $OrderReviewCopyWith(OrderReview value, $Res Function(OrderReview) _then) = _$OrderReviewCopyWithImpl;
@useResult
$Res call({
 String id, int orderNumber, String branchId, String customerId, String customerName, int shoppingScore, int productScore, int? deliveryScore, String? driverId, String? driverName, String? comment, DateTime? createdAt
});




}
/// @nodoc
class _$OrderReviewCopyWithImpl<$Res>
    implements $OrderReviewCopyWith<$Res> {
  _$OrderReviewCopyWithImpl(this._self, this._then);

  final OrderReview _self;
  final $Res Function(OrderReview) _then;

/// Create a copy of OrderReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? branchId = null,Object? customerId = null,Object? customerName = null,Object? shoppingScore = null,Object? productScore = null,Object? deliveryScore = freezed,Object? driverId = freezed,Object? driverName = freezed,Object? comment = freezed,Object? createdAt = freezed,}) {
  return _then(OrderReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,shoppingScore: null == shoppingScore ? _self.shoppingScore : shoppingScore // ignore: cast_nullable_to_non_nullable
as int,productScore: null == productScore ? _self.productScore : productScore // ignore: cast_nullable_to_non_nullable
as int,deliveryScore: freezed == deliveryScore ? _self.deliveryScore : deliveryScore // ignore: cast_nullable_to_non_nullable
as int?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderReview].
extension OrderReviewPatterns on OrderReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderReview value)  $default,){
final _that = this;
switch (_that) {
case _OrderReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderReview value)?  $default,){
final _that = this;
switch (_that) {
case _OrderReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int orderNumber,  String branchId,  String customerId,  String customerName,  int shoppingScore,  int productScore,  int? deliveryScore,  String? driverId,  String? driverName,  String? comment,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderReview() when $default != null:
return $default(_that.id,_that.orderNumber,_that.branchId,_that.customerId,_that.customerName,_that.shoppingScore,_that.productScore,_that.deliveryScore,_that.driverId,_that.driverName,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int orderNumber,  String branchId,  String customerId,  String customerName,  int shoppingScore,  int productScore,  int? deliveryScore,  String? driverId,  String? driverName,  String? comment,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _OrderReview():
return $default(_that.id,_that.orderNumber,_that.branchId,_that.customerId,_that.customerName,_that.shoppingScore,_that.productScore,_that.deliveryScore,_that.driverId,_that.driverName,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int orderNumber,  String branchId,  String customerId,  String customerName,  int shoppingScore,  int productScore,  int? deliveryScore,  String? driverId,  String? driverName,  String? comment,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderReview() when $default != null:
return $default(_that.id,_that.orderNumber,_that.branchId,_that.customerId,_that.customerName,_that.shoppingScore,_that.productScore,_that.deliveryScore,_that.driverId,_that.driverName,_that.comment,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _OrderReview extends OrderReview {
  const _OrderReview({required this.id, required this.orderNumber, required this.branchId, required this.customerId, required this.customerName, required this.shoppingScore, required this.productScore, this.deliveryScore, this.driverId, this.driverName, this.comment, this.createdAt}): super._();
  

/// The order this rates (also the document id).
@override final  String id;
@override final  int orderNumber;
@override final  String branchId;
@override final  String customerId;
@override final  String customerName;
/// How the shopping experience went.
@override final  int shoppingScore;
/// Quality of the products.
@override final  int productScore;
/// Null for pickup orders.
@override final  int? deliveryScore;
/// Driver who delivered it. Null for pickup orders.
@override final  String? driverId;
@override final  String? driverName;
/// Written feedback. Null if the customer left none.
@override final  String? comment;
/// Null until Firestore has saved the server time.
@override final  DateTime? createdAt;

/// Create a copy of OrderReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderReviewCopyWith<_OrderReview> get copyWith => __$OrderReviewCopyWithImpl<_OrderReview>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderReview&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.shoppingScore, shoppingScore) || other.shoppingScore == shoppingScore)&&(identical(other.productScore, productScore) || other.productScore == productScore)&&(identical(other.deliveryScore, deliveryScore) || other.deliveryScore == deliveryScore)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,orderNumber,branchId,customerId,customerName,shoppingScore,productScore,deliveryScore,driverId,driverName,comment,createdAt);
}

@override
String toString() {
    return 'OrderReview(id: $id, orderNumber: $orderNumber, branchId: $branchId, customerId: $customerId, customerName: $customerName, shoppingScore: $shoppingScore, productScore: $productScore, deliveryScore: $deliveryScore, driverId: $driverId, driverName: $driverName, comment: $comment, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OrderReviewCopyWith<$Res> implements $OrderReviewCopyWith<$Res> {
  factory _$OrderReviewCopyWith(_OrderReview value, $Res Function(_OrderReview) _then) = __$OrderReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, int orderNumber, String branchId, String customerId, String customerName, int shoppingScore, int productScore, int? deliveryScore, String? driverId, String? driverName, String? comment, DateTime? createdAt
});




}
/// @nodoc
class __$OrderReviewCopyWithImpl<$Res>
    implements _$OrderReviewCopyWith<$Res> {
  __$OrderReviewCopyWithImpl(this._self, this._then);

  final _OrderReview _self;
  final $Res Function(_OrderReview) _then;

/// Create a copy of OrderReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? branchId = null,Object? customerId = null,Object? customerName = null,Object? shoppingScore = null,Object? productScore = null,Object? deliveryScore = freezed,Object? driverId = freezed,Object? driverName = freezed,Object? comment = freezed,Object? createdAt = freezed,}) {
  return _then(_OrderReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as int,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,shoppingScore: null == shoppingScore ? _self.shoppingScore : shoppingScore // ignore: cast_nullable_to_non_nullable
as int,productScore: null == productScore ? _self.productScore : productScore // ignore: cast_nullable_to_non_nullable
as int,deliveryScore: freezed == deliveryScore ? _self.deliveryScore : deliveryScore // ignore: cast_nullable_to_non_nullable
as int?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
