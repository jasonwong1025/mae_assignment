// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardSummary {

 int get ordersToday; int get ordersYesterday;/// Order count for each hour since the branch opened.
/// The last number is the current hour.
 List<int> get ordersByHour;/// Today's revenue in whole ringgit.
 int get revenue; int get driversOnRoad; int get totalDrivers;/// Orders that are not finished yet.
 List<LiveOrder> get liveOrders;/// Latest staff actions, newest first.
 List<ActivityEntry> get activity;
/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSummaryCopyWith<DashboardSummary> get copyWith => _$DashboardSummaryCopyWithImpl<DashboardSummary>(this as DashboardSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DashboardSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSummary&&(identical(other.ordersToday, _this.ordersToday) || other.ordersToday == _this.ordersToday)&&(identical(other.ordersYesterday, _this.ordersYesterday) || other.ordersYesterday == _this.ordersYesterday)&&const DeepCollectionEquality().equals(other.ordersByHour, _this.ordersByHour)&&(identical(other.revenue, _this.revenue) || other.revenue == _this.revenue)&&(identical(other.driversOnRoad, _this.driversOnRoad) || other.driversOnRoad == _this.driversOnRoad)&&(identical(other.totalDrivers, _this.totalDrivers) || other.totalDrivers == _this.totalDrivers)&&const DeepCollectionEquality().equals(other.liveOrders, _this.liveOrders)&&const DeepCollectionEquality().equals(other.activity, _this.activity));
}


@override
int get hashCode {
  final _this = this as DashboardSummary;
  return Object.hash(runtimeType,_this.ordersToday,_this.ordersYesterday,const DeepCollectionEquality().hash(_this.ordersByHour),_this.revenue,_this.driversOnRoad,_this.totalDrivers,const DeepCollectionEquality().hash(_this.liveOrders),const DeepCollectionEquality().hash(_this.activity));
}

@override
String toString() {
  final _this = this as DashboardSummary;
  return 'DashboardSummary(ordersToday: ${_this.ordersToday}, ordersYesterday: ${_this.ordersYesterday}, ordersByHour: ${_this.ordersByHour}, revenue: ${_this.revenue}, driversOnRoad: ${_this.driversOnRoad}, totalDrivers: ${_this.totalDrivers}, liveOrders: ${_this.liveOrders}, activity: ${_this.activity})';
}


}

