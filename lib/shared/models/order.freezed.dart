// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderItem {

/// Unique within the order and never reused, so the same product can
/// appear on two lines and the worker's packing checklist keys on it.
 String get lineId; String get productId; String get name; String get brand; String get packSize; int get quantity;/// Price of one at the order's branch, in ringgit, at checkout.
 double get unitPrice;/// Category id and name, e.g. "Dairy & Eggs". Empty if unknown.
 String get categoryId; String get category;/// Product description from the catalogue. Can be empty.
 String get description;/// Cover image URL, or null if the product has none.
 String? get imageUrl;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.lineId, _this.lineId) || other.lineId == _this.lineId)&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.packSize, _this.packSize) || other.packSize == _this.packSize)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl));
}


@override
int get hashCode {
  final _this = this as OrderItem;
  return Object.hash(runtimeType,_this.lineId,_this.productId,_this.name,_this.brand,_this.packSize,_this.quantity,_this.unitPrice,_this.categoryId,_this.category,_this.description,_this.imageUrl);
}

@override
String toString() {
  final _this = this as OrderItem;
  return 'OrderItem(lineId: ${_this.lineId}, productId: ${_this.productId}, name: ${_this.name}, brand: ${_this.brand}, packSize: ${_this.packSize}, quantity: ${_this.quantity}, unitPrice: ${_this.unitPrice}, categoryId: ${_this.categoryId}, category: ${_this.category}, description: ${_this.description}, imageUrl: ${_this.imageUrl})';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
 String lineId, String productId, String name, String brand, String packSize, int quantity, double unitPrice, String categoryId, String category, String description, String? imageUrl
});




}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lineId = null,Object? productId = null,Object? name = null,Object? brand = null,Object? packSize = null,Object? quantity = null,Object? unitPrice = null,Object? categoryId = null,Object? category = null,Object? description = null,Object? imageUrl = freezed,}) {
  return _then(OrderItem(
lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,packSize: null == packSize ? _self.packSize : packSize // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lineId,  String productId,  String name,  String brand,  String packSize,  int quantity,  double unitPrice,  String categoryId,  String category,  String description,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.lineId,_that.productId,_that.name,_that.brand,_that.packSize,_that.quantity,_that.unitPrice,_that.categoryId,_that.category,_that.description,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lineId,  String productId,  String name,  String brand,  String packSize,  int quantity,  double unitPrice,  String categoryId,  String category,  String description,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.lineId,_that.productId,_that.name,_that.brand,_that.packSize,_that.quantity,_that.unitPrice,_that.categoryId,_that.category,_that.description,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lineId,  String productId,  String name,  String brand,  String packSize,  int quantity,  double unitPrice,  String categoryId,  String category,  String description,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.lineId,_that.productId,_that.name,_that.brand,_that.packSize,_that.quantity,_that.unitPrice,_that.categoryId,_that.category,_that.description,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc


class _OrderItem extends OrderItem {
  const _OrderItem({required this.lineId, required this.productId, required this.name, required this.brand, required this.packSize, required this.quantity, required this.unitPrice, this.categoryId = '', this.category = '', this.description = '', this.imageUrl}): super._();
  

/// Unique within the order and never reused, so the same product can
/// appear on two lines and the worker's packing checklist keys on it.
@override final  String lineId;
@override final  String productId;
@override final  String name;
@override final  String brand;
@override final  String packSize;
@override final  int quantity;
/// Price of one at the order's branch, in ringgit, at checkout.
@override final  double unitPrice;
/// Category id and name, e.g. "Dairy & Eggs". Empty if unknown.
@override@JsonKey() final  String categoryId;
@override@JsonKey() final  String category;
/// Product description from the catalogue. Can be empty.
@override@JsonKey() final  String description;
/// Cover image URL, or null if the product has none.
@override final  String? imageUrl;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.lineId, lineId) || other.lineId == lineId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.packSize, packSize) || other.packSize == packSize)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lineId,productId,name,brand,packSize,quantity,unitPrice,categoryId,category,description,imageUrl);
}

