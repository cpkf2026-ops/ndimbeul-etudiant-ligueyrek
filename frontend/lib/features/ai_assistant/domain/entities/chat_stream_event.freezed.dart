// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_stream_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ChatStreamEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String delta) token,
    required TResult Function(
      String conversationId,
      List<({String titre, String? url})> sources,
    )
    done,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String delta)? token,
    TResult? Function(
      String conversationId,
      List<({String titre, String? url})> sources,
    )?
    done,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String delta)? token,
    TResult Function(
      String conversationId,
      List<({String titre, String? url})> sources,
    )?
    done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatStreamEventToken value) token,
    required TResult Function(ChatStreamEventDone value) done,
    required TResult Function(ChatStreamEventError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStreamEventToken value)? token,
    TResult? Function(ChatStreamEventDone value)? done,
    TResult? Function(ChatStreamEventError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStreamEventToken value)? token,
    TResult Function(ChatStreamEventDone value)? done,
    TResult Function(ChatStreamEventError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStreamEventCopyWith<$Res> {
  factory $ChatStreamEventCopyWith(
    ChatStreamEvent value,
    $Res Function(ChatStreamEvent) then,
  ) = _$ChatStreamEventCopyWithImpl<$Res, ChatStreamEvent>;
}

/// @nodoc
class _$ChatStreamEventCopyWithImpl<$Res, $Val extends ChatStreamEvent>
    implements $ChatStreamEventCopyWith<$Res> {
  _$ChatStreamEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ChatStreamEventTokenImplCopyWith<$Res> {
  factory _$$ChatStreamEventTokenImplCopyWith(
    _$ChatStreamEventTokenImpl value,
    $Res Function(_$ChatStreamEventTokenImpl) then,
  ) = __$$ChatStreamEventTokenImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String delta});
}

/// @nodoc
class __$$ChatStreamEventTokenImplCopyWithImpl<$Res>
    extends _$ChatStreamEventCopyWithImpl<$Res, _$ChatStreamEventTokenImpl>
    implements _$$ChatStreamEventTokenImplCopyWith<$Res> {
  __$$ChatStreamEventTokenImplCopyWithImpl(
    _$ChatStreamEventTokenImpl _value,
    $Res Function(_$ChatStreamEventTokenImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? delta = null}) {
    return _then(
      _$ChatStreamEventTokenImpl(
        null == delta
            ? _value.delta
            : delta // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ChatStreamEventTokenImpl implements ChatStreamEventToken {
  const _$ChatStreamEventTokenImpl(this.delta);

  @override
  final String delta;

  @override
  String toString() {
    return 'ChatStreamEvent.token(delta: $delta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStreamEventTokenImpl &&
            (identical(other.delta, delta) || other.delta == delta));
  }

  @override
  int get hashCode => Object.hash(runtimeType, delta);

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStreamEventTokenImplCopyWith<_$ChatStreamEventTokenImpl>
  get copyWith =>
      __$$ChatStreamEventTokenImplCopyWithImpl<_$ChatStreamEventTokenImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String delta) token,
    required TResult Function(
      String conversationId,
      List<({String titre, String? url})> sources,
    )
    done,
    required TResult Function(String message) error,
  }) {
    return token(delta);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String delta)? token,
    TResult? Function(
      String conversationId,
      List<({String titre, String? url})> sources,
    )?
    done,
    TResult? Function(String message)? error,
  }) {
    return token?.call(delta);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String delta)? token,
    TResult Function(
      String conversationId,
      List<({String titre, String? url})> sources,
    )?
    done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (token != null) {
      return token(delta);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatStreamEventToken value) token,
    required TResult Function(ChatStreamEventDone value) done,
    required TResult Function(ChatStreamEventError value) error,
  }) {
    return token(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStreamEventToken value)? token,
    TResult? Function(ChatStreamEventDone value)? done,
    TResult? Function(ChatStreamEventError value)? error,
  }) {
    return token?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStreamEventToken value)? token,
    TResult Function(ChatStreamEventDone value)? done,
    TResult Function(ChatStreamEventError value)? error,
    required TResult orElse(),
  }) {
    if (token != null) {
      return token(this);
    }
    return orElse();
  }
}

abstract class ChatStreamEventToken implements ChatStreamEvent {
  const factory ChatStreamEventToken(final String delta) =
      _$ChatStreamEventTokenImpl;

  String get delta;

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStreamEventTokenImplCopyWith<_$ChatStreamEventTokenImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatStreamEventDoneImplCopyWith<$Res> {
  factory _$$ChatStreamEventDoneImplCopyWith(
    _$ChatStreamEventDoneImpl value,
    $Res Function(_$ChatStreamEventDoneImpl) then,
  ) = __$$ChatStreamEventDoneImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String conversationId,
    List<({String titre, String? url})> sources,
  });
}

