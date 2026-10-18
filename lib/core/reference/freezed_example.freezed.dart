// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'freezed_example.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExampleCartLine {

 String get productId; String get name; double get unitPrice; int get quantity;
/// Create a copy of ExampleCartLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExampleCartLineCopyWith<ExampleCartLine> get copyWith => _$ExampleCartLineCopyWithImpl<ExampleCartLine>(this as ExampleCartLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExampleCartLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExampleCartLine&&(identical(other.productId, _this.productId) || other.productId == _this.productId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity));
}


@override
int get hashCode {
  final _this = this as ExampleCartLine;
  return Object.hash(runtimeType,_this.productId,_this.name,_this.unitPrice,_this.quantity);
}

@override
String toString() {
  final _this = this as ExampleCartLine;
  return 'ExampleCartLine(productId: ${_this.productId}, name: ${_this.name}, unitPrice: ${_this.unitPrice}, quantity: ${_this.quantity})';
}


}

/// @nodoc
abstract mixin class $ExampleCartLineCopyWith<$Res>  {
  factory $ExampleCartLineCopyWith(ExampleCartLine value, $Res Function(ExampleCartLine) _then) = _$ExampleCartLineCopyWithImpl;
@useResult
$Res call({
 String productId, String name, double unitPrice, int quantity
});




}
/// @nodoc
class _$ExampleCartLineCopyWithImpl<$Res>
    implements $ExampleCartLineCopyWith<$Res> {
  _$ExampleCartLineCopyWithImpl(this._self, this._then);

  final ExampleCartLine _self;
  final $Res Function(ExampleCartLine) _then;

/// Create a copy of ExampleCartLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? name = null,Object? unitPrice = null,Object? quantity = null,}) {
  return _then(ExampleCartLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExampleCartLine].
extension ExampleCartLinePatterns on ExampleCartLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExampleCartLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExampleCartLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExampleCartLine value)  $default,){
final _that = this;
switch (_that) {
case _ExampleCartLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExampleCartLine value)?  $default,){
final _that = this;
switch (_that) {
case _ExampleCartLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  String name,  double unitPrice,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExampleCartLine() when $default != null:
return $default(_that.productId,_that.name,_that.unitPrice,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  String name,  double unitPrice,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _ExampleCartLine():
return $default(_that.productId,_that.name,_that.unitPrice,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  String name,  double unitPrice,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _ExampleCartLine() when $default != null:
return $default(_that.productId,_that.name,_that.unitPrice,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc


class _ExampleCartLine implements ExampleCartLine {
  const _ExampleCartLine({required this.productId, required this.name, required this.unitPrice, this.quantity = 1});
  

@override final  String productId;
@override final  String name;
@override final  double unitPrice;
@override@JsonKey() final  int quantity;

/// Create a copy of ExampleCartLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExampleCartLineCopyWith<_ExampleCartLine> get copyWith => __$ExampleCartLineCopyWithImpl<_ExampleCartLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExampleCartLine&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,productId,name,unitPrice,quantity);
}

@override
String toString() {
    return 'ExampleCartLine(productId: $productId, name: $name, unitPrice: $unitPrice, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$ExampleCartLineCopyWith<$Res> implements $ExampleCartLineCopyWith<$Res> {
  factory _$ExampleCartLineCopyWith(_ExampleCartLine value, $Res Function(_ExampleCartLine) _then) = __$ExampleCartLineCopyWithImpl;
@override @useResult
$Res call({
 String productId, String name, double unitPrice, int quantity
});




}
/// @nodoc
class __$ExampleCartLineCopyWithImpl<$Res>
    implements _$ExampleCartLineCopyWith<$Res> {
  __$ExampleCartLineCopyWithImpl(this._self, this._then);

  final _ExampleCartLine _self;
  final $Res Function(_ExampleCartLine) _then;

/// Create a copy of ExampleCartLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? name = null,Object? unitPrice = null,Object? quantity = null,}) {
  return _then(_ExampleCartLine(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ExampleCheckoutState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExampleCheckoutState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ExampleCheckoutState()';
}


}

/// @nodoc
class $ExampleCheckoutStateCopyWith<$Res>  {
$ExampleCheckoutStateCopyWith(ExampleCheckoutState _, $Res Function(ExampleCheckoutState) __);
}


/// Adds pattern-matching-related methods to [ExampleCheckoutState].
extension ExampleCheckoutStatePatterns on ExampleCheckoutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ExampleCheckoutIdle value)?  idle,TResult Function( ExampleCheckoutSubmitting value)?  submitting,TResult Function( ExampleCheckoutSuccess value)?  success,TResult Function( ExampleCheckoutFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ExampleCheckoutIdle() when idle != null:
return idle(_that);case ExampleCheckoutSubmitting() when submitting != null:
return submitting(_that);case ExampleCheckoutSuccess() when success != null:
return success(_that);case ExampleCheckoutFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ExampleCheckoutIdle value)  idle,required TResult Function( ExampleCheckoutSubmitting value)  submitting,required TResult Function( ExampleCheckoutSuccess value)  success,required TResult Function( ExampleCheckoutFailure value)  failure,}){
final _that = this;
switch (_that) {
case ExampleCheckoutIdle():
return idle(_that);case ExampleCheckoutSubmitting():
return submitting(_that);case ExampleCheckoutSuccess():
return success(_that);case ExampleCheckoutFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ExampleCheckoutIdle value)?  idle,TResult? Function( ExampleCheckoutSubmitting value)?  submitting,TResult? Function( ExampleCheckoutSuccess value)?  success,TResult? Function( ExampleCheckoutFailure value)?  failure,}){
final _that = this;
switch (_that) {
case ExampleCheckoutIdle() when idle != null:
return idle(_that);case ExampleCheckoutSubmitting() when submitting != null:
return submitting(_that);case ExampleCheckoutSuccess() when success != null:
return success(_that);case ExampleCheckoutFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  submitting,TResult Function( String orderId)?  success,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ExampleCheckoutIdle() when idle != null:
return idle();case ExampleCheckoutSubmitting() when submitting != null:
return submitting();case ExampleCheckoutSuccess() when success != null:
return success(_that.orderId);case ExampleCheckoutFailure() when failure != null:
return failure(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  submitting,required TResult Function( String orderId)  success,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case ExampleCheckoutIdle():
return idle();case ExampleCheckoutSubmitting():
return submitting();case ExampleCheckoutSuccess():
return success(_that.orderId);case ExampleCheckoutFailure():
return failure(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  submitting,TResult? Function( String orderId)?  success,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case ExampleCheckoutIdle() when idle != null:
return idle();case ExampleCheckoutSubmitting() when submitting != null:
return submitting();case ExampleCheckoutSuccess() when success != null:
return success(_that.orderId);case ExampleCheckoutFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ExampleCheckoutIdle implements ExampleCheckoutState {
  const ExampleCheckoutIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExampleCheckoutIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ExampleCheckoutState.idle()';
}


}




/// @nodoc


class ExampleCheckoutSubmitting implements ExampleCheckoutState {
  const ExampleCheckoutSubmitting();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExampleCheckoutSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ExampleCheckoutState.submitting()';
}


}




/// @nodoc


class ExampleCheckoutSuccess implements ExampleCheckoutState {
  const ExampleCheckoutSuccess(this.orderId);
  

 final  String orderId;

/// Create a copy of ExampleCheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExampleCheckoutSuccessCopyWith<ExampleCheckoutSuccess> get copyWith => _$ExampleCheckoutSuccessCopyWithImpl<ExampleCheckoutSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExampleCheckoutSuccess&&(identical(other.orderId, orderId) || other.orderId == orderId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,orderId);
}

@override
String toString() {
    return 'ExampleCheckoutState.success(orderId: $orderId)';
}


}

/// @nodoc
abstract mixin class $ExampleCheckoutSuccessCopyWith<$Res> implements $ExampleCheckoutStateCopyWith<$Res> {
  factory $ExampleCheckoutSuccessCopyWith(ExampleCheckoutSuccess value, $Res Function(ExampleCheckoutSuccess) _then) = _$ExampleCheckoutSuccessCopyWithImpl;
@useResult
$Res call({
 String orderId
});




}
/// @nodoc
class _$ExampleCheckoutSuccessCopyWithImpl<$Res>
    implements $ExampleCheckoutSuccessCopyWith<$Res> {
  _$ExampleCheckoutSuccessCopyWithImpl(this._self, this._then);

  final ExampleCheckoutSuccess _self;
  final $Res Function(ExampleCheckoutSuccess) _then;

/// Create a copy of ExampleCheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? orderId = null,}) {
  return _then(ExampleCheckoutSuccess(
null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ExampleCheckoutFailure implements ExampleCheckoutState {
  const ExampleCheckoutFailure(this.message);
  

 final  String message;

/// Create a copy of ExampleCheckoutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExampleCheckoutFailureCopyWith<ExampleCheckoutFailure> get copyWith => _$ExampleCheckoutFailureCopyWithImpl<ExampleCheckoutFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ExampleCheckoutFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'ExampleCheckoutState.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $ExampleCheckoutFailureCopyWith<$Res> implements $ExampleCheckoutStateCopyWith<$Res> {
  factory $ExampleCheckoutFailureCopyWith(ExampleCheckoutFailure value, $Res Function(ExampleCheckoutFailure) _then) = _$ExampleCheckoutFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ExampleCheckoutFailureCopyWithImpl<$Res>
    implements $ExampleCheckoutFailureCopyWith<$Res> {
  _$ExampleCheckoutFailureCopyWithImpl(this._self, this._then);

  final ExampleCheckoutFailure _self;
  final $Res Function(ExampleCheckoutFailure) _then;

/// Create a copy of ExampleCheckoutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ExampleCheckoutFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ExampleDocument {

 String get id; String get title; int get count; String? get note; DateTime? get createdAt;
/// Create a copy of ExampleDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExampleDocumentCopyWith<ExampleDocument> get copyWith => _$ExampleDocumentCopyWithImpl<ExampleDocument>(this as ExampleDocument, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExampleDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExampleDocument&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as ExampleDocument;
  return Object.hash(runtimeType,_this.id,_this.title,_this.count,_this.note,_this.createdAt);
}

@override
String toString() {
  final _this = this as ExampleDocument;
  return 'ExampleDocument(id: ${_this.id}, title: ${_this.title}, count: ${_this.count}, note: ${_this.note}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ExampleDocumentCopyWith<$Res>  {
  factory $ExampleDocumentCopyWith(ExampleDocument value, $Res Function(ExampleDocument) _then) = _$ExampleDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String title, int count, String? note, DateTime? createdAt
});




}
/// @nodoc
class _$ExampleDocumentCopyWithImpl<$Res>
    implements $ExampleDocumentCopyWith<$Res> {
  _$ExampleDocumentCopyWithImpl(this._self, this._then);

  final ExampleDocument _self;
  final $Res Function(ExampleDocument) _then;

/// Create a copy of ExampleDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? count = null,Object? note = freezed,Object? createdAt = freezed,}) {
  return _then(ExampleDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExampleDocument].
extension ExampleDocumentPatterns on ExampleDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExampleDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExampleDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExampleDocument value)  $default,){
final _that = this;
switch (_that) {
case _ExampleDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExampleDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ExampleDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int count,  String? note,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExampleDocument() when $default != null:
return $default(_that.id,_that.title,_that.count,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int count,  String? note,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ExampleDocument():
return $default(_that.id,_that.title,_that.count,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int count,  String? note,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ExampleDocument() when $default != null:
return $default(_that.id,_that.title,_that.count,_that.note,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _ExampleDocument extends ExampleDocument {
  const _ExampleDocument({required this.id, required this.title, required this.count, this.note, this.createdAt}): super._();
  

@override final  String id;
@override final  String title;
@override final  int count;
@override final  String? note;
@override final  DateTime? createdAt;

/// Create a copy of ExampleDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExampleDocumentCopyWith<_ExampleDocument> get copyWith => __$ExampleDocumentCopyWithImpl<_ExampleDocument>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExampleDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.count, count) || other.count == count)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,title,count,note,createdAt);
}

@override
String toString() {
    return 'ExampleDocument(id: $id, title: $title, count: $count, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ExampleDocumentCopyWith<$Res> implements $ExampleDocumentCopyWith<$Res> {
  factory _$ExampleDocumentCopyWith(_ExampleDocument value, $Res Function(_ExampleDocument) _then) = __$ExampleDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int count, String? note, DateTime? createdAt
});




}
/// @nodoc
class __$ExampleDocumentCopyWithImpl<$Res>
    implements _$ExampleDocumentCopyWith<$Res> {
  __$ExampleDocumentCopyWithImpl(this._self, this._then);

  final _ExampleDocument _self;
  final $Res Function(_ExampleDocument) _then;

/// Create a copy of ExampleDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? count = null,Object? note = freezed,Object? createdAt = freezed,}) {
  return _then(_ExampleDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
