// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bourse.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Bourse {
  String get id => throw _privateConstructorUsedError;
  String? get universiteId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String? get organisme => throw _privateConstructorUsedError;
  double? get montant => throw _privateConstructorUsedError;
  String get devise => throw _privateConstructorUsedError;
  String? get conditions => throw _privateConstructorUsedError;
  String? get demarches => throw _privateConstructorUsedError;
  DateTime? get dateLimite => throw _privateConstructorUsedError;
  bool get expiree => throw _privateConstructorUsedError;
  String? get lien => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;
  DateTime? get dateMaj => throw _privateConstructorUsedError;

  /// Create a copy of Bourse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BourseCopyWith<Bourse> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BourseCopyWith<$Res> {
  factory $BourseCopyWith(Bourse value, $Res Function(Bourse) then) =
      _$BourseCopyWithImpl<$Res, Bourse>;
  @useResult
  $Res call({
    String id,
    String? universiteId,
    String nom,
    String? organisme,
    double? montant,
    String devise,
    String? conditions,
    String? demarches,
    DateTime? dateLimite,
    bool expiree,
    String? lien,
    String? source,
    DateTime? dateMaj,
  });
}

/// @nodoc
class _$BourseCopyWithImpl<$Res, $Val extends Bourse>
    implements $BourseCopyWith<$Res> {
  _$BourseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Bourse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? universiteId = freezed,
    Object? nom = null,
    Object? organisme = freezed,
    Object? montant = freezed,
    Object? devise = null,
    Object? conditions = freezed,
    Object? demarches = freezed,
    Object? dateLimite = freezed,
    Object? expiree = null,
    Object? lien = freezed,
    Object? source = freezed,
    Object? dateMaj = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            universiteId: freezed == universiteId
                ? _value.universiteId
                : universiteId // ignore: cast_nullable_to_non_nullable
                      as String?,
            nom: null == nom
                ? _value.nom
                : nom // ignore: cast_nullable_to_non_nullable
                      as String,
            organisme: freezed == organisme
                ? _value.organisme
                : organisme // ignore: cast_nullable_to_non_nullable
                      as String?,
            montant: freezed == montant
                ? _value.montant
                : montant // ignore: cast_nullable_to_non_nullable
                      as double?,
            devise: null == devise
                ? _value.devise
                : devise // ignore: cast_nullable_to_non_nullable
                      as String,
            conditions: freezed == conditions
                ? _value.conditions
                : conditions // ignore: cast_nullable_to_non_nullable
                      as String?,
            demarches: freezed == demarches
                ? _value.demarches
                : demarches // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateLimite: freezed == dateLimite
                ? _value.dateLimite
                : dateLimite // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiree: null == expiree
                ? _value.expiree
                : expiree // ignore: cast_nullable_to_non_nullable
                      as bool,
            lien: freezed == lien
                ? _value.lien
                : lien // ignore: cast_nullable_to_non_nullable
                      as String?,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateMaj: freezed == dateMaj
                ? _value.dateMaj
                : dateMaj // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BourseImplCopyWith<$Res> implements $BourseCopyWith<$Res> {
  factory _$$BourseImplCopyWith(
    _$BourseImpl value,
    $Res Function(_$BourseImpl) then,
  ) = __$$BourseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? universiteId,
    String nom,
    String? organisme,
    double? montant,
    String devise,
    String? conditions,
    String? demarches,
    DateTime? dateLimite,
    bool expiree,
    String? lien,
    String? source,
    DateTime? dateMaj,
  });
}

