// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommandation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ConditionsAdmissionModel {
  List<String> get seriesAcceptees => throw _privateConstructorUsedError;
  double? get moyenneMinimale => throw _privateConstructorUsedError;
  String? get prerequis => throw _privateConstructorUsedError;

  /// Create a copy of ConditionsAdmissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConditionsAdmissionModelCopyWith<ConditionsAdmissionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConditionsAdmissionModelCopyWith<$Res> {
  factory $ConditionsAdmissionModelCopyWith(
    ConditionsAdmissionModel value,
    $Res Function(ConditionsAdmissionModel) then,
  ) = _$ConditionsAdmissionModelCopyWithImpl<$Res, ConditionsAdmissionModel>;
  @useResult
  $Res call({
    List<String> seriesAcceptees,
    double? moyenneMinimale,
    String? prerequis,
  });
}

/// @nodoc
class _$ConditionsAdmissionModelCopyWithImpl<
  $Res,
  $Val extends ConditionsAdmissionModel
>
    implements $ConditionsAdmissionModelCopyWith<$Res> {
  _$ConditionsAdmissionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConditionsAdmissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seriesAcceptees = null,
    Object? moyenneMinimale = freezed,
    Object? prerequis = freezed,
  }) {
    return _then(
      _value.copyWith(
            seriesAcceptees: null == seriesAcceptees
                ? _value.seriesAcceptees
                : seriesAcceptees // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            moyenneMinimale: freezed == moyenneMinimale
                ? _value.moyenneMinimale
                : moyenneMinimale // ignore: cast_nullable_to_non_nullable
                      as double?,
            prerequis: freezed == prerequis
                ? _value.prerequis
                : prerequis // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConditionsAdmissionModelImplCopyWith<$Res>
    implements $ConditionsAdmissionModelCopyWith<$Res> {
  factory _$$ConditionsAdmissionModelImplCopyWith(
    _$ConditionsAdmissionModelImpl value,
    $Res Function(_$ConditionsAdmissionModelImpl) then,
  ) = __$$ConditionsAdmissionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String> seriesAcceptees,
    double? moyenneMinimale,
    String? prerequis,
  });
}

/// @nodoc
class __$$ConditionsAdmissionModelImplCopyWithImpl<$Res>
    extends
        _$ConditionsAdmissionModelCopyWithImpl<
          $Res,
          _$ConditionsAdmissionModelImpl
        >
    implements _$$ConditionsAdmissionModelImplCopyWith<$Res> {
  __$$ConditionsAdmissionModelImplCopyWithImpl(
    _$ConditionsAdmissionModelImpl _value,
    $Res Function(_$ConditionsAdmissionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConditionsAdmissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seriesAcceptees = null,
    Object? moyenneMinimale = freezed,
    Object? prerequis = freezed,
  }) {
    return _then(
      _$ConditionsAdmissionModelImpl(
        seriesAcceptees: null == seriesAcceptees
            ? _value._seriesAcceptees
            : seriesAcceptees // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        moyenneMinimale: freezed == moyenneMinimale
            ? _value.moyenneMinimale
            : moyenneMinimale // ignore: cast_nullable_to_non_nullable
                  as double?,
        prerequis: freezed == prerequis
            ? _value.prerequis
            : prerequis // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ConditionsAdmissionModelImpl extends _ConditionsAdmissionModel {
  const _$ConditionsAdmissionModelImpl({
    final List<String> seriesAcceptees = const <String>[],
    this.moyenneMinimale,
    this.prerequis,
  }) : _seriesAcceptees = seriesAcceptees,
       super._();

  final List<String> _seriesAcceptees;
  @override
  @JsonKey()
  List<String> get seriesAcceptees {
    if (_seriesAcceptees is EqualUnmodifiableListView) return _seriesAcceptees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seriesAcceptees);
  }

  @override
  final double? moyenneMinimale;
  @override
  final String? prerequis;

  @override
  String toString() {
    return 'ConditionsAdmissionModel(seriesAcceptees: $seriesAcceptees, moyenneMinimale: $moyenneMinimale, prerequis: $prerequis)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConditionsAdmissionModelImpl &&
            const DeepCollectionEquality().equals(
              other._seriesAcceptees,
              _seriesAcceptees,
            ) &&
            (identical(other.moyenneMinimale, moyenneMinimale) ||
                other.moyenneMinimale == moyenneMinimale) &&
            (identical(other.prerequis, prerequis) ||
                other.prerequis == prerequis));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_seriesAcceptees),
    moyenneMinimale,
    prerequis,
  );

  /// Create a copy of ConditionsAdmissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConditionsAdmissionModelImplCopyWith<_$ConditionsAdmissionModelImpl>
  get copyWith =>
      __$$ConditionsAdmissionModelImplCopyWithImpl<
        _$ConditionsAdmissionModelImpl
      >(this, _$identity);
}

abstract class _ConditionsAdmissionModel extends ConditionsAdmissionModel {
  const factory _ConditionsAdmissionModel({
    final List<String> seriesAcceptees,
    final double? moyenneMinimale,
    final String? prerequis,
  }) = _$ConditionsAdmissionModelImpl;
  const _ConditionsAdmissionModel._() : super._();

  @override
  List<String> get seriesAcceptees;
  @override
  double? get moyenneMinimale;
  @override
  String? get prerequis;

  /// Create a copy of ConditionsAdmissionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConditionsAdmissionModelImplCopyWith<_$ConditionsAdmissionModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RecommandationModel {
  String get formationId => throw _privateConstructorUsedError;
  String get intitule => throw _privateConstructorUsedError;
  String? get niveau => throw _privateConstructorUsedError;
  String? get domaine => throw _privateConstructorUsedError;
  String get universiteId => throw _privateConstructorUsedError;
  String get universiteNom => throw _privateConstructorUsedError;
  String? get universiteRegion => throw _privateConstructorUsedError;
  double get scoreCorrespondance => throw _privateConstructorUsedError;
  String get explicationLlm => throw _privateConstructorUsedError;
  ConditionsAdmissionModel? get conditionsAdmission =>
      throw _privateConstructorUsedError;
  String? get debouches => throw _privateConstructorUsedError;

  /// Create a copy of RecommandationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommandationModelCopyWith<RecommandationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommandationModelCopyWith<$Res> {
  factory $RecommandationModelCopyWith(
    RecommandationModel value,
    $Res Function(RecommandationModel) then,
  ) = _$RecommandationModelCopyWithImpl<$Res, RecommandationModel>;
  @useResult
  $Res call({
    String formationId,
    String intitule,
    String? niveau,
    String? domaine,
    String universiteId,
    String universiteNom,
    String? universiteRegion,
    double scoreCorrespondance,
    String explicationLlm,
    ConditionsAdmissionModel? conditionsAdmission,
    String? debouches,
  });

  $ConditionsAdmissionModelCopyWith<$Res>? get conditionsAdmission;
}

/// @nodoc
class _$RecommandationModelCopyWithImpl<$Res, $Val extends RecommandationModel>
    implements $RecommandationModelCopyWith<$Res> {
  _$RecommandationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommandationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formationId = null,
    Object? intitule = null,
    Object? niveau = freezed,
    Object? domaine = freezed,
    Object? universiteId = null,
    Object? universiteNom = null,
    Object? universiteRegion = freezed,
    Object? scoreCorrespondance = null,
    Object? explicationLlm = null,
    Object? conditionsAdmission = freezed,
    Object? debouches = freezed,
  }) {
    return _then(
      _value.copyWith(
            formationId: null == formationId
                ? _value.formationId
                : formationId // ignore: cast_nullable_to_non_nullable
                      as String,
            intitule: null == intitule
                ? _value.intitule
                : intitule // ignore: cast_nullable_to_non_nullable
                      as String,
            niveau: freezed == niveau
                ? _value.niveau
                : niveau // ignore: cast_nullable_to_non_nullable
                      as String?,
            domaine: freezed == domaine
                ? _value.domaine
                : domaine // ignore: cast_nullable_to_non_nullable
                      as String?,
            universiteId: null == universiteId
                ? _value.universiteId
                : universiteId // ignore: cast_nullable_to_non_nullable
                      as String,
            universiteNom: null == universiteNom
                ? _value.universiteNom
                : universiteNom // ignore: cast_nullable_to_non_nullable
                      as String,
            universiteRegion: freezed == universiteRegion
                ? _value.universiteRegion
                : universiteRegion // ignore: cast_nullable_to_non_nullable
                      as String?,
            scoreCorrespondance: null == scoreCorrespondance
                ? _value.scoreCorrespondance
                : scoreCorrespondance // ignore: cast_nullable_to_non_nullable
                      as double,
            explicationLlm: null == explicationLlm
                ? _value.explicationLlm
                : explicationLlm // ignore: cast_nullable_to_non_nullable
                      as String,
            conditionsAdmission: freezed == conditionsAdmission
                ? _value.conditionsAdmission
                : conditionsAdmission // ignore: cast_nullable_to_non_nullable
                      as ConditionsAdmissionModel?,
            debouches: freezed == debouches
                ? _value.debouches
                : debouches // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of RecommandationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConditionsAdmissionModelCopyWith<$Res>? get conditionsAdmission {
    if (_value.conditionsAdmission == null) {
      return null;
    }

    return $ConditionsAdmissionModelCopyWith<$Res>(
      _value.conditionsAdmission!,
      (value) {
        return _then(_value.copyWith(conditionsAdmission: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$RecommandationModelImplCopyWith<$Res>
    implements $RecommandationModelCopyWith<$Res> {
  factory _$$RecommandationModelImplCopyWith(
    _$RecommandationModelImpl value,
    $Res Function(_$RecommandationModelImpl) then,
  ) = __$$RecommandationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String formationId,
    String intitule,
    String? niveau,
    String? domaine,
    String universiteId,
    String universiteNom,
    String? universiteRegion,
    double scoreCorrespondance,
    String explicationLlm,
    ConditionsAdmissionModel? conditionsAdmission,
    String? debouches,
  });

  @override
  $ConditionsAdmissionModelCopyWith<$Res>? get conditionsAdmission;
}

/// @nodoc
class __$$RecommandationModelImplCopyWithImpl<$Res>
    extends _$RecommandationModelCopyWithImpl<$Res, _$RecommandationModelImpl>
    implements _$$RecommandationModelImplCopyWith<$Res> {
  __$$RecommandationModelImplCopyWithImpl(
    _$RecommandationModelImpl _value,
    $Res Function(_$RecommandationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecommandationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formationId = null,
    Object? intitule = null,
    Object? niveau = freezed,
    Object? domaine = freezed,
    Object? universiteId = null,
    Object? universiteNom = null,
    Object? universiteRegion = freezed,
    Object? scoreCorrespondance = null,
    Object? explicationLlm = null,
    Object? conditionsAdmission = freezed,
    Object? debouches = freezed,
  }) {
    return _then(
      _$RecommandationModelImpl(
        formationId: null == formationId
            ? _value.formationId
            : formationId // ignore: cast_nullable_to_non_nullable
                  as String,
        intitule: null == intitule
            ? _value.intitule
            : intitule // ignore: cast_nullable_to_non_nullable
                  as String,
        niveau: freezed == niveau
            ? _value.niveau
            : niveau // ignore: cast_nullable_to_non_nullable
                  as String?,
        domaine: freezed == domaine
            ? _value.domaine
            : domaine // ignore: cast_nullable_to_non_nullable
                  as String?,
        universiteId: null == universiteId
            ? _value.universiteId
            : universiteId // ignore: cast_nullable_to_non_nullable
                  as String,
        universiteNom: null == universiteNom
            ? _value.universiteNom
            : universiteNom // ignore: cast_nullable_to_non_nullable
                  as String,
        universiteRegion: freezed == universiteRegion
            ? _value.universiteRegion
            : universiteRegion // ignore: cast_nullable_to_non_nullable
                  as String?,
        scoreCorrespondance: null == scoreCorrespondance
            ? _value.scoreCorrespondance
            : scoreCorrespondance // ignore: cast_nullable_to_non_nullable
                  as double,
        explicationLlm: null == explicationLlm
            ? _value.explicationLlm
            : explicationLlm // ignore: cast_nullable_to_non_nullable
                  as String,
        conditionsAdmission: freezed == conditionsAdmission
            ? _value.conditionsAdmission
            : conditionsAdmission // ignore: cast_nullable_to_non_nullable
                  as ConditionsAdmissionModel?,
        debouches: freezed == debouches
            ? _value.debouches
            : debouches // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$RecommandationModelImpl extends _RecommandationModel {
  const _$RecommandationModelImpl({
    required this.formationId,
    required this.intitule,
    this.niveau,
    this.domaine,
    required this.universiteId,
    required this.universiteNom,
    this.universiteRegion,
    required this.scoreCorrespondance,
    required this.explicationLlm,
    this.conditionsAdmission,
    this.debouches,
  }) : super._();

  @override
  final String formationId;
  @override
  final String intitule;
  @override
  final String? niveau;
  @override
  final String? domaine;
  @override
  final String universiteId;
  @override
  final String universiteNom;
  @override
  final String? universiteRegion;
  @override
  final double scoreCorrespondance;
  @override
  final String explicationLlm;
  @override
  final ConditionsAdmissionModel? conditionsAdmission;
  @override
  final String? debouches;

  @override
  String toString() {
    return 'RecommandationModel(formationId: $formationId, intitule: $intitule, niveau: $niveau, domaine: $domaine, universiteId: $universiteId, universiteNom: $universiteNom, universiteRegion: $universiteRegion, scoreCorrespondance: $scoreCorrespondance, explicationLlm: $explicationLlm, conditionsAdmission: $conditionsAdmission, debouches: $debouches)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommandationModelImpl &&
            (identical(other.formationId, formationId) ||
                other.formationId == formationId) &&
            (identical(other.intitule, intitule) ||
                other.intitule == intitule) &&
            (identical(other.niveau, niveau) || other.niveau == niveau) &&
            (identical(other.domaine, domaine) || other.domaine == domaine) &&
            (identical(other.universiteId, universiteId) ||
                other.universiteId == universiteId) &&
            (identical(other.universiteNom, universiteNom) ||
                other.universiteNom == universiteNom) &&
            (identical(other.universiteRegion, universiteRegion) ||
                other.universiteRegion == universiteRegion) &&
            (identical(other.scoreCorrespondance, scoreCorrespondance) ||
                other.scoreCorrespondance == scoreCorrespondance) &&
            (identical(other.explicationLlm, explicationLlm) ||
                other.explicationLlm == explicationLlm) &&
            (identical(other.conditionsAdmission, conditionsAdmission) ||
                other.conditionsAdmission == conditionsAdmission) &&
            (identical(other.debouches, debouches) ||
                other.debouches == debouches));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    formationId,
    intitule,
    niveau,
    domaine,
    universiteId,
    universiteNom,
    universiteRegion,
    scoreCorrespondance,
    explicationLlm,
    conditionsAdmission,
    debouches,
  );

  /// Create a copy of RecommandationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommandationModelImplCopyWith<_$RecommandationModelImpl> get copyWith =>
      __$$RecommandationModelImplCopyWithImpl<_$RecommandationModelImpl>(
        this,
        _$identity,
      );
}

abstract class _RecommandationModel extends RecommandationModel {
  const factory _RecommandationModel({
    required final String formationId,
    required final String intitule,
    final String? niveau,
    final String? domaine,
    required final String universiteId,
    required final String universiteNom,
    final String? universiteRegion,
    required final double scoreCorrespondance,
    required final String explicationLlm,
    final ConditionsAdmissionModel? conditionsAdmission,
    final String? debouches,
  }) = _$RecommandationModelImpl;
  const _RecommandationModel._() : super._();

  @override
  String get formationId;
  @override
  String get intitule;
  @override
  String? get niveau;
  @override
  String? get domaine;
  @override
  String get universiteId;
  @override
  String get universiteNom;
  @override
  String? get universiteRegion;
  @override
  double get scoreCorrespondance;
  @override
  String get explicationLlm;
  @override
  ConditionsAdmissionModel? get conditionsAdmission;
  @override
  String? get debouches;

  /// Create a copy of RecommandationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommandationModelImplCopyWith<_$RecommandationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
