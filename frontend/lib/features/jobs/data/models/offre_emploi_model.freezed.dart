// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offre_emploi_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OffreEmploiModel _$OffreEmploiModelFromJson(Map<String, dynamic> json) {
  return _OffreEmploiModel.fromJson(json);
}

/// @nodoc
mixin _$OffreEmploiModel {
  String get id => throw _privateConstructorUsedError;
  String get intitule => throw _privateConstructorUsedError;
  String get entreprise =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  JobType get type => throw _privateConstructorUsedError;
  String get domaine =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'niveau_requis')
  String? get niveauRequis => throw _privateConstructorUsedError;
  String get region => throw _privateConstructorUsedError;
  String get description =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'source_url')
  String? get sourceUrl => throw _privateConstructorUsedError;
  String? get source =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_publication')
  DateTime? get datePublication => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_limite')
  DateTime? get dateLimite => throw _privateConstructorUsedError;
  String get statut => throw _privateConstructorUsedError;
  bool get expiree =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'est_favori')
  bool? get estFavori => throw _privateConstructorUsedError;

  /// Serializes this OffreEmploiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OffreEmploiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OffreEmploiModelCopyWith<OffreEmploiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OffreEmploiModelCopyWith<$Res> {
  factory $OffreEmploiModelCopyWith(
    OffreEmploiModel value,
    $Res Function(OffreEmploiModel) then,
  ) = _$OffreEmploiModelCopyWithImpl<$Res, OffreEmploiModel>;
  @useResult
  $Res call({
    String id,
    String intitule,
    String entreprise,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) JobType type,
    String domaine,
    @JsonKey(name: 'niveau_requis') String? niveauRequis,
    String region,
    String description,
    @JsonKey(name: 'source_url') String? sourceUrl,
    String? source,
    @JsonKey(name: 'date_publication') DateTime? datePublication,
    @JsonKey(name: 'date_limite') DateTime? dateLimite,
    String statut,
    bool expiree,
    @JsonKey(name: 'est_favori') bool? estFavori,
  });
}

/// @nodoc
class _$OffreEmploiModelCopyWithImpl<$Res, $Val extends OffreEmploiModel>
    implements $OffreEmploiModelCopyWith<$Res> {
  _$OffreEmploiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OffreEmploiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? intitule = null,
    Object? entreprise = null,
    Object? type = null,
    Object? domaine = null,
    Object? niveauRequis = freezed,
    Object? region = null,
    Object? description = null,
    Object? sourceUrl = freezed,
    Object? source = freezed,
    Object? datePublication = freezed,
    Object? dateLimite = freezed,
    Object? statut = null,
    Object? expiree = null,
    Object? estFavori = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            intitule: null == intitule
                ? _value.intitule
                : intitule // ignore: cast_nullable_to_non_nullable
                      as String,
            entreprise: null == entreprise
                ? _value.entreprise
                : entreprise // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as JobType,
            domaine: null == domaine
                ? _value.domaine
                : domaine // ignore: cast_nullable_to_non_nullable
                      as String,
            niveauRequis: freezed == niveauRequis
                ? _value.niveauRequis
                : niveauRequis // ignore: cast_nullable_to_non_nullable
                      as String?,
            region: null == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            sourceUrl: freezed == sourceUrl
                ? _value.sourceUrl
                : sourceUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
            datePublication: freezed == datePublication
                ? _value.datePublication
                : datePublication // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dateLimite: freezed == dateLimite
                ? _value.dateLimite
                : dateLimite // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            statut: null == statut
                ? _value.statut
                : statut // ignore: cast_nullable_to_non_nullable
                      as String,
            expiree: null == expiree
                ? _value.expiree
                : expiree // ignore: cast_nullable_to_non_nullable
                      as bool,
            estFavori: freezed == estFavori
                ? _value.estFavori
                : estFavori // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OffreEmploiModelImplCopyWith<$Res>
    implements $OffreEmploiModelCopyWith<$Res> {
  factory _$$OffreEmploiModelImplCopyWith(
    _$OffreEmploiModelImpl value,
    $Res Function(_$OffreEmploiModelImpl) then,
  ) = __$$OffreEmploiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String intitule,
    String entreprise,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) JobType type,
    String domaine,
    @JsonKey(name: 'niveau_requis') String? niveauRequis,
    String region,
    String description,
    @JsonKey(name: 'source_url') String? sourceUrl,
    String? source,
    @JsonKey(name: 'date_publication') DateTime? datePublication,
    @JsonKey(name: 'date_limite') DateTime? dateLimite,
    String statut,
    bool expiree,
    @JsonKey(name: 'est_favori') bool? estFavori,
  });
}

