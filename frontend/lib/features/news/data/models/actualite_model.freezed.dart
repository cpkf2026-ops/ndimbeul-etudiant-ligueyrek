// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'actualite_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActualiteModel _$ActualiteModelFromJson(Map<String, dynamic> json) {
  return _ActualiteModel.fromJson(json);
}

/// @nodoc
mixin _$ActualiteModel {
  String get id => throw _privateConstructorUsedError;
  String get titre => throw _privateConstructorUsedError;
  String get contenu =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _categorieFromJson, toJson: _categorieToJson)
  CategorieActualite get categorie => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'source_url')
  String? get sourceUrl => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_publication')
  DateTime get datePublication => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_indexation')
  DateTime? get dateIndexation => throw _privateConstructorUsedError;
  String? get auteur => throw _privateConstructorUsedError;
  String? get fiabilite => throw _privateConstructorUsedError;

  /// Serializes this ActualiteModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActualiteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActualiteModelCopyWith<ActualiteModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActualiteModelCopyWith<$Res> {
  factory $ActualiteModelCopyWith(
    ActualiteModel value,
    $Res Function(ActualiteModel) then,
  ) = _$ActualiteModelCopyWithImpl<$Res, ActualiteModel>;
  @useResult
  $Res call({
    String id,
    String titre,
    String contenu,
    @JsonKey(fromJson: _categorieFromJson, toJson: _categorieToJson)
    CategorieActualite categorie,
    @JsonKey(name: 'source_url') String? sourceUrl,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'date_publication') DateTime datePublication,
    @JsonKey(name: 'date_indexation') DateTime? dateIndexation,
    String? auteur,
    String? fiabilite,
  });
}

/// @nodoc
class _$ActualiteModelCopyWithImpl<$Res, $Val extends ActualiteModel>
    implements $ActualiteModelCopyWith<$Res> {
  _$ActualiteModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActualiteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titre = null,
    Object? contenu = null,
    Object? categorie = null,
    Object? sourceUrl = freezed,
    Object? imageUrl = freezed,
    Object? datePublication = null,
    Object? dateIndexation = freezed,
    Object? auteur = freezed,
    Object? fiabilite = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            titre: null == titre
                ? _value.titre
                : titre // ignore: cast_nullable_to_non_nullable
                      as String,
            contenu: null == contenu
                ? _value.contenu
                : contenu // ignore: cast_nullable_to_non_nullable
                      as String,
            categorie: null == categorie
                ? _value.categorie
                : categorie // ignore: cast_nullable_to_non_nullable
                      as CategorieActualite,
            sourceUrl: freezed == sourceUrl
                ? _value.sourceUrl
                : sourceUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            datePublication: null == datePublication
                ? _value.datePublication
                : datePublication // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dateIndexation: freezed == dateIndexation
                ? _value.dateIndexation
                : dateIndexation // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            auteur: freezed == auteur
                ? _value.auteur
                : auteur // ignore: cast_nullable_to_non_nullable
                      as String?,
            fiabilite: freezed == fiabilite
                ? _value.fiabilite
                : fiabilite // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActualiteModelImplCopyWith<$Res>
    implements $ActualiteModelCopyWith<$Res> {
  factory _$$ActualiteModelImplCopyWith(
    _$ActualiteModelImpl value,
    $Res Function(_$ActualiteModelImpl) then,
  ) = __$$ActualiteModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String titre,
    String contenu,
    @JsonKey(fromJson: _categorieFromJson, toJson: _categorieToJson)
    CategorieActualite categorie,
    @JsonKey(name: 'source_url') String? sourceUrl,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'date_publication') DateTime datePublication,
    @JsonKey(name: 'date_indexation') DateTime? dateIndexation,
    String? auteur,
    String? fiabilite,
  });
}