@override
String toString() {
    return 'OrderItem(lineId: $lineId, productId: $productId, name: $name, brand: $brand, packSize: $packSize, quantity: $quantity, unitPrice: $unitPrice, categoryId: $categoryId, category: $category, description: $description, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
 String lineId, String productId, String name, String brand, String packSize, int quantity, double unitPrice, String categoryId, String category, String description, String? imageUrl
});




}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lineId = null,Object? productId = null,Object? name = null,Object? brand = null,Object? packSize = null,Object? quantity = null,Object? unitPrice = null,Object? categoryId = null,Object? category = null,Object? description = null,Object? imageUrl = freezed,}) {
  return _then(_OrderItem(
lineId: null == lineId ? _self.lineId : lineId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,packSize: null == packSize ? _self.packSize : packSize // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$LineShortage {

 ShortageStatus get status;/// The offered replacement, shaped like an order line with the same
/// `lineId` as the unavailable one. Null when there is none.
 OrderItem? get replacement;/// Null until Firestore has saved the server time.
 DateTime? get flaggedAt;/// When the customer decided. Null while [ShortageStatus.proposed].
 DateTime? get decidedAt;
/// Create a copy of LineShortage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineShortageCopyWith<LineShortage> get copyWith => _$LineShortageCopyWithImpl<LineShortage>(this as LineShortage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LineShortage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineShortage&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.replacement, _this.replacement) || other.replacement == _this.replacement)&&(identical(other.flaggedAt, _this.flaggedAt) || other.flaggedAt == _this.flaggedAt)&&(identical(other.decidedAt, _this.decidedAt) || other.decidedAt == _this.decidedAt));
}


@override
int get hashCode {
  final _this = this as LineShortage;
  return Object.hash(runtimeType,_this.status,_this.replacement,_this.flaggedAt,_this.decidedAt);
}

@override
String toString() {
  final _this = this as LineShortage;
  return 'LineShortage(status: ${_this.status}, replacement: ${_this.replacement}, flaggedAt: ${_this.flaggedAt}, decidedAt: ${_this.decidedAt})';
}


}

/// @nodoc
abstract mixin class $LineShortageCopyWith<$Res>  {
  factory $LineShortageCopyWith(LineShortage value, $Res Function(LineShortage) _then) = _$LineShortageCopyWithImpl;
@useResult
$Res call({
 ShortageStatus status, OrderItem? replacement, DateTime? flaggedAt, DateTime? decidedAt
});


$OrderItemCopyWith<$Res>? get replacement;

}
/// @nodoc
class _$LineShortageCopyWithImpl<$Res>
    implements $LineShortageCopyWith<$Res> {
  _$LineShortageCopyWithImpl(this._self, this._then);

  final LineShortage _self;
  final $Res Function(LineShortage) _then;

/// Create a copy of LineShortage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? replacement = freezed,Object? flaggedAt = freezed,Object? decidedAt = freezed,}) {
  return _then(LineShortage(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ShortageStatus,replacement: freezed == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as OrderItem?,flaggedAt: freezed == flaggedAt ? _self.flaggedAt : flaggedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of LineShortage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderItemCopyWith<$Res>? get replacement {
    if (_self.replacement == null) {
    return null;
  }

  return $OrderItemCopyWith<$Res>(_self.replacement!, (value) {
    return _then(_self.copyWith(replacement: value));
  });
}
}


/// Adds pattern-matching-related methods to [LineShortage].
extension LineShortagePatterns on LineShortage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineShortage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineShortage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineShortage value)  $default,){
final _that = this;
switch (_that) {
case _LineShortage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineShortage value)?  $default,){
final _that = this;
switch (_that) {
case _LineShortage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ShortageStatus status,  OrderItem? replacement,  DateTime? flaggedAt,  DateTime? decidedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineShortage() when $default != null:
return $default(_that.status,_that.replacement,_that.flaggedAt,_that.decidedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ShortageStatus status,  OrderItem? replacement,  DateTime? flaggedAt,  DateTime? decidedAt)  $default,) {final _that = this;
switch (_that) {
case _LineShortage():
return $default(_that.status,_that.replacement,_that.flaggedAt,_that.decidedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ShortageStatus status,  OrderItem? replacement,  DateTime? flaggedAt,  DateTime? decidedAt)?  $default,) {final _that = this;
switch (_that) {
case _LineShortage() when $default != null:
return $default(_that.status,_that.replacement,_that.flaggedAt,_that.decidedAt);case _:
  return null;

}
}

}

/// @nodoc


class _LineShortage extends LineShortage {
  const _LineShortage({required this.status, this.replacement, this.flaggedAt, this.decidedAt}): super._();
  

@override final  ShortageStatus status;
/// The offered replacement, shaped like an order line with the same
/// `lineId` as the unavailable one. Null when there is none.
@override final  OrderItem? replacement;
/// Null until Firestore has saved the server time.
@override final  DateTime? flaggedAt;
/// When the customer decided. Null while [ShortageStatus.proposed].
@override final  DateTime? decidedAt;

/// Create a copy of LineShortage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineShortageCopyWith<_LineShortage> get copyWith => __$LineShortageCopyWithImpl<_LineShortage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineShortage&&(identical(other.status, status) || other.status == status)&&(identical(other.replacement, replacement) || other.replacement == replacement)&&(identical(other.flaggedAt, flaggedAt) || other.flaggedAt == flaggedAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,replacement,flaggedAt,decidedAt);
}

@override
String toString() {
    return 'LineShortage(status: $status, replacement: $replacement, flaggedAt: $flaggedAt, decidedAt: $decidedAt)';
}


}

/// @nodoc
abstract mixin class _$LineShortageCopyWith<$Res> implements $LineShortageCopyWith<$Res> {
  factory _$LineShortageCopyWith(_LineShortage value, $Res Function(_LineShortage) _then) = __$LineShortageCopyWithImpl;
@override @useResult
$Res call({
 ShortageStatus status, OrderItem? replacement, DateTime? flaggedAt, DateTime? decidedAt
});


@override $OrderItemCopyWith<$Res>? get replacement;

}
/// @nodoc
class __$LineShortageCopyWithImpl<$Res>
    implements _$LineShortageCopyWith<$Res> {
  __$LineShortageCopyWithImpl(this._self, this._then);

  final _LineShortage _self;
  final $Res Function(_LineShortage) _then;

/// Create a copy of LineShortage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? replacement = freezed,Object? flaggedAt = freezed,Object? decidedAt = freezed,}) {
  return _then(_LineShortage(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ShortageStatus,replacement: freezed == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as OrderItem?,flaggedAt: freezed == flaggedAt ? _self.flaggedAt : flaggedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of LineShortage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderItemCopyWith<$Res>? get replacement {
    if (_self.replacement == null) {
    return null;
  }

  return $OrderItemCopyWith<$Res>(_self.replacement!, (value) {
    return _then(_self.copyWith(replacement: value));
  });
}
}

/// @nodoc
mixin _$OrderEvent {

 String get title; DateTime get time;/// Staff member who did it. Null for things the customer did.
 String? get by;
/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderEventCopyWith<OrderEvent> get copyWith => _$OrderEventCopyWithImpl<OrderEvent>(this as OrderEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderEvent&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.by, _this.by) || other.by == _this.by));
}


@override
int get hashCode {
  final _this = this as OrderEvent;
  return Object.hash(runtimeType,_this.title,_this.time,_this.by);
}

@override
String toString() {
  final _this = this as OrderEvent;
  return 'OrderEvent(title: ${_this.title}, time: ${_this.time}, by: ${_this.by})';
}


}

