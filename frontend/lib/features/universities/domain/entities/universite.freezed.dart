// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'universite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Universite {
  String get id => throw _privateConstructorUsedError;
  String get nom => throw _privateConstructorUsedError;
  String get codeUnique => throw _privateConstructorUsedError;
  String? get region => throw _privateConstructorUsedError;
  String? get commune =>
      throw _privateConstructorUsedError; // Null = statut non vérifié (aucune source officielle) : on n'affiche alors rien.
  EtablissementType? get type => throw _privateConstructorUsedError;
  String? get siteWebOfficiel => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get emailContact => throw _privateConstructorUsedError;
  String? get telephoneContact => throw _privateConstructorUsedError;
  String? get adresse =>
      throw _privateConstructorUsedError; // Fiche enrichie (infos publiques collectées par le service IA, surtout pour les
  // établissements sans site officiel) + page d'où elles viennent.
  List<String> get domaines => throw _privateConstructorUsedError;
  List<String> get diplomes => throw _privateConstructorUsedError;
  String? get admission => throw _privateConstructorUsedError;
  List<String> get niveauRequis => throw _privateConstructorUsedError;
  List<String> get piecesAFournir => throw _privateConstructorUsedError;
  String? get sourceInfos => throw _privateConstructorUsedError;
  List<Formation> get formations => throw _privateConstructorUsedError;
  List<Bourse> get bourses => throw _privateConstructorUsedError;
  List<Logement> get logements => throw _privateConstructorUsedError;
  List<FraisScolarite> get fraisScolarite => throw _privateConstructorUsedError;

  /// Create a copy of Universite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UniversiteCopyWith<Universite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UniversiteCopyWith<$Res> {
  factory $UniversiteCopyWith(
    Universite value,
    $Res Function(Universite) then,
  ) = _$UniversiteCopyWithImpl<$Res, Universite>;
  @useResult
  $Res call({
    String id,
    String nom,
    String codeUnique,
    String? region,
    String? commune,
    EtablissementType? type,
    String? siteWebOfficiel,
    String? description,
    String? imageUrl,
    String? emailContact,
    String? telephoneContact,
    String? adresse,
    List<String> domaines,
    List<String> diplomes,
    String? admission,
    List<String> niveauRequis,
    List<String> piecesAFournir,
    String? sourceInfos,
    List<Formation> formations,
    List<Bourse> bourses,
    List<Logement> logements,
    List<FraisScolarite> fraisScolarite,
  });
}

/// @nodoc
class _$UniversiteCopyWithImpl<$Res, $Val extends Universite>
    implements $UniversiteCopyWith<$Res> {
  _$UniversiteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Universite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? codeUnique = null,
    Object? region = freezed,
    Object? commune = freezed,
    Object? type = freezed,
    Object? siteWebOfficiel = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? emailContact = freezed,
    Object? telephoneContact = freezed,
    Object? adresse = freezed,
    Object? domaines = null,
    Object? diplomes = null,
    Object? admission = freezed,
    Object? niveauRequis = null,
    Object? piecesAFournir = null,
    Object? sourceInfos = freezed,
    Object? formations = null,
    Object? bourses = null,
    Object? logements = null,
    Object? fraisScolarite = null,
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
            codeUnique: null == codeUnique
                ? _value.codeUnique
                : codeUnique // ignore: cast_nullable_to_non_nullable
                      as String,
            region: freezed == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String?,
            commune: freezed == commune
                ? _value.commune
                : commune // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as EtablissementType?,
            siteWebOfficiel: freezed == siteWebOfficiel
                ? _value.siteWebOfficiel
                : siteWebOfficiel // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            emailContact: freezed == emailContact
                ? _value.emailContact
                : emailContact // ignore: cast_nullable_to_non_nullable
                      as String?,
            telephoneContact: freezed == telephoneContact
                ? _value.telephoneContact
                : telephoneContact // ignore: cast_nullable_to_non_nullable
                      as String?,
            adresse: freezed == adresse
                ? _value.adresse
                : adresse // ignore: cast_nullable_to_non_nullable
                      as String?,
            domaines: null == domaines
                ? _value.domaines
                : domaines // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            diplomes: null == diplomes
                ? _value.diplomes
                : diplomes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            admission: freezed == admission
                ? _value.admission
                : admission // ignore: cast_nullable_to_non_nullable
                      as String?,
            niveauRequis: null == niveauRequis
                ? _value.niveauRequis
                : niveauRequis // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            piecesAFournir: null == piecesAFournir
                ? _value.piecesAFournir
                : piecesAFournir // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            sourceInfos: freezed == sourceInfos
                ? _value.sourceInfos
                : sourceInfos // ignore: cast_nullable_to_non_nullable
                      as String?,
            formations: null == formations
                ? _value.formations
                : formations // ignore: cast_nullable_to_non_nullable
                      as List<Formation>,
            bourses: null == bourses
                ? _value.bourses
                : bourses // ignore: cast_nullable_to_non_nullable
                      as List<Bourse>,
            logements: null == logements
                ? _value.logements
                : logements // ignore: cast_nullable_to_non_nullable
                      as List<Logement>,
            fraisScolarite: null == fraisScolarite
                ? _value.fraisScolarite
                : fraisScolarite // ignore: cast_nullable_to_non_nullable
                      as List<FraisScolarite>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UniversiteImplCopyWith<$Res>
    implements $UniversiteCopyWith<$Res> {
  factory _$$UniversiteImplCopyWith(
    _$UniversiteImpl value,
    $Res Function(_$UniversiteImpl) then,
  ) = __$$UniversiteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nom,
    String codeUnique,
    String? region,
    String? commune,
    EtablissementType? type,
    String? siteWebOfficiel,
    String? description,
    String? imageUrl,
    String? emailContact,
    String? telephoneContact,
    String? adresse,
    List<String> domaines,
    List<String> diplomes,
    String? admission,
    List<String> niveauRequis,
    List<String> piecesAFournir,
    String? sourceInfos,
    List<Formation> formations,
    List<Bourse> bourses,
    List<Logement> logements,
    List<FraisScolarite> fraisScolarite,
  });
}

