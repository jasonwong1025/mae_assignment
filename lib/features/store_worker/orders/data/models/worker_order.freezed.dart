// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worker_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkerOrderItem {

/// Unique within its order and never reused. The packing checklist is
/// keyed by this, not by productId, so the same product can appear on
/// two lines.
 String get lineId; String get productId; String get name; String get brand;/// E.g. "1L" or "500g".
 String get packSize; int get quantity;/// Price of one at the order's branch, in ringgit.
 double get unitPrice;/// Category name, e.g. "Dairy & Eggs". Empty if unknown.
 String get category;/// Product description from the catalogue. Can be empty.
 String get description;/// Product photo. Null shows a placeholder.
 String? get imageUrl;
/// Create a copy of WorkerOrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkerOrderItemCopyWith<WorkerOrderItem> get copyWith => _$WorkerOrderItemCopyWithImpl<WorkerOrderItem>(this as WorkerOrderItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkerOrderItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkerOrderItem&&(identical(other.lineId, _this.lineId) || other.lineId == _this.lineId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.packSize, _this.packSize) || other.packSize == _this.packSize)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl));
}


@override
int get hashCode {
  final _this = this as WorkerOrderItem;
  return Object.hash(runtimeType,_this.lineId,_this.productId,_this.name,_this.brand,_this.packSize,_this.quantity,_this.unitPrice,_this.category,_this.description,_this.imageUrl);
}

@override
String toString() {
  final _this = this as WorkerOrderItem;
  return 'WorkerOrderItem(lineId: ${_this.lineId}, productId: ${_this.productId}, name: ${_this.name}, brand: ${_this.brand}, packSize: ${_this.packSize}, quantity: ${_this.quantity}, unitPrice: ${_this.unitPrice}, category: ${_this.category}, description: ${_this.description}, imageUrl: ${_this.imageUrl})';
}


}