/// @nodoc
abstract mixin class $DashboardSummaryCopyWith<$Res>  {
  factory $DashboardSummaryCopyWith(DashboardSummary value, $Res Function(DashboardSummary) _then) = _$DashboardSummaryCopyWithImpl;
@useResult
$Res call({
 int ordersToday, int ordersYesterday, List<int> ordersByHour, int revenue, int driversOnRoad, int totalDrivers, List<LiveOrder> liveOrders, List<ActivityEntry> activity
});




}
/// @nodoc
class _$DashboardSummaryCopyWithImpl<$Res>
    implements $DashboardSummaryCopyWith<$Res> {
  _$DashboardSummaryCopyWithImpl(this._self, this._then);

  final DashboardSummary _self;
  final $Res Function(DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ordersToday = null,Object? ordersYesterday = null,Object? ordersByHour = null,Object? revenue = null,Object? driversOnRoad = null,Object? totalDrivers = null,Object? liveOrders = null,Object? activity = null,}) {
  return _then(DashboardSummary(
ordersToday: null == ordersToday ? _self.ordersToday : ordersToday // ignore: cast_nullable_to_non_nullable
as int,ordersYesterday: null == ordersYesterday ? _self.ordersYesterday : ordersYesterday // ignore: cast_nullable_to_non_nullable
as int,ordersByHour: null == ordersByHour ? _self.ordersByHour : ordersByHour // ignore: cast_nullable_to_non_nullable
as List<int>,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as int,driversOnRoad: null == driversOnRoad ? _self.driversOnRoad : driversOnRoad // ignore: cast_nullable_to_non_nullable
as int,totalDrivers: null == totalDrivers ? _self.totalDrivers : totalDrivers // ignore: cast_nullable_to_non_nullable
as int,liveOrders: null == liveOrders ? _self.liveOrders : liveOrders // ignore: cast_nullable_to_non_nullable
as List<LiveOrder>,activity: null == activity ? _self.activity : activity // ignore: cast_nullable_to_non_nullable
as List<ActivityEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardSummary].
extension DashboardSummaryPatterns on DashboardSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSummary value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int ordersToday,  int ordersYesterday,  List<int> ordersByHour,  int revenue,  int driversOnRoad,  int totalDrivers,  List<LiveOrder> liveOrders,  List<ActivityEntry> activity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.ordersToday,_that.ordersYesterday,_that.ordersByHour,_that.revenue,_that.driversOnRoad,_that.totalDrivers,_that.liveOrders,_that.activity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int ordersToday,  int ordersYesterday,  List<int> ordersByHour,  int revenue,  int driversOnRoad,  int totalDrivers,  List<LiveOrder> liveOrders,  List<ActivityEntry> activity)  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary():
return $default(_that.ordersToday,_that.ordersYesterday,_that.ordersByHour,_that.revenue,_that.driversOnRoad,_that.totalDrivers,_that.liveOrders,_that.activity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int ordersToday,  int ordersYesterday,  List<int> ordersByHour,  int revenue,  int driversOnRoad,  int totalDrivers,  List<LiveOrder> liveOrders,  List<ActivityEntry> activity)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.ordersToday,_that.ordersYesterday,_that.ordersByHour,_that.revenue,_that.driversOnRoad,_that.totalDrivers,_that.liveOrders,_that.activity);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardSummary extends DashboardSummary {
  const _DashboardSummary({required this.ordersToday, required this.ordersYesterday, required  List<int> ordersByHour, required this.revenue, required this.driversOnRoad, required this.totalDrivers, required  List<LiveOrder> liveOrders, required  List<ActivityEntry> activity}): _ordersByHour = ordersByHour,_liveOrders = liveOrders,_activity = activity,super._();
  

@override final  int ordersToday;
@override final  int ordersYesterday;
/// Order count for each hour since the branch opened.
/// The last number is the current hour.
 final  List<int> _ordersByHour;
/// Order count for each hour since the branch opened.
/// The last number is the current hour.
@override List<int> get ordersByHour {
  if (_ordersByHour is EqualUnmodifiableListView) return _ordersByHour;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ordersByHour);
}

/// Today's revenue in whole ringgit.
@override final  int revenue;
@override final  int driversOnRoad;
@override final  int totalDrivers;
/// Orders that are not finished yet.
 final  List<LiveOrder> _liveOrders;
/// Orders that are not finished yet.
@override List<LiveOrder> get liveOrders {
  if (_liveOrders is EqualUnmodifiableListView) return _liveOrders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_liveOrders);
}

/// Latest staff actions, newest first.
 final  List<ActivityEntry> _activity;
/// Latest staff actions, newest first.
@override List<ActivityEntry> get activity {
  if (_activity is EqualUnmodifiableListView) return _activity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activity);
}


/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSummaryCopyWith<_DashboardSummary> get copyWith => __$DashboardSummaryCopyWithImpl<_DashboardSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSummary&&(identical(other.ordersToday, ordersToday) || other.ordersToday == ordersToday)&&(identical(other.ordersYesterday, ordersYesterday) || other.ordersYesterday == ordersYesterday)&&const DeepCollectionEquality().equals(other.ordersByHour, _ordersByHour)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.driversOnRoad, driversOnRoad) || other.driversOnRoad == driversOnRoad)&&(identical(other.totalDrivers, totalDrivers) || other.totalDrivers == totalDrivers)&&const DeepCollectionEquality().equals(other.liveOrders, _liveOrders)&&const DeepCollectionEquality().equals(other.activity, _activity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,ordersToday,ordersYesterday,const DeepCollectionEquality().hash(_ordersByHour),revenue,driversOnRoad,totalDrivers,const DeepCollectionEquality().hash(_liveOrders),const DeepCollectionEquality().hash(_activity));
}

