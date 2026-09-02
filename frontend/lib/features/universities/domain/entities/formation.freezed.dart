// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'formation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Formation {
  String get id => throw _privateConstructorUsedError;
  String get universiteId => throw _privateConstructorUsedError;
  String? get universiteNom => throw _privateConstructorUsedError;
  String get intitule => throw _privateConstructorUsedError;
  String get domaine => throw _privateConstructorUsedError;
  NiveauFormation get niveau => throw _privateConstructorUsedError;
  int? get dureeAnnees => throw _privateConstructorUsedError;
  List<String>? get seriesAcceptees => throw _privateConstructorUsedError;
  double? get moyenneMinimale => throw _privateConstructorUsedError;
  int? get capacite => throw _privateConstructorUsedError;
  String? get prerequis => throw _privateConstructorUsedError;
  String? get debouches => throw _privateConstructorUsedError;
  bool get estFavori => throw _privateConstructorUsedError;

  /// Create a copy of Formation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FormationCopyWith<Formation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FormationCopyWith<$Res> {
  factory $FormationCopyWith(Formation value, $Res Function(Formation) then) =
      _$FormationCopyWithImpl<$Res, Formation>;
  @useResult
  $Res call({
    String id,
    String universiteId,
    String? universiteNom,
    String intitule,
    String domaine,
    NiveauFormation niveau,
    int? dureeAnnees,
    List<String>? seriesAcceptees,
    double? moyenneMinimale,
    int? capacite,
    String? prerequis,
    String? debouches,
    bool estFavori,
  });
}

/// @nodoc
class _$FormationCopyWithImpl<$Res, $Val extends Formation>
    implements $FormationCopyWith<$Res> {
  _$FormationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Formation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? universiteId = null,
    Object? universiteNom = freezed,
    Object? intitule = null,
    Object? domaine = null,
    Object? niveau = null,
    Object? dureeAnnees = freezed,
    Object? seriesAcceptees = freezed,
    Object? moyenneMinimale = freezed,
    Object? capacite = freezed,
    Object? prerequis = freezed,
    Object? debouches = freezed,
    Object? estFavori = null,
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
            universiteNom: freezed == universiteNom
                ? _value.universiteNom
                : universiteNom // ignore: cast_nullable_to_non_nullable
                      as String?,
            intitule: null == intitule
                ? _value.intitule
                : intitule // ignore: cast_nullable_to_non_nullable
                      as String,
            domaine: null == domaine
                ? _value.domaine
                : domaine // ignore: cast_nullable_to_non_nullable
                      as String,
            niveau: null == niveau
                ? _value.niveau
                : niveau // ignore: cast_nullable_to_non_nullable
                      as NiveauFormation,
            dureeAnnees: freezed == dureeAnnees
                ? _value.dureeAnnees
                : dureeAnnees // ignore: cast_nullable_to_non_nullable
                      as int?,
            seriesAcceptees: freezed == seriesAcceptees
                ? _value.seriesAcceptees
                : seriesAcceptees // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            moyenneMinimale: freezed == moyenneMinimale
                ? _value.moyenneMinimale
                : moyenneMinimale // ignore: cast_nullable_to_non_nullable
                      as double?,
            capacite: freezed == capacite
                ? _value.capacite
                : capacite // ignore: cast_nullable_to_non_nullable
                      as int?,
            prerequis: freezed == prerequis
                ? _value.prerequis
                : prerequis // ignore: cast_nullable_to_non_nullable
                      as String?,
            debouches: freezed == debouches
                ? _value.debouches
                : debouches // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$FormationImplCopyWith<$Res>
    implements $FormationCopyWith<$Res> {
  factory _$$FormationImplCopyWith(
    _$FormationImpl value,
    $Res Function(_$FormationImpl) then,
  ) = __$$FormationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String universiteId,
    String? universiteNom,
    String intitule,
    String domaine,
    NiveauFormation niveau,
    int? dureeAnnees,
    List<String>? seriesAcceptees,
    double? moyenneMinimale,
    int? capacite,
    String? prerequis,
    String? debouches,
    bool estFavori,
  });
}

