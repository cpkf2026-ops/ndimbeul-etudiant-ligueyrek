// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'logement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LogementModel _$LogementModelFromJson(Map<String, dynamic> json) {
  return _LogementModel.fromJson(json);
}

/// @nodoc
mixin _$LogementModel {
  String get id =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'universite_id')
  String get universiteId => throw _privateConstructorUsedError;
  String get nom =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  TypeLogement get type => throw _privateConstructorUsedError;
  int? get capacite =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(
    name: 'tarif_mensuel',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  double? get tarifMensuel => throw _privateConstructorUsedError;
  String get devise => throw _privateConstructorUsedError;
  String? get contact => throw _privateConstructorUsedError;
  String? get source =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_maj')
  DateTime? get dateMaj => throw _privateConstructorUsedError;

  /// Serializes this LogementModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LogementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogementModelCopyWith<LogementModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogementModelCopyWith<$Res> {
  factory $LogementModelCopyWith(
    LogementModel value,
    $Res Function(LogementModel) then,
  ) = _$LogementModelCopyWithImpl<$Res, LogementModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'universite_id') String universiteId,
    String nom,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) TypeLogement type,
    int? capacite,
    @JsonKey(
      name: 'tarif_mensuel',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    double? tarifMensuel,
    String devise,
    String? contact,
    String? source,
    @JsonKey(name: 'date_maj') DateTime? dateMaj,
  });
}

/// @nodoc
class _$LogementModelCopyWithImpl<$Res, $Val extends LogementModel>
    implements $LogementModelCopyWith<$Res> {
  _$LogementModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? universiteId = null,
    Object? nom = null,
    Object? type = null,
    Object? capacite = freezed,
    Object? tarifMensuel = freezed,
    Object? devise = null,
    Object? contact = freezed,
    Object? source = freezed,
    Object? dateMaj = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            universiteId: null == universiteId
                ? _value.universiteId
                : universiteId // ignore: cast_nullable_to_non_nullable
                      as String,
            nom: null == nom
                ? _value.nom
                : nom // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TypeLogement,
            capacite: freezed == capacite
                ? _value.capacite
                : capacite // ignore: cast_nullable_to_non_nullable
                      as int?,
            tarifMensuel: freezed == tarifMensuel
                ? _value.tarifMensuel
                : tarifMensuel // ignore: cast_nullable_to_non_nullable
                      as double?,
            devise: null == devise
                ? _value.devise
                : devise // ignore: cast_nullable_to_non_nullable
                      as String,
            contact: freezed == contact
                ? _value.contact
                : contact // ignore: cast_nullable_to_non_nullable
                      as String?,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateMaj: freezed == dateMaj
                ? _value.dateMaj
                : dateMaj // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LogementModelImplCopyWith<$Res>
    implements $LogementModelCopyWith<$Res> {
  factory _$$LogementModelImplCopyWith(
    _$LogementModelImpl value,
    $Res Function(_$LogementModelImpl) then,
  ) = __$$LogementModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'universite_id') String universiteId,
    String nom,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) TypeLogement type,
    int? capacite,
    @JsonKey(
      name: 'tarif_mensuel',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    double? tarifMensuel,
    String devise,
    String? contact,
    String? source,
    @JsonKey(name: 'date_maj') DateTime? dateMaj,
  });
}