/// @nodoc
abstract mixin class $OrderEventCopyWith<$Res>  {
  factory $OrderEventCopyWith(OrderEvent value, $Res Function(OrderEvent) _then) = _$OrderEventCopyWithImpl;
@useResult
$Res call({
 String title, DateTime time, String? by
});




}
/// @nodoc
class _$OrderEventCopyWithImpl<$Res>
    implements $OrderEventCopyWith<$Res> {
  _$OrderEventCopyWithImpl(this._self, this._then);

  final OrderEvent _self;
  final $Res Function(OrderEvent) _then;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? time = null,Object? by = freezed,}) {
  return _then(OrderEvent(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,by: freezed == by ? _self.by : by // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderEvent].
extension OrderEventPatterns on OrderEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderEvent value)  $default,){
final _that = this;
switch (_that) {
case _OrderEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderEvent value)?  $default,){
final _that = this;
switch (_that) {
case _OrderEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  DateTime time,  String? by)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderEvent() when $default != null:
return $default(_that.title,_that.time,_that.by);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  DateTime time,  String? by)  $default,) {final _that = this;
switch (_that) {
case _OrderEvent():
return $default(_that.title,_that.time,_that.by);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  DateTime time,  String? by)?  $default,) {final _that = this;
switch (_that) {
case _OrderEvent() when $default != null:
return $default(_that.title,_that.time,_that.by);case _:
  return null;

}
}

}

/// @nodoc


class _OrderEvent extends OrderEvent {
  const _OrderEvent({required this.title, required this.time, this.by}): super._();
  

@override final  String title;
@override final  DateTime time;
/// Staff member who did it. Null for things the customer did.
@override final  String? by;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderEventCopyWith<_OrderEvent> get copyWith => __$OrderEventCopyWithImpl<_OrderEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderEvent&&(identical(other.title, title) || other.title == title)&&(identical(other.time, time) || other.time == time)&&(identical(other.by, by) || other.by == by));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title,time,by);
}

@override
String toString() {
    return 'OrderEvent(title: $title, time: $time, by: $by)';
}


}

/// @nodoc
abstract mixin class _$OrderEventCopyWith<$Res> implements $OrderEventCopyWith<$Res> {
  factory _$OrderEventCopyWith(_OrderEvent value, $Res Function(_OrderEvent) _then) = __$OrderEventCopyWithImpl;
@override @useResult
$Res call({
 String title, DateTime time, String? by
});




}
/// @nodoc
class __$OrderEventCopyWithImpl<$Res>
    implements _$OrderEventCopyWith<$Res> {
  __$OrderEventCopyWithImpl(this._self, this._then);

  final _OrderEvent _self;
  final $Res Function(_OrderEvent) _then;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? time = null,Object? by = freezed,}) {
  return _then(_OrderEvent(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as DateTime,by: freezed == by ? _self.by : by // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Order {

 String get id; int get number; String get customerId; String get customerName; String get customerPhone; String get branchId; String get branchName; bool get isDelivery; List<OrderItem> get items; double get subtotal; double get deliveryFee; double get discount; double get total; OrderStatus get status;/// Delivery address as readable text. Null/empty for pickup.
 String? get address;/// Delivery location pin, so the driver can navigate and the fee can be
/// worked out by distance. Null for pickup.
 LatLng? get addressLocation;/// Message the customer left with the order.
 String? get customerNote;/// Applied promo code, uppercased, or null.
 String? get promoCode;/// Random server-generated code on new orders. Older demo orders use
/// the deterministic fallback below.
 String? get collectionToken;/// Where the bag is collected from (the branch's address), shown to
/// drivers, who can be given deliveries from any branch.
 String? get branchAddress;/// Null until Firestore has saved the server time.
 DateTime? get placedAt;/// When the order entered its current status.
 DateTime? get statusSince;/// When the customer was promised the order: pickup time or delivery
/// time. Packing tasks are sorted by this, soonest first.
 DateTime? get dueAt; String? get packerId; String? get packerName; DateTime? get packerAssignedAt;/// Delivery orders only.
 String? get driverId; String? get driverName; DateTime? get driverAssignedAt;/// Line ids already packed.
 Set<String> get packedLineIds; DateTime? get packingStartedAt; DateTime? get readyAt;/// Worker id of the packer who marked the order ready.
 String? get readyBy; VerificationMethod? get pickupVerification; String? get pickupCompletedBy; String? get pickupCompletedByName; VerificationMethod? get collectionVerification;/// Driver who verified the bag. Start delivery needs this to be the
/// driver assigned now, so a replacement driver must verify again.
 String? get collectionVerifiedBy; DateTime? get collectionVerifiedAt; DateTime? get outForDeliveryAt; String? get deliveredBy; String? get deliveredByName;/// Photo the driver took when delivering, as a Storage download URL.
 String? get proofPhotoUrl;/// When the order was completed, by pickup or by delivery.
 DateTime? get completedAt;/// Where the driver last reported being while the order is out for
/// delivery, and when (server time). Null until the first fix.
 LatLng? get driverPosition; DateTime? get driverPositionAt;/// Items a packer found unavailable, by line id. See [LineShortage].
 Map<String, LineShortage> get shortages;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Order;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.customerPhone, _this.customerPhone) || other.customerPhone == _this.customerPhone)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.branchName, _this.branchName) || other.branchName == _this.branchName)&&(identical(other.isDelivery, _this.isDelivery) || other.isDelivery == _this.isDelivery)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.deliveryFee, _this.deliveryFee) || other.deliveryFee == _this.deliveryFee)&&(identical(other.discount, _this.discount) || other.discount == _this.discount)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.addressLocation, _this.addressLocation) || other.addressLocation == _this.addressLocation)&&(identical(other.customerNote, _this.customerNote) || other.customerNote == _this.customerNote)&&(identical(other.promoCode, _this.promoCode) || other.promoCode == _this.promoCode)&&(identical(other.collectionToken, _this.collectionToken) || other.collectionToken == _this.collectionToken)&&(identical(other.branchAddress, _this.branchAddress) || other.branchAddress == _this.branchAddress)&&(identical(other.placedAt, _this.placedAt) || other.placedAt == _this.placedAt)&&(identical(other.statusSince, _this.statusSince) || other.statusSince == _this.statusSince)&&(identical(other.dueAt, _this.dueAt) || other.dueAt == _this.dueAt)&&(identical(other.packerId, _this.packerId) || other.packerId == _this.packerId)&&(identical(other.packerName, _this.packerName) || other.packerName == _this.packerName)&&(identical(other.packerAssignedAt, _this.packerAssignedAt) || other.packerAssignedAt == _this.packerAssignedAt)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.driverName, _this.driverName) || other.driverName == _this.driverName)&&(identical(other.driverAssignedAt, _this.driverAssignedAt) || other.driverAssignedAt == _this.driverAssignedAt)&&const DeepCollectionEquality().equals(other.packedLineIds, _this.packedLineIds)&&(identical(other.packingStartedAt, _this.packingStartedAt) || other.packingStartedAt == _this.packingStartedAt)&&(identical(other.readyAt, _this.readyAt) || other.readyAt == _this.readyAt)&&(identical(other.readyBy, _this.readyBy) || other.readyBy == _this.readyBy)&&(identical(other.pickupVerification, _this.pickupVerification) || other.pickupVerification == _this.pickupVerification)&&(identical(other.pickupCompletedBy, _this.pickupCompletedBy) || other.pickupCompletedBy == _this.pickupCompletedBy)&&(identical(other.pickupCompletedByName, _this.pickupCompletedByName) || other.pickupCompletedByName == _this.pickupCompletedByName)&&(identical(other.collectionVerification, _this.collectionVerification) || other.collectionVerification == _this.collectionVerification)&&(identical(other.collectionVerifiedBy, _this.collectionVerifiedBy) || other.collectionVerifiedBy == _this.collectionVerifiedBy)&&(identical(other.collectionVerifiedAt, _this.collectionVerifiedAt) || other.collectionVerifiedAt == _this.collectionVerifiedAt)&&(identical(other.outForDeliveryAt, _this.outForDeliveryAt) || other.outForDeliveryAt == _this.outForDeliveryAt)&&(identical(other.deliveredBy, _this.deliveredBy) || other.deliveredBy == _this.deliveredBy)&&(identical(other.deliveredByName, _this.deliveredByName) || other.deliveredByName == _this.deliveredByName)&&(identical(other.proofPhotoUrl, _this.proofPhotoUrl) || other.proofPhotoUrl == _this.proofPhotoUrl)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.driverPosition, _this.driverPosition) || other.driverPosition == _this.driverPosition)&&(identical(other.driverPositionAt, _this.driverPositionAt) || other.driverPositionAt == _this.driverPositionAt)&&const DeepCollectionEquality().equals(other.shortages, _this.shortages));
}


