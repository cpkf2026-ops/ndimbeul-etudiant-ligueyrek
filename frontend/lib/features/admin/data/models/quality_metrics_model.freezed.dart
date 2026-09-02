
part of 'quality_metrics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QualityMetricsLaravelModel _$QualityMetricsLaravelModelFromJson(
  Map<String, dynamic> json,
) {
  return _QualityMetricsLaravelModel.fromJson(json);
}

/// @nodoc
mixin _$QualityMetricsLaravelModel {
  // ignore: invalid_annotation_target
  @JsonKey(name: 'sources_actives')
  int? get sourcesActives => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'sources_en_erreur')
  int? get sourcesEnErreur => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'sources_obsoletes')
  int? get sourcesObsoletes => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'offres_actives')
  int? get offresActives => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'offres_expirees')
  int? get offresExpirees => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'actions_admin_7_derniers_jours')
  int? get actionsAdmin7DerniersJours => throw _privateConstructorUsedError;

  /// Serializes this QualityMetricsLaravelModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QualityMetricsLaravelModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QualityMetricsLaravelModelCopyWith<QualityMetricsLaravelModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QualityMetricsLaravelModelCopyWith<$Res> {
  factory $QualityMetricsLaravelModelCopyWith(
    QualityMetricsLaravelModel value,
    $Res Function(QualityMetricsLaravelModel) then,
  ) =
      _$QualityMetricsLaravelModelCopyWithImpl<
        $Res,
        QualityMetricsLaravelModel
      >;
  @useResult
  $Res call({
    @JsonKey(name: 'sources_actives') int? sourcesActives,
    @JsonKey(name: 'sources_en_erreur') int? sourcesEnErreur,
    @JsonKey(name: 'sources_obsoletes') int? sourcesObsoletes,
    @JsonKey(name: 'offres_actives') int? offresActives,
    @JsonKey(name: 'offres_expirees') int? offresExpirees,
    @JsonKey(name: 'actions_admin_7_derniers_jours')
    int? actionsAdmin7DerniersJours,
  });
}

/// @nodoc
class _$QualityMetricsLaravelModelCopyWithImpl<
  $Res,
  $Val extends QualityMetricsLaravelModel
>
    implements $QualityMetricsLaravelModelCopyWith<$Res> {
  _$QualityMetricsLaravelModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QualityMetricsLaravelModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourcesActives = freezed,
    Object? sourcesEnErreur = freezed,
    Object? sourcesObsoletes = freezed,
    Object? offresActives = freezed,
    Object? offresExpirees = freezed,
    Object? actionsAdmin7DerniersJours = freezed,
  }) {
    return _then(
      _value.copyWith(
            sourcesActives: freezed == sourcesActives
                ? _value.sourcesActives
                : sourcesActives // ignore: cast_nullable_to_non_nullable
                      as int?,
            sourcesEnErreur: freezed == sourcesEnErreur
                ? _value.sourcesEnErreur
                : sourcesEnErreur // ignore: cast_nullable_to_non_nullable
                      as int?,
            sourcesObsoletes: freezed == sourcesObsoletes
                ? _value.sourcesObsoletes
                : sourcesObsoletes // ignore: cast_nullable_to_non_nullable
                      as int?,
            offresActives: freezed == offresActives
                ? _value.offresActives
                : offresActives // ignore: cast_nullable_to_non_nullable
                      as int?,
            offresExpirees: freezed == offresExpirees
                ? _value.offresExpirees
                : offresExpirees // ignore: cast_nullable_to_non_nullable
                      as int?,
            actionsAdmin7DerniersJours: freezed == actionsAdmin7DerniersJours
                ? _value.actionsAdmin7DerniersJours
                : actionsAdmin7DerniersJours // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QualityMetricsLaravelModelImplCopyWith<$Res>
    implements $QualityMetricsLaravelModelCopyWith<$Res> {
  factory _$$QualityMetricsLaravelModelImplCopyWith(
    _$QualityMetricsLaravelModelImpl value,
    $Res Function(_$QualityMetricsLaravelModelImpl) then,
  ) = __$$QualityMetricsLaravelModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'sources_actives') int? sourcesActives,
    @JsonKey(name: 'sources_en_erreur') int? sourcesEnErreur,
    @JsonKey(name: 'sources_obsoletes') int? sourcesObsoletes,
    @JsonKey(name: 'offres_actives') int? offresActives,
    @JsonKey(name: 'offres_expirees') int? offresExpirees,
    @JsonKey(name: 'actions_admin_7_derniers_jours')
    int? actionsAdmin7DerniersJours,
  });
}