/// @nodoc
class __$$BourseImplCopyWithImpl<$Res>
    extends _$BourseCopyWithImpl<$Res, _$BourseImpl>
    implements _$$BourseImplCopyWith<$Res> {
  __$$BourseImplCopyWithImpl(
    _$BourseImpl _value,
    $Res Function(_$BourseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Bourse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? universiteId = freezed,
    Object? nom = null,
    Object? organisme = freezed,
    Object? montant = freezed,
    Object? devise = null,
    Object? conditions = freezed,
    Object? demarches = freezed,
    Object? dateLimite = freezed,
    Object? expiree = null,
    Object? lien = freezed,
    Object? source = freezed,
    Object? dateMaj = freezed,
  }) {
    return _then(
      _$BourseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        universiteId: freezed == universiteId
            ? _value.universiteId
            : universiteId // ignore: cast_nullable_to_non_nullable
                  as String?,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        organisme: freezed == organisme
            ? _value.organisme
            : organisme // ignore: cast_nullable_to_non_nullable
                  as String?,
        montant: freezed == montant
            ? _value.montant
            : montant // ignore: cast_nullable_to_non_nullable
                  as double?,
        devise: null == devise
            ? _value.devise
            : devise // ignore: cast_nullable_to_non_nullable
                  as String,
        conditions: freezed == conditions
            ? _value.conditions
            : conditions // ignore: cast_nullable_to_non_nullable
                  as String?,
        demarches: freezed == demarches
            ? _value.demarches
            : demarches // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateLimite: freezed == dateLimite
            ? _value.dateLimite
            : dateLimite // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiree: null == expiree
            ? _value.expiree
            : expiree // ignore: cast_nullable_to_non_nullable
                  as bool,
        lien: freezed == lien
            ? _value.lien
            : lien // ignore: cast_nullable_to_non_nullable
                  as String?,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateMaj: freezed == dateMaj
            ? _value.dateMaj
            : dateMaj // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$BourseImpl implements _Bourse {
  const _$BourseImpl({
    required this.id,
    this.universiteId,
    required this.nom,
    this.organisme,
    this.montant,
    this.devise = 'XOF',
    this.conditions,
    this.demarches,
    this.dateLimite,
    this.expiree = false,
    this.lien,
    this.source,
    this.dateMaj,
  });

  @override
  final String id;
  @override
  final String? universiteId;
  @override
  final String nom;
  @override
  final String? organisme;
  @override
  final double? montant;
  @override
  @JsonKey()
  final String devise;
  @override
  final String? conditions;
  @override
  final String? demarches;
  @override
  final DateTime? dateLimite;
  @override
  @JsonKey()
  final bool expiree;
  @override
  final String? lien;
  @override
  final String? source;
  @override
  final DateTime? dateMaj;

  @override
  String toString() {
    return 'Bourse(id: $id, universiteId: $universiteId, nom: $nom, organisme: $organisme, montant: $montant, devise: $devise, conditions: $conditions, demarches: $demarches, dateLimite: $dateLimite, expiree: $expiree, lien: $lien, source: $source, dateMaj: $dateMaj)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BourseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.universiteId, universiteId) ||
                other.universiteId == universiteId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.organisme, organisme) ||
                other.organisme == organisme) &&
            (identical(other.montant, montant) || other.montant == montant) &&
            (identical(other.devise, devise) || other.devise == devise) &&
            (identical(other.conditions, conditions) ||
                other.conditions == conditions) &&
            (identical(other.demarches, demarches) ||
                other.demarches == demarches) &&
            (identical(other.dateLimite, dateLimite) ||
                other.dateLimite == dateLimite) &&
            (identical(other.expiree, expiree) || other.expiree == expiree) &&
            (identical(other.lien, lien) || other.lien == lien) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.dateMaj, dateMaj) || other.dateMaj == dateMaj));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    universiteId,
    nom,
    organisme,
    montant,
    devise,
    conditions,
    demarches,
    dateLimite,
    expiree,
    lien,
    source,
    dateMaj,
  );

  /// Create a copy of Bourse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BourseImplCopyWith<_$BourseImpl> get copyWith =>
      __$$BourseImplCopyWithImpl<_$BourseImpl>(this, _$identity);
}

abstract class _Bourse implements Bourse {
  const factory _Bourse({
    required final String id,
    final String? universiteId,
    required final String nom,
    final String? organisme,
    final double? montant,
    final String devise,
    final String? conditions,
    final String? demarches,
    final DateTime? dateLimite,
    final bool expiree,
    final String? lien,
    final String? source,
    final DateTime? dateMaj,
  }) = _$BourseImpl;

  @override
  String get id;
  @override
  String? get universiteId;
  @override
  String get nom;
  @override
  String? get organisme;
  @override
  double? get montant;
  @override
  String get devise;
  @override
  String? get conditions;
  @override
  String? get demarches;
  @override
  DateTime? get dateLimite;
  @override
  bool get expiree;
  @override
  String? get lien;
  @override
  String? get source;
  @override
  DateTime? get dateMaj;

  /// Create a copy of Bourse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BourseImplCopyWith<_$BourseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
