// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profil_diplome.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfilDiplome {
  String? get dernierDiplome => throw _privateConstructorUsedError;
  String? get domaine => throw _privateConstructorUsedError;
  SituationActuelle? get situationActuelle =>
      throw _privateConstructorUsedError;
  String? get entreprise => throw _privateConstructorUsedError;

  /// Create a copy of ProfilDiplome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfilDiplomeCopyWith<ProfilDiplome> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfilDiplomeCopyWith<$Res> {
  factory $ProfilDiplomeCopyWith(
    ProfilDiplome value,
    $Res Function(ProfilDiplome) then,
  ) = _$ProfilDiplomeCopyWithImpl<$Res, ProfilDiplome>;
  @useResult
  $Res call({
    String? dernierDiplome,
    String? domaine,
    SituationActuelle? situationActuelle,
    String? entreprise,
  });
}

/// @nodoc
class _$ProfilDiplomeCopyWithImpl<$Res, $Val extends ProfilDiplome>
    implements $ProfilDiplomeCopyWith<$Res> {
  _$ProfilDiplomeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfilDiplome
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
abstract class _$$ProfilDiplomeImplCopyWith<$Res>
    implements $ProfilDiplomeCopyWith<$Res> {
  factory _$$ProfilDiplomeImplCopyWith(
    _$ProfilDiplomeImpl value,
    $Res Function(_$ProfilDiplomeImpl) then,
  ) = __$$ProfilDiplomeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? dernierDiplome,
    String? domaine,
    SituationActuelle? situationActuelle,
    String? entreprise,
  });
}

/// @nodoc
class __$$ProfilDiplomeImplCopyWithImpl<$Res>
    extends _$ProfilDiplomeCopyWithImpl<$Res, _$ProfilDiplomeImpl>
    implements _$$ProfilDiplomeImplCopyWith<$Res> {
  __$$ProfilDiplomeImplCopyWithImpl(
    _$ProfilDiplomeImpl _value,
    $Res Function(_$ProfilDiplomeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfilDiplome
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
      _$ProfilDiplomeImpl(
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

class _$ProfilDiplomeImpl implements _ProfilDiplome {
  const _$ProfilDiplomeImpl({
    this.dernierDiplome,
    this.domaine,
    this.situationActuelle,
    this.entreprise,
  });

  @override
  final String? dernierDiplome;
  @override
  final String? domaine;
  @override
  final SituationActuelle? situationActuelle;
  @override
  final String? entreprise;

  @override
  String toString() {
    return 'ProfilDiplome(dernierDiplome: $dernierDiplome, domaine: $domaine, situationActuelle: $situationActuelle, entreprise: $entreprise)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfilDiplomeImpl &&
            (identical(other.dernierDiplome, dernierDiplome) ||
                other.dernierDiplome == dernierDiplome) &&
            (identical(other.domaine, domaine) || other.domaine == domaine) &&
            (identical(other.situationActuelle, situationActuelle) ||
                other.situationActuelle == situationActuelle) &&
            (identical(other.entreprise, entreprise) ||
                other.entreprise == entreprise));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    dernierDiplome,
    domaine,
    situationActuelle,
    entreprise,
  );

  /// Create a copy of ProfilDiplome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfilDiplomeImplCopyWith<_$ProfilDiplomeImpl> get copyWith =>
      __$$ProfilDiplomeImplCopyWithImpl<_$ProfilDiplomeImpl>(this, _$identity);
}

abstract class _ProfilDiplome implements ProfilDiplome {
  const factory _ProfilDiplome({
    final String? dernierDiplome,
    final String? domaine,
    final SituationActuelle? situationActuelle,
    final String? entreprise,
  }) = _$ProfilDiplomeImpl;

  @override
  String? get dernierDiplome;
  @override
  String? get domaine;
  @override
  SituationActuelle? get situationActuelle;
  @override
  String? get entreprise;

  /// Create a copy of ProfilDiplome
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfilDiplomeImplCopyWith<_$ProfilDiplomeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