/// @nodoc
class __$$QualityMetricsLaravelModelImplCopyWithImpl<$Res>
    extends
        _$QualityMetricsLaravelModelCopyWithImpl<
          $Res,
          _$QualityMetricsLaravelModelImpl
        >
    implements _$$QualityMetricsLaravelModelImplCopyWith<$Res> {
  __$$QualityMetricsLaravelModelImplCopyWithImpl(
    _$QualityMetricsLaravelModelImpl _value,
    $Res Function(_$QualityMetricsLaravelModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QualityMetricsLaravelModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourcesActives = freezed,
    Object? sourcesEnErreur = freezed,
    Object? sourcesObsoletes = freezed,
    Object? offresActives = freezed,
    Object? offresExpirees = freezed,
    Object? actionsAdmin7DerniersJours = freezed,
  }) {
    return _then(
      _$QualityMetricsLaravelModelImpl(
        sourcesActives: freezed == sourcesActives
            ? _value.sourcesActives
            : sourcesActives // ignore: cast_nullable_to_non_nullable
                  as int?,
        sourcesEnErreur: freezed == sourcesEnErreur
            ? _value.sourcesEnErreur
            : sourcesEnErreur // ignore: cast_nullable_to_non_nullable
                  as int?,
        sourcesObsoletes: freezed == sourcesObsoletes
            ? _value.sourcesObsoletes
            : sourcesObsoletes // ignore: cast_nullable_to_non_nullable
                  as int?,
        offresActives: freezed == offresActives
            ? _value.offresActives
            : offresActives // ignore: cast_nullable_to_non_nullable
                  as int?,
        offresExpirees: freezed == offresExpirees
            ? _value.offresExpirees
            : offresExpirees // ignore: cast_nullable_to_non_nullable
                  as int?,
        actionsAdmin7DerniersJours: freezed == actionsAdmin7DerniersJours
            ? _value.actionsAdmin7DerniersJours
            : actionsAdmin7DerniersJours // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QualityMetricsLaravelModelImpl extends _QualityMetricsLaravelModel {
  const _$QualityMetricsLaravelModelImpl({
    @JsonKey(name: 'sources_actives') this.sourcesActives,
    @JsonKey(name: 'sources_en_erreur') this.sourcesEnErreur,
    @JsonKey(name: 'sources_obsoletes') this.sourcesObsoletes,
    @JsonKey(name: 'offres_actives') this.offresActives,
    @JsonKey(name: 'offres_expirees') this.offresExpirees,
    @JsonKey(name: 'actions_admin_7_derniers_jours')
    this.actionsAdmin7DerniersJours,
  }) : super._();

  factory _$QualityMetricsLaravelModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$QualityMetricsLaravelModelImplFromJson(json);

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'sources_actives')
  final int? sourcesActives;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'sources_en_erreur')
  final int? sourcesEnErreur;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'sources_obsoletes')
  final int? sourcesObsoletes;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'offres_actives')
  final int? offresActives;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'offres_expirees')
  final int? offresExpirees;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'actions_admin_7_derniers_jours')
  final int? actionsAdmin7DerniersJours;

  @override
  String toString() {
    return 'QualityMetricsLaravelModel(sourcesActives: $sourcesActives, sourcesEnErreur: $sourcesEnErreur, sourcesObsoletes: $sourcesObsoletes, offresActives: $offresActives, offresExpirees: $offresExpirees, actionsAdmin7DerniersJours: $actionsAdmin7DerniersJours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QualityMetricsLaravelModelImpl &&
            (identical(other.sourcesActives, sourcesActives) ||
                other.sourcesActives == sourcesActives) &&
            (identical(other.sourcesEnErreur, sourcesEnErreur) ||
                other.sourcesEnErreur == sourcesEnErreur) &&
            (identical(other.sourcesObsoletes, sourcesObsoletes) ||
                other.sourcesObsoletes == sourcesObsoletes) &&
            (identical(other.offresActives, offresActives) ||
                other.offresActives == offresActives) &&
            (identical(other.offresExpirees, offresExpirees) ||
                other.offresExpirees == offresExpirees) &&
            (identical(
                  other.actionsAdmin7DerniersJours,
                  actionsAdmin7DerniersJours,
                ) ||
                other.actionsAdmin7DerniersJours ==
                    actionsAdmin7DerniersJours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sourcesActives,
    sourcesEnErreur,
    sourcesObsoletes,
    offresActives,
    offresExpirees,
    actionsAdmin7DerniersJours,
  );

  /// Create a copy of QualityMetricsLaravelModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QualityMetricsLaravelModelImplCopyWith<_$QualityMetricsLaravelModelImpl>
  get copyWith =>
      __$$QualityMetricsLaravelModelImplCopyWithImpl<
        _$QualityMetricsLaravelModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QualityMetricsLaravelModelImplToJson(this);
  }
}