/// @nodoc
class __$$ActualiteModelImplCopyWithImpl<$Res>
    extends _$ActualiteModelCopyWithImpl<$Res, _$ActualiteModelImpl>
    implements _$$ActualiteModelImplCopyWith<$Res> {
  __$$ActualiteModelImplCopyWithImpl(
    _$ActualiteModelImpl _value,
    $Res Function(_$ActualiteModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActualiteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titre = null,
    Object? contenu = null,
    Object? categorie = null,
    Object? sourceUrl = freezed,
    Object? imageUrl = freezed,
    Object? datePublication = null,
    Object? dateIndexation = freezed,
    Object? auteur = freezed,
    Object? fiabilite = freezed,
  }) {
    return _then(
      _$ActualiteModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        titre: null == titre
            ? _value.titre
            : titre // ignore: cast_nullable_to_non_nullable
                  as String,
        contenu: null == contenu
            ? _value.contenu
            : contenu // ignore: cast_nullable_to_non_nullable
                  as String,
        categorie: null == categorie
            ? _value.categorie
            : categorie // ignore: cast_nullable_to_non_nullable
                  as CategorieActualite,
        sourceUrl: freezed == sourceUrl
            ? _value.sourceUrl
            : sourceUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        datePublication: null == datePublication
            ? _value.datePublication
            : datePublication // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dateIndexation: freezed == dateIndexation
            ? _value.dateIndexation
            : dateIndexation // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        auteur: freezed == auteur
            ? _value.auteur
            : auteur // ignore: cast_nullable_to_non_nullable
                  as String?,
        fiabilite: freezed == fiabilite
            ? _value.fiabilite
            : fiabilite // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActualiteModelImpl extends _ActualiteModel {
  const _$ActualiteModelImpl({
    required this.id,
    required this.titre,
    required this.contenu,
    @JsonKey(fromJson: _categorieFromJson, toJson: _categorieToJson)
    required this.categorie,
    @JsonKey(name: 'source_url') this.sourceUrl,
    @JsonKey(name: 'image_url') this.imageUrl,
    @JsonKey(name: 'date_publication') required this.datePublication,
    @JsonKey(name: 'date_indexation') this.dateIndexation,
    this.auteur,
    this.fiabilite,
  }) : super._();

  factory _$ActualiteModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActualiteModelImplFromJson(json);

  @override
  final String id;
  @override
  final String titre;
  @override
  final String contenu;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _categorieFromJson, toJson: _categorieToJson)
  final CategorieActualite categorie;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'source_url')
  final String? sourceUrl;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_publication')
  final DateTime datePublication;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_indexation')
  final DateTime? dateIndexation;
  @override
  final String? auteur;
  @override
  final String? fiabilite;

  @override
  String toString() {
    return 'ActualiteModel(id: $id, titre: $titre, contenu: $contenu, categorie: $categorie, sourceUrl: $sourceUrl, imageUrl: $imageUrl, datePublication: $datePublication, dateIndexation: $dateIndexation, auteur: $auteur, fiabilite: $fiabilite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActualiteModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.titre, titre) || other.titre == titre) &&
            (identical(other.contenu, contenu) || other.contenu == contenu) &&
            (identical(other.categorie, categorie) ||
                other.categorie == categorie) &&
            (identical(other.sourceUrl, sourceUrl) ||
                other.sourceUrl == sourceUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.datePublication, datePublication) ||
                other.datePublication == datePublication) &&
            (identical(other.dateIndexation, dateIndexation) ||
                other.dateIndexation == dateIndexation) &&
            (identical(other.auteur, auteur) || other.auteur == auteur) &&
            (identical(other.fiabilite, fiabilite) ||
                other.fiabilite == fiabilite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    titre,
    contenu,
    categorie,
    sourceUrl,
    imageUrl,
    datePublication,
    dateIndexation,
    auteur,
    fiabilite,
  );

  /// Create a copy of ActualiteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActualiteModelImplCopyWith<_$ActualiteModelImpl> get copyWith =>
      __$$ActualiteModelImplCopyWithImpl<_$ActualiteModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActualiteModelImplToJson(this);
  }
}

abstract class _ActualiteModel extends ActualiteModel {
  const factory _ActualiteModel({
    required final String id,
    required final String titre,
    required final String contenu,
    @JsonKey(fromJson: _categorieFromJson, toJson: _categorieToJson)
    required final CategorieActualite categorie,
    @JsonKey(name: 'source_url') final String? sourceUrl,
    @JsonKey(name: 'image_url') final String? imageUrl,
    @JsonKey(name: 'date_publication') required final DateTime datePublication,
    @JsonKey(name: 'date_indexation') final DateTime? dateIndexation,
    final String? auteur,
    final String? fiabilite,
  }) = _$ActualiteModelImpl;
  const _ActualiteModel._() : super._();

  factory _ActualiteModel.fromJson(Map<String, dynamic> json) =
      _$ActualiteModelImpl.fromJson;

  @override
  String get id;
  @override
  String get titre;
  @override
  String get contenu; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _categorieFromJson, toJson: _categorieToJson)
  CategorieActualite get categorie; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'source_url')
  String? get sourceUrl; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_publication')
  DateTime get datePublication; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_indexation')
  DateTime? get dateIndexation;
  @override
  String? get auteur;
  @override
  String? get fiabilite;

  /// Create a copy of ActualiteModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActualiteModelImplCopyWith<_$ActualiteModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