@override
int get hashCode {
  final _this = this as Order;
  return Object.hashAll([runtimeType,_this.id,_this.number,_this.customerId,_this.customerName,_this.customerPhone,_this.branchId,_this.branchName,_this.isDelivery,const DeepCollectionEquality().hash(_this.items),_this.subtotal,_this.deliveryFee,_this.discount,_this.total,_this.status,_this.address,_this.addressLocation,_this.customerNote,_this.promoCode,_this.collectionToken,_this.branchAddress,_this.placedAt,_this.statusSince,_this.dueAt,_this.packerId,_this.packerName,_this.packerAssignedAt,_this.driverId,_this.driverName,_this.driverAssignedAt,const DeepCollectionEquality().hash(_this.packedLineIds),_this.packingStartedAt,_this.readyAt,_this.readyBy,_this.pickupVerification,_this.pickupCompletedBy,_this.pickupCompletedByName,_this.collectionVerification,_this.collectionVerifiedBy,_this.collectionVerifiedAt,_this.outForDeliveryAt,_this.deliveredBy,_this.deliveredByName,_this.proofPhotoUrl,_this.completedAt,_this.driverPosition,_this.driverPositionAt,const DeepCollectionEquality().hash(_this.shortages)]);
}

@override
String toString() {
  final _this = this as Order;
  return 'Order(id: ${_this.id}, number: ${_this.number}, customerId: ${_this.customerId}, customerName: ${_this.customerName}, customerPhone: ${_this.customerPhone}, branchId: ${_this.branchId}, branchName: ${_this.branchName}, isDelivery: ${_this.isDelivery}, items: ${_this.items}, subtotal: ${_this.subtotal}, deliveryFee: ${_this.deliveryFee}, discount: ${_this.discount}, total: ${_this.total}, status: ${_this.status}, address: ${_this.address}, addressLocation: ${_this.addressLocation}, customerNote: ${_this.customerNote}, promoCode: ${_this.promoCode}, collectionToken: ${_this.collectionToken}, branchAddress: ${_this.branchAddress}, placedAt: ${_this.placedAt}, statusSince: ${_this.statusSince}, dueAt: ${_this.dueAt}, packerId: ${_this.packerId}, packerName: ${_this.packerName}, packerAssignedAt: ${_this.packerAssignedAt}, driverId: ${_this.driverId}, driverName: ${_this.driverName}, driverAssignedAt: ${_this.driverAssignedAt}, packedLineIds: ${_this.packedLineIds}, packingStartedAt: ${_this.packingStartedAt}, readyAt: ${_this.readyAt}, readyBy: ${_this.readyBy}, pickupVerification: ${_this.pickupVerification}, pickupCompletedBy: ${_this.pickupCompletedBy}, pickupCompletedByName: ${_this.pickupCompletedByName}, collectionVerification: ${_this.collectionVerification}, collectionVerifiedBy: ${_this.collectionVerifiedBy}, collectionVerifiedAt: ${_this.collectionVerifiedAt}, outForDeliveryAt: ${_this.outForDeliveryAt}, deliveredBy: ${_this.deliveredBy}, deliveredByName: ${_this.deliveredByName}, proofPhotoUrl: ${_this.proofPhotoUrl}, completedAt: ${_this.completedAt}, driverPosition: ${_this.driverPosition}, driverPositionAt: ${_this.driverPositionAt}, shortages: ${_this.shortages})';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, int number, String customerId, String customerName, String customerPhone, String branchId, String branchName, bool isDelivery, List<OrderItem> items, double subtotal, double deliveryFee, double discount, double total, OrderStatus status, String? address, LatLng? addressLocation, String? customerNote, String? promoCode, String? collectionToken, String? branchAddress, DateTime? placedAt, DateTime? statusSince, DateTime? dueAt, String? packerId, String? packerName, DateTime? packerAssignedAt, String? driverId, String? driverName, DateTime? driverAssignedAt, Set<String> packedLineIds, DateTime? packingStartedAt, DateTime? readyAt, String? readyBy, VerificationMethod? pickupVerification, String? pickupCompletedBy, String? pickupCompletedByName, VerificationMethod? collectionVerification, String? collectionVerifiedBy, DateTime? collectionVerifiedAt, DateTime? outForDeliveryAt, String? deliveredBy, String? deliveredByName, String? proofPhotoUrl, DateTime? completedAt, LatLng? driverPosition, DateTime? driverPositionAt, Map<String, LineShortage> shortages
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? customerId = null,Object? customerName = null,Object? customerPhone = null,Object? branchId = null,Object? branchName = null,Object? isDelivery = null,Object? items = null,Object? subtotal = null,Object? deliveryFee = null,Object? discount = null,Object? total = null,Object? status = null,Object? address = freezed,Object? addressLocation = freezed,Object? customerNote = freezed,Object? promoCode = freezed,Object? collectionToken = freezed,Object? branchAddress = freezed,Object? placedAt = freezed,Object? statusSince = freezed,Object? dueAt = freezed,Object? packerId = freezed,Object? packerName = freezed,Object? packerAssignedAt = freezed,Object? driverId = freezed,Object? driverName = freezed,Object? driverAssignedAt = freezed,Object? packedLineIds = null,Object? packingStartedAt = freezed,Object? readyAt = freezed,Object? readyBy = freezed,Object? pickupVerification = freezed,Object? pickupCompletedBy = freezed,Object? pickupCompletedByName = freezed,Object? collectionVerification = freezed,Object? collectionVerifiedBy = freezed,Object? collectionVerifiedAt = freezed,Object? outForDeliveryAt = freezed,Object? deliveredBy = freezed,Object? deliveredByName = freezed,Object? proofPhotoUrl = freezed,Object? completedAt = freezed,Object? driverPosition = freezed,Object? driverPositionAt = freezed,Object? shortages = null,}) {
  return _then(Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,isDelivery: null == isDelivery ? _self.isDelivery : isDelivery // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,addressLocation: freezed == addressLocation ? _self.addressLocation : addressLocation // ignore: cast_nullable_to_non_nullable
as LatLng?,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,promoCode: freezed == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String?,collectionToken: freezed == collectionToken ? _self.collectionToken : collectionToken // ignore: cast_nullable_to_non_nullable
as String?,branchAddress: freezed == branchAddress ? _self.branchAddress : branchAddress // ignore: cast_nullable_to_non_nullable
as String?,placedAt: freezed == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,statusSince: freezed == statusSince ? _self.statusSince : statusSince // ignore: cast_nullable_to_non_nullable
as DateTime?,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,packerId: freezed == packerId ? _self.packerId : packerId // ignore: cast_nullable_to_non_nullable
as String?,packerName: freezed == packerName ? _self.packerName : packerName // ignore: cast_nullable_to_non_nullable
as String?,packerAssignedAt: freezed == packerAssignedAt ? _self.packerAssignedAt : packerAssignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,driverAssignedAt: freezed == driverAssignedAt ? _self.driverAssignedAt : driverAssignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,packedLineIds: null == packedLineIds ? _self.packedLineIds : packedLineIds // ignore: cast_nullable_to_non_nullable
as Set<String>,packingStartedAt: freezed == packingStartedAt ? _self.packingStartedAt : packingStartedAt // ignore: cast_nullable_to_non_nullable
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
as String?,proofPhotoUrl: freezed == proofPhotoUrl ? _self.proofPhotoUrl : proofPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,driverPosition: freezed == driverPosition ? _self.driverPosition : driverPosition // ignore: cast_nullable_to_non_nullable
as LatLng?,driverPositionAt: freezed == driverPositionAt ? _self.driverPositionAt : driverPositionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,shortages: null == shortages ? _self.shortages : shortages // ignore: cast_nullable_to_non_nullable
as Map<String, LineShortage>,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  String customerId,  String customerName,  String customerPhone,  String branchId,  String branchName,  bool isDelivery,  List<OrderItem> items,  double subtotal,  double deliveryFee,  double discount,  double total,  OrderStatus status,  String? address,  LatLng? addressLocation,  String? customerNote,  String? promoCode,  String? collectionToken,  String? branchAddress,  DateTime? placedAt,  DateTime? statusSince,  DateTime? dueAt,  String? packerId,  String? packerName,  DateTime? packerAssignedAt,  String? driverId,  String? driverName,  DateTime? driverAssignedAt,  Set<String> packedLineIds,  DateTime? packingStartedAt,  DateTime? readyAt,  String? readyBy,  VerificationMethod? pickupVerification,  String? pickupCompletedBy,  String? pickupCompletedByName,  VerificationMethod? collectionVerification,  String? collectionVerifiedBy,  DateTime? collectionVerifiedAt,  DateTime? outForDeliveryAt,  String? deliveredBy,  String? deliveredByName,  String? proofPhotoUrl,  DateTime? completedAt,  LatLng? driverPosition,  DateTime? driverPositionAt,  Map<String, LineShortage> shortages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.number,_that.customerId,_that.customerName,_that.customerPhone,_that.branchId,_that.branchName,_that.isDelivery,_that.items,_that.subtotal,_that.deliveryFee,_that.discount,_that.total,_that.status,_that.address,_that.addressLocation,_that.customerNote,_that.promoCode,_that.collectionToken,_that.branchAddress,_that.placedAt,_that.statusSince,_that.dueAt,_that.packerId,_that.packerName,_that.packerAssignedAt,_that.driverId,_that.driverName,_that.driverAssignedAt,_that.packedLineIds,_that.packingStartedAt,_that.readyAt,_that.readyBy,_that.pickupVerification,_that.pickupCompletedBy,_that.pickupCompletedByName,_that.collectionVerification,_that.collectionVerifiedBy,_that.collectionVerifiedAt,_that.outForDeliveryAt,_that.deliveredBy,_that.deliveredByName,_that.proofPhotoUrl,_that.completedAt,_that.driverPosition,_that.driverPositionAt,_that.shortages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  String customerId,  String customerName,  String customerPhone,  String branchId,  String branchName,  bool isDelivery,  List<OrderItem> items,  double subtotal,  double deliveryFee,  double discount,  double total,  OrderStatus status,  String? address,  LatLng? addressLocation,  String? customerNote,  String? promoCode,  String? collectionToken,  String? branchAddress,  DateTime? placedAt,  DateTime? statusSince,  DateTime? dueAt,  String? packerId,  String? packerName,  DateTime? packerAssignedAt,  String? driverId,  String? driverName,  DateTime? driverAssignedAt,  Set<String> packedLineIds,  DateTime? packingStartedAt,  DateTime? readyAt,  String? readyBy,  VerificationMethod? pickupVerification,  String? pickupCompletedBy,  String? pickupCompletedByName,  VerificationMethod? collectionVerification,  String? collectionVerifiedBy,  DateTime? collectionVerifiedAt,  DateTime? outForDeliveryAt,  String? deliveredBy,  String? deliveredByName,  String? proofPhotoUrl,  DateTime? completedAt,  LatLng? driverPosition,  DateTime? driverPositionAt,  Map<String, LineShortage> shortages)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.number,_that.customerId,_that.customerName,_that.customerPhone,_that.branchId,_that.branchName,_that.isDelivery,_that.items,_that.subtotal,_that.deliveryFee,_that.discount,_that.total,_that.status,_that.address,_that.addressLocation,_that.customerNote,_that.promoCode,_that.collectionToken,_that.branchAddress,_that.placedAt,_that.statusSince,_that.dueAt,_that.packerId,_that.packerName,_that.packerAssignedAt,_that.driverId,_that.driverName,_that.driverAssignedAt,_that.packedLineIds,_that.packingStartedAt,_that.readyAt,_that.readyBy,_that.pickupVerification,_that.pickupCompletedBy,_that.pickupCompletedByName,_that.collectionVerification,_that.collectionVerifiedBy,_that.collectionVerifiedAt,_that.outForDeliveryAt,_that.deliveredBy,_that.deliveredByName,_that.proofPhotoUrl,_that.completedAt,_that.driverPosition,_that.driverPositionAt,_that.shortages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  String customerId,  String customerName,  String customerPhone,  String branchId,  String branchName,  bool isDelivery,  List<OrderItem> items,  double subtotal,  double deliveryFee,  double discount,  double total,  OrderStatus status,  String? address,  LatLng? addressLocation,  String? customerNote,  String? promoCode,  String? collectionToken,  String? branchAddress,  DateTime? placedAt,  DateTime? statusSince,  DateTime? dueAt,  String? packerId,  String? packerName,  DateTime? packerAssignedAt,  String? driverId,  String? driverName,  DateTime? driverAssignedAt,  Set<String> packedLineIds,  DateTime? packingStartedAt,  DateTime? readyAt,  String? readyBy,  VerificationMethod? pickupVerification,  String? pickupCompletedBy,  String? pickupCompletedByName,  VerificationMethod? collectionVerification,  String? collectionVerifiedBy,  DateTime? collectionVerifiedAt,  DateTime? outForDeliveryAt,  String? deliveredBy,  String? deliveredByName,  String? proofPhotoUrl,  DateTime? completedAt,  LatLng? driverPosition,  DateTime? driverPositionAt,  Map<String, LineShortage> shortages)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.number,_that.customerId,_that.customerName,_that.customerPhone,_that.branchId,_that.branchName,_that.isDelivery,_that.items,_that.subtotal,_that.deliveryFee,_that.discount,_that.total,_that.status,_that.address,_that.addressLocation,_that.customerNote,_that.promoCode,_that.collectionToken,_that.branchAddress,_that.placedAt,_that.statusSince,_that.dueAt,_that.packerId,_that.packerName,_that.packerAssignedAt,_that.driverId,_that.driverName,_that.driverAssignedAt,_that.packedLineIds,_that.packingStartedAt,_that.readyAt,_that.readyBy,_that.pickupVerification,_that.pickupCompletedBy,_that.pickupCompletedByName,_that.collectionVerification,_that.collectionVerifiedBy,_that.collectionVerifiedAt,_that.outForDeliveryAt,_that.deliveredBy,_that.deliveredByName,_that.proofPhotoUrl,_that.completedAt,_that.driverPosition,_that.driverPositionAt,_that.shortages);case _:
  return null;

}
}

}

