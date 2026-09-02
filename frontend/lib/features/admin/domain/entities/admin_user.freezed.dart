// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AdminUser {
  String get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String get prenom => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  String? get region => throw _privateConstructorUsedError;
  UserStatut get statut => throw _privateConstructorUsedError;
  DateTime? get dateInscription => throw _privateConstructorUsedError;
  DateTime? get dateDerniereConnexion => throw _privateConstructorUsedError;

  /// Create a copy of AdminUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminUserCopyWith<AdminUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminUserCopyWith<$Res> {
  factory $AdminUserCopyWith(AdminUser value, $Res Function(AdminUser) then) =
      _$AdminUserCopyWithImpl<$Res, AdminUser>;
  @useResult
  $Res call({
    String id,
    String nom,
    String prenom,
    String email,
    UserRole role,
    String? region,
    UserStatut statut,
    DateTime? dateInscription,
    DateTime? dateDerniereConnexion,
  });
}

/// @nodoc
class _$AdminUserCopyWithImpl<$Res, $Val extends AdminUser>
    implements $AdminUserCopyWith<$Res> {
  _$AdminUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminUser
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
abstract class _$$AdminUserImplCopyWith<$Res>
    implements $AdminUserCopyWith<$Res> {
  factory _$$AdminUserImplCopyWith(
    _$AdminUserImpl value,
    $Res Function(_$AdminUserImpl) then,
  ) = __$$AdminUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nom,
    String prenom,
    String email,
    UserRole role,
    String? region,
    UserStatut statut,
    DateTime? dateInscription,
    DateTime? dateDerniereConnexion,
  });
}

/// @nodoc
class __$$AdminUserImplCopyWithImpl<$Res>
    extends _$AdminUserCopyWithImpl<$Res, _$AdminUserImpl>
    implements _$$AdminUserImplCopyWith<$Res> {
  __$$AdminUserImplCopyWithImpl(
    _$AdminUserImpl _value,
    $Res Function(_$AdminUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminUser
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
      _$AdminUserImpl(
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

class _$AdminUserImpl extends _AdminUser {
  const _$AdminUserImpl({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    this.region,
    required this.statut,
    this.dateInscription,
    this.dateDerniereConnexion,
  }) : super._();

  @override
  final String id;
  @override
  final String nom;
  @override
  final String prenom;
  @override
  final String email;
  @override
  final UserRole role;
  @override
  final String? region;
  @override
  final UserStatut statut;
  @override
  final DateTime? dateInscription;
  @override
  final DateTime? dateDerniereConnexion;

  @override
  String toString() {
    return 'AdminUser(id: $id, nom: $nom, prenom: $prenom, email: $email, role: $role, region: $region, statut: $statut, dateInscription: $dateInscription, dateDerniereConnexion: $dateDerniereConnexion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminUserImpl &&
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

  /// Create a copy of AdminUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminUserImplCopyWith<_$AdminUserImpl> get copyWith =>
      __$$AdminUserImplCopyWithImpl<_$AdminUserImpl>(this, _$identity);
}

abstract class _AdminUser extends AdminUser {
  const factory _AdminUser({
    required final String id,
    required final String nom,
    required final String prenom,
    required final String email,
    required final UserRole role,
    final String? region,
    required final UserStatut statut,
    final DateTime? dateInscription,
    final DateTime? dateDerniereConnexion,
  }) = _$AdminUserImpl;
  const _AdminUser._() : super._();

  @override
  String get id;
  @override
  String get nom;
  @override
  String get prenom;
  @override
  String get email;
  @override
  UserRole get role;
  @override
  String? get region;
  @override
  UserStatut get statut;
  @override
  DateTime? get dateInscription;
  @override
  DateTime? get dateDerniereConnexion;

  /// Create a copy of AdminUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminUserImplCopyWith<_$AdminUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
