// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profil_etudiant_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProfilEtudiantModel _$ProfilEtudiantModelFromJson(Map<String, dynamic> json) {
  return _ProfilEtudiantModel.fromJson(json);
}

/// @nodoc
mixin _$ProfilEtudiantModel {
  // ignore: invalid_annotation_target
  @JsonKey(name: 'universite_actuelle')
  String? get universiteActuelle => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'formation_actuelle')
  String? get formationActuelle => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(
    name: 'niveau_actuel',
    fromJson: _niveauFromJson,
    toJson: _niveauToJson,
  )
  NiveauEtudiant? get niveauActuel => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'domaines_interets', fromJson: _stringListFromJson)
  List<String>? get domainesInterets => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'recherche_stage')
  bool get rechercheStage => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'recherche_emploi')
  bool get rechercheEmploi => throw _privateConstructorUsedError;

  /// Serializes this ProfilEtudiantModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfilEtudiantModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfilEtudiantModelCopyWith<ProfilEtudiantModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfilEtudiantModelCopyWith<$Res> {
  factory $ProfilEtudiantModelCopyWith(
    ProfilEtudiantModel value,
    $Res Function(ProfilEtudiantModel) then,
  ) = _$ProfilEtudiantModelCopyWithImpl<$Res, ProfilEtudiantModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'universite_actuelle') String? universiteActuelle,
    @JsonKey(name: 'formation_actuelle') String? formationActuelle,
    @JsonKey(
      name: 'niveau_actuel',
      fromJson: _niveauFromJson,
      toJson: _niveauToJson,
    )
    NiveauEtudiant? niveauActuel,
    @JsonKey(name: 'domaines_interets', fromJson: _stringListFromJson)
    List<String>? domainesInterets,
    @JsonKey(name: 'recherche_stage') bool rechercheStage,
    @JsonKey(name: 'recherche_emploi') bool rechercheEmploi,
  });
}

/// @nodoc
class _$ProfilEtudiantModelCopyWithImpl<$Res, $Val extends ProfilEtudiantModel>
    implements $ProfilEtudiantModelCopyWith<$Res> {
  _$ProfilEtudiantModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfilEtudiantModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? universiteActuelle = freezed,
    Object? formationActuelle = freezed,
    Object? niveauActuel = freezed,
    Object? domainesInterets = freezed,
    Object? rechercheStage = null,
    Object? rechercheEmploi = null,
  }) {
    return _then(
      _value.copyWith(
            universiteActuelle: freezed == universiteActuelle
                ? _value.universiteActuelle
                : universiteActuelle // ignore: cast_nullable_to_non_nullable
                      as String?,
            formationActuelle: freezed == formationActuelle
                ? _value.formationActuelle
                : formationActuelle // ignore: cast_nullable_to_non_nullable
                      as String?,
            niveauActuel: freezed == niveauActuel
                ? _value.niveauActuel
                : niveauActuel // ignore: cast_nullable_to_non_nullable
                      as NiveauEtudiant?,
            domainesInterets: freezed == domainesInterets
                ? _value.domainesInterets
                : domainesInterets // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            rechercheStage: null == rechercheStage
                ? _value.rechercheStage
                : rechercheStage // ignore: cast_nullable_to_non_nullable
                      as bool,
            rechercheEmploi: null == rechercheEmploi
                ? _value.rechercheEmploi
                : rechercheEmploi // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfilEtudiantModelImplCopyWith<$Res>
    implements $ProfilEtudiantModelCopyWith<$Res> {
  factory _$$ProfilEtudiantModelImplCopyWith(
    _$ProfilEtudiantModelImpl value,
    $Res Function(_$ProfilEtudiantModelImpl) then,
  ) = __$$ProfilEtudiantModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'universite_actuelle') String? universiteActuelle,
    @JsonKey(name: 'formation_actuelle') String? formationActuelle,
    @JsonKey(
      name: 'niveau_actuel',
      fromJson: _niveauFromJson,
      toJson: _niveauToJson,
    )
    NiveauEtudiant? niveauActuel,
    @JsonKey(name: 'domaines_interets', fromJson: _stringListFromJson)
    List<String>? domainesInterets,
    @JsonKey(name: 'recherche_stage') bool rechercheStage,
    @JsonKey(name: 'recherche_emploi') bool rechercheEmploi,
  });
}