/// @nodoc


class _Order extends Order {
  const _Order({required this.id, required this.number, required this.customerId, required this.customerName, required this.customerPhone, required this.branchId, required this.branchName, required this.isDelivery, required  List<OrderItem> items, required this.subtotal, required this.deliveryFee, required this.discount, required this.total, required this.status, this.address, this.addressLocation, this.customerNote, this.promoCode, this.collectionToken, this.branchAddress, this.placedAt, this.statusSince, this.dueAt, this.packerId, this.packerName, this.packerAssignedAt, this.driverId, this.driverName, this.driverAssignedAt,  Set<String> packedLineIds = const <String>{}, this.packingStartedAt, this.readyAt, this.readyBy, this.pickupVerification, this.pickupCompletedBy, this.pickupCompletedByName, this.collectionVerification, this.collectionVerifiedBy, this.collectionVerifiedAt, this.outForDeliveryAt, this.deliveredBy, this.deliveredByName, this.proofPhotoUrl, this.completedAt, this.driverPosition, this.driverPositionAt,  Map<String, LineShortage> shortages = const <String, LineShortage>{}}): _items = items,_packedLineIds = packedLineIds,_shortages = shortages,super._();
  

@override final  String id;
@override final  int number;
@override final  String customerId;
@override final  String customerName;
@override final  String customerPhone;
@override final  String branchId;
@override final  String branchName;
@override final  bool isDelivery;
 final  List<OrderItem> _items;
@override List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  double subtotal;
@override final  double deliveryFee;
@override final  double discount;
@override final  double total;
@override final  OrderStatus status;
/// Delivery address as readable text. Null/empty for pickup.
@override final  String? address;
/// Delivery location pin, so the driver can navigate and the fee can be
/// worked out by distance. Null for pickup.
@override final  LatLng? addressLocation;
/// Message the customer left with the order.
@override final  String? customerNote;
/// Applied promo code, uppercased, or null.
@override final  String? promoCode;
/// Random server-generated code on new orders. Older demo orders use
/// the deterministic fallback below.
@override final  String? collectionToken;
/// Where the bag is collected from (the branch's address), shown to
/// drivers, who can be given deliveries from any branch.
@override final  String? branchAddress;
/// Null until Firestore has saved the server time.
@override final  DateTime? placedAt;
/// When the order entered its current status.
@override final  DateTime? statusSince;
/// When the customer was promised the order: pickup time or delivery
/// time. Packing tasks are sorted by this, soonest first.
@override final  DateTime? dueAt;
@override final  String? packerId;
@override final  String? packerName;
@override final  DateTime? packerAssignedAt;
/// Delivery orders only.
@override final  String? driverId;
@override final  String? driverName;
@override final  DateTime? driverAssignedAt;
/// Line ids already packed.
 final  Set<String> _packedLineIds;
/// Line ids already packed.
@override@JsonKey() Set<String> get packedLineIds {
  if (_packedLineIds is EqualUnmodifiableSetView) return _packedLineIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_packedLineIds);
}

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
/// Photo the driver took when delivering, as a Storage download URL.
@override final  String? proofPhotoUrl;
/// When the order was completed, by pickup or by delivery.
@override final  DateTime? completedAt;
/// Where the driver last reported being while the order is out for
/// delivery, and when (server time). Null until the first fix.
@override final  LatLng? driverPosition;
@override final  DateTime? driverPositionAt;
/// Items a packer found unavailable, by line id. See [LineShortage].
 final  Map<String, LineShortage> _shortages;
