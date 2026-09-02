// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'formation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FormationModel _$FormationModelFromJson(Map<String, dynamic> json) {
  return _FormationModel.fromJson(json);
}

/// @nodoc
mixin _$FormationModel {
  String get id =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'universite_id')
  String get universiteId => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'universite_nom')
  String? get universiteNom => throw _privateConstructorUsedError;
  String get intitule => throw _privateConstructorUsedError;
  String get domaine =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _niveauFromJson, toJson: _niveauToJson)
  NiveauFormation get niveau => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'duree_annees')
  int? get dureeAnnees => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'series_acceptees', fromJson: _seriesFromJson)
  List<String>? get seriesAcceptees => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(
    name: 'moyenne_minimale',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  double? get moyenneMinimale => throw _privateConstructorUsedError;
  int? get capacite => throw _privateConstructorUsedError;
  String? get prerequis => throw _privateConstructorUsedError;
  String? get debouches =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'est_favori', defaultValue: false)
  bool get estFavori => throw _privateConstructorUsedError;

  /// Serializes this FormationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FormationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FormationModelCopyWith<FormationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FormationModelCopyWith<$Res> {
  factory $FormationModelCopyWith(
    FormationModel value,
    $Res Function(FormationModel) then,
  ) = _$FormationModelCopyWithImpl<$Res, FormationModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'universite_id') String universiteId,
    @JsonKey(name: 'universite_nom') String? universiteNom,
    String intitule,
    String domaine,
    @JsonKey(fromJson: _niveauFromJson, toJson: _niveauToJson)
    NiveauFormation niveau,
    @JsonKey(name: 'duree_annees') int? dureeAnnees,
    @JsonKey(name: 'series_acceptees', fromJson: _seriesFromJson)
    List<String>? seriesAcceptees,
    @JsonKey(
      name: 'moyenne_minimale',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    double? moyenneMinimale,
    int? capacite,
    String? prerequis,
    String? debouches,
    @JsonKey(name: 'est_favori', defaultValue: false) bool estFavori,
  });
}

/// @nodoc
class _$FormationModelCopyWithImpl<$Res, $Val extends FormationModel>
    implements $FormationModelCopyWith<$Res> {
  _$FormationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FormationModel
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
abstract class _$$FormationModelImplCopyWith<$Res>
    implements $FormationModelCopyWith<$Res> {
  factory _$$FormationModelImplCopyWith(
    _$FormationModelImpl value,
    $Res Function(_$FormationModelImpl) then,
  ) = __$$FormationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'universite_id') String universiteId,
    @JsonKey(name: 'universite_nom') String? universiteNom,
    String intitule,
    String domaine,
    @JsonKey(fromJson: _niveauFromJson, toJson: _niveauToJson)
    NiveauFormation niveau,
    @JsonKey(name: 'duree_annees') int? dureeAnnees,
    @JsonKey(name: 'series_acceptees', fromJson: _seriesFromJson)
    List<String>? seriesAcceptees,
    @JsonKey(
      name: 'moyenne_minimale',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    double? moyenneMinimale,
    int? capacite,
    String? prerequis,
    String? debouches,
    @JsonKey(name: 'est_favori', defaultValue: false) bool estFavori,
  });
}