@override
String toString() {
    return 'DashboardSummary(ordersToday: $ordersToday, ordersYesterday: $ordersYesterday, ordersByHour: $ordersByHour, revenue: $revenue, driversOnRoad: $driversOnRoad, totalDrivers: $totalDrivers, liveOrders: $liveOrders, activity: $activity)';
}


}

/// @nodoc
abstract mixin class _$DashboardSummaryCopyWith<$Res> implements $DashboardSummaryCopyWith<$Res> {
  factory _$DashboardSummaryCopyWith(_DashboardSummary value, $Res Function(_DashboardSummary) _then) = __$DashboardSummaryCopyWithImpl;
@override @useResult
$Res call({
 int ordersToday, int ordersYesterday, List<int> ordersByHour, int revenue, int driversOnRoad, int totalDrivers, List<LiveOrder> liveOrders, List<ActivityEntry> activity
});




}
/// @nodoc
class __$DashboardSummaryCopyWithImpl<$Res>
    implements _$DashboardSummaryCopyWith<$Res> {
  __$DashboardSummaryCopyWithImpl(this._self, this._then);

  final _DashboardSummary _self;
  final $Res Function(_DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ordersToday = null,Object? ordersYesterday = null,Object? ordersByHour = null,Object? revenue = null,Object? driversOnRoad = null,Object? totalDrivers = null,Object? liveOrders = null,Object? activity = null,}) {
  return _then(_DashboardSummary(
ordersToday: null == ordersToday ? _self.ordersToday : ordersToday // ignore: cast_nullable_to_non_nullable
as int,ordersYesterday: null == ordersYesterday ? _self.ordersYesterday : ordersYesterday // ignore: cast_nullable_to_non_nullable
as int,ordersByHour: null == ordersByHour ? _self._ordersByHour : ordersByHour // ignore: cast_nullable_to_non_nullable
as List<int>,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as int,driversOnRoad: null == driversOnRoad ? _self.driversOnRoad : driversOnRoad // ignore: cast_nullable_to_non_nullable
as int,totalDrivers: null == totalDrivers ? _self.totalDrivers : totalDrivers // ignore: cast_nullable_to_non_nullable
as int,liveOrders: null == liveOrders ? _self._liveOrders : liveOrders // ignore: cast_nullable_to_non_nullable
as List<LiveOrder>,activity: null == activity ? _self._activity : activity // ignore: cast_nullable_to_non_nullable
as List<ActivityEntry>,
  ));
}


}

/// @nodoc
mixin _$LiveOrder {

 int get number; String get customerName;/// Never completed or cancelled: only unfinished orders are listed.
 OrderStatus get status;/// True for delivery, false for pickup at the store.
 bool get isDelivery;/// How long the order has been in its current status.
 int get minutesInStatus;
/// Create a copy of LiveOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveOrderCopyWith<LiveOrder> get copyWith => _$LiveOrderCopyWithImpl<LiveOrder>(this as LiveOrder, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LiveOrder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveOrder&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.isDelivery, _this.isDelivery) || other.isDelivery == _this.isDelivery)&&(identical(other.minutesInStatus, _this.minutesInStatus) || other.minutesInStatus == _this.minutesInStatus));
}


@override
int get hashCode {
  final _this = this as LiveOrder;
  return Object.hash(runtimeType,_this.number,_this.customerName,_this.status,_this.isDelivery,_this.minutesInStatus);
}

@override
String toString() {
  final _this = this as LiveOrder;
  return 'LiveOrder(number: ${_this.number}, customerName: ${_this.customerName}, status: ${_this.status}, isDelivery: ${_this.isDelivery}, minutesInStatus: ${_this.minutesInStatus})';
}


}