/// @nodoc
class __$$LogementModelImplCopyWithImpl<$Res>
    extends _$LogementModelCopyWithImpl<$Res, _$LogementModelImpl>
    implements _$$LogementModelImplCopyWith<$Res> {
  __$$LogementModelImplCopyWithImpl(
    _$LogementModelImpl _value,
    $Res Function(_$LogementModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LogementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? universiteId = null,
    Object? nom = null,
    Object? type = null,
    Object? capacite = freezed,
    Object? tarifMensuel = freezed,
    Object? devise = null,
    Object? contact = freezed,
    Object? source = freezed,
    Object? dateMaj = freezed,
  }) {
    return _then(
      _$LogementModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        universiteId: null == universiteId
            ? _value.universiteId
            : universiteId // ignore: cast_nullable_to_non_nullable
                  as String,
        nom: null == nom
            ? _value.nom
            : nom // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TypeLogement,
        capacite: freezed == capacite
            ? _value.capacite
            : capacite // ignore: cast_nullable_to_non_nullable
                  as int?,
        tarifMensuel: freezed == tarifMensuel
            ? _value.tarifMensuel
            : tarifMensuel // ignore: cast_nullable_to_non_nullable
                  as double?,
        devise: null == devise
            ? _value.devise
            : devise // ignore: cast_nullable_to_non_nullable
                  as String,
        contact: freezed == contact
            ? _value.contact
            : contact // ignore: cast_nullable_to_non_nullable
                  as String?,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateMaj: freezed == dateMaj
            ? _value.dateMaj
            : dateMaj // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LogementModelImpl extends _LogementModel {
  const _$LogementModelImpl({
    required this.id,
    @JsonKey(name: 'universite_id') required this.universiteId,
    required this.nom,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) required this.type,
    this.capacite,
    @JsonKey(
      name: 'tarif_mensuel',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    this.tarifMensuel,
    this.devise = 'XOF',
    this.contact,
    this.source,
    @JsonKey(name: 'date_maj') this.dateMaj,
  }) : super._();

  factory _$LogementModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogementModelImplFromJson(json);

  @override
  final String id;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_id')
  final String universiteId;
  @override
  final String nom;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  final TypeLogement type;
  @override
  final int? capacite;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(
    name: 'tarif_mensuel',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  final double? tarifMensuel;
  @override
  @JsonKey()
  final String devise;
  @override
  final String? contact;
  @override
  final String? source;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_maj')
  final DateTime? dateMaj;

  @override
  String toString() {
    return 'LogementModel(id: $id, universiteId: $universiteId, nom: $nom, type: $type, capacite: $capacite, tarifMensuel: $tarifMensuel, devise: $devise, contact: $contact, source: $source, dateMaj: $dateMaj)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogementModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.universiteId, universiteId) ||
                other.universiteId == universiteId) &&
            (identical(other.nom, nom) || other.nom == nom) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.capacite, capacite) ||
                other.capacite == capacite) &&
            (identical(other.tarifMensuel, tarifMensuel) ||
                other.tarifMensuel == tarifMensuel) &&
            (identical(other.devise, devise) || other.devise == devise) &&
            (identical(other.contact, contact) || other.contact == contact) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.dateMaj, dateMaj) || other.dateMaj == dateMaj));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    universiteId,
    nom,
    type,
    capacite,
    tarifMensuel,
    devise,
    contact,
    source,
    dateMaj,
  );

  /// Create a copy of LogementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogementModelImplCopyWith<_$LogementModelImpl> get copyWith =>
      __$$LogementModelImplCopyWithImpl<_$LogementModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LogementModelImplToJson(this);
  }
}

abstract class _LogementModel extends LogementModel {
  const factory _LogementModel({
    required final String id,
    @JsonKey(name: 'universite_id') required final String universiteId,
    required final String nom,
    @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
    required final TypeLogement type,
    final int? capacite,
    @JsonKey(
      name: 'tarif_mensuel',
      fromJson: _decimalFromJson,
      toJson: _decimalToJson,
    )
    final double? tarifMensuel,
    final String devise,
    final String? contact,
    final String? source,
    @JsonKey(name: 'date_maj') final DateTime? dateMaj,
  }) = _$LogementModelImpl;
  const _LogementModel._() : super._();

  factory _LogementModel.fromJson(Map<String, dynamic> json) =
      _$LogementModelImpl.fromJson;

  @override
  String get id; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'universite_id')
  String get universiteId;
  @override
  String get nom; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  TypeLogement get type;
  @override
  int? get capacite; // ignore: invalid_annotation_target
  @override
  @JsonKey(
    name: 'tarif_mensuel',
    fromJson: _decimalFromJson,
    toJson: _decimalToJson,
  )
  double? get tarifMensuel;
  @override
  String get devise;
  @override
  String? get contact;
  @override
  String? get source; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_maj')
  DateTime? get dateMaj;

  /// Create a copy of LogementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogementModelImplCopyWith<_$LogementModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
