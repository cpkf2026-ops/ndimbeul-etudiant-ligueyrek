// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String get prenom => throw _privateConstructorUsedError;
  String get email =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson)
  UserRole? get role => throw _privateConstructorUsedError;
  String? get region =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'profil_complete')
  bool get profilComplete => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_inscription')
  DateTime get dateInscription => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String id,
    String nom,
    String prenom,
    String email,
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson) UserRole? role,
    String? region,
    @JsonKey(name: 'profil_complete') bool profilComplete,
    @JsonKey(name: 'date_inscription') DateTime dateInscription,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? prenom = null,
    Object? email = null,
    Object? role = freezed,
    Object? region = freezed,
    Object? profilComplete = null,
    Object? dateInscription = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nom: null == nom
                ? _value.nom
                : nom // ignore: cast_nullable_to_non_nullable
                      as String,
            prenom: null == prenom
                ? _value.prenom
                : prenom // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as UserRole?,
            region: freezed == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String?,
            profilComplete: null == profilComplete
                ? _value.profilComplete
                : profilComplete // ignore: cast_nullable_to_non_nullable
                      as bool,
            dateInscription: null == dateInscription
                ? _value.dateInscription
                : dateInscription // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nom,
    String prenom,
    String email,
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson) UserRole? role,
    String? region,
    @JsonKey(name: 'profil_complete') bool profilComplete,
    @JsonKey(name: 'date_inscription') DateTime dateInscription,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? prenom = null,
    Object? email = null,
    Object? role = freezed,
    Object? region = freezed,
    Object? profilComplete = null,
    Object? dateInscription = null,
  }) {
    return _then(
      _$UserModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        prenom: null == prenom
            ? _value.prenom
            : prenom // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as UserRole?,
        region: freezed == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String?,
        profilComplete: null == profilComplete
            ? _value.profilComplete
            : profilComplete // ignore: cast_nullable_to_non_nullable
                  as bool,
        dateInscription: null == dateInscription
            ? _value.dateInscription
            : dateInscription // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson) this.role,
    this.region,
    @JsonKey(name: 'profil_complete') this.profilComplete = false,
    @JsonKey(name: 'date_inscription') required this.dateInscription,
  }) : super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String nom;
  @override
  final String prenom;
  @override
  final String email;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson)
  final UserRole? role;
  @override
  final String? region;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'profil_complete')
  final bool profilComplete;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_inscription')
  final DateTime dateInscription;

  @override
  String toString() {
    return 'UserModel(id: $id, nom: $nom, prenom: $prenom, email: $email, role: $role, region: $region, profilComplete: $profilComplete, dateInscription: $dateInscription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.prenom, prenom) || other.prenom == prenom) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.profilComplete, profilComplete) ||
                other.profilComplete == profilComplete) &&
            (identical(other.dateInscription, dateInscription) ||
                other.dateInscription == dateInscription));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nom,
    prenom,
    email,
    role,
    region,
    profilComplete,
    dateInscription,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel({
    required final String id,
    required final String nom,
    required final String prenom,
    required final String email,
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson) final UserRole? role,
    final String? region,
    @JsonKey(name: 'profil_complete') final bool profilComplete,
    @JsonKey(name: 'date_inscription') required final DateTime dateInscription,
  }) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get nom;
  @override
  String get prenom;
  @override
  String get email; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson)
  UserRole? get role;
  @override
  String? get region; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'profil_complete')
  bool get profilComplete; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_inscription')
  DateTime get dateInscription;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
