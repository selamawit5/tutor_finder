// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutor_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TutorProfile {

 String get userId; String get name; String get bio; EducationStatus get educationStatus; String get school; String get fieldOfStudy; List<String> get subjectIds; double get pricePerHour; List<String> get availability; double get ratingAverage; int get ratingCount; String? get photoUrl;
/// Create a copy of TutorProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TutorProfileCopyWith<TutorProfile> get copyWith => _$TutorProfileCopyWithImpl<TutorProfile>(this as TutorProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TutorProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TutorProfile&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.educationStatus, _this.educationStatus) || other.educationStatus == _this.educationStatus)&&(identical(other.school, _this.school) || other.school == _this.school)&&(identical(other.fieldOfStudy, _this.fieldOfStudy) || other.fieldOfStudy == _this.fieldOfStudy)&&const DeepCollectionEquality().equals(other.subjectIds, _this.subjectIds)&&(identical(other.pricePerHour, _this.pricePerHour) || other.pricePerHour == _this.pricePerHour)&&const DeepCollectionEquality().equals(other.availability, _this.availability)&&(identical(other.ratingAverage, _this.ratingAverage) || other.ratingAverage == _this.ratingAverage)&&(identical(other.ratingCount, _this.ratingCount) || other.ratingCount == _this.ratingCount)&&(identical(other.photoUrl, _this.photoUrl) || other.photoUrl == _this.photoUrl));
}


@override
int get hashCode {
  final _this = this as TutorProfile;
  return Object.hash(runtimeType,_this.userId,_this.name,_this.bio,_this.educationStatus,_this.school,_this.fieldOfStudy,const DeepCollectionEquality().hash(_this.subjectIds),_this.pricePerHour,const DeepCollectionEquality().hash(_this.availability),_this.ratingAverage,_this.ratingCount,_this.photoUrl);
}

@override
String toString() {
  final _this = this as TutorProfile;
  return 'TutorProfile(userId: ${_this.userId}, name: ${_this.name}, bio: ${_this.bio}, educationStatus: ${_this.educationStatus}, school: ${_this.school}, fieldOfStudy: ${_this.fieldOfStudy}, subjectIds: ${_this.subjectIds}, pricePerHour: ${_this.pricePerHour}, availability: ${_this.availability}, ratingAverage: ${_this.ratingAverage}, ratingCount: ${_this.ratingCount}, photoUrl: ${_this.photoUrl})';
}


}

/// @nodoc
abstract mixin class $TutorProfileCopyWith<$Res>  {
  factory $TutorProfileCopyWith(TutorProfile value, $Res Function(TutorProfile) _then) = _$TutorProfileCopyWithImpl;
@useResult
$Res call({
 String userId, String name, String bio, EducationStatus educationStatus, String school, String fieldOfStudy, List<String> subjectIds, double pricePerHour, List<String> availability, double ratingAverage, int ratingCount, String? photoUrl
});




}
/// @nodoc
class _$TutorProfileCopyWithImpl<$Res>
    implements $TutorProfileCopyWith<$Res> {
  _$TutorProfileCopyWithImpl(this._self, this._then);

  final TutorProfile _self;
  final $Res Function(TutorProfile) _then;

/// Create a copy of TutorProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? bio = null,Object? educationStatus = null,Object? school = null,Object? fieldOfStudy = null,Object? subjectIds = null,Object? pricePerHour = null,Object? availability = null,Object? ratingAverage = null,Object? ratingCount = null,Object? photoUrl = freezed,}) {
  return _then(TutorProfile(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,educationStatus: null == educationStatus ? _self.educationStatus : educationStatus // ignore: cast_nullable_to_non_nullable
as EducationStatus,school: null == school ? _self.school : school // ignore: cast_nullable_to_non_nullable
as String,fieldOfStudy: null == fieldOfStudy ? _self.fieldOfStudy : fieldOfStudy // ignore: cast_nullable_to_non_nullable
as String,subjectIds: null == subjectIds ? _self.subjectIds : subjectIds // ignore: cast_nullable_to_non_nullable
as List<String>,pricePerHour: null == pricePerHour ? _self.pricePerHour : pricePerHour // ignore: cast_nullable_to_non_nullable
as double,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as List<String>,ratingAverage: null == ratingAverage ? _self.ratingAverage : ratingAverage // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TutorProfile].
extension TutorProfilePatterns on TutorProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TutorProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TutorProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TutorProfile value)  $default,){
final _that = this;
switch (_that) {
case _TutorProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TutorProfile value)?  $default,){
final _that = this;
switch (_that) {
case _TutorProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String name,  String bio,  EducationStatus educationStatus,  String school,  String fieldOfStudy,  List<String> subjectIds,  double pricePerHour,  List<String> availability,  double ratingAverage,  int ratingCount,  String? photoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TutorProfile() when $default != null:
return $default(_that.userId,_that.name,_that.bio,_that.educationStatus,_that.school,_that.fieldOfStudy,_that.subjectIds,_that.pricePerHour,_that.availability,_that.ratingAverage,_that.ratingCount,_that.photoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String name,  String bio,  EducationStatus educationStatus,  String school,  String fieldOfStudy,  List<String> subjectIds,  double pricePerHour,  List<String> availability,  double ratingAverage,  int ratingCount,  String? photoUrl)  $default,) {final _that = this;
switch (_that) {
case _TutorProfile():
return $default(_that.userId,_that.name,_that.bio,_that.educationStatus,_that.school,_that.fieldOfStudy,_that.subjectIds,_that.pricePerHour,_that.availability,_that.ratingAverage,_that.ratingCount,_that.photoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String name,  String bio,  EducationStatus educationStatus,  String school,  String fieldOfStudy,  List<String> subjectIds,  double pricePerHour,  List<String> availability,  double ratingAverage,  int ratingCount,  String? photoUrl)?  $default,) {final _that = this;
switch (_that) {
case _TutorProfile() when $default != null:
return $default(_that.userId,_that.name,_that.bio,_that.educationStatus,_that.school,_that.fieldOfStudy,_that.subjectIds,_that.pricePerHour,_that.availability,_that.ratingAverage,_that.ratingCount,_that.photoUrl);case _:
  return null;

}
}

}

/// @nodoc


class _TutorProfile implements TutorProfile {
  const _TutorProfile({required this.userId, required this.name, required this.bio, required this.educationStatus, required this.school, required this.fieldOfStudy, required  List<String> subjectIds, required this.pricePerHour, required  List<String> availability, required this.ratingAverage, required this.ratingCount, this.photoUrl}): _subjectIds = subjectIds,_availability = availability;


@override final  String userId;
@override final  String name;
@override final  String bio;
@override final  EducationStatus educationStatus;
@override final  String school;
@override final  String fieldOfStudy;
 final  List<String> _subjectIds;
@override List<String> get subjectIds {
  if (_subjectIds is EqualUnmodifiableListView) return _subjectIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subjectIds);
}

@override final  double pricePerHour;
 final  List<String> _availability;
@override List<String> get availability {
  if (_availability is EqualUnmodifiableListView) return _availability;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availability);
}

@override final  double ratingAverage;
@override final  int ratingCount;
@override final  String? photoUrl;

/// Create a copy of TutorProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TutorProfileCopyWith<_TutorProfile> get copyWith => __$TutorProfileCopyWithImpl<_TutorProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TutorProfile&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.educationStatus, educationStatus) || other.educationStatus == educationStatus)&&(identical(other.school, school) || other.school == school)&&(identical(other.fieldOfStudy, fieldOfStudy) || other.fieldOfStudy == fieldOfStudy)&&const DeepCollectionEquality().equals(other.subjectIds, _subjectIds)&&(identical(other.pricePerHour, pricePerHour) || other.pricePerHour == pricePerHour)&&const DeepCollectionEquality().equals(other.availability, _availability)&&(identical(other.ratingAverage, ratingAverage) || other.ratingAverage == ratingAverage)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,name,bio,educationStatus,school,fieldOfStudy,const DeepCollectionEquality().hash(_subjectIds),pricePerHour,const DeepCollectionEquality().hash(_availability),ratingAverage,ratingCount,photoUrl);
}

