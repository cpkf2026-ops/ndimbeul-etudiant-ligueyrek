// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'universite_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UniversiteModel _$UniversiteModelFromJson(Map<String, dynamic> json) {
  return _UniversiteModel.fromJson(json);
}

/// @nodoc
mixin _$UniversiteModel {
  String get id => throw _privateConstructorUsedError;
  String get nom =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'code_unique')
  String get codeUnique => throw _privateConstructorUsedError;
  String? get region => throw _privateConstructorUsedError;
  String? get commune =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  EtablissementType get type => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'site_web_officiel')
  String? get siteWebOfficiel => throw _privateConstructorUsedError;
  String? get description =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  ContactModel? get contact => throw _privateConstructorUsedError;
  List<FormationModel> get formations => throw _privateConstructorUsedError;
  List<BourseModel> get bourses => throw _privateConstructorUsedError;
  List<LogementModel> get logements =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'frais_scolarite')
  List<FraisScolariteModel> get fraisScolarite =>
      throw _privateConstructorUsedError;

  /// Serializes this UniversiteModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UniversiteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UniversiteModelCopyWith<UniversiteModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UniversiteModelCopyWith<$Res> {
  factory $UniversiteModelCopyWith(
    UniversiteModel value,
    $Res Function(UniversiteModel) then,
  ) = _$UniversiteModelCopyWithImpl<$Res, UniversiteModel>;
  @useResult
  $Res call({
    String id,
    String nom,
    @JsonKey(name: 'code_unique') String codeUnique,
    String? region,
    String? commune,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
    EtablissementType type,
    @JsonKey(name: 'site_web_officiel') String? siteWebOfficiel,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    ContactModel? contact,
    List<FormationModel> formations,
    List<BourseModel> bourses,
    List<LogementModel> logements,
    @JsonKey(name: 'frais_scolarite') List<FraisScolariteModel> fraisScolarite,
  });

  $ContactModelCopyWith<$Res>? get contact;
}

