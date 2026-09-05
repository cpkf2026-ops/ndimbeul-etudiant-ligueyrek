// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profil_diplome_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProfilDiplomeModel _$ProfilDiplomeModelFromJson(Map<String, dynamic> json) {
  return _ProfilDiplomeModel.fromJson(json);
}

/// @nodoc
mixin _$ProfilDiplomeModel {
  // ignore: invalid_annotation_target
  @JsonKey(name: 'dernier_diplome')
  String? get dernierDiplome => throw _privateConstructorUsedError;
  String? get domaine =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(
    name: 'situation_actuelle',
    fromJson: _situationFromJson,
    toJson: _situationToJson,
  )
  SituationActuelle? get situationActuelle =>
      throw _privateConstructorUsedError;
  String? get entreprise => throw _privateConstructorUsedError;

  /// Serializes this ProfilDiplomeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfilDiplomeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfilDiplomeModelCopyWith<ProfilDiplomeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfilDiplomeModelCopyWith<$Res> {
  factory $ProfilDiplomeModelCopyWith(
    ProfilDiplomeModel value,
    $Res Function(ProfilDiplomeModel) then,
  ) = _$ProfilDiplomeModelCopyWithImpl<$Res, ProfilDiplomeModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'dernier_diplome') String? dernierDiplome,
    String? domaine,
    @JsonKey(
      name: 'situation_actuelle',
      fromJson: _situationFromJson,
      toJson: _situationToJson,
    )
    SituationActuelle? situationActuelle,
    String? entreprise,
  });
}

/// @nodoc
class _$ProfilDiplomeModelCopyWithImpl<$Res, $Val extends ProfilDiplomeModel>
    implements $ProfilDiplomeModelCopyWith<$Res> {
  _$ProfilDiplomeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfilDiplomeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dernierDiplome = freezed,
    Object? domaine = freezed,
    Object? situationActuelle = freezed,
    Object? entreprise = freezed,
  }) {
    return _then(
      _value.copyWith(
            dernierDiplome: freezed == dernierDiplome
                ? _value.dernierDiplome
                : dernierDiplome // ignore: cast_nullable_to_non_nullable
                      as String?,
            domaine: freezed == domaine
                ? _value.domaine
                : domaine // ignore: cast_nullable_to_non_nullable
                      as String?,
            situationActuelle: freezed == situationActuelle
                ? _value.situationActuelle
                : situationActuelle // ignore: cast_nullable_to_non_nullable
                      as SituationActuelle?,
            entreprise: freezed == entreprise
                ? _value.entreprise
                : entreprise // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfilDiplomeModelImplCopyWith<$Res>
    implements $ProfilDiplomeModelCopyWith<$Res> {
  factory _$$ProfilDiplomeModelImplCopyWith(
    _$ProfilDiplomeModelImpl value,
    $Res Function(_$ProfilDiplomeModelImpl) then,
  ) = __$$ProfilDiplomeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'dernier_diplome') String? dernierDiplome,
    String? domaine,
    @JsonKey(
      name: 'situation_actuelle',
      fromJson: _situationFromJson,
      toJson: _situationToJson,
    )
    SituationActuelle? situationActuelle,
    String? entreprise,
  });
}

/// @nodoc
class __$$ProfilDiplomeModelImplCopyWithImpl<$Res>
    extends _$ProfilDiplomeModelCopyWithImpl<$Res, _$ProfilDiplomeModelImpl>
    implements _$$ProfilDiplomeModelImplCopyWith<$Res> {
  __$$ProfilDiplomeModelImplCopyWithImpl(
    _$ProfilDiplomeModelImpl _value,
    $Res Function(_$ProfilDiplomeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfilDiplomeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dernierDiplome = freezed,
    Object? domaine = freezed,
    Object? situationActuelle = freezed,
    Object? entreprise = freezed,
  }) {
    return _then(
      _$ProfilDiplomeModelImpl(
        dernierDiplome: freezed == dernierDiplome
            ? _value.dernierDiplome
            : dernierDiplome // ignore: cast_nullable_to_non_nullable
                  as String?,
        domaine: freezed == domaine
            ? _value.domaine
            : domaine // ignore: cast_nullable_to_non_nullable
                  as String?,
        situationActuelle: freezed == situationActuelle
            ? _value.situationActuelle
            : situationActuelle // ignore: cast_nullable_to_non_nullable
                  as SituationActuelle?,
        entreprise: freezed == entreprise
            ? _value.entreprise
            : entreprise // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfilDiplomeModelImpl extends _ProfilDiplomeModel {
  const _$ProfilDiplomeModelImpl({
    @JsonKey(name: 'dernier_diplome') this.dernierDiplome,
    this.domaine,
    @JsonKey(
      name: 'situation_actuelle',
      fromJson: _situationFromJson,
      toJson: _situationToJson,
    )
    this.situationActuelle,
    this.entreprise,
  }) : super._();

  factory _$ProfilDiplomeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfilDiplomeModelImplFromJson(json);

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'dernier_diplome')
  final String? dernierDiplome;
  @override
  final String? domaine;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(
    name: 'situation_actuelle',
    fromJson: _situationFromJson,
    toJson: _situationToJson,
  )
  final SituationActuelle? situationActuelle;
  @override
  final String? entreprise;

  @override
  String toString() {
    return 'ProfilDiplomeModel(dernierDiplome: $dernierDiplome, domaine: $domaine, situationActuelle: $situationActuelle, entreprise: $entreprise)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfilDiplomeModelImpl &&
            (identical(other.dernierDiplome, dernierDiplome) ||
                other.dernierDiplome == dernierDiplome) &&
            (identical(other.domaine, domaine) || other.domaine == domaine) &&
            (identical(other.situationActuelle, situationActuelle) ||
                other.situationActuelle == situationActuelle) &&
            (identical(other.entreprise, entreprise) ||
                other.entreprise == entreprise));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dernierDiplome,
    domaine,
    situationActuelle,
    entreprise,
  );

  /// Create a copy of ProfilDiplomeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfilDiplomeModelImplCopyWith<_$ProfilDiplomeModelImpl> get copyWith =>
      __$$ProfilDiplomeModelImplCopyWithImpl<_$ProfilDiplomeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfilDiplomeModelImplToJson(this);
  }
}

abstract class _ProfilDiplomeModel extends ProfilDiplomeModel {
  const factory _ProfilDiplomeModel({
    @JsonKey(name: 'dernier_diplome') final String? dernierDiplome,
    final String? domaine,
    @JsonKey(
      name: 'situation_actuelle',
      fromJson: _situationFromJson,
      toJson: _situationToJson,
    )
    final SituationActuelle? situationActuelle,
    final String? entreprise,
  }) = _$ProfilDiplomeModelImpl;
  const _ProfilDiplomeModel._() : super._();

  factory _ProfilDiplomeModel.fromJson(Map<String, dynamic> json) =
      _$ProfilDiplomeModelImpl.fromJson;

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'dernier_diplome')
  String? get dernierDiplome;
  @override
  String? get domaine; // ignore: invalid_annotation_target
  @override
  @JsonKey(
    name: 'situation_actuelle',
    fromJson: _situationFromJson,
    toJson: _situationToJson,
  )
  SituationActuelle? get situationActuelle;
  @override
  String? get entreprise;

  /// Create a copy of ProfilDiplomeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfilDiplomeModelImplCopyWith<_$ProfilDiplomeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
