// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_ia.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ConversationSummary {
  String get id => throw _privateConstructorUsedError;
  DateTime? get dateDerniereActivite => throw _privateConstructorUsedError;
  DateTime? get dateCreation => throw _privateConstructorUsedError;

  /// Create a copy of ConversationSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationSummaryCopyWith<ConversationSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationSummaryCopyWith<$Res> {
  factory $ConversationSummaryCopyWith(
    ConversationSummary value,
    $Res Function(ConversationSummary) then,
  ) = _$ConversationSummaryCopyWithImpl<$Res, ConversationSummary>;
  @useResult
  $Res call({
    String id,
    DateTime? dateDerniereActivite,
    DateTime? dateCreation,
  });
}

/// @nodoc
class _$ConversationSummaryCopyWithImpl<$Res, $Val extends ConversationSummary>
    implements $ConversationSummaryCopyWith<$Res> {
  _$ConversationSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dateDerniereActivite = freezed,
    Object? dateCreation = freezed,
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
            dateCreation: freezed == dateCreation
                ? _value.dateCreation
                : dateCreation // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConversationSummaryImplCopyWith<$Res>
    implements $ConversationSummaryCopyWith<$Res> {
  factory _$$ConversationSummaryImplCopyWith(
    _$ConversationSummaryImpl value,
    $Res Function(_$ConversationSummaryImpl) then,
  ) = __$$ConversationSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime? dateDerniereActivite,
    DateTime? dateCreation,
  });
}

/// @nodoc
class __$$ConversationSummaryImplCopyWithImpl<$Res>
    extends _$ConversationSummaryCopyWithImpl<$Res, _$ConversationSummaryImpl>
    implements _$$ConversationSummaryImplCopyWith<$Res> {
  __$$ConversationSummaryImplCopyWithImpl(
    _$ConversationSummaryImpl _value,
    $Res Function(_$ConversationSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dateDerniereActivite = freezed,
    Object? dateCreation = freezed,
  }) {
    return _then(
      _$ConversationSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        dateDerniereActivite: freezed == dateDerniereActivite
            ? _value.dateDerniereActivite
            : dateDerniereActivite // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dateCreation: freezed == dateCreation
            ? _value.dateCreation
            : dateCreation // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$ConversationSummaryImpl implements _ConversationSummary {
  const _$ConversationSummaryImpl({
    required this.id,
    this.dateDerniereActivite,
    this.dateCreation,
  });

  @override
  final String id;
  @override
  final DateTime? dateDerniereActivite;
  @override
  final DateTime? dateCreation;

  @override
  String toString() {
    return 'ConversationSummary(id: $id, dateDerniereActivite: $dateDerniereActivite, dateCreation: $dateCreation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dateDerniereActivite, dateDerniereActivite) ||
                other.dateDerniereActivite == dateDerniereActivite) &&
            (identical(other.dateCreation, dateCreation) ||
                other.dateCreation == dateCreation));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, dateDerniereActivite, dateCreation);

  /// Create a copy of ConversationSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationSummaryImplCopyWith<_$ConversationSummaryImpl> get copyWith =>
      __$$ConversationSummaryImplCopyWithImpl<_$ConversationSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _ConversationSummary implements ConversationSummary {
  const factory _ConversationSummary({
    required final String id,
    final DateTime? dateDerniereActivite,
    final DateTime? dateCreation,
  }) = _$ConversationSummaryImpl;

  @override
  String get id;
  @override
  DateTime? get dateDerniereActivite;
  @override
  DateTime? get dateCreation;

  /// Create a copy of ConversationSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationSummaryImplCopyWith<_$ConversationSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ConversationIa {
  String get id => throw _privateConstructorUsedError;
  List<MessageIa> get messages => throw _privateConstructorUsedError;
  DateTime? get dateDerniereActivite => throw _privateConstructorUsedError;

  /// Create a copy of ConversationIa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationIaCopyWith<ConversationIa> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationIaCopyWith<$Res> {
  factory $ConversationIaCopyWith(
    ConversationIa value,
    $Res Function(ConversationIa) then,
  ) = _$ConversationIaCopyWithImpl<$Res, ConversationIa>;
  @useResult
  $Res call({
    String id,
    List<MessageIa> messages,
    DateTime? dateDerniereActivite,
  });
}

/// @nodoc
class _$ConversationIaCopyWithImpl<$Res, $Val extends ConversationIa>
    implements $ConversationIaCopyWith<$Res> {
  _$ConversationIaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationIa
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messages = null,
    Object? dateDerniereActivite = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<MessageIa>,
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
abstract class _$$ConversationIaImplCopyWith<$Res>
    implements $ConversationIaCopyWith<$Res> {
  factory _$$ConversationIaImplCopyWith(
    _$ConversationIaImpl value,
    $Res Function(_$ConversationIaImpl) then,
  ) = __$$ConversationIaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    List<MessageIa> messages,
    DateTime? dateDerniereActivite,
  });
}

/// @nodoc
class __$$ConversationIaImplCopyWithImpl<$Res>
    extends _$ConversationIaCopyWithImpl<$Res, _$ConversationIaImpl>
    implements _$$ConversationIaImplCopyWith<$Res> {
  __$$ConversationIaImplCopyWithImpl(
    _$ConversationIaImpl _value,
    $Res Function(_$ConversationIaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationIa
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messages = null,
    Object? dateDerniereActivite = freezed,
  }) {
    return _then(
      _$ConversationIaImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<MessageIa>,
        dateDerniereActivite: freezed == dateDerniereActivite
            ? _value.dateDerniereActivite
            : dateDerniereActivite // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$ConversationIaImpl implements _ConversationIa {
  const _$ConversationIaImpl({
    required this.id,
    final List<MessageIa> messages = const <MessageIa>[],
    this.dateDerniereActivite,
  }) : _messages = messages;

  @override
  final String id;
  final List<MessageIa> _messages;
  @override
  @JsonKey()
  List<MessageIa> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final DateTime? dateDerniereActivite;

  @override
  String toString() {
    return 'ConversationIa(id: $id, messages: $messages, dateDerniereActivite: $dateDerniereActivite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationIaImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.dateDerniereActivite, dateDerniereActivite) ||
                other.dateDerniereActivite == dateDerniereActivite));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_messages),
    dateDerniereActivite,
  );

  /// Create a copy of ConversationIa
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationIaImplCopyWith<_$ConversationIaImpl> get copyWith =>
      __$$ConversationIaImplCopyWithImpl<_$ConversationIaImpl>(
        this,
        _$identity,
      );
}

abstract class _ConversationIa implements ConversationIa {
  const factory _ConversationIa({
    required final String id,
    final List<MessageIa> messages,
    final DateTime? dateDerniereActivite,
  }) = _$ConversationIaImpl;

  @override
  String get id;
  @override
  List<MessageIa> get messages;
  @override
  DateTime? get dateDerniereActivite;

  /// Create a copy of ConversationIa
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationIaImplCopyWith<_$ConversationIaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
