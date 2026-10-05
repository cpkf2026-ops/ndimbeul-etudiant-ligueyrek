// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offre_emploi.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OffreEmploi {
  String get id => throw _privateConstructorUsedError;
  String get intitule => throw _privateConstructorUsedError;
  String get entreprise => throw _privateConstructorUsedError;
  JobType get type => throw _privateConstructorUsedError;
  String get domaine => throw _privateConstructorUsedError;
  String? get niveauRequis => throw _privateConstructorUsedError;
  String get region => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get sourceUrl => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;

  /// Fiabilité de la source vérifiée par la veille IA : 'officiel', 'presse'
  /// ou 'plateforme' (null pour les données de démonstration).
  String? get fiabilite => throw _privateConstructorUsedError;
  DateTime? get datePublication => throw _privateConstructorUsedError;
  DateTime? get dateLimite => throw _privateConstructorUsedError;
  DateTime? get dateIndexation => throw _privateConstructorUsedError;
  String get statut => throw _privateConstructorUsedError;
  bool get expiree => throw _privateConstructorUsedError;
  bool get estFavori => throw _privateConstructorUsedError;

  /// Create a copy of OffreEmploi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OffreEmploiCopyWith<OffreEmploi> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OffreEmploiCopyWith<$Res> {
  factory $OffreEmploiCopyWith(
    OffreEmploi value,
    $Res Function(OffreEmploi) then,
  ) = _$OffreEmploiCopyWithImpl<$Res, OffreEmploi>;
  @useResult
  $Res call({
    String id,
    String intitule,
    String entreprise,
    JobType type,
    String domaine,
    String? niveauRequis,
    String region,
    String description,
    String? sourceUrl,
    String? source,
    String? fiabilite,
    DateTime? datePublication,
    DateTime? dateLimite,
    DateTime? dateIndexation,
    String statut,
    bool expiree,
    bool estFavori,
  });
}

/// @nodoc
class _$OffreEmploiCopyWithImpl<$Res, $Val extends OffreEmploi>
    implements $OffreEmploiCopyWith<$Res> {
  _$OffreEmploiCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OffreEmploi
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
    Object? fiabilite = freezed,
    Object? datePublication = freezed,
    Object? dateLimite = freezed,
    Object? dateIndexation = freezed,
    Object? statut = null,
    Object? expiree = null,
    Object? estFavori = null,
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
            fiabilite: freezed == fiabilite
                ? _value.fiabilite
                : fiabilite // ignore: cast_nullable_to_non_nullable
                      as String?,
            datePublication: freezed == datePublication
                ? _value.datePublication
                : datePublication // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dateLimite: freezed == dateLimite
                ? _value.dateLimite
                : dateLimite // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dateIndexation: freezed == dateIndexation
                ? _value.dateIndexation
                : dateIndexation // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            statut: null == statut
                ? _value.statut
                : statut // ignore: cast_nullable_to_non_nullable
                      as String,
            expiree: null == expiree
                ? _value.expiree
                : expiree // ignore: cast_nullable_to_non_nullable
                      as bool,
            estFavori: null == estFavori
                ? _value.estFavori
                : estFavori // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OffreEmploiImplCopyWith<$Res>
    implements $OffreEmploiCopyWith<$Res> {
  factory _$$OffreEmploiImplCopyWith(
    _$OffreEmploiImpl value,
    $Res Function(_$OffreEmploiImpl) then,
  ) = __$$OffreEmploiImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String intitule,
    String entreprise,
    JobType type,
    String domaine,
    String? niveauRequis,
    String region,
    String description,
    String? sourceUrl,
    String? source,
    String? fiabilite,
    DateTime? datePublication,
    DateTime? dateLimite,
    DateTime? dateIndexation,
    String statut,
    bool expiree,
    bool estFavori,
  });
}

