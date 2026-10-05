// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profil_lyceen_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProfilLyceenModel _$ProfilLyceenModelFromJson(Map<String, dynamic> json) {
  return _ProfilLyceenModel.fromJson(json);
}

/// @nodoc
mixin _$ProfilLyceenModel {
  // ignore: invalid_annotation_target
  @JsonKey(name: 'serie_bac')
  String? get serieBac => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(
    name: 'moyenne_generale',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  double? get moyenneGenerale => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _stringListFromJson)
  List<String>? get passions => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'matieres_fortes', fromJson: _stringListFromJson)
  List<String>? get matieresFortes => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'metiers_envisages', fromJson: _stringListFromJson)
  List<String>? get metiersEnvisages => throw _privateConstructorUsedError;
  bool get mobilite =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(
    name: 'pref_public_prive',
    fromJson: _prefFromJson,
    toJson: _prefToJson,
  )
  PrefEtablissement get prefPublicPrive => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'region_cible')
  String? get regionCible => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'annee_terminale')
  int? get anneeTerminale => throw _privateConstructorUsedError;
  int get completude => throw _privateConstructorUsedError;

  /// Serializes this ProfilLyceenModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfilLyceenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfilLyceenModelCopyWith<ProfilLyceenModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfilLyceenModelCopyWith<$Res> {
  factory $ProfilLyceenModelCopyWith(
    ProfilLyceenModel value,
    $Res Function(ProfilLyceenModel) then,
  ) = _$ProfilLyceenModelCopyWithImpl<$Res, ProfilLyceenModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'serie_bac') String? serieBac,
    @JsonKey(
      name: 'moyenne_generale',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    double? moyenneGenerale,
    @JsonKey(fromJson: _stringListFromJson) List<String>? passions,
    @JsonKey(name: 'matieres_fortes', fromJson: _stringListFromJson)
    List<String>? matieresFortes,
    @JsonKey(name: 'metiers_envisages', fromJson: _stringListFromJson)
    List<String>? metiersEnvisages,
    bool mobilite,
    @JsonKey(
      name: 'pref_public_prive',
      fromJson: _prefFromJson,
      toJson: _prefToJson,
    )
    PrefEtablissement prefPublicPrive,
    @JsonKey(name: 'region_cible') String? regionCible,
    @JsonKey(name: 'annee_terminale') int? anneeTerminale,
    int completude,
  });
}

