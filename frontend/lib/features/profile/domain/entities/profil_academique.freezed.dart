// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profil_academique.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProfilAcademique {
  Object get profil => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ProfilLyceen profil) lyceen,
    required TResult Function(ProfilEtudiant profil) etudiant,
    required TResult Function(ProfilDiplome profil) diplome,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ProfilLyceen profil)? lyceen,
    TResult? Function(ProfilEtudiant profil)? etudiant,
    TResult? Function(ProfilDiplome profil)? diplome,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ProfilLyceen profil)? lyceen,
    TResult Function(ProfilEtudiant profil)? etudiant,
    TResult Function(ProfilDiplome profil)? diplome,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProfilAcademiqueLyceen value) lyceen,
    required TResult Function(ProfilAcademiqueEtudiant value) etudiant,
    required TResult Function(ProfilAcademiqueDiplome value) diplome,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProfilAcademiqueLyceen value)? lyceen,
    TResult? Function(ProfilAcademiqueEtudiant value)? etudiant,
    TResult? Function(ProfilAcademiqueDiplome value)? diplome,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProfilAcademiqueLyceen value)? lyceen,
    TResult Function(ProfilAcademiqueEtudiant value)? etudiant,
    TResult Function(ProfilAcademiqueDiplome value)? diplome,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfilAcademiqueCopyWith<$Res> {
  factory $ProfilAcademiqueCopyWith(
    ProfilAcademique value,
    $Res Function(ProfilAcademique) then,
  ) = _$ProfilAcademiqueCopyWithImpl<$Res, ProfilAcademique>;
}

/// @nodoc
class _$ProfilAcademiqueCopyWithImpl<$Res, $Val extends ProfilAcademique>
    implements $ProfilAcademiqueCopyWith<$Res> {
  _$ProfilAcademiqueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ProfilAcademiqueLyceenImplCopyWith<$Res> {
  factory _$$ProfilAcademiqueLyceenImplCopyWith(
    _$ProfilAcademiqueLyceenImpl value,
    $Res Function(_$ProfilAcademiqueLyceenImpl) then,
  ) = __$$ProfilAcademiqueLyceenImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ProfilLyceen profil});

  $ProfilLyceenCopyWith<$Res> get profil;
}

/// @nodoc
class __$$ProfilAcademiqueLyceenImplCopyWithImpl<$Res>
    extends _$ProfilAcademiqueCopyWithImpl<$Res, _$ProfilAcademiqueLyceenImpl>
    implements _$$ProfilAcademiqueLyceenImplCopyWith<$Res> {
  __$$ProfilAcademiqueLyceenImplCopyWithImpl(
    _$ProfilAcademiqueLyceenImpl _value,
    $Res Function(_$ProfilAcademiqueLyceenImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? profil = null}) {
    return _then(
      _$ProfilAcademiqueLyceenImpl(
        null == profil
            ? _value.profil
            : profil // ignore: cast_nullable_to_non_nullable
                  as ProfilLyceen,
      ),
    );
  }

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfilLyceenCopyWith<$Res> get profil {
    return $ProfilLyceenCopyWith<$Res>(_value.profil, (value) {
      return _then(_value.copyWith(profil: value));
    });
  }
}

/// @nodoc

class _$ProfilAcademiqueLyceenImpl implements ProfilAcademiqueLyceen {
  const _$ProfilAcademiqueLyceenImpl(this.profil);

  @override
  final ProfilLyceen profil;

  @override
  String toString() {
    return 'ProfilAcademique.lyceen(profil: $profil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfilAcademiqueLyceenImpl &&
            (identical(other.profil, profil) || other.profil == profil));
  }

  @override
  int get hashCode => Object.hash(runtimeType, profil);

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfilAcademiqueLyceenImplCopyWith<_$ProfilAcademiqueLyceenImpl>
  get copyWith =>
      __$$ProfilAcademiqueLyceenImplCopyWithImpl<_$ProfilAcademiqueLyceenImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ProfilLyceen profil) lyceen,
    required TResult Function(ProfilEtudiant profil) etudiant,
    required TResult Function(ProfilDiplome profil) diplome,
  }) {
    return lyceen(profil);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ProfilLyceen profil)? lyceen,
    TResult? Function(ProfilEtudiant profil)? etudiant,
    TResult? Function(ProfilDiplome profil)? diplome,
  }) {
    return lyceen?.call(profil);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ProfilLyceen profil)? lyceen,
    TResult Function(ProfilEtudiant profil)? etudiant,
    TResult Function(ProfilDiplome profil)? diplome,
    required TResult orElse(),
  }) {
    if (lyceen != null) {
      return lyceen(profil);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProfilAcademiqueLyceen value) lyceen,
    required TResult Function(ProfilAcademiqueEtudiant value) etudiant,
    required TResult Function(ProfilAcademiqueDiplome value) diplome,
  }) {
    return lyceen(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProfilAcademiqueLyceen value)? lyceen,
    TResult? Function(ProfilAcademiqueEtudiant value)? etudiant,
    TResult? Function(ProfilAcademiqueDiplome value)? diplome,
  }) {
    return lyceen?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProfilAcademiqueLyceen value)? lyceen,
    TResult Function(ProfilAcademiqueEtudiant value)? etudiant,
    TResult Function(ProfilAcademiqueDiplome value)? diplome,
    required TResult orElse(),
  }) {
    if (lyceen != null) {
      return lyceen(this);
    }
    return orElse();
  }
}