/// @nodoc
class __$$FormationImplCopyWithImpl<$Res>
    extends _$FormationCopyWithImpl<$Res, _$FormationImpl>
    implements _$$FormationImplCopyWith<$Res> {
  __$$FormationImplCopyWithImpl(
    _$FormationImpl _value,
    $Res Function(_$FormationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Formation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? universiteId = null,
    Object? universiteNom = freezed,
    Object? intitule = null,
    Object? domaine = null,
    Object? niveau = null,
    Object? dureeAnnees = freezed,
    Object? seriesAcceptees = freezed,
    Object? moyenneMinimale = freezed,
    Object? capacite = freezed,
    Object? prerequis = freezed,
    Object? debouches = freezed,
    Object? estFavori = null,
  }) {
    return _then(
      _$FormationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        universiteId: null == universiteId
            ? _value.universiteId
            : universiteId // ignore: cast_nullable_to_non_nullable
                  as String,
        universiteNom: freezed == universiteNom
            ? _value.universiteNom
            : universiteNom // ignore: cast_nullable_to_non_nullable
                  as String?,
        intitule: null == intitule
            ? _value.intitule
            : intitule // ignore: cast_nullable_to_non_nullable
                  as String,
        domaine: null == domaine
            ? _value.domaine
            : domaine // ignore: cast_nullable_to_non_nullable
                  as String,
        niveau: null == niveau
            ? _value.niveau
            : niveau // ignore: cast_nullable_to_non_nullable
                  as NiveauFormation,
        dureeAnnees: freezed == dureeAnnees
            ? _value.dureeAnnees
            : dureeAnnees // ignore: cast_nullable_to_non_nullable
                  as int?,
        seriesAcceptees: freezed == seriesAcceptees
            ? _value._seriesAcceptees
            : seriesAcceptees // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        moyenneMinimale: freezed == moyenneMinimale
            ? _value.moyenneMinimale
            : moyenneMinimale // ignore: cast_nullable_to_non_nullable
                  as double?,
        capacite: freezed == capacite
            ? _value.capacite
            : capacite // ignore: cast_nullable_to_non_nullable
                  as int?,
        prerequis: freezed == prerequis
            ? _value.prerequis
            : prerequis // ignore: cast_nullable_to_non_nullable
                  as String?,
        debouches: freezed == debouches
            ? _value.debouches
            : debouches // ignore: cast_nullable_to_non_nullable
                  as String?,
        estFavori: null == estFavori
            ? _value.estFavori
            : estFavori // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$FormationImpl implements _Formation {
  const _$FormationImpl({
    required this.id,
    required this.universiteId,
    this.universiteNom,
    required this.intitule,
    required this.domaine,
    required this.niveau,
    this.dureeAnnees,
    final List<String>? seriesAcceptees,
    this.moyenneMinimale,
    this.capacite,
    this.prerequis,
    this.debouches,
    this.estFavori = false,
  }) : _seriesAcceptees = seriesAcceptees;

  @override
  final String id;
  @override
  final String universiteId;
  @override
  final String? universiteNom;
  @override
  final String intitule;
  @override
  final String domaine;
  @override
  final NiveauFormation niveau;
  @override
  final int? dureeAnnees;
  final List<String>? _seriesAcceptees;
  @override
  List<String>? get seriesAcceptees {
    final value = _seriesAcceptees;
    if (value == null) return null;
    if (_seriesAcceptees is EqualUnmodifiableListView) return _seriesAcceptees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final double? moyenneMinimale;
  @override
  final int? capacite;
  @override
  final String? prerequis;
  @override
  final String? debouches;
  @override
  @JsonKey()
  final bool estFavori;

  @override
  String toString() {
    return 'Formation(id: $id, universiteId: $universiteId, universiteNom: $universiteNom, intitule: $intitule, domaine: $domaine, niveau: $niveau, dureeAnnees: $dureeAnnees, seriesAcceptees: $seriesAcceptees, moyenneMinimale: $moyenneMinimale, capacite: $capacite, prerequis: $prerequis, debouches: $debouches, estFavori: $estFavori)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FormationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.universiteId, universiteId) ||
                other.universiteId == universiteId) &&
            (identical(other.universiteNom, universiteNom) ||
                other.universiteNom == universiteNom) &&
            (identical(other.intitule, intitule) ||
                other.intitule == intitule) &&
            (identical(other.domaine, domaine) || other.domaine == domaine) &&
            (identical(other.niveau, niveau) || other.niveau == niveau) &&
            (identical(other.dureeAnnees, dureeAnnees) ||
                other.dureeAnnees == dureeAnnees) &&
            const DeepCollectionEquality().equals(
              other._seriesAcceptees,
              _seriesAcceptees,
            ) &&
            (identical(other.moyenneMinimale, moyenneMinimale) ||
                other.moyenneMinimale == moyenneMinimale) &&
            (identical(other.capacite, capacite) ||
                other.capacite == capacite) &&
            (identical(other.prerequis, prerequis) ||
                other.prerequis == prerequis) &&
            (identical(other.debouches, debouches) ||
                other.debouches == debouches) &&
            (identical(other.estFavori, estFavori) ||
                other.estFavori == estFavori));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    universiteId,
    universiteNom,
    intitule,
    domaine,
    niveau,
    dureeAnnees,
    const DeepCollectionEquality().hash(_seriesAcceptees),
    moyenneMinimale,
    capacite,
    prerequis,
    debouches,
    estFavori,
  );

  /// Create a copy of Formation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FormationImplCopyWith<_$FormationImpl> get copyWith =>
      __$$FormationImplCopyWithImpl<_$FormationImpl>(this, _$identity);
}

abstract class _Formation implements Formation {
  const factory _Formation({
    required final String id,
    required final String universiteId,
    final String? universiteNom,
    required final String intitule,
    required final String domaine,
    required final NiveauFormation niveau,
    final int? dureeAnnees,
    final List<String>? seriesAcceptees,
    final double? moyenneMinimale,
    final int? capacite,
    final String? prerequis,
    final String? debouches,
    final bool estFavori,
  }) = _$FormationImpl;

  @override
  String get id;
  @override
  String get universiteId;
  @override
  String? get universiteNom;
  @override
  String get intitule;
  @override
  String get domaine;
  @override
  NiveauFormation get niveau;
  @override
  int? get dureeAnnees;
  @override
  List<String>? get seriesAcceptees;
  @override
  double? get moyenneMinimale;
  @override
  int? get capacite;
  @override
  String? get prerequis;
  @override
  String? get debouches;
  @override
  bool get estFavori;

  /// Create a copy of Formation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FormationImplCopyWith<_$FormationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
