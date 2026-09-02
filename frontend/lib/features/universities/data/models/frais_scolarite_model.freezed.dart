// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'frais_scolarite_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FraisScolariteModel _$FraisScolariteModelFromJson(Map<String, dynamic> json) {
  return _FraisScolariteModel.fromJson(json);
}

/// @nodoc
mixin _$FraisScolariteModel {
  String get id =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'universite_id')
  String get universiteId => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'formation_id')
  String? get formationId => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  double get montant => throw _privateConstructorUsedError;
  String get devise => throw _privateConstructorUsedError;
  List<dynamic>? get echeancier =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'moyens_paiement')
  List<String>? get moyensPaiement => throw _privateConstructorUsedError;
  String? get source =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_maj')
  DateTime? get dateMaj => throw _privateConstructorUsedError;

  /// Serializes this FraisScolariteModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FraisScolariteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FraisScolariteModelCopyWith<FraisScolariteModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FraisScolariteModelCopyWith<$Res> {
  factory $FraisScolariteModelCopyWith(
    FraisScolariteModel value,
    $Res Function(FraisScolariteModel) then,
  ) = _$FraisScolariteModelCopyWithImpl<$Res, FraisScolariteModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'universite_id') String universiteId,
    @JsonKey(name: 'formation_id') String? formationId,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) double montant,
    String devise,
    List<dynamic>? echeancier,
    @JsonKey(name: 'moyens_paiement') List<String>? moyensPaiement,
    String? source,
    @JsonKey(name: 'date_maj') DateTime? dateMaj,
  });
}

/// @nodoc
class _$FraisScolariteModelCopyWithImpl<$Res, $Val extends FraisScolariteModel>
    implements $FraisScolariteModelCopyWith<$Res> {
  _$FraisScolariteModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FraisScolariteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? universiteId = null,
    Object? formationId = freezed,
    Object? montant = null,
    Object? devise = null,
    Object? echeancier = freezed,
    Object? moyensPaiement = freezed,
    Object? source = freezed,
    Object? dateMaj = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            universiteId: null == universiteId
                ? _value.universiteId
                : universiteId // ignore: cast_nullable_to_non_nullable
                      as String,
            formationId: freezed == formationId
                ? _value.formationId
                : formationId // ignore: cast_nullable_to_non_nullable
                      as String?,
            montant: null == montant
                ? _value.montant
                : montant // ignore: cast_nullable_to_non_nullable
                      as double,
            devise: null == devise
                ? _value.devise
                : devise // ignore: cast_nullable_to_non_nullable
                      as String,
            echeancier: freezed == echeancier
                ? _value.echeancier
                : echeancier // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            moyensPaiement: freezed == moyensPaiement
                ? _value.moyensPaiement
                : moyensPaiement // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
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
abstract class _$$FraisScolariteModelImplCopyWith<$Res>
    implements $FraisScolariteModelCopyWith<$Res> {
  factory _$$FraisScolariteModelImplCopyWith(
    _$FraisScolariteModelImpl value,
    $Res Function(_$FraisScolariteModelImpl) then,
  ) = __$$FraisScolariteModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'universite_id') String universiteId,
    @JsonKey(name: 'formation_id') String? formationId,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson) double montant,
    String devise,
    List<dynamic>? echeancier,
    @JsonKey(name: 'moyens_paiement') List<String>? moyensPaiement,
    String? source,
    @JsonKey(name: 'date_maj') DateTime? dateMaj,
  });
}