/// @nodoc
class _$ProfilLyceenModelCopyWithImpl<$Res, $Val extends ProfilLyceenModel>
    implements $ProfilLyceenModelCopyWith<$Res> {
  _$ProfilLyceenModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfilLyceenModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serieBac = freezed,
    Object? moyenneGenerale = freezed,
    Object? passions = freezed,
    Object? matieresFortes = freezed,
    Object? metiersEnvisages = freezed,
    Object? mobilite = null,
    Object? prefPublicPrive = null,
    Object? regionCible = freezed,
    Object? anneeTerminale = freezed,
    Object? completude = null,
  }) {
    return _then(
      _value.copyWith(
            serieBac: freezed == serieBac
                ? _value.serieBac
                : serieBac // ignore: cast_nullable_to_non_nullable
                      as String?,
            moyenneGenerale: freezed == moyenneGenerale
                ? _value.moyenneGenerale
                : moyenneGenerale // ignore: cast_nullable_to_non_nullable
                      as double?,
            passions: freezed == passions
                ? _value.passions
                : passions // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            matieresFortes: freezed == matieresFortes
                ? _value.matieresFortes
                : matieresFortes // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            metiersEnvisages: freezed == metiersEnvisages
                ? _value.metiersEnvisages
                : metiersEnvisages // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            mobilite: null == mobilite
                ? _value.mobilite
                : mobilite // ignore: cast_nullable_to_non_nullable
                      as bool,
            prefPublicPrive: null == prefPublicPrive
                ? _value.prefPublicPrive
                : prefPublicPrive // ignore: cast_nullable_to_non_nullable
                      as PrefEtablissement,
            regionCible: freezed == regionCible
                ? _value.regionCible
                : regionCible // ignore: cast_nullable_to_non_nullable
                      as String?,
            anneeTerminale: freezed == anneeTerminale
                ? _value.anneeTerminale
                : anneeTerminale // ignore: cast_nullable_to_non_nullable
                      as int?,
            completude: null == completude
                ? _value.completude
                : completude // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfilLyceenModelImplCopyWith<$Res>
    implements $ProfilLyceenModelCopyWith<$Res> {
  factory _$$ProfilLyceenModelImplCopyWith(
    _$ProfilLyceenModelImpl value,
    $Res Function(_$ProfilLyceenModelImpl) then,
  ) = __$$ProfilLyceenModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'serie_bac') String? serieBac,
    @JsonKey(
      name: 'moyenne_generale',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    double? moyenneGenerale,
    @JsonKey(fromJson: _stringListFromJson) List<String>? passions,
    @JsonKey(name: 'matieres_fortes', fromJson: _stringListFromJson)
    List<String>? matieresFortes,
    @JsonKey(name: 'metiers_envisages', fromJson: _stringListFromJson)
    List<String>? metiersEnvisages,
    bool mobilite,
    @JsonKey(
      name: 'pref_public_prive',
      fromJson: _prefFromJson,
      toJson: _prefToJson,
    )
    PrefEtablissement prefPublicPrive,
    @JsonKey(name: 'region_cible') String? regionCible,
    @JsonKey(name: 'annee_terminale') int? anneeTerminale,
    int completude,
  });
}

/// @nodoc
class __$$ProfilLyceenModelImplCopyWithImpl<$Res>
    extends _$ProfilLyceenModelCopyWithImpl<$Res, _$ProfilLyceenModelImpl>
    implements _$$ProfilLyceenModelImplCopyWith<$Res> {
  __$$ProfilLyceenModelImplCopyWithImpl(
    _$ProfilLyceenModelImpl _value,
    $Res Function(_$ProfilLyceenModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfilLyceenModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serieBac = freezed,
    Object? moyenneGenerale = freezed,
    Object? passions = freezed,
    Object? matieresFortes = freezed,
    Object? metiersEnvisages = freezed,
    Object? mobilite = null,
    Object? prefPublicPrive = null,
    Object? regionCible = freezed,
    Object? anneeTerminale = freezed,
    Object? completude = null,
  }) {
    return _then(
      _$ProfilLyceenModelImpl(
        serieBac: freezed == serieBac
            ? _value.serieBac
            : serieBac // ignore: cast_nullable_to_non_nullable
                  as String?,
        moyenneGenerale: freezed == moyenneGenerale
            ? _value.moyenneGenerale
            : moyenneGenerale // ignore: cast_nullable_to_non_nullable
                  as double?,
        passions: freezed == passions
            ? _value._passions
            : passions // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        matieresFortes: freezed == matieresFortes
            ? _value._matieresFortes
            : matieresFortes // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        metiersEnvisages: freezed == metiersEnvisages
            ? _value._metiersEnvisages
            : metiersEnvisages // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        mobilite: null == mobilite
            ? _value.mobilite
            : mobilite // ignore: cast_nullable_to_non_nullable
                  as bool,
        prefPublicPrive: null == prefPublicPrive
            ? _value.prefPublicPrive
            : prefPublicPrive // ignore: cast_nullable_to_non_nullable
                  as PrefEtablissement,
        regionCible: freezed == regionCible
            ? _value.regionCible
            : regionCible // ignore: cast_nullable_to_non_nullable
                  as String?,
        anneeTerminale: freezed == anneeTerminale
            ? _value.anneeTerminale
            : anneeTerminale // ignore: cast_nullable_to_non_nullable
                  as int?,
        completude: null == completude
            ? _value.completude
            : completude // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfilLyceenModelImpl extends _ProfilLyceenModel {
  const _$ProfilLyceenModelImpl({
    @JsonKey(name: 'serie_bac') this.serieBac,
    @JsonKey(
      name: 'moyenne_generale',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    this.moyenneGenerale,
    @JsonKey(fromJson: _stringListFromJson) final List<String>? passions,
    @JsonKey(name: 'matieres_fortes', fromJson: _stringListFromJson)
    final List<String>? matieresFortes,
    @JsonKey(name: 'metiers_envisages', fromJson: _stringListFromJson)
    final List<String>? metiersEnvisages,
    this.mobilite = false,
    @JsonKey(
      name: 'pref_public_prive',
      fromJson: _prefFromJson,
      toJson: _prefToJson,
    )
    this.prefPublicPrive = PrefEtablissement.indifferent,
    @JsonKey(name: 'region_cible') this.regionCible,
    @JsonKey(name: 'annee_terminale') this.anneeTerminale,
    this.completude = 0,
  }) : _passions = passions,
       _matieresFortes = matieresFortes,
       _metiersEnvisages = metiersEnvisages,
       super._();

  factory _$ProfilLyceenModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfilLyceenModelImplFromJson(json);

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'serie_bac')
  final String? serieBac;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(
    name: 'moyenne_generale',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  final double? moyenneGenerale;
  // ignore: invalid_annotation_target
  final List<String>? _passions;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _stringListFromJson)
  List<String>? get passions {
    final value = _passions;
    if (value == null) return null;
    if (_passions is EqualUnmodifiableListView) return _passions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // ignore: invalid_annotation_target
  final List<String>? _matieresFortes;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'matieres_fortes', fromJson: _stringListFromJson)
  List<String>? get matieresFortes {
    final value = _matieresFortes;
    if (value == null) return null;
    if (_matieresFortes is EqualUnmodifiableListView) return _matieresFortes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // ignore: invalid_annotation_target
  final List<String>? _metiersEnvisages;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'metiers_envisages', fromJson: _stringListFromJson)
  List<String>? get metiersEnvisages {
    final value = _metiersEnvisages;
    if (value == null) return null;
    if (_metiersEnvisages is EqualUnmodifiableListView)
      return _metiersEnvisages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool mobilite;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(
    name: 'pref_public_prive',
    fromJson: _prefFromJson,
    toJson: _prefToJson,
  )
  final PrefEtablissement prefPublicPrive;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'region_cible')
  final String? regionCible;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'annee_terminale')
  final int? anneeTerminale;
  @override
  @JsonKey()
  final int completude;

  @override
  String toString() {
    return 'ProfilLyceenModel(serieBac: $serieBac, moyenneGenerale: $moyenneGenerale, passions: $passions, matieresFortes: $matieresFortes, metiersEnvisages: $metiersEnvisages, mobilite: $mobilite, prefPublicPrive: $prefPublicPrive, regionCible: $regionCible, anneeTerminale: $anneeTerminale, completude: $completude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfilLyceenModelImpl &&
            (identical(other.serieBac, serieBac) ||
                other.serieBac == serieBac) &&
            (identical(other.moyenneGenerale, moyenneGenerale) ||
                other.moyenneGenerale == moyenneGenerale) &&
            const DeepCollectionEquality().equals(other._passions, _passions) &&
            const DeepCollectionEquality().equals(
              other._matieresFortes,
              _matieresFortes,
            ) &&
            const DeepCollectionEquality().equals(
              other._metiersEnvisages,
              _metiersEnvisages,
            ) &&
            (identical(other.mobilite, mobilite) ||
                other.mobilite == mobilite) &&
            (identical(other.prefPublicPrive, prefPublicPrive) ||
                other.prefPublicPrive == prefPublicPrive) &&
            (identical(other.regionCible, regionCible) ||
                other.regionCible == regionCible) &&
            (identical(other.anneeTerminale, anneeTerminale) ||
                other.anneeTerminale == anneeTerminale) &&
            (identical(other.completude, completude) ||
                other.completude == completude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    serieBac,
    moyenneGenerale,
    const DeepCollectionEquality().hash(_passions),
    const DeepCollectionEquality().hash(_matieresFortes),
    const DeepCollectionEquality().hash(_metiersEnvisages),
    mobilite,
    prefPublicPrive,
    regionCible,
    anneeTerminale,
    completude,
  );

  /// Create a copy of ProfilLyceenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfilLyceenModelImplCopyWith<_$ProfilLyceenModelImpl> get copyWith =>
      __$$ProfilLyceenModelImplCopyWithImpl<_$ProfilLyceenModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfilLyceenModelImplToJson(this);
  }
}

abstract class _ProfilLyceenModel extends ProfilLyceenModel {
  const factory _ProfilLyceenModel({
    @JsonKey(name: 'serie_bac') final String? serieBac,
    @JsonKey(
      name: 'moyenne_generale',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    final double? moyenneGenerale,
    @JsonKey(fromJson: _stringListFromJson) final List<String>? passions,
    @JsonKey(name: 'matieres_fortes', fromJson: _stringListFromJson)
    final List<String>? matieresFortes,
    @JsonKey(name: 'metiers_envisages', fromJson: _stringListFromJson)
    final List<String>? metiersEnvisages,
    final bool mobilite,
    @JsonKey(
      name: 'pref_public_prive',
      fromJson: _prefFromJson,
      toJson: _prefToJson,
    )
    final PrefEtablissement prefPublicPrive,
    @JsonKey(name: 'region_cible') final String? regionCible,
    @JsonKey(name: 'annee_terminale') final int? anneeTerminale,
    final int completude,
  }) = _$ProfilLyceenModelImpl;
  const _ProfilLyceenModel._() : super._();

  factory _ProfilLyceenModel.fromJson(Map<String, dynamic> json) =
      _$ProfilLyceenModelImpl.fromJson;

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'serie_bac')
  String? get serieBac; // ignore: invalid_annotation_target
  @override
  @JsonKey(
    name: 'moyenne_generale',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  double? get moyenneGenerale; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _stringListFromJson)
  List<String>? get passions; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'matieres_fortes', fromJson: _stringListFromJson)
  List<String>? get matieresFortes; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'metiers_envisages', fromJson: _stringListFromJson)
  List<String>? get metiersEnvisages;
  @override
  bool get mobilite; // ignore: invalid_annotation_target
  @override
  @JsonKey(
    name: 'pref_public_prive',
    fromJson: _prefFromJson,
    toJson: _prefToJson,
  )
  PrefEtablissement get prefPublicPrive; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'region_cible')
  String? get regionCible; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'annee_terminale')
  int? get anneeTerminale;
  @override
  int get completude;

  /// Create a copy of ProfilLyceenModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfilLyceenModelImplCopyWith<_$ProfilLyceenModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
