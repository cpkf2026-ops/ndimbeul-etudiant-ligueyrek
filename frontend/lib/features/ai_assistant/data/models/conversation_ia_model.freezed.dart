// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_ia_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConversationSummaryModel _$ConversationSummaryModelFromJson(
  Map<String, dynamic> json,
) {
  return _ConversationSummaryModel.fromJson(json);
}

/// @nodoc
mixin _$ConversationSummaryModel {
  String get id =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_derniere_activite')
  DateTime? get dateDerniereActivite => throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ConversationSummaryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConversationSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationSummaryModelCopyWith<ConversationSummaryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationSummaryModelCopyWith<$Res> {
  factory $ConversationSummaryModelCopyWith(
    ConversationSummaryModel value,
    $Res Function(ConversationSummaryModel) then,
  ) = _$ConversationSummaryModelCopyWithImpl<$Res, ConversationSummaryModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'date_derniere_activite') DateTime? dateDerniereActivite,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$ConversationSummaryModelCopyWithImpl<
  $Res,
  $Val extends ConversationSummaryModel
>
    implements $ConversationSummaryModelCopyWith<$Res> {
  _$ConversationSummaryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dateDerniereActivite = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            dateDerniereActivite: freezed == dateDerniereActivite
                ? _value.dateDerniereActivite
                : dateDerniereActivite // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConversationSummaryModelImplCopyWith<$Res>
    implements $ConversationSummaryModelCopyWith<$Res> {
  factory _$$ConversationSummaryModelImplCopyWith(
    _$ConversationSummaryModelImpl value,
    $Res Function(_$ConversationSummaryModelImpl) then,
  ) = __$$ConversationSummaryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'date_derniere_activite') DateTime? dateDerniereActivite,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$ConversationSummaryModelImplCopyWithImpl<$Res>
    extends
        _$ConversationSummaryModelCopyWithImpl<
          $Res,
          _$ConversationSummaryModelImpl
        >
    implements _$$ConversationSummaryModelImplCopyWith<$Res> {
  __$$ConversationSummaryModelImplCopyWithImpl(
    _$ConversationSummaryModelImpl _value,
    $Res Function(_$ConversationSummaryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dateDerniereActivite = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ConversationSummaryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        dateDerniereActivite: freezed == dateDerniereActivite
            ? _value.dateDerniereActivite
            : dateDerniereActivite // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationSummaryModelImpl extends _ConversationSummaryModel {
  const _$ConversationSummaryModelImpl({
    required this.id,
    @JsonKey(name: 'date_derniere_activite') this.dateDerniereActivite,
    @JsonKey(name: 'created_at') this.createdAt,
  }) : super._();

  factory _$ConversationSummaryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationSummaryModelImplFromJson(json);

  @override
  final String id;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_derniere_activite')
  final DateTime? dateDerniereActivite;
  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ConversationSummaryModel(id: $id, dateDerniereActivite: $dateDerniereActivite, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationSummaryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dateDerniereActivite, dateDerniereActivite) ||
                other.dateDerniereActivite == dateDerniereActivite) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, dateDerniereActivite, createdAt);

  /// Create a copy of ConversationSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationSummaryModelImplCopyWith<_$ConversationSummaryModelImpl>
  get copyWith =>
      __$$ConversationSummaryModelImplCopyWithImpl<
        _$ConversationSummaryModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationSummaryModelImplToJson(this);
  }
}

abstract class _ConversationSummaryModel extends ConversationSummaryModel {
  const factory _ConversationSummaryModel({
    required final String id,
    @JsonKey(name: 'date_derniere_activite')
    final DateTime? dateDerniereActivite,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$ConversationSummaryModelImpl;
  const _ConversationSummaryModel._() : super._();

  factory _ConversationSummaryModel.fromJson(Map<String, dynamic> json) =
      _$ConversationSummaryModelImpl.fromJson;

  @override
  String get id; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_derniere_activite')
  DateTime? get dateDerniereActivite; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of ConversationSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationSummaryModelImplCopyWith<_$ConversationSummaryModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ConversationIaModel _$ConversationIaModelFromJson(Map<String, dynamic> json) {
  return _ConversationIaModel.fromJson(json);
}

/// @nodoc
mixin _$ConversationIaModel {
  String get id => throw _privateConstructorUsedError;
  List<MessageIaModel>? get messages =>
      throw _privateConstructorUsedError; // ignore: invalid_annotation_target
  @JsonKey(name: 'date_derniere_activite')
  DateTime? get dateDerniereActivite => throw _privateConstructorUsedError;

  /// Serializes this ConversationIaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConversationIaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationIaModelCopyWith<ConversationIaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationIaModelCopyWith<$Res> {
  factory $ConversationIaModelCopyWith(
    ConversationIaModel value,
    $Res Function(ConversationIaModel) then,
  ) = _$ConversationIaModelCopyWithImpl<$Res, ConversationIaModel>;
  @useResult
  $Res call({
    String id,
    List<MessageIaModel>? messages,
    @JsonKey(name: 'date_derniere_activite') DateTime? dateDerniereActivite,
  });
}

/// @nodoc
class _$ConversationIaModelCopyWithImpl<$Res, $Val extends ConversationIaModel>
    implements $ConversationIaModelCopyWith<$Res> {
  _$ConversationIaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationIaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messages = freezed,
    Object? dateDerniereActivite = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            messages: freezed == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<MessageIaModel>?,
            dateDerniereActivite: freezed == dateDerniereActivite
                ? _value.dateDerniereActivite
                : dateDerniereActivite // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConversationIaModelImplCopyWith<$Res>
    implements $ConversationIaModelCopyWith<$Res> {
  factory _$$ConversationIaModelImplCopyWith(
    _$ConversationIaModelImpl value,
    $Res Function(_$ConversationIaModelImpl) then,
  ) = __$$ConversationIaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    List<MessageIaModel>? messages,
    @JsonKey(name: 'date_derniere_activite') DateTime? dateDerniereActivite,
  });
}

/// @nodoc
class __$$ConversationIaModelImplCopyWithImpl<$Res>
    extends _$ConversationIaModelCopyWithImpl<$Res, _$ConversationIaModelImpl>
    implements _$$ConversationIaModelImplCopyWith<$Res> {
  __$$ConversationIaModelImplCopyWithImpl(
    _$ConversationIaModelImpl _value,
    $Res Function(_$ConversationIaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationIaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messages = freezed,
    Object? dateDerniereActivite = freezed,
  }) {
    return _then(
      _$ConversationIaModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        messages: freezed == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<MessageIaModel>?,
        dateDerniereActivite: freezed == dateDerniereActivite
            ? _value.dateDerniereActivite
            : dateDerniereActivite // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationIaModelImpl extends _ConversationIaModel {
  const _$ConversationIaModelImpl({
    required this.id,
    final List<MessageIaModel>? messages,
    @JsonKey(name: 'date_derniere_activite') this.dateDerniereActivite,
  }) : _messages = messages,
       super._();

  factory _$ConversationIaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationIaModelImplFromJson(json);

  @override
  final String id;
  final List<MessageIaModel>? _messages;
  @override
  List<MessageIaModel>? get messages {
    final value = _messages;
    if (value == null) return null;
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_derniere_activite')
  final DateTime? dateDerniereActivite;

  @override
  String toString() {
    return 'ConversationIaModel(id: $id, messages: $messages, dateDerniereActivite: $dateDerniereActivite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationIaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.dateDerniereActivite, dateDerniereActivite) ||
                other.dateDerniereActivite == dateDerniereActivite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_messages),
    dateDerniereActivite,
  );

  /// Create a copy of ConversationIaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationIaModelImplCopyWith<_$ConversationIaModelImpl> get copyWith =>
      __$$ConversationIaModelImplCopyWithImpl<_$ConversationIaModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationIaModelImplToJson(this);
  }
}

abstract class _ConversationIaModel extends ConversationIaModel {
  const factory _ConversationIaModel({
    required final String id,
    final List<MessageIaModel>? messages,
    @JsonKey(name: 'date_derniere_activite')
    final DateTime? dateDerniereActivite,
  }) = _$ConversationIaModelImpl;
  const _ConversationIaModel._() : super._();

  factory _ConversationIaModel.fromJson(Map<String, dynamic> json) =
      _$ConversationIaModelImpl.fromJson;

  @override
  String get id;
  @override
  List<MessageIaModel>? get messages; // ignore: invalid_annotation_target
  @override
  @JsonKey(name: 'date_derniere_activite')
  DateTime? get dateDerniereActivite;

  /// Create a copy of ConversationIaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationIaModelImplCopyWith<_$ConversationIaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
