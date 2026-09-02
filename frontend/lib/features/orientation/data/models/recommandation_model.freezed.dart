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
mixin _$RecommandationModel {
  String get formationId => throw _privateConstructorUsedError;
  double get scoreCorrespondance => throw _privateConstructorUsedError;
  String get explicationLlm => throw _privateConstructorUsedError;
  List<String> get sourcesInfos => throw _privateConstructorUsedError;
  DateTime? get dateGeneration => throw _privateConstructorUsedError;
  String? get formationIntitule => throw _privateConstructorUsedError;
  String? get universiteId => throw _privateConstructorUsedError;
  String? get universiteNom => throw _privateConstructorUsedError;

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
    double scoreCorrespondance,
    String explicationLlm,
    List<String> sourcesInfos,
    DateTime? dateGeneration,
    String? formationIntitule,
    String? universiteId,
    String? universiteNom,
  });
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
    Object? scoreCorrespondance = null,
    Object? explicationLlm = null,
    Object? sourcesInfos = null,
    Object? dateGeneration = freezed,
    Object? formationIntitule = freezed,
    Object? universiteId = freezed,
    Object? universiteNom = freezed,
  }) {
    return _then(
      _value.copyWith(
            formationId: null == formationId
                ? _value.formationId
                : formationId // ignore: cast_nullable_to_non_nullable
                      as String,
            scoreCorrespondance: null == scoreCorrespondance
                ? _value.scoreCorrespondance
                : scoreCorrespondance // ignore: cast_nullable_to_non_nullable
                      as double,
            explicationLlm: null == explicationLlm
                ? _value.explicationLlm
                : explicationLlm // ignore: cast_nullable_to_non_nullable
                      as String,
            sourcesInfos: null == sourcesInfos
                ? _value.sourcesInfos
                : sourcesInfos // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            dateGeneration: freezed == dateGeneration
                ? _value.dateGeneration
                : dateGeneration // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            formationIntitule: freezed == formationIntitule
                ? _value.formationIntitule
                : formationIntitule // ignore: cast_nullable_to_non_nullable
                      as String?,
            universiteId: freezed == universiteId
                ? _value.universiteId
                : universiteId // ignore: cast_nullable_to_non_nullable
                      as String?,
            universiteNom: freezed == universiteNom
                ? _value.universiteNom
                : universiteNom // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
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
    double scoreCorrespondance,
    String explicationLlm,
    List<String> sourcesInfos,
    DateTime? dateGeneration,
    String? formationIntitule,
    String? universiteId,
    String? universiteNom,
  });
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
    Object? scoreCorrespondance = null,
    Object? explicationLlm = null,
    Object? sourcesInfos = null,
    Object? dateGeneration = freezed,
    Object? formationIntitule = freezed,
    Object? universiteId = freezed,
    Object? universiteNom = freezed,
  }) {
    return _then(
      _$RecommandationModelImpl(
        formationId: null == formationId
            ? _value.formationId
            : formationId // ignore: cast_nullable_to_non_nullable
                  as String,
        scoreCorrespondance: null == scoreCorrespondance
            ? _value.scoreCorrespondance
            : scoreCorrespondance // ignore: cast_nullable_to_non_nullable
                  as double,
        explicationLlm: null == explicationLlm
            ? _value.explicationLlm
            : explicationLlm // ignore: cast_nullable_to_non_nullable
                  as String,
        sourcesInfos: null == sourcesInfos
            ? _value._sourcesInfos
            : sourcesInfos // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        dateGeneration: freezed == dateGeneration
            ? _value.dateGeneration
            : dateGeneration // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        formationIntitule: freezed == formationIntitule
            ? _value.formationIntitule
            : formationIntitule // ignore: cast_nullable_to_non_nullable
                  as String?,
        universiteId: freezed == universiteId
            ? _value.universiteId
            : universiteId // ignore: cast_nullable_to_non_nullable
                  as String?,
        universiteNom: freezed == universiteNom
            ? _value.universiteNom
            : universiteNom // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$RecommandationModelImpl extends _RecommandationModel {
  const _$RecommandationModelImpl({
    required this.formationId,
    required this.scoreCorrespondance,
    required this.explicationLlm,
    final List<String> sourcesInfos = const <String>[],
    this.dateGeneration,
    this.formationIntitule,
    this.universiteId,
    this.universiteNom,
  }) : _sourcesInfos = sourcesInfos,
       super._();

  @override
  final String formationId;
  @override
  final double scoreCorrespondance;
  @override
  final String explicationLlm;
  final List<String> _sourcesInfos;
  @override
  @JsonKey()
  List<String> get sourcesInfos {
    if (_sourcesInfos is EqualUnmodifiableListView) return _sourcesInfos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sourcesInfos);
  }

  @override
  final DateTime? dateGeneration;
  @override
  final String? formationIntitule;
  @override
  final String? universiteId;
  @override
  final String? universiteNom;

  @override
  String toString() {
    return 'RecommandationModel(formationId: $formationId, scoreCorrespondance: $scoreCorrespondance, explicationLlm: $explicationLlm, sourcesInfos: $sourcesInfos, dateGeneration: $dateGeneration, formationIntitule: $formationIntitule, universiteId: $universiteId, universiteNom: $universiteNom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommandationModelImpl &&
            (identical(other.formationId, formationId) ||
                other.formationId == formationId) &&
            (identical(other.scoreCorrespondance, scoreCorrespondance) ||
                other.scoreCorrespondance == scoreCorrespondance) &&
            (identical(other.explicationLlm, explicationLlm) ||
                other.explicationLlm == explicationLlm) &&
            const DeepCollectionEquality().equals(
              other._sourcesInfos,
              _sourcesInfos,
            ) &&
            (identical(other.dateGeneration, dateGeneration) ||
                other.dateGeneration == dateGeneration) &&
            (identical(other.formationIntitule, formationIntitule) ||
                other.formationIntitule == formationIntitule) &&
            (identical(other.universiteId, universiteId) ||
                other.universiteId == universiteId) &&
            (identical(other.universiteNom, universiteNom) ||
                other.universiteNom == universiteNom));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    formationId,
    scoreCorrespondance,
    explicationLlm,
    const DeepCollectionEquality().hash(_sourcesInfos),
    dateGeneration,
    formationIntitule,
    universiteId,
    universiteNom,
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
    required final double scoreCorrespondance,
    required final String explicationLlm,
    final List<String> sourcesInfos,
    final DateTime? dateGeneration,
    final String? formationIntitule,
    final String? universiteId,
    final String? universiteNom,
  }) = _$RecommandationModelImpl;
  const _RecommandationModel._() : super._();

  @override
  String get formationId;
  @override
  double get scoreCorrespondance;
  @override
  String get explicationLlm;
  @override
  List<String> get sourcesInfos;
  @override
  DateTime? get dateGeneration;
  @override
  String? get formationIntitule;
  @override
  String? get universiteId;
  @override
  String? get universiteNom;

  /// Create a copy of RecommandationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommandationModelImplCopyWith<_$RecommandationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
