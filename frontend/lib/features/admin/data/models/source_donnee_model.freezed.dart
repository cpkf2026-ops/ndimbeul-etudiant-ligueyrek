
part of 'source_donnee_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SourceDonneeModel _$SourceDonneeModelFromJson(Map<String, dynamic> json) {
  return _SourceDonneeModel.fromJson(json);
}

/// @nodoc
mixin _$SourceDonneeModel {
  String get id =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'universite_id')
  String? get universiteId => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  SourceType get type => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'url_ou_chemin')
  String get urlOuChemin => throw _privateConstructorUsedError;
  String? get categorie =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
  SourceStatut get statut => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'derniere_erreur')
  String? get derniereErreur => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_dernier_crawl')
  DateTime? get dateDernierCrawl => throw _privateConstructorUsedError;

  /// Serializes this SourceDonneeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SourceDonneeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SourceDonneeModelCopyWith<SourceDonneeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SourceDonneeModelCopyWith<$Res> {
  factory $SourceDonneeModelCopyWith(
    SourceDonneeModel value,
    $Res Function(SourceDonneeModel) then,
  ) = _$SourceDonneeModelCopyWithImpl<$Res, SourceDonneeModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'universite_id') String? universiteId,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) SourceType type,
    @JsonKey(name: 'url_ou_chemin') String urlOuChemin,
    String? categorie,
    @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
    SourceStatut statut,
    @JsonKey(name: 'derniere_erreur') String? derniereErreur,
    @JsonKey(name: 'date_dernier_crawl') DateTime? dateDernierCrawl,
  });
}

/// @nodoc
class _$SourceDonneeModelCopyWithImpl<$Res, $Val extends SourceDonneeModel>
    implements $SourceDonneeModelCopyWith<$Res> {
  _$SourceDonneeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SourceDonneeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? universiteId = freezed,
    Object? type = null,
    Object? urlOuChemin = null,
    Object? categorie = freezed,
    Object? statut = null,
    Object? derniereErreur = freezed,
    Object? dateDernierCrawl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            universiteId: freezed == universiteId
                ? _value.universiteId
                : universiteId // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as SourceType,
            urlOuChemin: null == urlOuChemin
                ? _value.urlOuChemin
                : urlOuChemin // ignore: cast_nullable_to_non_nullable
                      as String,
            categorie: freezed == categorie
                ? _value.categorie
                : categorie // ignore: cast_nullable_to_non_nullable
                      as String?,
            statut: null == statut
                ? _value.statut
                : statut // ignore: cast_nullable_to_non_nullable
                      as SourceStatut,
            derniereErreur: freezed == derniereErreur
                ? _value.derniereErreur
                : derniereErreur // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateDernierCrawl: freezed == dateDernierCrawl
                ? _value.dateDernierCrawl
                : dateDernierCrawl // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SourceDonneeModelImplCopyWith<$Res>
    implements $SourceDonneeModelCopyWith<$Res> {
  factory _$$SourceDonneeModelImplCopyWith(
    _$SourceDonneeModelImpl value,
    $Res Function(_$SourceDonneeModelImpl) then,
  ) = __$$SourceDonneeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'universite_id') String? universiteId,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) SourceType type,
    @JsonKey(name: 'url_ou_chemin') String urlOuChemin,
    String? categorie,
    @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
    SourceStatut statut,
    @JsonKey(name: 'derniere_erreur') String? derniereErreur,
    @JsonKey(name: 'date_dernier_crawl') DateTime? dateDernierCrawl,
  });
}