/// Items a packer found unavailable, by line id. See [LineShortage].
@override@JsonKey() Map<String, LineShortage> get shortages {
  if (_shortages is EqualUnmodifiableMapView) return _shortages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_shortages);
}


/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.isDelivery, isDelivery) || other.isDelivery == isDelivery)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.total, total) || other.total == total)&&(identical(other.status, status) || other.status == status)&&(identical(other.address, address) || other.address == address)&&(identical(other.addressLocation, addressLocation) || other.addressLocation == addressLocation)&&(identical(other.customerNote, customerNote) || other.customerNote == customerNote)&&(identical(other.promoCode, promoCode) || other.promoCode == promoCode)&&(identical(other.collectionToken, collectionToken) || other.collectionToken == collectionToken)&&(identical(other.branchAddress, branchAddress) || other.branchAddress == branchAddress)&&(identical(other.placedAt, placedAt) || other.placedAt == placedAt)&&(identical(other.statusSince, statusSince) || other.statusSince == statusSince)&&(identical(other.dueAt, dueAt) || other.dueAt == dueAt)&&(identical(other.packerId, packerId) || other.packerId == packerId)&&(identical(other.packerName, packerName) || other.packerName == packerName)&&(identical(other.packerAssignedAt, packerAssignedAt) || other.packerAssignedAt == packerAssignedAt)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverAssignedAt, driverAssignedAt) || other.driverAssignedAt == driverAssignedAt)&&const DeepCollectionEquality().equals(other.packedLineIds, _packedLineIds)&&(identical(other.packingStartedAt, packingStartedAt) || other.packingStartedAt == packingStartedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.readyBy, readyBy) || other.readyBy == readyBy)&&(identical(other.pickupVerification, pickupVerification) || other.pickupVerification == pickupVerification)&&(identical(other.pickupCompletedBy, pickupCompletedBy) || other.pickupCompletedBy == pickupCompletedBy)&&(identical(other.pickupCompletedByName, pickupCompletedByName) || other.pickupCompletedByName == pickupCompletedByName)&&(identical(other.collectionVerification, collectionVerification) || other.collectionVerification == collectionVerification)&&(identical(other.collectionVerifiedBy, collectionVerifiedBy) || other.collectionVerifiedBy == collectionVerifiedBy)&&(identical(other.collectionVerifiedAt, collectionVerifiedAt) || other.collectionVerifiedAt == collectionVerifiedAt)&&(identical(other.outForDeliveryAt, outForDeliveryAt) || other.outForDeliveryAt == outForDeliveryAt)&&(identical(other.deliveredBy, deliveredBy) || other.deliveredBy == deliveredBy)&&(identical(other.deliveredByName, deliveredByName) || other.deliveredByName == deliveredByName)&&(identical(other.proofPhotoUrl, proofPhotoUrl) || other.proofPhotoUrl == proofPhotoUrl)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.driverPosition, driverPosition) || other.driverPosition == driverPosition)&&(identical(other.driverPositionAt, driverPositionAt) || other.driverPositionAt == driverPositionAt)&&const DeepCollectionEquality().equals(other.shortages, _shortages));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,number,customerId,customerName,customerPhone,branchId,branchName,isDelivery,const DeepCollectionEquality().hash(_items),subtotal,deliveryFee,discount,total,status,address,addressLocation,customerNote,promoCode,collectionToken,branchAddress,placedAt,statusSince,dueAt,packerId,packerName,packerAssignedAt,driverId,driverName,driverAssignedAt,const DeepCollectionEquality().hash(_packedLineIds),packingStartedAt,readyAt,readyBy,pickupVerification,pickupCompletedBy,pickupCompletedByName,collectionVerification,collectionVerifiedBy,collectionVerifiedAt,outForDeliveryAt,deliveredBy,deliveredByName,proofPhotoUrl,completedAt,driverPosition,driverPositionAt,const DeepCollectionEquality().hash(_shortages)]);
}