/// @nodoc
class __$$FormationModelImplCopyWithImpl<$Res>
    extends _$FormationModelCopyWithImpl<$Res, _$FormationModelImpl>
    implements _$$FormationModelImplCopyWith<$Res> {
  __$$FormationModelImplCopyWithImpl(
    _$FormationModelImpl _value,
    $Res Function(_$FormationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FormationModel
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
      _$FormationModelImpl(
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
@JsonSerializable()
class _$FormationModelImpl extends _FormationModel {
  const _$FormationModelImpl({
    required this.id,
    @JsonKey(name: 'universite_id') required this.universiteId,
    @JsonKey(name: 'universite_nom') this.universiteNom,
    required this.intitule,
    required this.domaine,
    @JsonKey(fromJson: _niveauFromJson, toJson: _niveauToJson)
    required this.niveau,
    @JsonKey(name: 'duree_annees') this.dureeAnnees,
    @JsonKey(name: 'series_acceptees', fromJson: _seriesFromJson)
    final List<String>? seriesAcceptees,
    @JsonKey(
      name: 'moyenne_minimale',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    this.moyenneMinimale,
    this.capacite,
    this.prerequis,
    this.debouches,
    @JsonKey(name: 'est_favori', defaultValue: false) this.estFavori = false,
  }) : _seriesAcceptees = seriesAcceptees,
       super._();

  factory _$FormationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FormationModelImplFromJson(json);

  @override
  final String id;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_id')
  final String universiteId;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_nom')
  final String? universiteNom;
  @override
  final String intitule;
  @override
  final String domaine;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _niveauFromJson, toJson: _niveauToJson)
  final NiveauFormation niveau;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'duree_annees')
  final int? dureeAnnees;
  // ignore: invalid_annotation_target
  final List<String>? _seriesAcceptees;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'series_acceptees', fromJson: _seriesFromJson)
  List<String>? get seriesAcceptees {
    final value = _seriesAcceptees;
    if (value == null) return null;
    if (_seriesAcceptees is EqualUnmodifiableListView) return _seriesAcceptees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // ignore: invalid_annotation_target
  @override
  @JsonKey(
    name: 'moyenne_minimale',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  final double? moyenneMinimale;
  @override
  final int? capacite;
  @override
  final String? prerequis;
  @override
  final String? debouches;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'est_favori', defaultValue: false)
  final bool estFavori;

  @override
  String toString() {
    return 'FormationModel(id: $id, universiteId: $universiteId, universiteNom: $universiteNom, intitule: $intitule, domaine: $domaine, niveau: $niveau, dureeAnnees: $dureeAnnees, seriesAcceptees: $seriesAcceptees, moyenneMinimale: $moyenneMinimale, capacite: $capacite, prerequis: $prerequis, debouches: $debouches, estFavori: $estFavori)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FormationModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of FormationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FormationModelImplCopyWith<_$FormationModelImpl> get copyWith =>
      __$$FormationModelImplCopyWithImpl<_$FormationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FormationModelImplToJson(this);
  }
}

abstract class _FormationModel extends FormationModel {
  const factory _FormationModel({
    required final String id,
    @JsonKey(name: 'universite_id') required final String universiteId,
    @JsonKey(name: 'universite_nom') final String? universiteNom,
    required final String intitule,
    required final String domaine,
    @JsonKey(fromJson: _niveauFromJson, toJson: _niveauToJson)
    required final NiveauFormation niveau,
    @JsonKey(name: 'duree_annees') final int? dureeAnnees,
    @JsonKey(name: 'series_acceptees', fromJson: _seriesFromJson)
    final List<String>? seriesAcceptees,
    @JsonKey(
      name: 'moyenne_minimale',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    final double? moyenneMinimale,
    final int? capacite,
    final String? prerequis,
    final String? debouches,
    @JsonKey(name: 'est_favori', defaultValue: false) final bool estFavori,
  }) = _$FormationModelImpl;
  const _FormationModel._() : super._();

  factory _FormationModel.fromJson(Map<String, dynamic> json) =
      _$FormationModelImpl.fromJson;

  @override
  String get id; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_id')
  String get universiteId; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_nom')
  String? get universiteNom;
  @override
  String get intitule;
  @override
  String get domaine; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _niveauFromJson, toJson: _niveauToJson)
  NiveauFormation get niveau; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'duree_annees')
  int? get dureeAnnees; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'series_acceptees', fromJson: _seriesFromJson)
  List<String>? get seriesAcceptees; // ignore: invalid_annotation_target
  @override
  @JsonKey(
    name: 'moyenne_minimale',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  double? get moyenneMinimale;
  @override
  int? get capacite;
  @override
  String? get prerequis;
  @override
  String? get debouches; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'est_favori', defaultValue: false)
  bool get estFavori;

  /// Create a copy of FormationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FormationModelImplCopyWith<_$FormationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