/// @nodoc
class __$$SourceDonneeModelImplCopyWithImpl<$Res>
    extends _$SourceDonneeModelCopyWithImpl<$Res, _$SourceDonneeModelImpl>
    implements _$$SourceDonneeModelImplCopyWith<$Res> {
  __$$SourceDonneeModelImplCopyWithImpl(
    _$SourceDonneeModelImpl _value,
    $Res Function(_$SourceDonneeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourceDonneeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? universiteId = freezed,
    Object? type = null,
    Object? urlOuChemin = null,
    Object? categorie = freezed,
    Object? statut = null,
    Object? derniereErreur = freezed,
    Object? dateDernierCrawl = freezed,
  }) {
    return _then(
      _$SourceDonneeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        universiteId: freezed == universiteId
            ? _value.universiteId
            : universiteId // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as SourceType,
        urlOuChemin: null == urlOuChemin
            ? _value.urlOuChemin
            : urlOuChemin // ignore: cast_nullable_to_non_nullable
                  as String,
        categorie: freezed == categorie
            ? _value.categorie
            : categorie // ignore: cast_nullable_to_non_nullable
                  as String?,
        statut: null == statut
            ? _value.statut
            : statut // ignore: cast_nullable_to_non_nullable
                  as SourceStatut,
        derniereErreur: freezed == derniereErreur
            ? _value.derniereErreur
            : derniereErreur // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateDernierCrawl: freezed == dateDernierCrawl
            ? _value.dateDernierCrawl
            : dateDernierCrawl // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SourceDonneeModelImpl extends _SourceDonneeModel {
  const _$SourceDonneeModelImpl({
    required this.id,
    @JsonKey(name: 'universite_id') this.universiteId,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) required this.type,
    @JsonKey(name: 'url_ou_chemin') required this.urlOuChemin,
    this.categorie,
    @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
    required this.statut,
    @JsonKey(name: 'derniere_erreur') this.derniereErreur,
    @JsonKey(name: 'date_dernier_crawl') this.dateDernierCrawl,
  }) : super._();

  factory _$SourceDonneeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SourceDonneeModelImplFromJson(json);

  @override
  final String id;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_id')
  final String? universiteId;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  final SourceType type;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'url_ou_chemin')
  final String urlOuChemin;
  @override
  final String? categorie;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
  final SourceStatut statut;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'derniere_erreur')
  final String? derniereErreur;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_dernier_crawl')
  final DateTime? dateDernierCrawl;

  @override
  String toString() {
    return 'SourceDonneeModel(id: $id, universiteId: $universiteId, type: $type, urlOuChemin: $urlOuChemin, categorie: $categorie, statut: $statut, derniereErreur: $derniereErreur, dateDernierCrawl: $dateDernierCrawl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SourceDonneeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.universiteId, universiteId) ||
                other.universiteId == universiteId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.urlOuChemin, urlOuChemin) ||
                other.urlOuChemin == urlOuChemin) &&
            (identical(other.categorie, categorie) ||
                other.categorie == categorie) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.derniereErreur, derniereErreur) ||
                other.derniereErreur == derniereErreur) &&
            (identical(other.dateDernierCrawl, dateDernierCrawl) ||
                other.dateDernierCrawl == dateDernierCrawl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    universiteId,
    type,
    urlOuChemin,
    categorie,
    statut,
    derniereErreur,
    dateDernierCrawl,
  );

  /// Create a copy of SourceDonneeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SourceDonneeModelImplCopyWith<_$SourceDonneeModelImpl> get copyWith =>
      __$$SourceDonneeModelImplCopyWithImpl<_$SourceDonneeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SourceDonneeModelImplToJson(this);
  }
}

abstract class _SourceDonneeModel extends SourceDonneeModel {
  const factory _SourceDonneeModel({
    required final String id,
    @JsonKey(name: 'universite_id') final String? universiteId,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
    required final SourceType type,
    @JsonKey(name: 'url_ou_chemin') required final String urlOuChemin,
    final String? categorie,
    @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
    required final SourceStatut statut,
    @JsonKey(name: 'derniere_erreur') final String? derniereErreur,
    @JsonKey(name: 'date_dernier_crawl') final DateTime? dateDernierCrawl,
  }) = _$SourceDonneeModelImpl;
  const _SourceDonneeModel._() : super._();

  factory _SourceDonneeModel.fromJson(Map<String, dynamic> json) =
      _$SourceDonneeModelImpl.fromJson;

  @override
  String get id; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_id')
  String? get universiteId; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  SourceType get type; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'url_ou_chemin')
  String get urlOuChemin;
  @override
  String? get categorie; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _statutFromJson, toJson: _statutToJson)
  SourceStatut get statut; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'derniere_erreur')
  String? get derniereErreur; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_dernier_crawl')
  DateTime? get dateDernierCrawl;

  /// Create a copy of SourceDonneeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SourceDonneeModelImplCopyWith<_$SourceDonneeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