abstract class ProfilAcademiqueLyceen implements ProfilAcademique {
  const factory ProfilAcademiqueLyceen(final ProfilLyceen profil) =
      _$ProfilAcademiqueLyceenImpl;

  @override
  ProfilLyceen get profil;

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfilAcademiqueLyceenImplCopyWith<_$ProfilAcademiqueLyceenImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProfilAcademiqueEtudiantImplCopyWith<$Res> {
  factory _$$ProfilAcademiqueEtudiantImplCopyWith(
    _$ProfilAcademiqueEtudiantImpl value,
    $Res Function(_$ProfilAcademiqueEtudiantImpl) then,
  ) = __$$ProfilAcademiqueEtudiantImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ProfilEtudiant profil});

  $ProfilEtudiantCopyWith<$Res> get profil;
}

/// @nodoc
class __$$ProfilAcademiqueEtudiantImplCopyWithImpl<$Res>
    extends _$ProfilAcademiqueCopyWithImpl<$Res, _$ProfilAcademiqueEtudiantImpl>
    implements _$$ProfilAcademiqueEtudiantImplCopyWith<$Res> {
  __$$ProfilAcademiqueEtudiantImplCopyWithImpl(
    _$ProfilAcademiqueEtudiantImpl _value,
    $Res Function(_$ProfilAcademiqueEtudiantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? profil = null}) {
    return _then(
      _$ProfilAcademiqueEtudiantImpl(
        null == profil
            ? _value.profil
            : profil // ignore: cast_nullable_to_non_nullable
                  as ProfilEtudiant,
      ),
    );
  }

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfilEtudiantCopyWith<$Res> get profil {
    return $ProfilEtudiantCopyWith<$Res>(_value.profil, (value) {
      return _then(_value.copyWith(profil: value));
    });
  }
}

/// @nodoc

class _$ProfilAcademiqueEtudiantImpl implements ProfilAcademiqueEtudiant {
  const _$ProfilAcademiqueEtudiantImpl(this.profil);

  @override
  final ProfilEtudiant profil;

  @override
  String toString() {
    return 'ProfilAcademique.etudiant(profil: $profil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfilAcademiqueEtudiantImpl &&
            (identical(other.profil, profil) || other.profil == profil));
  }

  @override
  int get hashCode => Object.hash(runtimeType, profil);

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfilAcademiqueEtudiantImplCopyWith<_$ProfilAcademiqueEtudiantImpl>
  get copyWith =>
      __$$ProfilAcademiqueEtudiantImplCopyWithImpl<
        _$ProfilAcademiqueEtudiantImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ProfilLyceen profil) lyceen,
    required TResult Function(ProfilEtudiant profil) etudiant,
    required TResult Function(ProfilDiplome profil) diplome,
  }) {
    return etudiant(profil);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ProfilLyceen profil)? lyceen,
    TResult? Function(ProfilEtudiant profil)? etudiant,
    TResult? Function(ProfilDiplome profil)? diplome,
  }) {
    return etudiant?.call(profil);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ProfilLyceen profil)? lyceen,
    TResult Function(ProfilEtudiant profil)? etudiant,
    TResult Function(ProfilDiplome profil)? diplome,
    required TResult orElse(),
  }) {
    if (etudiant != null) {
      return etudiant(profil);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProfilAcademiqueLyceen value) lyceen,
    required TResult Function(ProfilAcademiqueEtudiant value) etudiant,
    required TResult Function(ProfilAcademiqueDiplome value) diplome,
  }) {
    return etudiant(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProfilAcademiqueLyceen value)? lyceen,
    TResult? Function(ProfilAcademiqueEtudiant value)? etudiant,
    TResult? Function(ProfilAcademiqueDiplome value)? diplome,
  }) {
    return etudiant?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProfilAcademiqueLyceen value)? lyceen,
    TResult Function(ProfilAcademiqueEtudiant value)? etudiant,
    TResult Function(ProfilAcademiqueDiplome value)? diplome,
    required TResult orElse(),
  }) {
    if (etudiant != null) {
      return etudiant(this);
    }
    return orElse();
  }
}