/// @nodoc
class __$$OffreEmploiImplCopyWithImpl<$Res>
    extends _$OffreEmploiCopyWithImpl<$Res, _$OffreEmploiImpl>
    implements _$$OffreEmploiImplCopyWith<$Res> {
  __$$OffreEmploiImplCopyWithImpl(
    _$OffreEmploiImpl _value,
    $Res Function(_$OffreEmploiImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OffreEmploi
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
    Object? fiabilite = freezed,
    Object? datePublication = freezed,
    Object? dateLimite = freezed,
    Object? dateIndexation = freezed,
    Object? statut = null,
    Object? expiree = null,
    Object? estFavori = null,
  }) {
    return _then(
      _$OffreEmploiImpl(
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
        fiabilite: freezed == fiabilite
            ? _value.fiabilite
            : fiabilite // ignore: cast_nullable_to_non_nullable
                  as String?,
        datePublication: freezed == datePublication
            ? _value.datePublication
            : datePublication // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dateLimite: freezed == dateLimite
            ? _value.dateLimite
            : dateLimite // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dateIndexation: freezed == dateIndexation
            ? _value.dateIndexation
            : dateIndexation // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        statut: null == statut
            ? _value.statut
            : statut // ignore: cast_nullable_to_non_nullable
                  as String,
        expiree: null == expiree
            ? _value.expiree
            : expiree // ignore: cast_nullable_to_non_nullable
                  as bool,
        estFavori: null == estFavori
            ? _value.estFavori
            : estFavori // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$OffreEmploiImpl extends _OffreEmploi {
  const _$OffreEmploiImpl({
    required this.id,
    required this.intitule,
    required this.entreprise,
    required this.type,
    required this.domaine,
    this.niveauRequis,
    required this.region,
    required this.description,
    this.sourceUrl,
    this.source,
    this.fiabilite,
    this.datePublication,
    this.dateLimite,
    this.dateIndexation,
    required this.statut,
    this.expiree = false,
    this.estFavori = false,
  }) : super._();

  @override
  final String id;
  @override
  final String intitule;
  @override
  final String entreprise;
  @override
  final JobType type;
  @override
  final String domaine;
  @override
  final String? niveauRequis;
  @override
  final String region;
  @override
  final String description;
  @override
  final String? sourceUrl;
  @override
  final String? source;

  /// Fiabilité de la source vérifiée par la veille IA : 'officiel', 'presse'
  /// ou 'plateforme' (null pour les données de démonstration).
  @override
  final String? fiabilite;
  @override
  final DateTime? datePublication;
  @override
  final DateTime? dateLimite;
  @override
  final DateTime? dateIndexation;
  @override
  final String statut;
  @override
  @JsonKey()
  final bool expiree;
  @override
  @JsonKey()
  final bool estFavori;

  @override
  String toString() {
    return 'OffreEmploi(id: $id, intitule: $intitule, entreprise: $entreprise, type: $type, domaine: $domaine, niveauRequis: $niveauRequis, region: $region, description: $description, sourceUrl: $sourceUrl, source: $source, fiabilite: $fiabilite, datePublication: $datePublication, dateLimite: $dateLimite, dateIndexation: $dateIndexation, statut: $statut, expiree: $expiree, estFavori: $estFavori)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OffreEmploiImpl &&
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
            (identical(other.fiabilite, fiabilite) ||
                other.fiabilite == fiabilite) &&
            (identical(other.datePublication, datePublication) ||
                other.datePublication == datePublication) &&
            (identical(other.dateLimite, dateLimite) ||
                other.dateLimite == dateLimite) &&
            (identical(other.dateIndexation, dateIndexation) ||
                other.dateIndexation == dateIndexation) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.expiree, expiree) || other.expiree == expiree) &&
            (identical(other.estFavori, estFavori) ||
                other.estFavori == estFavori));
  }

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
    fiabilite,
    datePublication,
    dateLimite,
    dateIndexation,
    statut,
    expiree,
    estFavori,
  );

  /// Create a copy of OffreEmploi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OffreEmploiImplCopyWith<_$OffreEmploiImpl> get copyWith =>
      __$$OffreEmploiImplCopyWithImpl<_$OffreEmploiImpl>(this, _$identity);
}

abstract class _OffreEmploi extends OffreEmploi {
  const factory _OffreEmploi({
    required final String id,
    required final String intitule,
    required final String entreprise,
    required final JobType type,
    required final String domaine,
    final String? niveauRequis,
    required final String region,
    required final String description,
    final String? sourceUrl,
    final String? source,
    final String? fiabilite,
    final DateTime? datePublication,
    final DateTime? dateLimite,
    final DateTime? dateIndexation,
    required final String statut,
    final bool expiree,
    final bool estFavori,
  }) = _$OffreEmploiImpl;
  const _OffreEmploi._() : super._();

  @override
  String get id;
  @override
  String get intitule;
  @override
  String get entreprise;
  @override
  JobType get type;
  @override
  String get domaine;
  @override
  String? get niveauRequis;
  @override
  String get region;
  @override
  String get description;
  @override
  String? get sourceUrl;
  @override
  String? get source;

  /// Fiabilité de la source vérifiée par la veille IA : 'officiel', 'presse'
  /// ou 'plateforme' (null pour les données de démonstration).
  @override
  String? get fiabilite;
  @override
  DateTime? get datePublication;
  @override
  DateTime? get dateLimite;
  @override
  DateTime? get dateIndexation;
  @override
  String get statut;
  @override
  bool get expiree;
  @override
  bool get estFavori;

  /// Create a copy of OffreEmploi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OffreEmploiImplCopyWith<_$OffreEmploiImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
