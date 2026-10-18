// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branch_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BranchState {

 List<Branch> get branches; Branch get selected;
/// Create a copy of BranchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchStateCopyWith<BranchState> get copyWith => _$BranchStateCopyWithImpl<BranchState>(this as BranchState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BranchState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchState&&const DeepCollectionEquality().equals(other.branches, _this.branches)&&(identical(other.selected, _this.selected) || other.selected == _this.selected));
}


@override
int get hashCode {
  final _this = this as BranchState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.branches),_this.selected);
}

@override
String toString() {
  final _this = this as BranchState;
  return 'BranchState(branches: ${_this.branches}, selected: ${_this.selected})';
}


}

/// @nodoc
abstract mixin class $BranchStateCopyWith<$Res>  {
  factory $BranchStateCopyWith(BranchState value, $Res Function(BranchState) _then) = _$BranchStateCopyWithImpl;
@useResult
$Res call({
 List<Branch> branches, Branch selected
});


$BranchCopyWith<$Res> get selected;

}
/// @nodoc
class _$BranchStateCopyWithImpl<$Res>
    implements $BranchStateCopyWith<$Res> {
  _$BranchStateCopyWithImpl(this._self, this._then);

  final BranchState _self;
  final $Res Function(BranchState) _then;

/// Create a copy of BranchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? branches = null,Object? selected = null,}) {
  return _then(BranchState(
branches: null == branches ? _self.branches : branches // ignore: cast_nullable_to_non_nullable
as List<Branch>,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as Branch,
  ));
}
/// Create a copy of BranchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchCopyWith<$Res> get selected {
  
  return $BranchCopyWith<$Res>(_self.selected, (value) {
    return _then(_self.copyWith(selected: value));
  });
}
}


/// Adds pattern-matching-related methods to [BranchState].
extension BranchStatePatterns on BranchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BranchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BranchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BranchState value)  $default,){
final _that = this;
switch (_that) {
case _BranchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BranchState value)?  $default,){
final _that = this;
switch (_that) {
case _BranchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Branch> branches,  Branch selected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BranchState() when $default != null:
return $default(_that.branches,_that.selected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Branch> branches,  Branch selected)  $default,) {final _that = this;
switch (_that) {
case _BranchState():
return $default(_that.branches,_that.selected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Branch> branches,  Branch selected)?  $default,) {final _that = this;
switch (_that) {
case _BranchState() when $default != null:
return $default(_that.branches,_that.selected);case _:
  return null;

}
}

}

/// @nodoc


class _BranchState extends BranchState {
  const _BranchState({required  List<Branch> branches, required this.selected}): _branches = branches,super._();
  

 final  List<Branch> _branches;
@override List<Branch> get branches {
  if (_branches is EqualUnmodifiableListView) return _branches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_branches);
}

@override final  Branch selected;

/// Create a copy of BranchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BranchStateCopyWith<_BranchState> get copyWith => __$BranchStateCopyWithImpl<_BranchState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BranchState&&const DeepCollectionEquality().equals(other.branches, _branches)&&(identical(other.selected, selected) || other.selected == selected));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_branches),selected);
}

@override
String toString() {
    return 'BranchState(branches: $branches, selected: $selected)';
}


}

/// @nodoc
abstract mixin class _$BranchStateCopyWith<$Res> implements $BranchStateCopyWith<$Res> {
  factory _$BranchStateCopyWith(_BranchState value, $Res Function(_BranchState) _then) = __$BranchStateCopyWithImpl;
@override @useResult
$Res call({
 List<Branch> branches, Branch selected
});


@override $BranchCopyWith<$Res> get selected;

}
/// @nodoc
class __$BranchStateCopyWithImpl<$Res>
    implements _$BranchStateCopyWith<$Res> {
  __$BranchStateCopyWithImpl(this._self, this._then);

  final _BranchState _self;
  final $Res Function(_BranchState) _then;

/// Create a copy of BranchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? branches = null,Object? selected = null,}) {
  return _then(_BranchState(
branches: null == branches ? _self._branches : branches // ignore: cast_nullable_to_non_nullable
as List<Branch>,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as Branch,
  ));
}

/// Create a copy of BranchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchCopyWith<$Res> get selected {
  
  return $BranchCopyWith<$Res>(_self.selected, (value) {
    return _then(_self.copyWith(selected: value));
  });
}
}

// dart format on
