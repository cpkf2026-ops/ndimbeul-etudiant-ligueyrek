// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AdminUserModel _$AdminUserModelFromJson(Map<String, dynamic> json) {
  return _AdminUserModel.fromJson(json);
}

/// @nodoc
mixin _$AdminUserModel {
  String get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String get prenom => throw _privateConstructorUsedError;
  String get email =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson)
  UserRole get role => throw _privateConstructorUsedError;
  String? get region =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
  UserStatut get statut => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_inscription')
  DateTime? get dateInscription => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_derniere_connexion')
  DateTime? get dateDerniereConnexion => throw _privateConstructorUsedError;

  /// Serializes this AdminUserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminUserModelCopyWith<AdminUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminUserModelCopyWith<$Res> {
  factory $AdminUserModelCopyWith(
    AdminUserModel value,
    $Res Function(AdminUserModel) then,
  ) = _$AdminUserModelCopyWithImpl<$Res, AdminUserModel>;
  @useResult
  $Res call({
    String id,
    String nom,
    String prenom,
    String email,
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson) UserRole role,
    String? region,
    @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
    UserStatut statut,
    @JsonKey(name: 'date_inscription') DateTime? dateInscription,
    @JsonKey(name: 'date_derniere_connexion') DateTime? dateDerniereConnexion,
  });
}

/// @nodoc
class _$AdminUserModelCopyWithImpl<$Res, $Val extends AdminUserModel>
    implements $AdminUserModelCopyWith<$Res> {
  _$AdminUserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? prenom = null,
    Object? email = null,
    Object? role = null,
    Object? region = freezed,
    Object? statut = null,
    Object? dateInscription = freezed,
    Object? dateDerniereConnexion = freezed,
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
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as UserRole,
            region: freezed == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String?,
            statut: null == statut
                ? _value.statut
                : statut // ignore: cast_nullable_to_non_nullable
                      as UserStatut,
            dateInscription: freezed == dateInscription
                ? _value.dateInscription
                : dateInscription // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dateDerniereConnexion: freezed == dateDerniereConnexion
                ? _value.dateDerniereConnexion
                : dateDerniereConnexion // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminUserModelImplCopyWith<$Res>
    implements $AdminUserModelCopyWith<$Res> {
  factory _$$AdminUserModelImplCopyWith(
    _$AdminUserModelImpl value,
    $Res Function(_$AdminUserModelImpl) then,
  ) = __$$AdminUserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nom,
    String prenom,
    String email,
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson) UserRole role,
    String? region,
    @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
    UserStatut statut,
    @JsonKey(name: 'date_inscription') DateTime? dateInscription,
    @JsonKey(name: 'date_derniere_connexion') DateTime? dateDerniereConnexion,
  });
}

/// @nodoc
class __$$AdminUserModelImplCopyWithImpl<$Res>
    extends _$AdminUserModelCopyWithImpl<$Res, _$AdminUserModelImpl>
    implements _$$AdminUserModelImplCopyWith<$Res> {
  __$$AdminUserModelImplCopyWithImpl(
    _$AdminUserModelImpl _value,
    $Res Function(_$AdminUserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? prenom = null,
    Object? email = null,
    Object? role = null,
    Object? region = freezed,
    Object? statut = null,
    Object? dateInscription = freezed,
    Object? dateDerniereConnexion = freezed,
  }) {
    return _then(
      _$AdminUserModelImpl(
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
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as UserRole,
        region: freezed == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String?,
        statut: null == statut
            ? _value.statut
            : statut // ignore: cast_nullable_to_non_nullable
                  as UserStatut,
        dateInscription: freezed == dateInscription
            ? _value.dateInscription
            : dateInscription // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dateDerniereConnexion: freezed == dateDerniereConnexion
            ? _value.dateDerniereConnexion
            : dateDerniereConnexion // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminUserModelImpl extends _AdminUserModel {
  const _$AdminUserModelImpl({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson) required this.role,
    this.region,
    @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
    this.statut = UserStatut.actif,
    @JsonKey(name: 'date_inscription') this.dateInscription,
    @JsonKey(name: 'date_derniere_connexion') this.dateDerniereConnexion,
  }) : super._();

  factory _$AdminUserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminUserModelImplFromJson(json);

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
  final UserRole role;
  @override
  final String? region;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
  final UserStatut statut;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_inscription')
  final DateTime? dateInscription;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_derniere_connexion')
  final DateTime? dateDerniereConnexion;

  @override
  String toString() {
    return 'AdminUserModel(id: $id, nom: $nom, prenom: $prenom, email: $email, role: $role, region: $region, statut: $statut, dateInscription: $dateInscription, dateDerniereConnexion: $dateDerniereConnexion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminUserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.prenom, prenom) || other.prenom == prenom) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.dateInscription, dateInscription) ||
                other.dateInscription == dateInscription) &&
            (identical(other.dateDerniereConnexion, dateDerniereConnexion) ||
                other.dateDerniereConnexion == dateDerniereConnexion));
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
    statut,
    dateInscription,
    dateDerniereConnexion,
  );

  /// Create a copy of AdminUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminUserModelImplCopyWith<_$AdminUserModelImpl> get copyWith =>
      __$$AdminUserModelImplCopyWithImpl<_$AdminUserModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminUserModelImplToJson(this);
  }
}

abstract class _AdminUserModel extends AdminUserModel {
  const factory _AdminUserModel({
    required final String id,
    required final String nom,
    required final String prenom,
    required final String email,
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson)
    required final UserRole role,
    final String? region,
    @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
    final UserStatut statut,
    @JsonKey(name: 'date_inscription') final DateTime? dateInscription,
    @JsonKey(name: 'date_derniere_connexion')
    final DateTime? dateDerniereConnexion,
  }) = _$AdminUserModelImpl;
  const _AdminUserModel._() : super._();

  factory _AdminUserModel.fromJson(Map<String, dynamic> json) =
      _$AdminUserModelImpl.fromJson;

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
  UserRole get role;
  @override
  String? get region; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
  UserStatut get statut; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_inscription')
  DateTime? get dateInscription; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_derniere_connexion')
  DateTime? get dateDerniereConnexion;

  /// Create a copy of AdminUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminUserModelImplCopyWith<_$AdminUserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