/// @nodoc
class _$UniversiteModelCopyWithImpl<$Res, $Val extends UniversiteModel>
    implements $UniversiteModelCopyWith<$Res> {
  _$UniversiteModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UniversiteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? codeUnique = null,
    Object? region = freezed,
    Object? commune = freezed,
    Object? type = null,
    Object? siteWebOfficiel = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? contact = freezed,
    Object? formations = null,
    Object? bourses = null,
    Object? logements = null,
    Object? fraisScolarite = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nom: null == nom
                ? _value.nom
                : nom // ignore: cast_nullable_to_non_nullable
                      as String,
            codeUnique: null == codeUnique
                ? _value.codeUnique
                : codeUnique // ignore: cast_nullable_to_non_nullable
                      as String,
            region: freezed == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String?,
            commune: freezed == commune
                ? _value.commune
                : commune // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as EtablissementType,
            siteWebOfficiel: freezed == siteWebOfficiel
                ? _value.siteWebOfficiel
                : siteWebOfficiel // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            contact: freezed == contact
                ? _value.contact
                : contact // ignore: cast_nullable_to_non_nullable
                      as ContactModel?,
            formations: null == formations
                ? _value.formations
                : formations // ignore: cast_nullable_to_non_nullable
                      as List<FormationModel>,
            bourses: null == bourses
                ? _value.bourses
                : bourses // ignore: cast_nullable_to_non_nullable
                      as List<BourseModel>,
            logements: null == logements
                ? _value.logements
                : logements // ignore: cast_nullable_to_non_nullable
                      as List<LogementModel>,
            fraisScolarite: null == fraisScolarite
                ? _value.fraisScolarite
                : fraisScolarite // ignore: cast_nullable_to_non_nullable
                      as List<FraisScolariteModel>,
          )
          as $Val,
    );
  }

  /// Create a copy of UniversiteModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContactModelCopyWith<$Res>? get contact {
    if (_value.contact == null) {
      return null;
    }

    return $ContactModelCopyWith<$Res>(_value.contact!, (value) {
      return _then(_value.copyWith(contact: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UniversiteModelImplCopyWith<$Res>
    implements $UniversiteModelCopyWith<$Res> {
  factory _$$UniversiteModelImplCopyWith(
    _$UniversiteModelImpl value,
    $Res Function(_$UniversiteModelImpl) then,
  ) = __$$UniversiteModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nom,
    @JsonKey(name: 'code_unique') String codeUnique,
    String? region,
    String? commune,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
    EtablissementType type,
    @JsonKey(name: 'site_web_officiel') String? siteWebOfficiel,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    ContactModel? contact,
    List<FormationModel> formations,
    List<BourseModel> bourses,
    List<LogementModel> logements,
    @JsonKey(name: 'frais_scolarite') List<FraisScolariteModel> fraisScolarite,
  });

  @override
  $ContactModelCopyWith<$Res>? get contact;
}

/// @nodoc
class __$$UniversiteModelImplCopyWithImpl<$Res>
    extends _$UniversiteModelCopyWithImpl<$Res, _$UniversiteModelImpl>
    implements _$$UniversiteModelImplCopyWith<$Res> {
  __$$UniversiteModelImplCopyWithImpl(
    _$UniversiteModelImpl _value,
    $Res Function(_$UniversiteModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UniversiteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nom = null,
    Object? codeUnique = null,
    Object? region = freezed,
    Object? commune = freezed,
    Object? type = null,
    Object? siteWebOfficiel = freezed,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? contact = freezed,
    Object? formations = null,
    Object? bourses = null,
    Object? logements = null,
    Object? fraisScolarite = null,
  }) {
    return _then(
      _$UniversiteModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        codeUnique: null == codeUnique
            ? _value.codeUnique
            : codeUnique // ignore: cast_nullable_to_non_nullable
                  as String,
        region: freezed == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String?,
        commune: freezed == commune
            ? _value.commune
            : commune // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as EtablissementType,
        siteWebOfficiel: freezed == siteWebOfficiel
            ? _value.siteWebOfficiel
            : siteWebOfficiel // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        contact: freezed == contact
            ? _value.contact
            : contact // ignore: cast_nullable_to_non_nullable
                  as ContactModel?,
        formations: null == formations
            ? _value._formations
            : formations // ignore: cast_nullable_to_non_nullable
                  as List<FormationModel>,
        bourses: null == bourses
            ? _value._bourses
            : bourses // ignore: cast_nullable_to_non_nullable
                  as List<BourseModel>,
        logements: null == logements
            ? _value._logements
            : logements // ignore: cast_nullable_to_non_nullable
                  as List<LogementModel>,
        fraisScolarite: null == fraisScolarite
            ? _value._fraisScolarite
            : fraisScolarite // ignore: cast_nullable_to_non_nullable
                  as List<FraisScolariteModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UniversiteModelImpl extends _UniversiteModel {
  const _$UniversiteModelImpl({
    required this.id,
    required this.nom,
    @JsonKey(name: 'code_unique') required this.codeUnique,
    this.region,
    this.commune,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) required this.type,
    @JsonKey(name: 'site_web_officiel') this.siteWebOfficiel,
    this.description,
    @JsonKey(name: 'image_url') this.imageUrl,
    this.contact,
    final List<FormationModel> formations = const [],
    final List<BourseModel> bourses = const [],
    final List<LogementModel> logements = const [],
    @JsonKey(name: 'frais_scolarite')
    final List<FraisScolariteModel> fraisScolarite = const [],
  }) : _formations = formations,
       _bourses = bourses,
       _logements = logements,
       _fraisScolarite = fraisScolarite,
       super._();

  factory _$UniversiteModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UniversiteModelImplFromJson(json);

  @override
  final String id;
  @override
  final String nom;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'code_unique')
  final String codeUnique;
  @override
  final String? region;
  @override
  final String? commune;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  final EtablissementType type;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'site_web_officiel')
  final String? siteWebOfficiel;
  @override
  final String? description;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  final ContactModel? contact;
  final List<FormationModel> _formations;
  @override
  @JsonKey()
  List<FormationModel> get formations {
    if (_formations is EqualUnmodifiableListView) return _formations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_formations);
  }

  final List<BourseModel> _bourses;
  @override
  @JsonKey()
  List<BourseModel> get bourses {
    if (_bourses is EqualUnmodifiableListView) return _bourses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bourses);
  }

  final List<LogementModel> _logements;
  @override
  @JsonKey()
  List<LogementModel> get logements {
    if (_logements is EqualUnmodifiableListView) return _logements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logements);
  }

  // ignore: invalid_annotation_target
  final List<FraisScolariteModel> _fraisScolarite;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'frais_scolarite')
  List<FraisScolariteModel> get fraisScolarite {
    if (_fraisScolarite is EqualUnmodifiableListView) return _fraisScolarite;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fraisScolarite);
  }

  @override
  String toString() {
    return 'UniversiteModel(id: $id, nom: $nom, codeUnique: $codeUnique, region: $region, commune: $commune, type: $type, siteWebOfficiel: $siteWebOfficiel, description: $description, imageUrl: $imageUrl, contact: $contact, formations: $formations, bourses: $bourses, logements: $logements, fraisScolarite: $fraisScolarite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UniversiteModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.codeUnique, codeUnique) ||
                other.codeUnique == codeUnique) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.commune, commune) || other.commune == commune) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.siteWebOfficiel, siteWebOfficiel) ||
                other.siteWebOfficiel == siteWebOfficiel) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.contact, contact) || other.contact == contact) &&
            const DeepCollectionEquality().equals(
              other._formations,
              _formations,
            ) &&
            const DeepCollectionEquality().equals(other._bourses, _bourses) &&
            const DeepCollectionEquality().equals(
              other._logements,
              _logements,
            ) &&
            const DeepCollectionEquality().equals(
              other._fraisScolarite,
              _fraisScolarite,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nom,
    codeUnique,
    region,
    commune,
    type,
    siteWebOfficiel,
    description,
    imageUrl,
    contact,
    const DeepCollectionEquality().hash(_formations),
    const DeepCollectionEquality().hash(_bourses),
    const DeepCollectionEquality().hash(_logements),
    const DeepCollectionEquality().hash(_fraisScolarite),
  );

  /// Create a copy of UniversiteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UniversiteModelImplCopyWith<_$UniversiteModelImpl> get copyWith =>
      __$$UniversiteModelImplCopyWithImpl<_$UniversiteModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UniversiteModelImplToJson(this);
  }
}