abstract class _QualityMetricsLaravelModel extends QualityMetricsLaravelModel {
  const factory _QualityMetricsLaravelModel({
    @JsonKey(name: 'sources_actives') final int? sourcesActives,
    @JsonKey(name: 'sources_en_erreur') final int? sourcesEnErreur,
    @JsonKey(name: 'sources_obsoletes') final int? sourcesObsoletes,
    @JsonKey(name: 'offres_actives') final int? offresActives,
    @JsonKey(name: 'offres_expirees') final int? offresExpirees,
    @JsonKey(name: 'actions_admin_7_derniers_jours')
    final int? actionsAdmin7DerniersJours,
  }) = _$QualityMetricsLaravelModelImpl;
  const _QualityMetricsLaravelModel._() : super._();

  factory _QualityMetricsLaravelModel.fromJson(Map<String, dynamic> json) =
      _$QualityMetricsLaravelModelImpl.fromJson;

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'sources_actives')
  int? get sourcesActives; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'sources_en_erreur')
  int? get sourcesEnErreur; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'sources_obsoletes')
  int? get sourcesObsoletes; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'offres_actives')
  int? get offresActives; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'offres_expirees')
  int? get offresExpirees; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'actions_admin_7_derniers_jours')
  int? get actionsAdmin7DerniersJours;

  /// Create a copy of QualityMetricsLaravelModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QualityMetricsLaravelModelImplCopyWith<_$QualityMetricsLaravelModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

QualityMetricsModel _$QualityMetricsModelFromJson(Map<String, dynamic> json) {
  return _QualityMetricsModel.fromJson(json);
}

/// @nodoc
mixin _$QualityMetricsModel {
  // ignore: invalid_annotation_target
  @JsonKey(name: 'metriques_ia')
  Map<String, dynamic>? get metriquesIa => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'metriques_laravel')
  QualityMetricsLaravelModel? get metriquesLaravel =>
      throw _privateConstructorUsedError;

  /// Serializes this QualityMetricsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QualityMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QualityMetricsModelCopyWith<QualityMetricsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QualityMetricsModelCopyWith<$Res> {
  factory $QualityMetricsModelCopyWith(
    QualityMetricsModel value,
    $Res Function(QualityMetricsModel) then,
  ) = _$QualityMetricsModelCopyWithImpl<$Res, QualityMetricsModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'metriques_ia') Map<String, dynamic>? metriquesIa,
    @JsonKey(name: 'metriques_laravel')
    QualityMetricsLaravelModel? metriquesLaravel,
  });

  $QualityMetricsLaravelModelCopyWith<$Res>? get metriquesLaravel;
}