/// @nodoc
abstract mixin class $LiveOrderCopyWith<$Res>  {
  factory $LiveOrderCopyWith(LiveOrder value, $Res Function(LiveOrder) _then) = _$LiveOrderCopyWithImpl;
@useResult
$Res call({
 int number, String customerName, OrderStatus status, bool isDelivery, int minutesInStatus
});




}
/// @nodoc
class _$LiveOrderCopyWithImpl<$Res>
    implements $LiveOrderCopyWith<$Res> {
  _$LiveOrderCopyWithImpl(this._self, this._then);

  final LiveOrder _self;
  final $Res Function(LiveOrder) _then;

/// Create a copy of LiveOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? customerName = null,Object? status = null,Object? isDelivery = null,Object? minutesInStatus = null,}) {
  return _then(LiveOrder(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,isDelivery: null == isDelivery ? _self.isDelivery : isDelivery // ignore: cast_nullable_to_non_nullable
as bool,minutesInStatus: null == minutesInStatus ? _self.minutesInStatus : minutesInStatus // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveOrder].
extension LiveOrderPatterns on LiveOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveOrder value)  $default,){
final _that = this;
switch (_that) {
case _LiveOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveOrder value)?  $default,){
final _that = this;
switch (_that) {
case _LiveOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  String customerName,  OrderStatus status,  bool isDelivery,  int minutesInStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveOrder() when $default != null:
return $default(_that.number,_that.customerName,_that.status,_that.isDelivery,_that.minutesInStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  String customerName,  OrderStatus status,  bool isDelivery,  int minutesInStatus)  $default,) {final _that = this;
switch (_that) {
case _LiveOrder():
return $default(_that.number,_that.customerName,_that.status,_that.isDelivery,_that.minutesInStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  String customerName,  OrderStatus status,  bool isDelivery,  int minutesInStatus)?  $default,) {final _that = this;
switch (_that) {
case _LiveOrder() when $default != null:
return $default(_that.number,_that.customerName,_that.status,_that.isDelivery,_that.minutesInStatus);case _:
  return null;

}
}

}

/// @nodoc


class _LiveOrder extends LiveOrder {
  const _LiveOrder({required this.number, required this.customerName, required this.status, required this.isDelivery, required this.minutesInStatus}): super._();
  

@override final  int number;
@override final  String customerName;
/// Never completed or cancelled: only unfinished orders are listed.
@override final  OrderStatus status;
/// True for delivery, false for pickup at the store.
@override final  bool isDelivery;
/// How long the order has been in its current status.
@override final  int minutesInStatus;

/// Create a copy of LiveOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveOrderCopyWith<_LiveOrder> get copyWith => __$LiveOrderCopyWithImpl<_LiveOrder>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveOrder&&(identical(other.number, number) || other.number == number)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.status, status) || other.status == status)&&(identical(other.isDelivery, isDelivery) || other.isDelivery == isDelivery)&&(identical(other.minutesInStatus, minutesInStatus) || other.minutesInStatus == minutesInStatus));
}


@override
int get hashCode {
    return Object.hash(runtimeType,number,customerName,status,isDelivery,minutesInStatus);
}

@override
String toString() {
    return 'LiveOrder(number: $number, customerName: $customerName, status: $status, isDelivery: $isDelivery, minutesInStatus: $minutesInStatus)';
}


}

/// @nodoc
abstract mixin class _$LiveOrderCopyWith<$Res> implements $LiveOrderCopyWith<$Res> {
  factory _$LiveOrderCopyWith(_LiveOrder value, $Res Function(_LiveOrder) _then) = __$LiveOrderCopyWithImpl;
@override @useResult
$Res call({
 int number, String customerName, OrderStatus status, bool isDelivery, int minutesInStatus
});




}
/// @nodoc
class __$LiveOrderCopyWithImpl<$Res>
    implements _$LiveOrderCopyWith<$Res> {
  __$LiveOrderCopyWithImpl(this._self, this._then);

  final _LiveOrder _self;
  final $Res Function(_LiveOrder) _then;

/// Create a copy of LiveOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? customerName = null,Object? status = null,Object? isDelivery = null,Object? minutesInStatus = null,}) {
  return _then(_LiveOrder(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,isDelivery: null == isDelivery ? _self.isDelivery : isDelivery // ignore: cast_nullable_to_non_nullable
as bool,minutesInStatus: null == minutesInStatus ? _self.minutesInStatus : minutesInStatus // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ActivityEntry {

 String get message; int get minutesAgo;
/// Create a copy of ActivityEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityEntryCopyWith<ActivityEntry> get copyWith => _$ActivityEntryCopyWithImpl<ActivityEntry>(this as ActivityEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ActivityEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityEntry&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.minutesAgo, _this.minutesAgo) || other.minutesAgo == _this.minutesAgo));
}


@override
int get hashCode {
  final _this = this as ActivityEntry;
  return Object.hash(runtimeType,_this.message,_this.minutesAgo);
}

@override
String toString() {
  final _this = this as ActivityEntry;
  return 'ActivityEntry(message: ${_this.message}, minutesAgo: ${_this.minutesAgo})';
}


}

/// @nodoc
abstract mixin class $ActivityEntryCopyWith<$Res>  {
  factory $ActivityEntryCopyWith(ActivityEntry value, $Res Function(ActivityEntry) _then) = _$ActivityEntryCopyWithImpl;
@useResult
$Res call({
 String message, int minutesAgo
});




}
/// @nodoc
class _$ActivityEntryCopyWithImpl<$Res>
    implements $ActivityEntryCopyWith<$Res> {
  _$ActivityEntryCopyWithImpl(this._self, this._then);

  final ActivityEntry _self;
  final $Res Function(ActivityEntry) _then;

/// Create a copy of ActivityEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? minutesAgo = null,}) {
  return _then(ActivityEntry(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,minutesAgo: null == minutesAgo ? _self.minutesAgo : minutesAgo // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityEntry].
extension ActivityEntryPatterns on ActivityEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityEntry value)  $default,){
final _that = this;
switch (_that) {
case _ActivityEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  int minutesAgo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityEntry() when $default != null:
return $default(_that.message,_that.minutesAgo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  int minutesAgo)  $default,) {final _that = this;
switch (_that) {
case _ActivityEntry():
return $default(_that.message,_that.minutesAgo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  int minutesAgo)?  $default,) {final _that = this;
switch (_that) {
case _ActivityEntry() when $default != null:
return $default(_that.message,_that.minutesAgo);case _:
  return null;

}
}

}

/// @nodoc


class _ActivityEntry extends ActivityEntry {
  const _ActivityEntry({required this.message, required this.minutesAgo}): super._();
  

@override final  String message;
@override final  int minutesAgo;

/// Create a copy of ActivityEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityEntryCopyWith<_ActivityEntry> get copyWith => __$ActivityEntryCopyWithImpl<_ActivityEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityEntry&&(identical(other.message, message) || other.message == message)&&(identical(other.minutesAgo, minutesAgo) || other.minutesAgo == minutesAgo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,minutesAgo);
}

@override
String toString() {
    return 'ActivityEntry(message: $message, minutesAgo: $minutesAgo)';
}


}

/// @nodoc
abstract mixin class _$ActivityEntryCopyWith<$Res> implements $ActivityEntryCopyWith<$Res> {
  factory _$ActivityEntryCopyWith(_ActivityEntry value, $Res Function(_ActivityEntry) _then) = __$ActivityEntryCopyWithImpl;
@override @useResult
$Res call({
 String message, int minutesAgo
});




}
/// @nodoc
class __$ActivityEntryCopyWithImpl<$Res>
    implements _$ActivityEntryCopyWith<$Res> {
  __$ActivityEntryCopyWithImpl(this._self, this._then);

  final _ActivityEntry _self;
  final $Res Function(_ActivityEntry) _then;

/// Create a copy of ActivityEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? minutesAgo = null,}) {
  return _then(_ActivityEntry(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,minutesAgo: null == minutesAgo ? _self.minutesAgo : minutesAgo // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