@override
String toString() {
    return 'TutorProfile(userId: $userId, name: $name, bio: $bio, educationStatus: $educationStatus, school: $school, fieldOfStudy: $fieldOfStudy, subjectIds: $subjectIds, pricePerHour: $pricePerHour, availability: $availability, ratingAverage: $ratingAverage, ratingCount: $ratingCount, photoUrl: $photoUrl)';
}


}

/// @nodoc
abstract mixin class _$TutorProfileCopyWith<$Res> implements $TutorProfileCopyWith<$Res> {
  factory _$TutorProfileCopyWith(_TutorProfile value, $Res Function(_TutorProfile) _then) = __$TutorProfileCopyWithImpl;
@override @useResult
$Res call({
 String userId, String name, String bio, EducationStatus educationStatus, String school, String fieldOfStudy, List<String> subjectIds, double pricePerHour, List<String> availability, double ratingAverage, int ratingCount, String? photoUrl
});




}
/// @nodoc
class __$TutorProfileCopyWithImpl<$Res>
    implements _$TutorProfileCopyWith<$Res> {
  __$TutorProfileCopyWithImpl(this._self, this._then);

  final _TutorProfile _self;
  final $Res Function(_TutorProfile) _then;

/// Create a copy of TutorProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? bio = null,Object? educationStatus = null,Object? school = null,Object? fieldOfStudy = null,Object? subjectIds = null,Object? pricePerHour = null,Object? availability = null,Object? ratingAverage = null,Object? ratingCount = null,Object? photoUrl = freezed,}) {
  return _then(_TutorProfile(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,educationStatus: null == educationStatus ? _self.educationStatus : educationStatus // ignore: cast_nullable_to_non_nullable
as EducationStatus,school: null == school ? _self.school : school // ignore: cast_nullable_to_non_nullable
as String,fieldOfStudy: null == fieldOfStudy ? _self.fieldOfStudy : fieldOfStudy // ignore: cast_nullable_to_non_nullable
as String,subjectIds: null == subjectIds ? _self._subjectIds : subjectIds // ignore: cast_nullable_to_non_nullable
as List<String>,pricePerHour: null == pricePerHour ? _self.pricePerHour : pricePerHour // ignore: cast_nullable_to_non_nullable
as double,availability: null == availability ? _self._availability : availability // ignore: cast_nullable_to_non_nullable
as List<String>,ratingAverage: null == ratingAverage ? _self.ratingAverage : ratingAverage // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
