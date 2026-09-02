// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bourse_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BourseModel _$BourseModelFromJson(Map<String, dynamic> json) {
  return _BourseModel.fromJson(json);
}

/// @nodoc
mixin _$BourseModel {
  String get id =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'universite_id')
  String? get universiteId => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String? get organisme =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  double? get montant => throw _privateConstructorUsedError;
  String get devise => throw _privateConstructorUsedError;
  String? get conditions => throw _privateConstructorUsedError;
  String? get demarches =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_limite')
  DateTime? get dateLimite => throw _privateConstructorUsedError;
  bool get expiree => throw _privateConstructorUsedError;
  String? get lien => throw _privateConstructorUsedError;
  String? get source =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_maj')
  DateTime? get dateMaj => throw _privateConstructorUsedError;

  /// Serializes this BourseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BourseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BourseModelCopyWith<BourseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BourseModelCopyWith<$Res> {
  factory $BourseModelCopyWith(
    BourseModel value,
    $Res Function(BourseModel) then,
  ) = _$BourseModelCopyWithImpl<$Res, BourseModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'universite_id') String? universiteId,
    String nom,
    String? organisme,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    double? montant,
    String devise,
    String? conditions,
    String? demarches,
    @JsonKey(name: 'date_limite') DateTime? dateLimite,
    bool expiree,
    String? lien,
    String? source,
    @JsonKey(name: 'date_maj') DateTime? dateMaj,
  });
}

/// @nodoc
class _$BourseModelCopyWithImpl<$Res, $Val extends BourseModel>
    implements $BourseModelCopyWith<$Res> {
  _$BourseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BourseModel
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
abstract class _$$BourseModelImplCopyWith<$Res>
    implements $BourseModelCopyWith<$Res> {
  factory _$$BourseModelImplCopyWith(
    _$BourseModelImpl value,
    $Res Function(_$BourseModelImpl) then,
  ) = __$$BourseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'universite_id') String? universiteId,
    String nom,
    String? organisme,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    double? montant,
    String devise,
    String? conditions,
    String? demarches,
    @JsonKey(name: 'date_limite') DateTime? dateLimite,
    bool expiree,
    String? lien,
    String? source,
    @JsonKey(name: 'date_maj') DateTime? dateMaj,
  });
}

/// @nodoc
class __$$BourseModelImplCopyWithImpl<$Res>
    extends _$BourseModelCopyWithImpl<$Res, _$BourseModelImpl>
    implements _$$BourseModelImplCopyWith<$Res> {
  __$$BourseModelImplCopyWithImpl(
    _$BourseModelImpl _value,
    $Res Function(_$BourseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BourseModel
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
      _$BourseModelImpl(
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
@JsonSerializable()
class _$BourseModelImpl extends _BourseModel {
  const _$BourseModelImpl({
    required this.id,
    @JsonKey(name: 'universite_id') this.universiteId,
    required this.nom,
    this.organisme,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) this.montant,
    this.devise = 'XOF',
    this.conditions,
    this.demarches,
    @JsonKey(name: 'date_limite') this.dateLimite,
    this.expiree = false,
    this.lien,
    this.source,
    @JsonKey(name: 'date_maj') this.dateMaj,
  }) : super._();

  factory _$BourseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BourseModelImplFromJson(json);

  @override
  final String id;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_id')
  final String? universiteId;
  @override
  final String nom;
  @override
  final String? organisme;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  final double? montant;
  @override
  @JsonKey()
  final String devise;
  @override
  final String? conditions;
  @override
  final String? demarches;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_limite')
  final DateTime? dateLimite;
  @override
  @JsonKey()
  final bool expiree;
  @override
  final String? lien;
  @override
  final String? source;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_maj')
  final DateTime? dateMaj;

  @override
  String toString() {
    return 'BourseModel(id: $id, universiteId: $universiteId, nom: $nom, organisme: $organisme, montant: $montant, devise: $devise, conditions: $conditions, demarches: $demarches, dateLimite: $dateLimite, expiree: $expiree, lien: $lien, source: $source, dateMaj: $dateMaj)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BourseModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of BourseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BourseModelImplCopyWith<_$BourseModelImpl> get copyWith =>
      __$$BourseModelImplCopyWithImpl<_$BourseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BourseModelImplToJson(this);
  }
}

abstract class _BourseModel extends BourseModel {
  const factory _BourseModel({
    required final String id,
    @JsonKey(name: 'universite_id') final String? universiteId,
    required final String nom,
    final String? organisme,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    final double? montant,
    final String devise,
    final String? conditions,
    final String? demarches,
    @JsonKey(name: 'date_limite') final DateTime? dateLimite,
    final bool expiree,
    final String? lien,
    final String? source,
    @JsonKey(name: 'date_maj') final DateTime? dateMaj,
  }) = _$BourseModelImpl;
  const _BourseModel._() : super._();

  factory _BourseModel.fromJson(Map<String, dynamic> json) =
      _$BourseModelImpl.fromJson;

  @override
  String get id; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_id')
  String? get universiteId;
  @override
  String get nom;
  @override
  String? get organisme; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  double? get montant;
  @override
  String get devise;
  @override
  String? get conditions;
  @override
  String? get demarches; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_limite')
  DateTime? get dateLimite;
  @override
  bool get expiree;
  @override
  String? get lien;
  @override
  String? get source; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_maj')
  DateTime? get dateMaj;

  /// Create a copy of BourseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BourseModelImplCopyWith<_$BourseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