/// @nodoc
class __$$ProfilEtudiantModelImplCopyWithImpl<$Res>
    extends _$ProfilEtudiantModelCopyWithImpl<$Res, _$ProfilEtudiantModelImpl>
    implements _$$ProfilEtudiantModelImplCopyWith<$Res> {
  __$$ProfilEtudiantModelImplCopyWithImpl(
    _$ProfilEtudiantModelImpl _value,
    $Res Function(_$ProfilEtudiantModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfilEtudiantModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? universiteActuelle = freezed,
    Object? formationActuelle = freezed,
    Object? niveauActuel = freezed,
    Object? domainesInterets = freezed,
    Object? rechercheStage = null,
    Object? rechercheEmploi = null,
  }) {
    return _then(
      _$ProfilEtudiantModelImpl(
        universiteActuelle: freezed == universiteActuelle
            ? _value.universiteActuelle
            : universiteActuelle // ignore: cast_nullable_to_non_nullable
                  as String?,
        formationActuelle: freezed == formationActuelle
            ? _value.formationActuelle
            : formationActuelle // ignore: cast_nullable_to_non_nullable
                  as String?,
        niveauActuel: freezed == niveauActuel
            ? _value.niveauActuel
            : niveauActuel // ignore: cast_nullable_to_non_nullable
                  as NiveauEtudiant?,
        domainesInterets: freezed == domainesInterets
            ? _value._domainesInterets
            : domainesInterets // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        rechercheStage: null == rechercheStage
            ? _value.rechercheStage
            : rechercheStage // ignore: cast_nullable_to_non_nullable
                  as bool,
        rechercheEmploi: null == rechercheEmploi
            ? _value.rechercheEmploi
            : rechercheEmploi // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfilEtudiantModelImpl extends _ProfilEtudiantModel {
  const _$ProfilEtudiantModelImpl({
    @JsonKey(name: 'universite_actuelle') this.universiteActuelle,
    @JsonKey(name: 'formation_actuelle') this.formationActuelle,
    @JsonKey(
      name: 'niveau_actuel',
      fromJson: _niveauFromJson,
      toJson: _niveauToJson,
    )
    this.niveauActuel,
    @JsonKey(name: 'domaines_interets', fromJson: _stringListFromJson)
    final List<String>? domainesInterets,
    @JsonKey(name: 'recherche_stage') this.rechercheStage = false,
    @JsonKey(name: 'recherche_emploi') this.rechercheEmploi = false,
  }) : _domainesInterets = domainesInterets,
       super._();

  factory _$ProfilEtudiantModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfilEtudiantModelImplFromJson(json);

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_actuelle')
  final String? universiteActuelle;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'formation_actuelle')
  final String? formationActuelle;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(
    name: 'niveau_actuel',
    fromJson: _niveauFromJson,
    toJson: _niveauToJson,
  )
  final NiveauEtudiant? niveauActuel;
  // ignore: invalid_annotation_target
  final List<String>? _domainesInterets;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'domaines_interets', fromJson: _stringListFromJson)
  List<String>? get domainesInterets {
    final value = _domainesInterets;
    if (value == null) return null;
    if (_domainesInterets is EqualUnmodifiableListView)
      return _domainesInterets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'recherche_stage')
  final bool rechercheStage;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'recherche_emploi')
  final bool rechercheEmploi;

  @override
  String toString() {
    return 'ProfilEtudiantModel(universiteActuelle: $universiteActuelle, formationActuelle: $formationActuelle, niveauActuel: $niveauActuel, domainesInterets: $domainesInterets, rechercheStage: $rechercheStage, rechercheEmploi: $rechercheEmploi)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfilEtudiantModelImpl &&
            (identical(other.universiteActuelle, universiteActuelle) ||
                other.universiteActuelle == universiteActuelle) &&
            (identical(other.formationActuelle, formationActuelle) ||
                other.formationActuelle == formationActuelle) &&
            (identical(other.niveauActuel, niveauActuel) ||
                other.niveauActuel == niveauActuel) &&
            const DeepCollectionEquality().equals(
              other._domainesInterets,
              _domainesInterets,
            ) &&
            (identical(other.rechercheStage, rechercheStage) ||
                other.rechercheStage == rechercheStage) &&
            (identical(other.rechercheEmploi, rechercheEmploi) ||
                other.rechercheEmploi == rechercheEmploi));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    universiteActuelle,
    formationActuelle,
    niveauActuel,
    const DeepCollectionEquality().hash(_domainesInterets),
    rechercheStage,
    rechercheEmploi,
  );

  /// Create a copy of ProfilEtudiantModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfilEtudiantModelImplCopyWith<_$ProfilEtudiantModelImpl> get copyWith =>
      __$$ProfilEtudiantModelImplCopyWithImpl<_$ProfilEtudiantModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfilEtudiantModelImplToJson(this);
  }
}

abstract class _ProfilEtudiantModel extends ProfilEtudiantModel {
  const factory _ProfilEtudiantModel({
    @JsonKey(name: 'universite_actuelle') final String? universiteActuelle,
    @JsonKey(name: 'formation_actuelle') final String? formationActuelle,
    @JsonKey(
      name: 'niveau_actuel',
      fromJson: _niveauFromJson,
      toJson: _niveauToJson,
    )
    final NiveauEtudiant? niveauActuel,
    @JsonKey(name: 'domaines_interets', fromJson: _stringListFromJson)
    final List<String>? domainesInterets,
    @JsonKey(name: 'recherche_stage') final bool rechercheStage,
    @JsonKey(name: 'recherche_emploi') final bool rechercheEmploi,
  }) = _$ProfilEtudiantModelImpl;
  const _ProfilEtudiantModel._() : super._();

  factory _ProfilEtudiantModel.fromJson(Map<String, dynamic> json) =
      _$ProfilEtudiantModelImpl.fromJson;

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_actuelle')
  String? get universiteActuelle; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'formation_actuelle')
  String? get formationActuelle; // ignore: invalid_annotation_target
  @override
  @JsonKey(
    name: 'niveau_actuel',
    fromJson: _niveauFromJson,
    toJson: _niveauToJson,
  )
  NiveauEtudiant? get niveauActuel; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'domaines_interets', fromJson: _stringListFromJson)
  List<String>? get domainesInterets; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'recherche_stage')
  bool get rechercheStage; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'recherche_emploi')
  bool get rechercheEmploi;

  /// Create a copy of ProfilEtudiantModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfilEtudiantModelImplCopyWith<_$ProfilEtudiantModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