abstract class _UniversiteModel extends UniversiteModel {
  const factory _UniversiteModel({
    required final String id,
    required final String nom,
    @JsonKey(name: 'code_unique') required final String codeUnique,
    final String? region,
    final String? commune,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
    required final EtablissementType type,
    @JsonKey(name: 'site_web_officiel') final String? siteWebOfficiel,
    final String? description,
    @JsonKey(name: 'image_url') final String? imageUrl,
    final ContactModel? contact,
    final List<FormationModel> formations,
    final List<BourseModel> bourses,
    final List<LogementModel> logements,
    @JsonKey(name: 'frais_scolarite')
    final List<FraisScolariteModel> fraisScolarite,
  }) = _$UniversiteModelImpl;
  const _UniversiteModel._() : super._();

  factory _UniversiteModel.fromJson(Map<String, dynamic> json) =
      _$UniversiteModelImpl.fromJson;

  @override
  String get id;
  @override
  String get nom; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'code_unique')
  String get codeUnique;
  @override
  String? get region;
  @override
  String? get commune; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  EtablissementType get type; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'site_web_officiel')
  String? get siteWebOfficiel;
  @override
  String? get description; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  ContactModel? get contact;
  @override
  List<FormationModel> get formations;
  @override
  List<BourseModel> get bourses;
  @override
  List<LogementModel> get logements; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'frais_scolarite')
  List<FraisScolariteModel> get fraisScolarite;

  /// Create a copy of UniversiteModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UniversiteModelImplCopyWith<_$UniversiteModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