/// @nodoc
class __$$UniversiteImplCopyWithImpl<$Res>
    extends _$UniversiteCopyWithImpl<$Res, _$UniversiteImpl>
    implements _$$UniversiteImplCopyWith<$Res> {
  __$$UniversiteImplCopyWithImpl(
    _$UniversiteImpl _value,
    $Res Function(_$UniversiteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Universite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? codeUnique = null,
    Object? region = freezed,
    Object? commune = freezed,
    Object? type = freezed,
    Object? siteWebOfficiel = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? emailContact = freezed,
    Object? telephoneContact = freezed,
    Object? adresse = freezed,
    Object? domaines = null,
    Object? diplomes = null,
    Object? admission = freezed,
    Object? niveauRequis = null,
    Object? piecesAFournir = null,
    Object? sourceInfos = freezed,
    Object? formations = null,
    Object? bourses = null,
    Object? logements = null,
    Object? fraisScolarite = null,
  }) {
    return _then(
      _$UniversiteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        codeUnique: null == codeUnique
            ? _value.codeUnique
            : codeUnique // ignore: cast_nullable_to_non_nullable
                  as String,
        region: freezed == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String?,
        commune: freezed == commune
            ? _value.commune
            : commune // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as EtablissementType?,
        siteWebOfficiel: freezed == siteWebOfficiel
            ? _value.siteWebOfficiel
            : siteWebOfficiel // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        emailContact: freezed == emailContact
            ? _value.emailContact
            : emailContact // ignore: cast_nullable_to_non_nullable
                  as String?,
        telephoneContact: freezed == telephoneContact
            ? _value.telephoneContact
            : telephoneContact // ignore: cast_nullable_to_non_nullable
                  as String?,
        adresse: freezed == adresse
            ? _value.adresse
            : adresse // ignore: cast_nullable_to_non_nullable
                  as String?,
        domaines: null == domaines
            ? _value._domaines
            : domaines // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        diplomes: null == diplomes
            ? _value._diplomes
            : diplomes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        admission: freezed == admission
            ? _value.admission
            : admission // ignore: cast_nullable_to_non_nullable
                  as String?,
        niveauRequis: null == niveauRequis
            ? _value._niveauRequis
            : niveauRequis // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        piecesAFournir: null == piecesAFournir
            ? _value._piecesAFournir
            : piecesAFournir // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        sourceInfos: freezed == sourceInfos
            ? _value.sourceInfos
            : sourceInfos // ignore: cast_nullable_to_non_nullable
                  as String?,
        formations: null == formations
            ? _value._formations
            : formations // ignore: cast_nullable_to_non_nullable
                  as List<Formation>,
        bourses: null == bourses
            ? _value._bourses
            : bourses // ignore: cast_nullable_to_non_nullable
                  as List<Bourse>,
        logements: null == logements
            ? _value._logements
            : logements // ignore: cast_nullable_to_non_nullable
                  as List<Logement>,
        fraisScolarite: null == fraisScolarite
            ? _value._fraisScolarite
            : fraisScolarite // ignore: cast_nullable_to_non_nullable
                  as List<FraisScolarite>,
      ),
    );
  }
}