/// @nodoc
abstract mixin class $WorkerOrderItemCopyWith<$Res>  {
  factory $WorkerOrderItemCopyWith(WorkerOrderItem value, $Res Function(WorkerOrderItem) _then) = _$WorkerOrderItemCopyWithImpl;
@useResult
$Res call({
 String lineId, String productId, String name, String brand, String packSize, int quantity, double unitPrice, String category, String description, String? imageUrl
});




}
/// @nodoc
class _$WorkerOrderItemCopyWithImpl<$Res>
    implements $WorkerOrderItemCopyWith<$Res> {
  _$WorkerOrderItemCopyWithImpl(this._self, this._then);

  final WorkerOrderItem _self;
  final $Res Function(WorkerOrderItem) _then;

/// Create a copy of WorkerOrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineId = null,Object? productId = null,Object? name = null,Object? brand = null,Object? packSize = null,Object? quantity = null,Object? unitPrice = null,Object? category = null,Object? description = null,Object? imageUrl = freezed,}) {
  return _then(WorkerOrderItem(
lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,packSize: null == packSize ? _self.packSize : packSize // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkerOrderItem].
extension WorkerOrderItemPatterns on WorkerOrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkerOrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkerOrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkerOrderItem value)  $default,){
final _that = this;
switch (_that) {
case _WorkerOrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkerOrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _WorkerOrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lineId,  String productId,  String name,  String brand,  String packSize,  int quantity,  double unitPrice,  String category,  String description,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkerOrderItem() when $default != null:
return $default(_that.lineId,_that.productId,_that.name,_that.brand,_that.packSize,_that.quantity,_that.unitPrice,_that.category,_that.description,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lineId,  String productId,  String name,  String brand,  String packSize,  int quantity,  double unitPrice,  String category,  String description,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _WorkerOrderItem():
return $default(_that.lineId,_that.productId,_that.name,_that.brand,_that.packSize,_that.quantity,_that.unitPrice,_that.category,_that.description,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lineId,  String productId,  String name,  String brand,  String packSize,  int quantity,  double unitPrice,  String category,  String description,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _WorkerOrderItem() when $default != null:
return $default(_that.lineId,_that.productId,_that.name,_that.brand,_that.packSize,_that.quantity,_that.unitPrice,_that.category,_that.description,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc


class _WorkerOrderItem extends WorkerOrderItem {
  const _WorkerOrderItem({required this.lineId, required this.productId, required this.name, required this.brand, required this.packSize, required this.quantity, this.unitPrice = 0, this.category = '', this.description = '', this.imageUrl}): super._();
  

/// Unique within its order and never reused. The packing checklist is
/// keyed by this, not by productId, so the same product can appear on
/// two lines.
@override final  String lineId;
@override final  String productId;
@override final  String name;
@override final  String brand;
/// E.g. "1L" or "500g".
@override final  String packSize;
@override final  int quantity;
/// Price of one at the order's branch, in ringgit.
@override@JsonKey() final  double unitPrice;
/// Category name, e.g. "Dairy & Eggs". Empty if unknown.
@override@JsonKey() final  String category;
/// Product description from the catalogue. Can be empty.
@override@JsonKey() final  String description;
/// Product photo. Null shows a placeholder.
@override final  String? imageUrl;

/// Create a copy of WorkerOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkerOrderItemCopyWith<_WorkerOrderItem> get copyWith => __$WorkerOrderItemCopyWithImpl<_WorkerOrderItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkerOrderItem&&(identical(other.lineId, lineId) || other.lineId == lineId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.packSize, packSize) || other.packSize == packSize)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lineId,productId,name,brand,packSize,quantity,unitPrice,category,description,imageUrl);
}

@override
String toString() {
    return 'WorkerOrderItem(lineId: $lineId, productId: $productId, name: $name, brand: $brand, packSize: $packSize, quantity: $quantity, unitPrice: $unitPrice, category: $category, description: $description, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$WorkerOrderItemCopyWith<$Res> implements $WorkerOrderItemCopyWith<$Res> {
  factory _$WorkerOrderItemCopyWith(_WorkerOrderItem value, $Res Function(_WorkerOrderItem) _then) = __$WorkerOrderItemCopyWithImpl;
@override @useResult
$Res call({
 String lineId, String productId, String name, String brand, String packSize, int quantity, double unitPrice, String category, String description, String? imageUrl
});




}
/// @nodoc
class __$WorkerOrderItemCopyWithImpl<$Res>
    implements _$WorkerOrderItemCopyWith<$Res> {
  __$WorkerOrderItemCopyWithImpl(this._self, this._then);

  final _WorkerOrderItem _self;
  final $Res Function(_WorkerOrderItem) _then;

/// Create a copy of WorkerOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineId = null,Object? productId = null,Object? name = null,Object? brand = null,Object? packSize = null,Object? quantity = null,Object? unitPrice = null,Object? category = null,Object? description = null,Object? imageUrl = freezed,}) {
  return _then(_WorkerOrderItem(
lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,packSize: null == packSize ? _self.packSize : packSize // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$WorkerOrder {

/// Unique id. Used in routes and the QR label.
 String get id;/// Number shown to people, e.g. 2301 for "#2301".
 int get number; String get branchId; String get branchName; String get customerName; String get customerPhone;/// False for self-pickup.
 bool get isDelivery; List<WorkerOrderItem> get items; OrderStatus get status; DateTime get placedAt;/// When the order entered its current status.
 DateTime get statusSince; String get packerId; String get packerName; DateTime get packerAssignedAt;/// Where the bag is collected from (the branch's address), shown to
/// drivers, who can be given deliveries from any branch.
 String? get branchAddress;/// When the customer was promised the order: pickup time or delivery
/// time. Packing tasks are sorted by this, soonest first.
 DateTime? get dueAt;/// Line ids already packed.
 Set<String> get packedLineIds;/// Delivery address. Null for pickup orders.
 String? get address;/// Message the customer left with the order.
 String? get customerNote;/// Delivery orders only.
 String? get driverId; String? get driverName; DateTime? get driverAssignedAt; DateTime? get packingStartedAt; DateTime? get readyAt;/// Worker id of the packer who marked the order ready.
 String? get readyBy; VerificationMethod? get pickupVerification; String? get pickupCompletedBy; String? get pickupCompletedByName; VerificationMethod? get collectionVerification;/// Driver who verified the bag. Start delivery needs this to be the
/// driver assigned now, so a replacement driver must verify again.
 String? get collectionVerifiedBy; DateTime? get collectionVerifiedAt; DateTime? get outForDeliveryAt; String? get deliveredBy; String? get deliveredByName;/// Photo the driver took when delivering. Kept in memory for the mock;
/// later uploaded to storage with only its URL on the order.
 Uint8List? get proofPhoto;/// When the order was completed, by pickup or by delivery.
 DateTime? get completedAt; DateTime? get cancelledAt;
/// Create a copy of WorkerOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkerOrderCopyWith<WorkerOrder> get copyWith => _$WorkerOrderCopyWithImpl<WorkerOrder>(this as WorkerOrder, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WorkerOrder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkerOrder&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.branchName, _this.branchName) || other.branchName == _this.branchName)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.customerPhone, _this.customerPhone) || other.customerPhone == _this.customerPhone)&&(identical(other.isDelivery, _this.isDelivery) || other.isDelivery == _this.isDelivery)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.placedAt, _this.placedAt) || other.placedAt == _this.placedAt)&&(identical(other.statusSince, _this.statusSince) || other.statusSince == _this.statusSince)&&(identical(other.packerId, _this.packerId) || other.packerId == _this.packerId)&&(identical(other.packerName, _this.packerName) || other.packerName == _this.packerName)&&(identical(other.packerAssignedAt, _this.packerAssignedAt) || other.packerAssignedAt == _this.packerAssignedAt)&&(identical(other.branchAddress, _this.branchAddress) || other.branchAddress == _this.branchAddress)&&(identical(other.dueAt, _this.dueAt) || other.dueAt == _this.dueAt)&&const DeepCollectionEquality().equals(other.packedLineIds, _this.packedLineIds)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.customerNote, _this.customerNote) || other.customerNote == _this.customerNote)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.driverName, _this.driverName) || other.driverName == _this.driverName)&&(identical(other.driverAssignedAt, _this.driverAssignedAt) || other.driverAssignedAt == _this.driverAssignedAt)&&(identical(other.packingStartedAt, _this.packingStartedAt) || other.packingStartedAt == _this.packingStartedAt)&&(identical(other.readyAt, _this.readyAt) || other.readyAt == _this.readyAt)&&(identical(other.readyBy, _this.readyBy) || other.readyBy == _this.readyBy)&&(identical(other.pickupVerification, _this.pickupVerification) || other.pickupVerification == _this.pickupVerification)&&(identical(other.pickupCompletedBy, _this.pickupCompletedBy) || other.pickupCompletedBy == _this.pickupCompletedBy)&&(identical(other.pickupCompletedByName, _this.pickupCompletedByName) || other.pickupCompletedByName == _this.pickupCompletedByName)&&(identical(other.collectionVerification, _this.collectionVerification) || other.collectionVerification == _this.collectionVerification)&&(identical(other.collectionVerifiedBy, _this.collectionVerifiedBy) || other.collectionVerifiedBy == _this.collectionVerifiedBy)&&(identical(other.collectionVerifiedAt, _this.collectionVerifiedAt) || other.collectionVerifiedAt == _this.collectionVerifiedAt)&&(identical(other.outForDeliveryAt, _this.outForDeliveryAt) || other.outForDeliveryAt == _this.outForDeliveryAt)&&(identical(other.deliveredBy, _this.deliveredBy) || other.deliveredBy == _this.deliveredBy)&&(identical(other.deliveredByName, _this.deliveredByName) || other.deliveredByName == _this.deliveredByName)&&const DeepCollectionEquality().equals(other.proofPhoto, _this.proofPhoto)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.cancelledAt, _this.cancelledAt) || other.cancelledAt == _this.cancelledAt));
}


@override
int get hashCode {
  final _this = this as WorkerOrder;
  return Object.hashAll([runtimeType,_this.id,_this.number,_this.branchId,_this.branchName,_this.customerName,_this.customerPhone,_this.isDelivery,const DeepCollectionEquality().hash(_this.items),_this.status,_this.placedAt,_this.statusSince,_this.packerId,_this.packerName,_this.packerAssignedAt,_this.branchAddress,_this.dueAt,const DeepCollectionEquality().hash(_this.packedLineIds),_this.address,_this.customerNote,_this.driverId,_this.driverName,_this.driverAssignedAt,_this.packingStartedAt,_this.readyAt,_this.readyBy,_this.pickupVerification,_this.pickupCompletedBy,_this.pickupCompletedByName,_this.collectionVerification,_this.collectionVerifiedBy,_this.collectionVerifiedAt,_this.outForDeliveryAt,_this.deliveredBy,_this.deliveredByName,const DeepCollectionEquality().hash(_this.proofPhoto),_this.completedAt,_this.cancelledAt]);
}

@override
String toString() {
  final _this = this as WorkerOrder;
  return 'WorkerOrder(id: ${_this.id}, number: ${_this.number}, branchId: ${_this.branchId}, branchName: ${_this.branchName}, customerName: ${_this.customerName}, customerPhone: ${_this.customerPhone}, isDelivery: ${_this.isDelivery}, items: ${_this.items}, status: ${_this.status}, placedAt: ${_this.placedAt}, statusSince: ${_this.statusSince}, packerId: ${_this.packerId}, packerName: ${_this.packerName}, packerAssignedAt: ${_this.packerAssignedAt}, branchAddress: ${_this.branchAddress}, dueAt: ${_this.dueAt}, packedLineIds: ${_this.packedLineIds}, address: ${_this.address}, customerNote: ${_this.customerNote}, driverId: ${_this.driverId}, driverName: ${_this.driverName}, driverAssignedAt: ${_this.driverAssignedAt}, packingStartedAt: ${_this.packingStartedAt}, readyAt: ${_this.readyAt}, readyBy: ${_this.readyBy}, pickupVerification: ${_this.pickupVerification}, pickupCompletedBy: ${_this.pickupCompletedBy}, pickupCompletedByName: ${_this.pickupCompletedByName}, collectionVerification: ${_this.collectionVerification}, collectionVerifiedBy: ${_this.collectionVerifiedBy}, collectionVerifiedAt: ${_this.collectionVerifiedAt}, outForDeliveryAt: ${_this.outForDeliveryAt}, deliveredBy: ${_this.deliveredBy}, deliveredByName: ${_this.deliveredByName}, proofPhoto: ${_this.proofPhoto}, completedAt: ${_this.completedAt}, cancelledAt: ${_this.cancelledAt})';
}


}

/// @nodoc
abstract mixin class $WorkerOrderCopyWith<$Res>  {
  factory $WorkerOrderCopyWith(WorkerOrder value, $Res Function(WorkerOrder) _then) = _$WorkerOrderCopyWithImpl;
@useResult
$Res call({
 String id, int number, String branchId, String branchName, String customerName, String customerPhone, bool isDelivery, List<WorkerOrderItem> items, OrderStatus status, DateTime placedAt, DateTime statusSince, String packerId, String packerName, DateTime packerAssignedAt, String? branchAddress, DateTime? dueAt, Set<String> packedLineIds, String? address, String? customerNote, String? driverId, String? driverName, DateTime? driverAssignedAt, DateTime? packingStartedAt, DateTime? readyAt, String? readyBy, VerificationMethod? pickupVerification, String? pickupCompletedBy, String? pickupCompletedByName, VerificationMethod? collectionVerification, String? collectionVerifiedBy, DateTime? collectionVerifiedAt, DateTime? outForDeliveryAt, String? deliveredBy, String? deliveredByName, Uint8List? proofPhoto, DateTime? completedAt, DateTime? cancelledAt
});




}
/// @nodoc
class _$WorkerOrderCopyWithImpl<$Res>
    implements $WorkerOrderCopyWith<$Res> {
  _$WorkerOrderCopyWithImpl(this._self, this._then);

  final WorkerOrder _self;
  final $Res Function(WorkerOrder) _then;

/// Create a copy of WorkerOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? branchId = null,Object? branchName = null,Object? customerName = null,Object? customerPhone = null,Object? isDelivery = null,Object? items = null,Object? status = null,Object? placedAt = null,Object? statusSince = null,Object? packerId = null,Object? packerName = null,Object? packerAssignedAt = null,Object? branchAddress = freezed,Object? dueAt = freezed,Object? packedLineIds = null,Object? address = freezed,Object? customerNote = freezed,Object? driverId = freezed,Object? driverName = freezed,Object? driverAssignedAt = freezed,Object? packingStartedAt = freezed,Object? readyAt = freezed,Object? readyBy = freezed,Object? pickupVerification = freezed,Object? pickupCompletedBy = freezed,Object? pickupCompletedByName = freezed,Object? collectionVerification = freezed,Object? collectionVerifiedBy = freezed,Object? collectionVerifiedAt = freezed,Object? outForDeliveryAt = freezed,Object? deliveredBy = freezed,Object? deliveredByName = freezed,Object? proofPhoto = freezed,Object? completedAt = freezed,Object? cancelledAt = freezed,}) {
  return _then(WorkerOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,isDelivery: null == isDelivery ? _self.isDelivery : isDelivery // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<WorkerOrderItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,statusSince: null == statusSince ? _self.statusSince : statusSince // ignore: cast_nullable_to_non_nullable
as DateTime,packerId: null == packerId ? _self.packerId : packerId // ignore: cast_nullable_to_non_nullable
as String,packerName: null == packerName ? _self.packerName : packerName // ignore: cast_nullable_to_non_nullable
as String,packerAssignedAt: null == packerAssignedAt ? _self.packerAssignedAt : packerAssignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,branchAddress: freezed == branchAddress ? _self.branchAddress : branchAddress // ignore: cast_nullable_to_non_nullable
as String?,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,packedLineIds: null == packedLineIds ? _self.packedLineIds : packedLineIds // ignore: cast_nullable_to_non_nullable
as Set<String>,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,driverAssignedAt: freezed == driverAssignedAt ? _self.driverAssignedAt : driverAssignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,packingStartedAt: freezed == packingStartedAt ? _self.packingStartedAt : packingStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readyAt: freezed == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readyBy: freezed == readyBy ? _self.readyBy : readyBy // ignore: cast_nullable_to_non_nullable
as String?,pickupVerification: freezed == pickupVerification ? _self.pickupVerification : pickupVerification // ignore: cast_nullable_to_non_nullable
as VerificationMethod?,pickupCompletedBy: freezed == pickupCompletedBy ? _self.pickupCompletedBy : pickupCompletedBy // ignore: cast_nullable_to_non_nullable
as String?,pickupCompletedByName: freezed == pickupCompletedByName ? _self.pickupCompletedByName : pickupCompletedByName // ignore: cast_nullable_to_non_nullable
as String?,collectionVerification: freezed == collectionVerification ? _self.collectionVerification : collectionVerification // ignore: cast_nullable_to_non_nullable
as VerificationMethod?,collectionVerifiedBy: freezed == collectionVerifiedBy ? _self.collectionVerifiedBy : collectionVerifiedBy // ignore: cast_nullable_to_non_nullable
as String?,collectionVerifiedAt: freezed == collectionVerifiedAt ? _self.collectionVerifiedAt : collectionVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outForDeliveryAt: freezed == outForDeliveryAt ? _self.outForDeliveryAt : outForDeliveryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredBy: freezed == deliveredBy ? _self.deliveredBy : deliveredBy // ignore: cast_nullable_to_non_nullable
as String?,deliveredByName: freezed == deliveredByName ? _self.deliveredByName : deliveredByName // ignore: cast_nullable_to_non_nullable
as String?,proofPhoto: freezed == proofPhoto ? _self.proofPhoto : proofPhoto // ignore: cast_nullable_to_non_nullable
as Uint8List?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkerOrder].
extension WorkerOrderPatterns on WorkerOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkerOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkerOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkerOrder value)  $default,){
final _that = this;
switch (_that) {
case _WorkerOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkerOrder value)?  $default,){
final _that = this;
switch (_that) {
case _WorkerOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  String branchId,  String branchName,  String customerName,  String customerPhone,  bool isDelivery,  List<WorkerOrderItem> items,  OrderStatus status,  DateTime placedAt,  DateTime statusSince,  String packerId,  String packerName,  DateTime packerAssignedAt,  String? branchAddress,  DateTime? dueAt,  Set<String> packedLineIds,  String? address,  String? customerNote,  String? driverId,  String? driverName,  DateTime? driverAssignedAt,  DateTime? packingStartedAt,  DateTime? readyAt,  String? readyBy,  VerificationMethod? pickupVerification,  String? pickupCompletedBy,  String? pickupCompletedByName,  VerificationMethod? collectionVerification,  String? collectionVerifiedBy,  DateTime? collectionVerifiedAt,  DateTime? outForDeliveryAt,  String? deliveredBy,  String? deliveredByName,  Uint8List? proofPhoto,  DateTime? completedAt,  DateTime? cancelledAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkerOrder() when $default != null:
return $default(_that.id,_that.number,_that.branchId,_that.branchName,_that.customerName,_that.customerPhone,_that.isDelivery,_that.items,_that.status,_that.placedAt,_that.statusSince,_that.packerId,_that.packerName,_that.packerAssignedAt,_that.branchAddress,_that.dueAt,_that.packedLineIds,_that.address,_that.customerNote,_that.driverId,_that.driverName,_that.driverAssignedAt,_that.packingStartedAt,_that.readyAt,_that.readyBy,_that.pickupVerification,_that.pickupCompletedBy,_that.pickupCompletedByName,_that.collectionVerification,_that.collectionVerifiedBy,_that.collectionVerifiedAt,_that.outForDeliveryAt,_that.deliveredBy,_that.deliveredByName,_that.proofPhoto,_that.completedAt,_that.cancelledAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  String branchId,  String branchName,  String customerName,  String customerPhone,  bool isDelivery,  List<WorkerOrderItem> items,  OrderStatus status,  DateTime placedAt,  DateTime statusSince,  String packerId,  String packerName,  DateTime packerAssignedAt,  String? branchAddress,  DateTime? dueAt,  Set<String> packedLineIds,  String? address,  String? customerNote,  String? driverId,  String? driverName,  DateTime? driverAssignedAt,  DateTime? packingStartedAt,  DateTime? readyAt,  String? readyBy,  VerificationMethod? pickupVerification,  String? pickupCompletedBy,  String? pickupCompletedByName,  VerificationMethod? collectionVerification,  String? collectionVerifiedBy,  DateTime? collectionVerifiedAt,  DateTime? outForDeliveryAt,  String? deliveredBy,  String? deliveredByName,  Uint8List? proofPhoto,  DateTime? completedAt,  DateTime? cancelledAt)  $default,) {final _that = this;
switch (_that) {
case _WorkerOrder():
return $default(_that.id,_that.number,_that.branchId,_that.branchName,_that.customerName,_that.customerPhone,_that.isDelivery,_that.items,_that.status,_that.placedAt,_that.statusSince,_that.packerId,_that.packerName,_that.packerAssignedAt,_that.branchAddress,_that.dueAt,_that.packedLineIds,_that.address,_that.customerNote,_that.driverId,_that.driverName,_that.driverAssignedAt,_that.packingStartedAt,_that.readyAt,_that.readyBy,_that.pickupVerification,_that.pickupCompletedBy,_that.pickupCompletedByName,_that.collectionVerification,_that.collectionVerifiedBy,_that.collectionVerifiedAt,_that.outForDeliveryAt,_that.deliveredBy,_that.deliveredByName,_that.proofPhoto,_that.completedAt,_that.cancelledAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  String branchId,  String branchName,  String customerName,  String customerPhone,  bool isDelivery,  List<WorkerOrderItem> items,  OrderStatus status,  DateTime placedAt,  DateTime statusSince,  String packerId,  String packerName,  DateTime packerAssignedAt,  String? branchAddress,  DateTime? dueAt,  Set<String> packedLineIds,  String? address,  String? customerNote,  String? driverId,  String? driverName,  DateTime? driverAssignedAt,  DateTime? packingStartedAt,  DateTime? readyAt,  String? readyBy,  VerificationMethod? pickupVerification,  String? pickupCompletedBy,  String? pickupCompletedByName,  VerificationMethod? collectionVerification,  String? collectionVerifiedBy,  DateTime? collectionVerifiedAt,  DateTime? outForDeliveryAt,  String? deliveredBy,  String? deliveredByName,  Uint8List? proofPhoto,  DateTime? completedAt,  DateTime? cancelledAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkerOrder() when $default != null:
return $default(_that.id,_that.number,_that.branchId,_that.branchName,_that.customerName,_that.customerPhone,_that.isDelivery,_that.items,_that.status,_that.placedAt,_that.statusSince,_that.packerId,_that.packerName,_that.packerAssignedAt,_that.branchAddress,_that.dueAt,_that.packedLineIds,_that.address,_that.customerNote,_that.driverId,_that.driverName,_that.driverAssignedAt,_that.packingStartedAt,_that.readyAt,_that.readyBy,_that.pickupVerification,_that.pickupCompletedBy,_that.pickupCompletedByName,_that.collectionVerification,_that.collectionVerifiedBy,_that.collectionVerifiedAt,_that.outForDeliveryAt,_that.deliveredBy,_that.deliveredByName,_that.proofPhoto,_that.completedAt,_that.cancelledAt);case _:
  return null;

}
}

}

/// @nodoc


class _WorkerOrder extends WorkerOrder {
  const _WorkerOrder({required this.id, required this.number, required this.branchId, required this.branchName, required this.customerName, required this.customerPhone, required this.isDelivery, required  List<WorkerOrderItem> items, required this.status, required this.placedAt, required this.statusSince, required this.packerId, required this.packerName, required this.packerAssignedAt, this.branchAddress, this.dueAt,  Set<String> packedLineIds = const <String>{}, this.address, this.customerNote, this.driverId, this.driverName, this.driverAssignedAt, this.packingStartedAt, this.readyAt, this.readyBy, this.pickupVerification, this.pickupCompletedBy, this.pickupCompletedByName, this.collectionVerification, this.collectionVerifiedBy, this.collectionVerifiedAt, this.outForDeliveryAt, this.deliveredBy, this.deliveredByName, this.proofPhoto, this.completedAt, this.cancelledAt}): _items = items,_packedLineIds = packedLineIds,super._();
  

/// Unique id. Used in routes and the QR label.
@override final  String id;
/// Number shown to people, e.g. 2301 for "#2301".
@override final  int number;
@override final  String branchId;
@override final  String branchName;
@override final  String customerName;
@override final  String customerPhone;
/// False for self-pickup.
@override final  bool isDelivery;
 final  List<WorkerOrderItem> _items;
@override List<WorkerOrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  OrderStatus status;
@override final  DateTime placedAt;
/// When the order entered its current status.
@override final  DateTime statusSince;
@override final  String packerId;
@override final  String packerName;
@override final  DateTime packerAssignedAt;
/// Where the bag is collected from (the branch's address), shown to
/// drivers, who can be given deliveries from any branch.
@override final  String? branchAddress;
/// When the customer was promised the order: pickup time or delivery
/// time. Packing tasks are sorted by this, soonest first.
@override final  DateTime? dueAt;
/// Line ids already packed.
 final  Set<String> _packedLineIds;
/// Line ids already packed.
@override@JsonKey() Set<String> get packedLineIds {
  if (_packedLineIds is EqualUnmodifiableSetView) return _packedLineIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_packedLineIds);
}

/// Delivery address. Null for pickup orders.
@override final  String? address;
/// Message the customer left with the order.
@override final  String? customerNote;
/// Delivery orders only.
@override final  String? driverId;
@override final  String? driverName;
@override final  DateTime? driverAssignedAt;
@override final  DateTime? packingStartedAt;
@override final  DateTime? readyAt;
/// Worker id of the packer who marked the order ready.
@override final  String? readyBy;
@override final  VerificationMethod? pickupVerification;
@override final  String? pickupCompletedBy;
@override final  String? pickupCompletedByName;
@override final  VerificationMethod? collectionVerification;
/// Driver who verified the bag. Start delivery needs this to be the
/// driver assigned now, so a replacement driver must verify again.
@override final  String? collectionVerifiedBy;
@override final  DateTime? collectionVerifiedAt;
@override final  DateTime? outForDeliveryAt;
@override final  String? deliveredBy;
@override final  String? deliveredByName;
/// Photo the driver took when delivering. Kept in memory for the mock;
/// later uploaded to storage with only its URL on the order.
@override final  Uint8List? proofPhoto;
/// When the order was completed, by pickup or by delivery.
@override final  DateTime? completedAt;
@override final  DateTime? cancelledAt;

/// Create a copy of WorkerOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkerOrderCopyWith<_WorkerOrder> get copyWith => __$WorkerOrderCopyWithImpl<_WorkerOrder>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkerOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.isDelivery, isDelivery) || other.isDelivery == isDelivery)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.status, status) || other.status == status)&&(identical(other.placedAt, placedAt) || other.placedAt == placedAt)&&(identical(other.statusSince, statusSince) || other.statusSince == statusSince)&&(identical(other.packerId, packerId) || other.packerId == packerId)&&(identical(other.packerName, packerName) || other.packerName == packerName)&&(identical(other.packerAssignedAt, packerAssignedAt) || other.packerAssignedAt == packerAssignedAt)&&(identical(other.branchAddress, branchAddress) || other.branchAddress == branchAddress)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&const DeepCollectionEquality().equals(other.packedLineIds, _packedLineIds)&&(identical(other.address, address) || other.address == address)&&(identical(other.customerNote, customerNote) || other.customerNote == customerNote)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverAssignedAt, driverAssignedAt) || other.driverAssignedAt == driverAssignedAt)&&(identical(other.packingStartedAt, packingStartedAt) || other.packingStartedAt == packingStartedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.readyBy, readyBy) || other.readyBy == readyBy)&&(identical(other.pickupVerification, pickupVerification) || other.pickupVerification == pickupVerification)&&(identical(other.pickupCompletedBy, pickupCompletedBy) || other.pickupCompletedBy == pickupCompletedBy)&&(identical(other.pickupCompletedByName, pickupCompletedByName) || other.pickupCompletedByName == pickupCompletedByName)&&(identical(other.collectionVerification, collectionVerification) || other.collectionVerification == collectionVerification)&&(identical(other.collectionVerifiedBy, collectionVerifiedBy) || other.collectionVerifiedBy == collectionVerifiedBy)&&(identical(other.collectionVerifiedAt, collectionVerifiedAt) || other.collectionVerifiedAt == collectionVerifiedAt)&&(identical(other.outForDeliveryAt, outForDeliveryAt) || other.outForDeliveryAt == outForDeliveryAt)&&(identical(other.deliveredBy, deliveredBy) || other.deliveredBy == deliveredBy)&&(identical(other.deliveredByName, deliveredByName) || other.deliveredByName == deliveredByName)&&const DeepCollectionEquality().equals(other.proofPhoto, proofPhoto)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,number,branchId,branchName,customerName,customerPhone,isDelivery,const DeepCollectionEquality().hash(_items),status,placedAt,statusSince,packerId,packerName,packerAssignedAt,branchAddress,dueAt,const DeepCollectionEquality().hash(_packedLineIds),address,customerNote,driverId,driverName,driverAssignedAt,packingStartedAt,readyAt,readyBy,pickupVerification,pickupCompletedBy,pickupCompletedByName,collectionVerification,collectionVerifiedBy,collectionVerifiedAt,outForDeliveryAt,deliveredBy,deliveredByName,const DeepCollectionEquality().hash(proofPhoto),completedAt,cancelledAt]);
}

@override
String toString() {
    return 'WorkerOrder(id: $id, number: $number, branchId: $branchId, branchName: $branchName, customerName: $customerName, customerPhone: $customerPhone, isDelivery: $isDelivery, items: $items, status: $status, placedAt: $placedAt, statusSince: $statusSince, packerId: $packerId, packerName: $packerName, packerAssignedAt: $packerAssignedAt, branchAddress: $branchAddress, dueAt: $dueAt, packedLineIds: $packedLineIds, address: $address, customerNote: $customerNote, driverId: $driverId, driverName: $driverName, driverAssignedAt: $driverAssignedAt, packingStartedAt: $packingStartedAt, readyAt: $readyAt, readyBy: $readyBy, pickupVerification: $pickupVerification, pickupCompletedBy: $pickupCompletedBy, pickupCompletedByName: $pickupCompletedByName, collectionVerification: $collectionVerification, collectionVerifiedBy: $collectionVerifiedBy, collectionVerifiedAt: $collectionVerifiedAt, outForDeliveryAt: $outForDeliveryAt, deliveredBy: $deliveredBy, deliveredByName: $deliveredByName, proofPhoto: $proofPhoto, completedAt: $completedAt, cancelledAt: $cancelledAt)';
}


}

/// @nodoc
abstract mixin class _$WorkerOrderCopyWith<$Res> implements $WorkerOrderCopyWith<$Res> {
  factory _$WorkerOrderCopyWith(_WorkerOrder value, $Res Function(_WorkerOrder) _then) = __$WorkerOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, String branchId, String branchName, String customerName, String customerPhone, bool isDelivery, List<WorkerOrderItem> items, OrderStatus status, DateTime placedAt, DateTime statusSince, String packerId, String packerName, DateTime packerAssignedAt, String? branchAddress, DateTime? dueAt, Set<String> packedLineIds, String? address, String? customerNote, String? driverId, String? driverName, DateTime? driverAssignedAt, DateTime? packingStartedAt, DateTime? readyAt, String? readyBy, VerificationMethod? pickupVerification, String? pickupCompletedBy, String? pickupCompletedByName, VerificationMethod? collectionVerification, String? collectionVerifiedBy, DateTime? collectionVerifiedAt, DateTime? outForDeliveryAt, String? deliveredBy, String? deliveredByName, Uint8List? proofPhoto, DateTime? completedAt, DateTime? cancelledAt
});




}
/// @nodoc
class __$WorkerOrderCopyWithImpl<$Res>
    implements _$WorkerOrderCopyWith<$Res> {
  __$WorkerOrderCopyWithImpl(this._self, this._then);

  final _WorkerOrder _self;
  final $Res Function(_WorkerOrder) _then;

/// Create a copy of WorkerOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? branchId = null,Object? branchName = null,Object? customerName = null,Object? customerPhone = null,Object? isDelivery = null,Object? items = null,Object? status = null,Object? placedAt = null,Object? statusSince = null,Object? packerId = null,Object? packerName = null,Object? packerAssignedAt = null,Object? branchAddress = freezed,Object? dueAt = freezed,Object? packedLineIds = null,Object? address = freezed,Object? customerNote = freezed,Object? driverId = freezed,Object? driverName = freezed,Object? driverAssignedAt = freezed,Object? packingStartedAt = freezed,Object? readyAt = freezed,Object? readyBy = freezed,Object? pickupVerification = freezed,Object? pickupCompletedBy = freezed,Object? pickupCompletedByName = freezed,Object? collectionVerification = freezed,Object? collectionVerifiedBy = freezed,Object? collectionVerifiedAt = freezed,Object? outForDeliveryAt = freezed,Object? deliveredBy = freezed,Object? deliveredByName = freezed,Object? proofPhoto = freezed,Object? completedAt = freezed,Object? cancelledAt = freezed,}) {
  return _then(_WorkerOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,isDelivery: null == isDelivery ? _self.isDelivery : isDelivery // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<WorkerOrderItem>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,statusSince: null == statusSince ? _self.statusSince : statusSince // ignore: cast_nullable_to_non_nullable
as DateTime,packerId: null == packerId ? _self.packerId : packerId // ignore: cast_nullable_to_non_nullable
as String,packerName: null == packerName ? _self.packerName : packerName // ignore: cast_nullable_to_non_nullable
as String,packerAssignedAt: null == packerAssignedAt ? _self.packerAssignedAt : packerAssignedAt // ignore: cast_nullable_to_non_nullable
as DateTime,branchAddress: freezed == branchAddress ? _self.branchAddress : branchAddress // ignore: cast_nullable_to_non_nullable
as String?,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,packedLineIds: null == packedLineIds ? _self._packedLineIds : packedLineIds // ignore: cast_nullable_to_non_nullable
as Set<String>,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,driverAssignedAt: freezed == driverAssignedAt ? _self.driverAssignedAt : driverAssignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,packingStartedAt: freezed == packingStartedAt ? _self.packingStartedAt : packingStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readyAt: freezed == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readyBy: freezed == readyBy ? _self.readyBy : readyBy // ignore: cast_nullable_to_non_nullable
as String?,pickupVerification: freezed == pickupVerification ? _self.pickupVerification : pickupVerification // ignore: cast_nullable_to_non_nullable
as VerificationMethod?,pickupCompletedBy: freezed == pickupCompletedBy ? _self.pickupCompletedBy : pickupCompletedBy // ignore: cast_nullable_to_non_nullable
as String?,pickupCompletedByName: freezed == pickupCompletedByName ? _self.pickupCompletedByName : pickupCompletedByName // ignore: cast_nullable_to_non_nullable
as String?,collectionVerification: freezed == collectionVerification ? _self.collectionVerification : collectionVerification // ignore: cast_nullable_to_non_nullable
as VerificationMethod?,collectionVerifiedBy: freezed == collectionVerifiedBy ? _self.collectionVerifiedBy : collectionVerifiedBy // ignore: cast_nullable_to_non_nullable
as String?,collectionVerifiedAt: freezed == collectionVerifiedAt ? _self.collectionVerifiedAt : collectionVerifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outForDeliveryAt: freezed == outForDeliveryAt ? _self.outForDeliveryAt : outForDeliveryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredBy: freezed == deliveredBy ? _self.deliveredBy : deliveredBy // ignore: cast_nullable_to_non_nullable
as String?,deliveredByName: freezed == deliveredByName ? _self.deliveredByName : deliveredByName // ignore: cast_nullable_to_non_nullable
as String?,proofPhoto: freezed == proofPhoto ? _self.proofPhoto : proofPhoto // ignore: cast_nullable_to_non_nullable
as Uint8List?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