/// @nodoc
class __$$ChatStreamEventDoneImplCopyWithImpl<$Res>
    extends _$ChatStreamEventCopyWithImpl<$Res, _$ChatStreamEventDoneImpl>
    implements _$$ChatStreamEventDoneImplCopyWith<$Res> {
  __$$ChatStreamEventDoneImplCopyWithImpl(
    _$ChatStreamEventDoneImpl _value,
    $Res Function(_$ChatStreamEventDoneImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? conversationId = null, Object? sources = null}) {
    return _then(
      _$ChatStreamEventDoneImpl(
        conversationId: null == conversationId
            ? _value.conversationId
            : conversationId // ignore: cast_nullable_to_non_nullable
                  as String,
        sources: null == sources
            ? _value._sources
            : sources // ignore: cast_nullable_to_non_nullable
                  as List<({String titre, String? url})>,
      ),
    );
  }
}

/// @nodoc

class _$ChatStreamEventDoneImpl implements ChatStreamEventDone {
  const _$ChatStreamEventDoneImpl({
    required this.conversationId,
    final List<({String titre, String? url})> sources = const <SourceCitee>[],
  }) : _sources = sources;

  @override
  final String conversationId;
  final List<({String titre, String? url})> _sources;
  @override
  @JsonKey()
  List<({String titre, String? url})> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  @override
  String toString() {
    return 'ChatStreamEvent.done(conversationId: $conversationId, sources: $sources)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStreamEventDoneImpl &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            const DeepCollectionEquality().equals(other._sources, _sources));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    conversationId,
    const DeepCollectionEquality().hash(_sources),
  );

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStreamEventDoneImplCopyWith<_$ChatStreamEventDoneImpl> get copyWith =>
      __$$ChatStreamEventDoneImplCopyWithImpl<_$ChatStreamEventDoneImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String delta) token,
    required TResult Function(
      String conversationId,
      List<({String titre, String? url})> sources,
    )
    done,
    required TResult Function(String message) error,
  }) {
    return done(conversationId, sources);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String delta)? token,
    TResult? Function(
      String conversationId,
      List<({String titre, String? url})> sources,
    )?
    done,
    TResult? Function(String message)? error,
  }) {
    return done?.call(conversationId, sources);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String delta)? token,
    TResult Function(
      String conversationId,
      List<({String titre, String? url})> sources,
    )?
    done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done(conversationId, sources);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatStreamEventToken value) token,
    required TResult Function(ChatStreamEventDone value) done,
    required TResult Function(ChatStreamEventError value) error,
  }) {
    return done(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStreamEventToken value)? token,
    TResult? Function(ChatStreamEventDone value)? done,
    TResult? Function(ChatStreamEventError value)? error,
  }) {
    return done?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStreamEventToken value)? token,
    TResult Function(ChatStreamEventDone value)? done,
    TResult Function(ChatStreamEventError value)? error,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done(this);
    }
    return orElse();
  }
}

abstract class ChatStreamEventDone implements ChatStreamEvent {
  const factory ChatStreamEventDone({
    required final String conversationId,
    final List<({String titre, String? url})> sources,
  }) = _$ChatStreamEventDoneImpl;

  String get conversationId;
  List<({String titre, String? url})> get sources;

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStreamEventDoneImplCopyWith<_$ChatStreamEventDoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatStreamEventErrorImplCopyWith<$Res> {
  factory _$$ChatStreamEventErrorImplCopyWith(
    _$ChatStreamEventErrorImpl value,
    $Res Function(_$ChatStreamEventErrorImpl) then,
  ) = __$$ChatStreamEventErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ChatStreamEventErrorImplCopyWithImpl<$Res>
    extends _$ChatStreamEventCopyWithImpl<$Res, _$ChatStreamEventErrorImpl>
    implements _$$ChatStreamEventErrorImplCopyWith<$Res> {
  __$$ChatStreamEventErrorImplCopyWithImpl(
    _$ChatStreamEventErrorImpl _value,
    $Res Function(_$ChatStreamEventErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ChatStreamEventErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ChatStreamEventErrorImpl implements ChatStreamEventError {
  const _$ChatStreamEventErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'ChatStreamEvent.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStreamEventErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStreamEventErrorImplCopyWith<_$ChatStreamEventErrorImpl>
  get copyWith =>
      __$$ChatStreamEventErrorImplCopyWithImpl<_$ChatStreamEventErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String delta) token,
    required TResult Function(
      String conversationId,
      List<({String titre, String? url})> sources,
    )
    done,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String delta)? token,
    TResult? Function(
      String conversationId,
      List<({String titre, String? url})> sources,
    )?
    done,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String delta)? token,
    TResult Function(
      String conversationId,
      List<({String titre, String? url})> sources,
    )?
    done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChatStreamEventToken value) token,
    required TResult Function(ChatStreamEventDone value) done,
    required TResult Function(ChatStreamEventError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChatStreamEventToken value)? token,
    TResult? Function(ChatStreamEventDone value)? done,
    TResult? Function(ChatStreamEventError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChatStreamEventToken value)? token,
    TResult Function(ChatStreamEventDone value)? done,
    TResult Function(ChatStreamEventError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ChatStreamEventError implements ChatStreamEvent {
  const factory ChatStreamEventError(final String message) =
      _$ChatStreamEventErrorImpl;

  String get message;

  /// Create a copy of ChatStreamEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStreamEventErrorImplCopyWith<_$ChatStreamEventErrorImpl>
  get copyWith => throw _privateConstructorUsedError;
}