/// @nodoc

class _$UniversiteImpl extends _Universite {
  const _$UniversiteImpl({
    required this.id,
    required this.nom,
    required this.codeUnique,
    this.region,
    this.commune,
    this.type,
    this.siteWebOfficiel,
    this.description,
    this.imageUrl,
    this.emailContact,
    this.telephoneContact,
    this.adresse,
    final List<String> domaines = const [],
    final List<String> diplomes = const [],
    this.admission,
    final List<String> niveauRequis = const [],
    final List<String> piecesAFournir = const [],
    this.sourceInfos,
    final List<Formation> formations = const [],
    final List<Bourse> bourses = const [],
    final List<Logement> logements = const [],
    final List<FraisScolarite> fraisScolarite = const [],
  }) : _domaines = domaines,
       _diplomes = diplomes,
       _niveauRequis = niveauRequis,
       _piecesAFournir = piecesAFournir,
       _formations = formations,
       _bourses = bourses,
       _logements = logements,
       _fraisScolarite = fraisScolarite,
       super._();

  @override
  final String id;
  @override
  final String nom;
  @override
  final String codeUnique;
  @override
  final String? region;
  @override
  final String? commune;
  // Null = statut non vérifié (aucune source officielle) : on n'affiche alors rien.
  @override
  final EtablissementType? type;
  @override
  final String? siteWebOfficiel;
  @override
  final String? description;
  @override
  final String? imageUrl;
  @override
  final String? emailContact;
  @override
  final String? telephoneContact;
  @override
  final String? adresse;
  // Fiche enrichie (infos publiques collectées par le service IA, surtout pour les
  // établissements sans site officiel) + page d'où elles viennent.
  final List<String> _domaines;
  // Fiche enrichie (infos publiques collectées par le service IA, surtout pour les
  // établissements sans site officiel) + page d'où elles viennent.
  @override
  @JsonKey()
  List<String> get domaines {
    if (_domaines is EqualUnmodifiableListView) return _domaines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_domaines);
  }

  final List<String> _diplomes;
  @override
  @JsonKey()
  List<String> get diplomes {
    if (_diplomes is EqualUnmodifiableListView) return _diplomes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_diplomes);
  }

  @override
  final String? admission;
  final List<String> _niveauRequis;
  @override
  @JsonKey()
  List<String> get niveauRequis {
    if (_niveauRequis is EqualUnmodifiableListView) return _niveauRequis;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_niveauRequis);
  }

  final List<String> _piecesAFournir;
  @override
  @JsonKey()
  List<String> get piecesAFournir {
    if (_piecesAFournir is EqualUnmodifiableListView) return _piecesAFournir;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_piecesAFournir);
  }

  @override
  final String? sourceInfos;
  final List<Formation> _formations;
  @override
  @JsonKey()
  List<Formation> get formations {
    if (_formations is EqualUnmodifiableListView) return _formations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_formations);
  }

  final List<Bourse> _bourses;
  @override
  @JsonKey()
  List<Bourse> get bourses {
    if (_bourses is EqualUnmodifiableListView) return _bourses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bourses);
  }

  final List<Logement> _logements;
  @override
  @JsonKey()
  List<Logement> get logements {
    if (_logements is EqualUnmodifiableListView) return _logements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logements);
  }

  final List<FraisScolarite> _fraisScolarite;
  @override
  @JsonKey()
  List<FraisScolarite> get fraisScolarite {
    if (_fraisScolarite is EqualUnmodifiableListView) return _fraisScolarite;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fraisScolarite);
  }

  @override
  String toString() {
    return 'Universite(id: $id, nom: $nom, codeUnique: $codeUnique, region: $region, commune: $commune, type: $type, siteWebOfficiel: $siteWebOfficiel, description: $description, imageUrl: $imageUrl, emailContact: $emailContact, telephoneContact: $telephoneContact, adresse: $adresse, domaines: $domaines, diplomes: $diplomes, admission: $admission, niveauRequis: $niveauRequis, piecesAFournir: $piecesAFournir, sourceInfos: $sourceInfos, formations: $formations, bourses: $bourses, logements: $logements, fraisScolarite: $fraisScolarite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UniversiteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.codeUnique, codeUnique) ||
                other.codeUnique == codeUnique) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.commune, commune) || other.commune == commune) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.siteWebOfficiel, siteWebOfficiel) ||
                other.siteWebOfficiel == siteWebOfficiel) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.emailContact, emailContact) ||
                other.emailContact == emailContact) &&
            (identical(other.telephoneContact, telephoneContact) ||
                other.telephoneContact == telephoneContact) &&
            (identical(other.adresse, adresse) || other.adresse == adresse) &&
            const DeepCollectionEquality().equals(other._domaines, _domaines) &&
            const DeepCollectionEquality().equals(other._diplomes, _diplomes) &&
            (identical(other.admission, admission) ||
                other.admission == admission) &&
            const DeepCollectionEquality().equals(
              other._niveauRequis,
              _niveauRequis,
            ) &&
            const DeepCollectionEquality().equals(
              other._piecesAFournir,
              _piecesAFournir,
            ) &&
            (identical(other.sourceInfos, sourceInfos) ||
                other.sourceInfos == sourceInfos) &&
            const DeepCollectionEquality().equals(
              other._formations,
              _formations,
            ) &&
            const DeepCollectionEquality().equals(other._bourses, _bourses) &&
            const DeepCollectionEquality().equals(
              other._logements,
              _logements,
            ) &&
            const DeepCollectionEquality().equals(
              other._fraisScolarite,
              _fraisScolarite,
            ));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    nom,
    codeUnique,
    region,
    commune,
    type,
    siteWebOfficiel,
    description,
    imageUrl,
    emailContact,
    telephoneContact,
    adresse,
    const DeepCollectionEquality().hash(_domaines),
    const DeepCollectionEquality().hash(_diplomes),
    admission,
    const DeepCollectionEquality().hash(_niveauRequis),
    const DeepCollectionEquality().hash(_piecesAFournir),
    sourceInfos,
    const DeepCollectionEquality().hash(_formations),
    const DeepCollectionEquality().hash(_bourses),
    const DeepCollectionEquality().hash(_logements),
    const DeepCollectionEquality().hash(_fraisScolarite),
  ]);

  /// Create a copy of Universite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UniversiteImplCopyWith<_$UniversiteImpl> get copyWith =>
      __$$UniversiteImplCopyWithImpl<_$UniversiteImpl>(this, _$identity);
}