/// @nodoc
class _$QualityMetricsModelCopyWithImpl<$Res, $Val extends QualityMetricsModel>
    implements $QualityMetricsModelCopyWith<$Res> {
  _$QualityMetricsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QualityMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metriquesIa = freezed,
    Object? metriquesLaravel = freezed,
  }) {
    return _then(
      _value.copyWith(
            metriquesIa: freezed == metriquesIa
                ? _value.metriquesIa
                : metriquesIa // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            metriquesLaravel: freezed == metriquesLaravel
                ? _value.metriquesLaravel
                : metriquesLaravel // ignore: cast_nullable_to_non_nullable
                      as QualityMetricsLaravelModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of QualityMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $QualityMetricsLaravelModelCopyWith<$Res>? get metriquesLaravel {
    if (_value.metriquesLaravel == null) {
      return null;
    }

    return $QualityMetricsLaravelModelCopyWith<$Res>(_value.metriquesLaravel!, (
      value,
    ) {
      return _then(_value.copyWith(metriquesLaravel: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$QualityMetricsModelImplCopyWith<$Res>
    implements $QualityMetricsModelCopyWith<$Res> {
  factory _$$QualityMetricsModelImplCopyWith(
    _$QualityMetricsModelImpl value,
    $Res Function(_$QualityMetricsModelImpl) then,
  ) = __$$QualityMetricsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'metriques_ia') Map<String, dynamic>? metriquesIa,
    @JsonKey(name: 'metriques_laravel')
    QualityMetricsLaravelModel? metriquesLaravel,
  });

  @override
  $QualityMetricsLaravelModelCopyWith<$Res>? get metriquesLaravel;
}

/// @nodoc
class __$$QualityMetricsModelImplCopyWithImpl<$Res>
    extends _$QualityMetricsModelCopyWithImpl<$Res, _$QualityMetricsModelImpl>
    implements _$$QualityMetricsModelImplCopyWith<$Res> {
  __$$QualityMetricsModelImplCopyWithImpl(
    _$QualityMetricsModelImpl _value,
    $Res Function(_$QualityMetricsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QualityMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metriquesIa = freezed,
    Object? metriquesLaravel = freezed,
  }) {
    return _then(
      _$QualityMetricsModelImpl(
        metriquesIa: freezed == metriquesIa
            ? _value._metriquesIa
            : metriquesIa // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        metriquesLaravel: freezed == metriquesLaravel
            ? _value.metriquesLaravel
            : metriquesLaravel // ignore: cast_nullable_to_non_nullable
                  as QualityMetricsLaravelModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QualityMetricsModelImpl extends _QualityMetricsModel {
  const _$QualityMetricsModelImpl({
    @JsonKey(name: 'metriques_ia') final Map<String, dynamic>? metriquesIa,
    @JsonKey(name: 'metriques_laravel') this.metriquesLaravel,
  }) : _metriquesIa = metriquesIa,
       super._();

  factory _$QualityMetricsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$QualityMetricsModelImplFromJson(json);

  // ignore: invalid_annotation_target
  final Map<String, dynamic>? _metriquesIa;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'metriques_ia')
  Map<String, dynamic>? get metriquesIa {
    final value = _metriquesIa;
    if (value == null) return null;
    if (_metriquesIa is EqualUnmodifiableMapView) return _metriquesIa;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'metriques_laravel')
  final QualityMetricsLaravelModel? metriquesLaravel;

  @override
  String toString() {
    return 'QualityMetricsModel(metriquesIa: $metriquesIa, metriquesLaravel: $metriquesLaravel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QualityMetricsModelImpl &&
            const DeepCollectionEquality().equals(
              other._metriquesIa,
              _metriquesIa,
            ) &&
            (identical(other.metriquesLaravel, metriquesLaravel) ||
                other.metriquesLaravel == metriquesLaravel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_metriquesIa),
    metriquesLaravel,
  );

  /// Create a copy of QualityMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QualityMetricsModelImplCopyWith<_$QualityMetricsModelImpl> get copyWith =>
      __$$QualityMetricsModelImplCopyWithImpl<_$QualityMetricsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QualityMetricsModelImplToJson(this);
  }
}

abstract class _QualityMetricsModel extends QualityMetricsModel {
  const factory _QualityMetricsModel({
    @JsonKey(name: 'metriques_ia') final Map<String, dynamic>? metriquesIa,
    @JsonKey(name: 'metriques_laravel')
    final QualityMetricsLaravelModel? metriquesLaravel,
  }) = _$QualityMetricsModelImpl;
  const _QualityMetricsModel._() : super._();

  factory _QualityMetricsModel.fromJson(Map<String, dynamic> json) =
      _$QualityMetricsModelImpl.fromJson;

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'metriques_ia')
  Map<String, dynamic>? get metriquesIa; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'metriques_laravel')
  QualityMetricsLaravelModel? get metriquesLaravel;

  /// Create a copy of QualityMetricsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QualityMetricsModelImplCopyWith<_$QualityMetricsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