/// @nodoc
class __$$FraisScolariteModelImplCopyWithImpl<$Res>
    extends _$FraisScolariteModelCopyWithImpl<$Res, _$FraisScolariteModelImpl>
    implements _$$FraisScolariteModelImplCopyWith<$Res> {
  __$$FraisScolariteModelImplCopyWithImpl(
    _$FraisScolariteModelImpl _value,
    $Res Function(_$FraisScolariteModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FraisScolariteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? universiteId = null,
    Object? formationId = freezed,
    Object? montant = null,
    Object? devise = null,
    Object? echeancier = freezed,
    Object? moyensPaiement = freezed,
    Object? source = freezed,
    Object? dateMaj = freezed,
  }) {
    return _then(
      _$FraisScolariteModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        universiteId: null == universiteId
            ? _value.universiteId
            : universiteId // ignore: cast_nullable_to_non_nullable
                  as String,
        formationId: freezed == formationId
            ? _value.formationId
            : formationId // ignore: cast_nullable_to_non_nullable
                  as String?,
        montant: null == montant
            ? _value.montant
            : montant // ignore: cast_nullable_to_non_nullable
                  as double,
        devise: null == devise
            ? _value.devise
            : devise // ignore: cast_nullable_to_non_nullable
                  as String,
        echeancier: freezed == echeancier
            ? _value._echeancier
            : echeancier // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        moyensPaiement: freezed == moyensPaiement
            ? _value._moyensPaiement
            : moyensPaiement // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
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
class _$FraisScolariteModelImpl extends _FraisScolariteModel {
  const _$FraisScolariteModelImpl({
    required this.id,
    @JsonKey(name: 'universite_id') required this.universiteId,
    @JsonKey(name: 'formation_id') this.formationId,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    required this.montant,
    this.devise = 'XOF',
    final List<dynamic>? echeancier,
    @JsonKey(name: 'moyens_paiement') final List<String>? moyensPaiement,
    this.source,
    @JsonKey(name: 'date_maj') this.dateMaj,
  }) : _echeancier = echeancier,
       _moyensPaiement = moyensPaiement,
       super._();

  factory _$FraisScolariteModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FraisScolariteModelImplFromJson(json);

  @override
  final String id;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_id')
  final String universiteId;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'formation_id')
  final String? formationId;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  final double montant;
  @override
  @JsonKey()
  final String devise;
  final List<dynamic>? _echeancier;
  @override
  List<dynamic>? get echeancier {
    final value = _echeancier;
    if (value == null) return null;
    if (_echeancier is EqualUnmodifiableListView) return _echeancier;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // ignore: invalid_annotation_target
  final List<String>? _moyensPaiement;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'moyens_paiement')
  List<String>? get moyensPaiement {
    final value = _moyensPaiement;
    if (value == null) return null;
    if (_moyensPaiement is EqualUnmodifiableListView) return _moyensPaiement;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? source;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_maj')
  final DateTime? dateMaj;

  @override
  String toString() {
    return 'FraisScolariteModel(id: $id, universiteId: $universiteId, formationId: $formationId, montant: $montant, devise: $devise, echeancier: $echeancier, moyensPaiement: $moyensPaiement, source: $source, dateMaj: $dateMaj)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FraisScolariteModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.universiteId, universiteId) ||
                other.universiteId == universiteId) &&
            (identical(other.formationId, formationId) ||
                other.formationId == formationId) &&
            (identical(other.montant, montant) || other.montant == montant) &&
            (identical(other.devise, devise) || other.devise == devise) &&
            const DeepCollectionEquality().equals(
              other._echeancier,
              _echeancier,
            ) &&
            const DeepCollectionEquality().equals(
              other._moyensPaiement,
              _moyensPaiement,
            ) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.dateMaj, dateMaj) || other.dateMaj == dateMaj));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    universiteId,
    formationId,
    montant,
    devise,
    const DeepCollectionEquality().hash(_echeancier),
    const DeepCollectionEquality().hash(_moyensPaiement),
    source,
    dateMaj,
  );

  /// Create a copy of FraisScolariteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FraisScolariteModelImplCopyWith<_$FraisScolariteModelImpl> get copyWith =>
      __$$FraisScolariteModelImplCopyWithImpl<_$FraisScolariteModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FraisScolariteModelImplToJson(this);
  }
}

abstract class _FraisScolariteModel extends FraisScolariteModel {
  const factory _FraisScolariteModel({
    required final String id,
    @JsonKey(name: 'universite_id') required final String universiteId,
    @JsonKey(name: 'formation_id') final String? formationId,
    @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
    required final double montant,
    final String devise,
    final List<dynamic>? echeancier,
    @JsonKey(name: 'moyens_paiement') final List<String>? moyensPaiement,
    final String? source,
    @JsonKey(name: 'date_maj') final DateTime? dateMaj,
  }) = _$FraisScolariteModelImpl;
  const _FraisScolariteModel._() : super._();

  factory _FraisScolariteModel.fromJson(Map<String, dynamic> json) =
      _$FraisScolariteModelImpl.fromJson;

  @override
  String get id; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_id')
  String get universiteId; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'formation_id')
  String? get formationId; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _decimalFromJson, toJson: _decimalToJson)
  double get montant;
  @override
  String get devise;
  @override
  List<dynamic>? get echeancier; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'moyens_paiement')
  List<String>? get moyensPaiement;
  @override
  String? get source; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_maj')
  DateTime? get dateMaj;

  /// Create a copy of FraisScolariteModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FraisScolariteModelImplCopyWith<_$FraisScolariteModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