abstract class ProfilAcademiqueEtudiant implements ProfilAcademique {
  const factory ProfilAcademiqueEtudiant(final ProfilEtudiant profil) =
      _$ProfilAcademiqueEtudiantImpl;

  @override
  ProfilEtudiant get profil;

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfilAcademiqueEtudiantImplCopyWith<_$ProfilAcademiqueEtudiantImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProfilAcademiqueDiplomeImplCopyWith<$Res> {
  factory _$$ProfilAcademiqueDiplomeImplCopyWith(
    _$ProfilAcademiqueDiplomeImpl value,
    $Res Function(_$ProfilAcademiqueDiplomeImpl) then,
  ) = __$$ProfilAcademiqueDiplomeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ProfilDiplome profil});

  $ProfilDiplomeCopyWith<$Res> get profil;
}

/// @nodoc
class __$$ProfilAcademiqueDiplomeImplCopyWithImpl<$Res>
    extends _$ProfilAcademiqueCopyWithImpl<$Res, _$ProfilAcademiqueDiplomeImpl>
    implements _$$ProfilAcademiqueDiplomeImplCopyWith<$Res> {
  __$$ProfilAcademiqueDiplomeImplCopyWithImpl(
    _$ProfilAcademiqueDiplomeImpl _value,
    $Res Function(_$ProfilAcademiqueDiplomeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? profil = null}) {
    return _then(
      _$ProfilAcademiqueDiplomeImpl(
        null == profil
            ? _value.profil
            : profil // ignore: cast_nullable_to_non_nullable
                  as ProfilDiplome,
      ),
    );
  }

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfilDiplomeCopyWith<$Res> get profil {
    return $ProfilDiplomeCopyWith<$Res>(_value.profil, (value) {
      return _then(_value.copyWith(profil: value));
    });
  }
}

/// @nodoc

class _$ProfilAcademiqueDiplomeImpl implements ProfilAcademiqueDiplome {
  const _$ProfilAcademiqueDiplomeImpl(this.profil);

  @override
  final ProfilDiplome profil;

  @override
  String toString() {
    return 'ProfilAcademique.diplome(profil: $profil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfilAcademiqueDiplomeImpl &&
            (identical(other.profil, profil) || other.profil == profil));
  }

  @override
  int get hashCode => Object.hash(runtimeType, profil);

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfilAcademiqueDiplomeImplCopyWith<_$ProfilAcademiqueDiplomeImpl>
  get copyWith =>
      __$$ProfilAcademiqueDiplomeImplCopyWithImpl<
        _$ProfilAcademiqueDiplomeImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ProfilLyceen profil) lyceen,
    required TResult Function(ProfilEtudiant profil) etudiant,
    required TResult Function(ProfilDiplome profil) diplome,
  }) {
    return diplome(profil);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(ProfilLyceen profil)? lyceen,
    TResult? Function(ProfilEtudiant profil)? etudiant,
    TResult? Function(ProfilDiplome profil)? diplome,
  }) {
    return diplome?.call(profil);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ProfilLyceen profil)? lyceen,
    TResult Function(ProfilEtudiant profil)? etudiant,
    TResult Function(ProfilDiplome profil)? diplome,
    required TResult orElse(),
  }) {
    if (diplome != null) {
      return diplome(profil);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProfilAcademiqueLyceen value) lyceen,
    required TResult Function(ProfilAcademiqueEtudiant value) etudiant,
    required TResult Function(ProfilAcademiqueDiplome value) diplome,
  }) {
    return diplome(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProfilAcademiqueLyceen value)? lyceen,
    TResult? Function(ProfilAcademiqueEtudiant value)? etudiant,
    TResult? Function(ProfilAcademiqueDiplome value)? diplome,
  }) {
    return diplome?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProfilAcademiqueLyceen value)? lyceen,
    TResult Function(ProfilAcademiqueEtudiant value)? etudiant,
    TResult Function(ProfilAcademiqueDiplome value)? diplome,
    required TResult orElse(),
  }) {
    if (diplome != null) {
      return diplome(this);
    }
    return orElse();
  }
}

abstract class ProfilAcademiqueDiplome implements ProfilAcademique {
  const factory ProfilAcademiqueDiplome(final ProfilDiplome profil) =
      _$ProfilAcademiqueDiplomeImpl;

  @override
  ProfilDiplome get profil;

  /// Create a copy of ProfilAcademique
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfilAcademiqueDiplomeImplCopyWith<_$ProfilAcademiqueDiplomeImpl>
  get copyWith => throw _privateConstructorUsedError;
}
