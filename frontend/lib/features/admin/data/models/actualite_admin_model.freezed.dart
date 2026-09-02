

part of 'actualite_admin_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActualiteAdminModel _$ActualiteAdminModelFromJson(Map<String, dynamic> json) {
  return _ActualiteAdminModel.fromJson(json);
}

/// @nodoc
mixin _$ActualiteAdminModel {
  String get id => throw _privateConstructorUsedError;
  String get titre => throw _privateConstructorUsedError;
  String? get contenu => throw _privateConstructorUsedError;
  String? get categorie =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'source_url')
  String? get sourceUrl => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_publication')
  DateTime? get datePublication => throw _privateConstructorUsedError;
  String? get auteur => throw _privateConstructorUsedError;

  /// Serializes this ActualiteAdminModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActualiteAdminModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActualiteAdminModelCopyWith<ActualiteAdminModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActualiteAdminModelCopyWith<$Res> {
  factory $ActualiteAdminModelCopyWith(
    ActualiteAdminModel value,
    $Res Function(ActualiteAdminModel) then,
  ) = _$ActualiteAdminModelCopyWithImpl<$Res, ActualiteAdminModel>;
  @useResult
  $Res call({
    String id,
    String titre,
    String? contenu,
    String? categorie,
    @JsonKey(name: 'source_url') String? sourceUrl,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'date_publication') DateTime? datePublication,
    String? auteur,
  });
}

/// @nodoc
class _$ActualiteAdminModelCopyWithImpl<$Res, $Val extends ActualiteAdminModel>
    implements $ActualiteAdminModelCopyWith<$Res> {
  _$ActualiteAdminModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActualiteAdminModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titre = null,
    Object? contenu = freezed,
    Object? categorie = freezed,
    Object? sourceUrl = freezed,
    Object? imageUrl = freezed,
    Object? datePublication = freezed,
    Object? auteur = freezed,
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
            contenu: freezed == contenu
                ? _value.contenu
                : contenu // ignore: cast_nullable_to_non_nullable
                      as String?,
            categorie: freezed == categorie
                ? _value.categorie
                : categorie // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceUrl: freezed == sourceUrl
                ? _value.sourceUrl
                : sourceUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            datePublication: freezed == datePublication
                ? _value.datePublication
                : datePublication // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            auteur: freezed == auteur
                ? _value.auteur
                : auteur // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActualiteAdminModelImplCopyWith<$Res>
    implements $ActualiteAdminModelCopyWith<$Res> {
  factory _$$ActualiteAdminModelImplCopyWith(
    _$ActualiteAdminModelImpl value,
    $Res Function(_$ActualiteAdminModelImpl) then,
  ) = __$$ActualiteAdminModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String titre,
    String? contenu,
    String? categorie,
    @JsonKey(name: 'source_url') String? sourceUrl,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'date_publication') DateTime? datePublication,
    String? auteur,
  });
}

/// @nodoc
class __$$ActualiteAdminModelImplCopyWithImpl<$Res>
    extends _$ActualiteAdminModelCopyWithImpl<$Res, _$ActualiteAdminModelImpl>
    implements _$$ActualiteAdminModelImplCopyWith<$Res> {
  __$$ActualiteAdminModelImplCopyWithImpl(
    _$ActualiteAdminModelImpl _value,
    $Res Function(_$ActualiteAdminModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActualiteAdminModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titre = null,
    Object? contenu = freezed,
    Object? categorie = freezed,
    Object? sourceUrl = freezed,
    Object? imageUrl = freezed,
    Object? datePublication = freezed,
    Object? auteur = freezed,
  }) {
    return _then(
      _$ActualiteAdminModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        titre: null == titre
            ? _value.titre
            : titre // ignore: cast_nullable_to_non_nullable
                  as String,
        contenu: freezed == contenu
            ? _value.contenu
            : contenu // ignore: cast_nullable_to_non_nullable
                  as String?,
        categorie: freezed == categorie
            ? _value.categorie
            : categorie // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceUrl: freezed == sourceUrl
            ? _value.sourceUrl
            : sourceUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        datePublication: freezed == datePublication
            ? _value.datePublication
            : datePublication // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        auteur: freezed == auteur
            ? _value.auteur
            : auteur // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActualiteAdminModelImpl extends _ActualiteAdminModel {
  const _$ActualiteAdminModelImpl({
    required this.id,
    required this.titre,
    this.contenu,
    this.categorie,
    @JsonKey(name: 'source_url') this.sourceUrl,
    @JsonKey(name: 'image_url') this.imageUrl,
    @JsonKey(name: 'date_publication') this.datePublication,
    this.auteur,
  }) : super._();

  factory _$ActualiteAdminModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActualiteAdminModelImplFromJson(json);

  @override
  final String id;
  @override
  final String titre;
  @override
  final String? contenu;
  @override
  final String? categorie;
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
  final DateTime? datePublication;
  @override
  final String? auteur;

  @override
  String toString() {
    return 'ActualiteAdminModel(id: $id, titre: $titre, contenu: $contenu, categorie: $categorie, sourceUrl: $sourceUrl, imageUrl: $imageUrl, datePublication: $datePublication, auteur: $auteur)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActualiteAdminModelImpl &&
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
            (identical(other.auteur, auteur) || other.auteur == auteur));
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
    auteur,
  );

  /// Create a copy of ActualiteAdminModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActualiteAdminModelImplCopyWith<_$ActualiteAdminModelImpl> get copyWith =>
      __$$ActualiteAdminModelImplCopyWithImpl<_$ActualiteAdminModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActualiteAdminModelImplToJson(this);
  }
}

abstract class _ActualiteAdminModel extends ActualiteAdminModel {
  const factory _ActualiteAdminModel({
    required final String id,
    required final String titre,
    final String? contenu,
    final String? categorie,
    @JsonKey(name: 'source_url') final String? sourceUrl,
    @JsonKey(name: 'image_url') final String? imageUrl,
    @JsonKey(name: 'date_publication') final DateTime? datePublication,
    final String? auteur,
  }) = _$ActualiteAdminModelImpl;
  const _ActualiteAdminModel._() : super._();

  factory _ActualiteAdminModel.fromJson(Map<String, dynamic> json) =
      _$ActualiteAdminModelImpl.fromJson;

  @override
  String get id;
  @override
  String get titre;
  @override
  String? get contenu;
  @override
  String? get categorie; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'source_url')
  String? get sourceUrl; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_publication')
  DateTime? get datePublication;
  @override
  String? get auteur;

  /// Create a copy of ActualiteAdminModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActualiteAdminModelImplCopyWith<_$ActualiteAdminModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