abstract class _Universite extends Universite {
  const factory _Universite({
    required final String id,
    required final String nom,
    required final String codeUnique,
    final String? region,
    final String? commune,
    final EtablissementType? type,
    final String? siteWebOfficiel,
    final String? description,
    final String? imageUrl,
    final String? emailContact,
    final String? telephoneContact,
    final String? adresse,
    final List<String> domaines,
    final List<String> diplomes,
    final String? admission,
    final List<String> niveauRequis,
    final List<String> piecesAFournir,
    final String? sourceInfos,
    final List<Formation> formations,
    final List<Bourse> bourses,
    final List<Logement> logements,
    final List<FraisScolarite> fraisScolarite,
  }) = _$UniversiteImpl;
  const _Universite._() : super._();

  @override
  String get id;
  @override
  String get nom;
  @override
  String get codeUnique;
  @override
  String? get region;
  @override
  String? get commune; // Null = statut non vérifié (aucune source officielle) : on n'affiche alors rien.
  @override
  EtablissementType? get type;
  @override
  String? get siteWebOfficiel;
  @override
  String? get description;
  @override
  String? get imageUrl;
  @override
  String? get emailContact;
  @override
  String? get telephoneContact;
  @override
  String? get adresse; // Fiche enrichie (infos publiques collectées par le service IA, surtout pour les
  // établissements sans site officiel) + page d'où elles viennent.
  @override
  List<String> get domaines;
  @override
  List<String> get diplomes;
  @override
  String? get admission;
  @override
  List<String> get niveauRequis;
  @override
  List<String> get piecesAFournir;
  @override
  String? get sourceInfos;
  @override
  List<Formation> get formations;
  @override
  List<Bourse> get bourses;
  @override
  List<Logement> get logements;
  @override
  List<FraisScolarite> get fraisScolarite;

  /// Create a copy of Universite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UniversiteImplCopyWith<_$UniversiteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
