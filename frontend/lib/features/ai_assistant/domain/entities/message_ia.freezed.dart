// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_ia.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MessageIa {
  MessageRole get role => throw _privateConstructorUsedError;
  String get contenu => throw _privateConstructorUsedError;
  List<String> get sources => throw _privateConstructorUsedError;
  DateTime? get date => throw _privateConstructorUsedError;
  bool get isStreaming => throw _privateConstructorUsedError;

  /// Create a copy of MessageIa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageIaCopyWith<MessageIa> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageIaCopyWith<$Res> {
  factory $MessageIaCopyWith(MessageIa value, $Res Function(MessageIa) then) =
      _$MessageIaCopyWithImpl<$Res, MessageIa>;
  @useResult
  $Res call({
    MessageRole role,
    String contenu,
    List<String> sources,
    DateTime? date,
    bool isStreaming,
  });
}

/// @nodoc
class _$MessageIaCopyWithImpl<$Res, $Val extends MessageIa>
    implements $MessageIaCopyWith<$Res> {
  _$MessageIaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageIa
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? contenu = null,
    Object? sources = null,
    Object? date = freezed,
    Object? isStreaming = null,
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
            sources: null == sources
                ? _value.sources
                : sources // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            date: freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isStreaming: null == isStreaming
                ? _value.isStreaming
                : isStreaming // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageIaImplCopyWith<$Res>
    implements $MessageIaCopyWith<$Res> {
  factory _$$MessageIaImplCopyWith(
    _$MessageIaImpl value,
    $Res Function(_$MessageIaImpl) then,
  ) = __$$MessageIaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MessageRole role,
    String contenu,
    List<String> sources,
    DateTime? date,
    bool isStreaming,
  });
}

/// @nodoc
class __$$MessageIaImplCopyWithImpl<$Res>
    extends _$MessageIaCopyWithImpl<$Res, _$MessageIaImpl>
    implements _$$MessageIaImplCopyWith<$Res> {
  __$$MessageIaImplCopyWithImpl(
    _$MessageIaImpl _value,
    $Res Function(_$MessageIaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageIa
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? contenu = null,
    Object? sources = null,
    Object? date = freezed,
    Object? isStreaming = null,
  }) {
    return _then(
      _$MessageIaImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as MessageRole,
        contenu: null == contenu
            ? _value.contenu
            : contenu // ignore: cast_nullable_to_non_nullable
                  as String,
        sources: null == sources
            ? _value._sources
            : sources // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        date: freezed == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isStreaming: null == isStreaming
            ? _value.isStreaming
            : isStreaming // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$MessageIaImpl extends _MessageIa {
  const _$MessageIaImpl({
    required this.role,
    required this.contenu,
    final List<String> sources = const <String>[],
    this.date,
    this.isStreaming = false,
  }) : _sources = sources,
       super._();

  @override
  final MessageRole role;
  @override
  final String contenu;
  final List<String> _sources;
  @override
  @JsonKey()
  List<String> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  @override
  final DateTime? date;
  @override
  @JsonKey()
  final bool isStreaming;

  @override
  String toString() {
    return 'MessageIa(role: $role, contenu: $contenu, sources: $sources, date: $date, isStreaming: $isStreaming)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageIaImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.contenu, contenu) || other.contenu == contenu) &&
            const DeepCollectionEquality().equals(other._sources, _sources) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    role,
    contenu,
    const DeepCollectionEquality().hash(_sources),
    date,
    isStreaming,
  );

  /// Create a copy of MessageIa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageIaImplCopyWith<_$MessageIaImpl> get copyWith =>
      __$$MessageIaImplCopyWithImpl<_$MessageIaImpl>(this, _$identity);
}

abstract class _MessageIa extends MessageIa {
  const factory _MessageIa({
    required final MessageRole role,
    required final String contenu,
    final List<String> sources,
    final DateTime? date,
    final bool isStreaming,
  }) = _$MessageIaImpl;
  const _MessageIa._() : super._();

  @override
  MessageRole get role;
  @override
  String get contenu;
  @override
  List<String> get sources;
  @override
  DateTime? get date;
  @override
  bool get isStreaming;

  /// Create a copy of MessageIa
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageIaImplCopyWith<_$MessageIaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
