// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppNotificationModel {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get titre => throw _privateConstructorUsedError;
  String get corps => throw _privateConstructorUsedError;
  DateTime? get readAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of AppNotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppNotificationModelCopyWith<AppNotificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppNotificationModelCopyWith<$Res> {
  factory $AppNotificationModelCopyWith(
    AppNotificationModel value,
    $Res Function(AppNotificationModel) then,
  ) = _$AppNotificationModelCopyWithImpl<$Res, AppNotificationModel>;
  @useResult
  $Res call({
    String id,
    String type,
    String titre,
    String corps,
    DateTime? readAt,
    DateTime createdAt,
  });
}

/// @nodoc
class _$AppNotificationModelCopyWithImpl<
  $Res,
  $Val extends AppNotificationModel
>
    implements $AppNotificationModelCopyWith<$Res> {
  _$AppNotificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppNotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? titre = null,
    Object? corps = null,
    Object? readAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            titre: null == titre
                ? _value.titre
                : titre // ignore: cast_nullable_to_non_nullable
                      as String,
            corps: null == corps
                ? _value.corps
                : corps // ignore: cast_nullable_to_non_nullable
                      as String,
            readAt: freezed == readAt
                ? _value.readAt
                : readAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppNotificationModelImplCopyWith<$Res>
    implements $AppNotificationModelCopyWith<$Res> {
  factory _$$AppNotificationModelImplCopyWith(
    _$AppNotificationModelImpl value,
    $Res Function(_$AppNotificationModelImpl) then,
  ) = __$$AppNotificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    String titre,
    String corps,
    DateTime? readAt,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$AppNotificationModelImplCopyWithImpl<$Res>
    extends _$AppNotificationModelCopyWithImpl<$Res, _$AppNotificationModelImpl>
    implements _$$AppNotificationModelImplCopyWith<$Res> {
  __$$AppNotificationModelImplCopyWithImpl(
    _$AppNotificationModelImpl _value,
    $Res Function(_$AppNotificationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppNotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? titre = null,
    Object? corps = null,
    Object? readAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$AppNotificationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        titre: null == titre
            ? _value.titre
            : titre // ignore: cast_nullable_to_non_nullable
                  as String,
        corps: null == corps
            ? _value.corps
            : corps // ignore: cast_nullable_to_non_nullable
                  as String,
        readAt: freezed == readAt
            ? _value.readAt
            : readAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$AppNotificationModelImpl extends _AppNotificationModel {
  const _$AppNotificationModelImpl({
    required this.id,
    required this.type,
    required this.titre,
    required this.corps,
    this.readAt,
    required this.createdAt,
  }) : super._();

  @override
  final String id;
  @override
  final String type;
  @override
  final String titre;
  @override
  final String corps;
  @override
  final DateTime? readAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AppNotificationModel(id: $id, type: $type, titre: $titre, corps: $corps, readAt: $readAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppNotificationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.titre, titre) || other.titre == titre) &&
            (identical(other.corps, corps) || other.corps == corps) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, titre, corps, readAt, createdAt);

  /// Create a copy of AppNotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppNotificationModelImplCopyWith<_$AppNotificationModelImpl>
  get copyWith =>
      __$$AppNotificationModelImplCopyWithImpl<_$AppNotificationModelImpl>(
        this,
        _$identity,
      );
}

abstract class _AppNotificationModel extends AppNotificationModel {
  const factory _AppNotificationModel({
    required final String id,
    required final String type,
    required final String titre,
    required final String corps,
    final DateTime? readAt,
    required final DateTime createdAt,
  }) = _$AppNotificationModelImpl;
  const _AppNotificationModel._() : super._();

  @override
  String get id;
  @override
  String get type;
  @override
  String get titre;
  @override
  String get corps;
  @override
  DateTime? get readAt;
  @override
  DateTime get createdAt;

  /// Create a copy of AppNotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppNotificationModelImplCopyWith<_$AppNotificationModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