@override
String toString() {
    return 'Order(id: $id, number: $number, customerId: $customerId, customerName: $customerName, customerPhone: $customerPhone, branchId: $branchId, branchName: $branchName, isDelivery: $isDelivery, items: $items, subtotal: $subtotal, deliveryFee: $deliveryFee, discount: $discount, total: $total, status: $status, address: $address, addressLocation: $addressLocation, customerNote: $customerNote, promoCode: $promoCode, collectionToken: $collectionToken, branchAddress: $branchAddress, placedAt: $placedAt, statusSince: $statusSince, dueAt: $dueAt, packerId: $packerId, packerName: $packerName, packerAssignedAt: $packerAssignedAt, driverId: $driverId, driverName: $driverName, driverAssignedAt: $driverAssignedAt, packedLineIds: $packedLineIds, packingStartedAt: $packingStartedAt, readyAt: $readyAt, readyBy: $readyBy, pickupVerification: $pickupVerification, pickupCompletedBy: $pickupCompletedBy, pickupCompletedByName: $pickupCompletedByName, collectionVerification: $collectionVerification, collectionVerifiedBy: $collectionVerifiedBy, collectionVerifiedAt: $collectionVerifiedAt, outForDeliveryAt: $outForDeliveryAt, deliveredBy: $deliveredBy, deliveredByName: $deliveredByName, proofPhotoUrl: $proofPhotoUrl, completedAt: $completedAt, driverPosition: $driverPosition, driverPositionAt: $driverPositionAt, shortages: $shortages)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, String customerId, String customerName, String customerPhone, String branchId, String branchName, bool isDelivery, List<OrderItem> items, double subtotal, double deliveryFee, double discount, double total, OrderStatus status, String? address, LatLng? addressLocation, String? customerNote, String? promoCode, String? collectionToken, String? branchAddress, DateTime? placedAt, DateTime? statusSince, DateTime? dueAt, String? packerId, String? packerName, DateTime? packerAssignedAt, String? driverId, String? driverName, DateTime? driverAssignedAt, Set<String> packedLineIds, DateTime? packingStartedAt, DateTime? readyAt, String? readyBy, VerificationMethod? pickupVerification, String? pickupCompletedBy, String? pickupCompletedByName, VerificationMethod? collectionVerification, String? collectionVerifiedBy, DateTime? collectionVerifiedAt, DateTime? outForDeliveryAt, String? deliveredBy, String? deliveredByName, String? proofPhotoUrl, DateTime? completedAt, LatLng? driverPosition, DateTime? driverPositionAt, Map<String, LineShortage> shortages
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? customerId = null,Object? customerName = null,Object? customerPhone = null,Object? branchId = null,Object? branchName = null,Object? isDelivery = null,Object? items = null,Object? subtotal = null,Object? deliveryFee = null,Object? discount = null,Object? total = null,Object? status = null,Object? address = freezed,Object? addressLocation = freezed,Object? customerNote = freezed,Object? promoCode = freezed,Object? collectionToken = freezed,Object? branchAddress = freezed,Object? placedAt = freezed,Object? statusSince = freezed,Object? dueAt = freezed,Object? packerId = freezed,Object? packerName = freezed,Object? packerAssignedAt = freezed,Object? driverId = freezed,Object? driverName = freezed,Object? driverAssignedAt = freezed,Object? packedLineIds = null,Object? packingStartedAt = freezed,Object? readyAt = freezed,Object? readyBy = freezed,Object? pickupVerification = freezed,Object? pickupCompletedBy = freezed,Object? pickupCompletedByName = freezed,Object? collectionVerification = freezed,Object? collectionVerifiedBy = freezed,Object? collectionVerifiedAt = freezed,Object? outForDeliveryAt = freezed,Object? deliveredBy = freezed,Object? deliveredByName = freezed,Object? proofPhotoUrl = freezed,Object? completedAt = freezed,Object? driverPosition = freezed,Object? driverPositionAt = freezed,Object? shortages = null,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,isDelivery: null == isDelivery ? _self.isDelivery : isDelivery // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,addressLocation: freezed == addressLocation ? _self.addressLocation : addressLocation // ignore: cast_nullable_to_non_nullable
as LatLng?,customerNote: freezed == customerNote ? _self.customerNote : customerNote // ignore: cast_nullable_to_non_nullable
as String?,promoCode: freezed == promoCode ? _self.promoCode : promoCode // ignore: cast_nullable_to_non_nullable
as String?,collectionToken: freezed == collectionToken ? _self.collectionToken : collectionToken // ignore: cast_nullable_to_non_nullable
as String?,branchAddress: freezed == branchAddress ? _self.branchAddress : branchAddress // ignore: cast_nullable_to_non_nullable
as String?,placedAt: freezed == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,statusSince: freezed == statusSince ? _self.statusSince : statusSince // ignore: cast_nullable_to_non_nullable
as DateTime?,dueAt: freezed == dueAt ? _self.dueAt : dueAt // ignore: cast_nullable_to_non_nullable
as DateTime?,packerId: freezed == packerId ? _self.packerId : packerId // ignore: cast_nullable_to_non_nullable
as String?,packerName: freezed == packerName ? _self.packerName : packerName // ignore: cast_nullable_to_non_nullable
as String?,packerAssignedAt: freezed == packerAssignedAt ? _self.packerAssignedAt : packerAssignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,driverAssignedAt: freezed == driverAssignedAt ? _self.driverAssignedAt : driverAssignedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,packedLineIds: null == packedLineIds ? _self._packedLineIds : packedLineIds // ignore: cast_nullable_to_non_nullable
as Set<String>,packingStartedAt: freezed == packingStartedAt ? _self.packingStartedAt : packingStartedAt // ignore: cast_nullable_to_non_nullable
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
as String?,proofPhotoUrl: freezed == proofPhotoUrl ? _self.proofPhotoUrl : proofPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,driverPosition: freezed == driverPosition ? _self.driverPosition : driverPosition // ignore: cast_nullable_to_non_nullable
as LatLng?,driverPositionAt: freezed == driverPositionAt ? _self.driverPositionAt : driverPositionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,shortages: null == shortages ? _self._shortages : shortages // ignore: cast_nullable_to_non_nullable
as Map<String, LineShortage>,
  ));
}


}

// dart format on
