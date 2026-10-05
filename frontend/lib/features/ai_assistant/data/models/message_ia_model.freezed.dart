// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_ia_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MessageIaModel _$MessageIaModelFromJson(Map<String, dynamic> json) {
  return _MessageIaModel.fromJson(json);
}

/// @nodoc
mixin _$MessageIaModel {
  // ignore: invalid_annotation_target
  @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson)
  MessageRole get role => throw _privateConstructorUsedError;
  String get contenu =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(fromJson: _sourcesFromJson)
  List<({String titre, String? url})>? get sources =>
      throw _privateConstructorUsedError;
  DateTime? get date => throw _privateConstructorUsedError;

  /// Serializes this MessageIaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageIaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageIaModelCopyWith<MessageIaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageIaModelCopyWith<$Res> {
  factory $MessageIaModelCopyWith(
    MessageIaModel value,
    $Res Function(MessageIaModel) then,
  ) = _$MessageIaModelCopyWithImpl<$Res, MessageIaModel>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson) MessageRole role,
    String contenu,
    @JsonKey(fromJson: _sourcesFromJson)
    List<({String titre, String? url})>? sources,
    DateTime? date,
  });
}

/// @nodoc
class _$MessageIaModelCopyWithImpl<$Res, $Val extends MessageIaModel>
    implements $MessageIaModelCopyWith<$Res> {
  _$MessageIaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageIaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? contenu = null,
    Object? sources = freezed,
    Object? date = freezed,
  }) {
    return _then(
      _value.copyWith(
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as MessageRole,
            contenu: null == contenu
                ? _value.contenu
                : contenu // ignore: cast_nullable_to_non_nullable
                      as String,
            sources: freezed == sources
                ? _value.sources
                : sources // ignore: cast_nullable_to_non_nullable
                      as List<({String titre, String? url})>?,
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageIaModelImplCopyWith<$Res>
    implements $MessageIaModelCopyWith<$Res> {
  factory _$$MessageIaModelImplCopyWith(
    _$MessageIaModelImpl value,
    $Res Function(_$MessageIaModelImpl) then,
  ) = __$$MessageIaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson) MessageRole role,
    String contenu,
    @JsonKey(fromJson: _sourcesFromJson)
    List<({String titre, String? url})>? sources,
    DateTime? date,
  });
}

/// @nodoc
class __$$MessageIaModelImplCopyWithImpl<$Res>
    extends _$MessageIaModelCopyWithImpl<$Res, _$MessageIaModelImpl>
    implements _$$MessageIaModelImplCopyWith<$Res> {
  __$$MessageIaModelImplCopyWithImpl(
    _$MessageIaModelImpl _value,
    $Res Function(_$MessageIaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageIaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? contenu = null,
    Object? sources = freezed,
    Object? date = freezed,
  }) {
    return _then(
      _$MessageIaModelImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as MessageRole,
        contenu: null == contenu
            ? _value.contenu
            : contenu // ignore: cast_nullable_to_non_nullable
                  as String,
        sources: freezed == sources
            ? _value._sources
            : sources // ignore: cast_nullable_to_non_nullable
                  as List<({String titre, String? url})>?,
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageIaModelImpl extends _MessageIaModel {
  const _$MessageIaModelImpl({
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson) required this.role,
    required this.contenu,
    @JsonKey(fromJson: _sourcesFromJson)
    final List<({String titre, String? url})>? sources,
    this.date,
  }) : _sources = sources,
       super._();

  factory _$MessageIaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageIaModelImplFromJson(json);

  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson)
  final MessageRole role;
  @override
  final String contenu;
  // ignore: invalid_annotation_target
  final List<({String titre, String? url})>? _sources;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _sourcesFromJson)
  List<({String titre, String? url})>? get sources {
    final value = _sources;
    if (value == null) return null;
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? date;

  @override
  String toString() {
    return 'MessageIaModel(role: $role, contenu: $contenu, sources: $sources, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageIaModelImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.contenu, contenu) || other.contenu == contenu) &&
            const DeepCollectionEquality().equals(other._sources, _sources) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    role,
    contenu,
    const DeepCollectionEquality().hash(_sources),
    date,
  );

  /// Create a copy of MessageIaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageIaModelImplCopyWith<_$MessageIaModelImpl> get copyWith =>
      __$$MessageIaModelImplCopyWithImpl<_$MessageIaModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageIaModelImplToJson(this);
  }
}

abstract class _MessageIaModel extends MessageIaModel {
  const factory _MessageIaModel({
    @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson)
    required final MessageRole role,
    required final String contenu,
    @JsonKey(fromJson: _sourcesFromJson)
    final List<({String titre, String? url})>? sources,
    final DateTime? date,
  }) = _$MessageIaModelImpl;
  const _MessageIaModel._() : super._();

  factory _MessageIaModel.fromJson(Map<String, dynamic> json) =
      _$MessageIaModelImpl.fromJson;

  // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _roleFromJson, toJson: _roleToJson)
  MessageRole get role;
  @override
  String get contenu; // ignore: invalid_annotation_target
  @override
  @JsonKey(fromJson: _sourcesFromJson)
  List<({String titre, String? url})>? get sources;
  @override
  DateTime? get date;

  /// Create a copy of MessageIaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageIaModelImplCopyWith<_$MessageIaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