/// @nodoc
class __$$OffreEmploiModelImplCopyWithImpl<$Res>
    extends _$OffreEmploiModelCopyWithImpl<$Res, _$OffreEmploiModelImpl>
    implements _$$OffreEmploiModelImplCopyWith<$Res> {
  __$$OffreEmploiModelImplCopyWithImpl(
    _$OffreEmploiModelImpl _value,
    $Res Function(_$OffreEmploiModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OffreEmploiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? intitule = null,
    Object? entreprise = null,
    Object? type = null,
    Object? domaine = null,
    Object? niveauRequis = freezed,
    Object? region = null,
    Object? description = null,
    Object? sourceUrl = freezed,
    Object? source = freezed,
    Object? datePublication = freezed,
    Object? dateLimite = freezed,
    Object? statut = null,
    Object? expiree = null,
    Object? estFavori = freezed,
  }) {
    return _then(
      _$OffreEmploiModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        intitule: null == intitule
            ? _value.intitule
            : intitule // ignore: cast_nullable_to_non_nullable
                  as String,
        entreprise: null == entreprise
            ? _value.entreprise
            : entreprise // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as JobType,
        domaine: null == domaine
            ? _value.domaine
            : domaine // ignore: cast_nullable_to_non_nullable
                  as String,
        niveauRequis: freezed == niveauRequis
            ? _value.niveauRequis
            : niveauRequis // ignore: cast_nullable_to_non_nullable
                  as String?,
        region: null == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceUrl: freezed == sourceUrl
            ? _value.sourceUrl
            : sourceUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        datePublication: freezed == datePublication
            ? _value.datePublication
            : datePublication // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dateLimite: freezed == dateLimite
            ? _value.dateLimite
            : dateLimite // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        statut: null == statut
            ? _value.statut
            : statut // ignore: cast_nullable_to_non_nullable
                  as String,
        expiree: null == expiree
            ? _value.expiree
            : expiree // ignore: cast_nullable_to_non_nullable
                  as bool,
        estFavori: freezed == estFavori
            ? _value.estFavori
            : estFavori // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OffreEmploiModelImpl extends _OffreEmploiModel {
  const _$OffreEmploiModelImpl({
    required this.id,
    required this.intitule,
    required this.entreprise,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) required this.type,
    required this.domaine,
    @JsonKey(name: 'niveau_requis') this.niveauRequis,
    required this.region,
    required this.description,
    @JsonKey(name: 'source_url') this.sourceUrl,
    this.source,
    @JsonKey(name: 'date_publication') this.datePublication,
    @JsonKey(name: 'date_limite') this.dateLimite,
    required this.statut,
    this.expiree = false,
    @JsonKey(name: 'est_favori') this.estFavori,
  }) : super._();

  factory _$OffreEmploiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OffreEmploiModelImplFromJson(json);

  @override
  final String id;
  @override
  final String intitule;
  @override
  final String entreprise;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  final JobType type;
  @override
  final String domaine;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'niveau_requis')
  final String? niveauRequis;
  @override
  final String region;
  @override
  final String description;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'source_url')
  final String? sourceUrl;
  @override
  final String? source;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_publication')
  final DateTime? datePublication;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_limite')
  final DateTime? dateLimite;
  @override
  final String statut;
  @override
  @JsonKey()
  final bool expiree;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'est_favori')
  final bool? estFavori;

  @override
  String toString() {
    return 'OffreEmploiModel(id: $id, intitule: $intitule, entreprise: $entreprise, type: $type, domaine: $domaine, niveauRequis: $niveauRequis, region: $region, description: $description, sourceUrl: $sourceUrl, source: $source, datePublication: $datePublication, dateLimite: $dateLimite, statut: $statut, expiree: $expiree, estFavori: $estFavori)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OffreEmploiModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.intitule, intitule) ||
                other.intitule == intitule) &&
            (identical(other.entreprise, entreprise) ||
                other.entreprise == entreprise) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.domaine, domaine) || other.domaine == domaine) &&
            (identical(other.niveauRequis, niveauRequis) ||
                other.niveauRequis == niveauRequis) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sourceUrl, sourceUrl) ||
                other.sourceUrl == sourceUrl) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.datePublication, datePublication) ||
                other.datePublication == datePublication) &&
            (identical(other.dateLimite, dateLimite) ||
                other.dateLimite == dateLimite) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.expiree, expiree) || other.expiree == expiree) &&
            (identical(other.estFavori, estFavori) ||
                other.estFavori == estFavori));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    intitule,
    entreprise,
    type,
    domaine,
    niveauRequis,
    region,
    description,
    sourceUrl,
    source,
    datePublication,
    dateLimite,
    statut,
    expiree,
    estFavori,
  );

  /// Create a copy of OffreEmploiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OffreEmploiModelImplCopyWith<_$OffreEmploiModelImpl> get copyWith =>
      __$$OffreEmploiModelImplCopyWithImpl<_$OffreEmploiModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OffreEmploiModelImplToJson(this);
  }
}

abstract class _OffreEmploiModel extends OffreEmploiModel {
  const factory _OffreEmploiModel({
    required final String id,
    required final String intitule,
    required final String entreprise,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
    required final JobType type,
    required final String domaine,
    @JsonKey(name: 'niveau_requis') final String? niveauRequis,
    required final String region,
    required final String description,
    @JsonKey(name: 'source_url') final String? sourceUrl,
    final String? source,
    @JsonKey(name: 'date_publication') final DateTime? datePublication,
    @JsonKey(name: 'date_limite') final DateTime? dateLimite,
    required final String statut,
    final bool expiree,
    @JsonKey(name: 'est_favori') final bool? estFavori,
  }) = _$OffreEmploiModelImpl;
  const _OffreEmploiModel._() : super._();

  factory _OffreEmploiModel.fromJson(Map<String, dynamic> json) =
      _$OffreEmploiModelImpl.fromJson;

  @override
  String get id;
  @override
  String get intitule;
  @override
  String get entreprise; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  JobType get type;
  @override
  String get domaine; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'niveau_requis')
  String? get niveauRequis;
  @override
  String get region;
  @override
  String get description; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'source_url')
  String? get sourceUrl;
  @override
  String? get source; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_publication')
  DateTime? get datePublication; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_limite')
  DateTime? get dateLimite;
  @override
  String get statut;
  @override
  bool get expiree; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'est_favori')
  bool? get estFavori;

  /// Create a copy of OffreEmploiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OffreEmploiModelImplCopyWith<_$OffreEmploiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
