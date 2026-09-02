// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppNotification {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get titre => throw _privateConstructorUsedError;
  String get corps => throw _privateConstructorUsedError;
  DateTime? get readAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppNotificationCopyWith<AppNotification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppNotificationCopyWith<$Res> {
  factory $AppNotificationCopyWith(
    AppNotification value,
    $Res Function(AppNotification) then,
  ) = _$AppNotificationCopyWithImpl<$Res, AppNotification>;
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
class _$AppNotificationCopyWithImpl<$Res, $Val extends AppNotification>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppNotification
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
abstract class _$$AppNotificationImplCopyWith<$Res>
    implements $AppNotificationCopyWith<$Res> {
  factory _$$AppNotificationImplCopyWith(
    _$AppNotificationImpl value,
    $Res Function(_$AppNotificationImpl) then,
  ) = __$$AppNotificationImplCopyWithImpl<$Res>;
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
class __$$AppNotificationImplCopyWithImpl<$Res>
    extends _$AppNotificationCopyWithImpl<$Res, _$AppNotificationImpl>
    implements _$$AppNotificationImplCopyWith<$Res> {
  __$$AppNotificationImplCopyWithImpl(
    _$AppNotificationImpl _value,
    $Res Function(_$AppNotificationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppNotification
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
      _$AppNotificationImpl(
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

class _$AppNotificationImpl extends _AppNotification {
  const _$AppNotificationImpl({
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
    return 'AppNotification(id: $id, type: $type, titre: $titre, corps: $corps, readAt: $readAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppNotificationImpl &&
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

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppNotificationImplCopyWith<_$AppNotificationImpl> get copyWith =>
      __$$AppNotificationImplCopyWithImpl<_$AppNotificationImpl>(
        this,
        _$identity,
      );
}

abstract class _AppNotification extends AppNotification {
  const factory _AppNotification({
    required final String id,
    required final String type,
    required final String titre,
    required final String corps,
    final DateTime? readAt,
    required final DateTime createdAt,
  }) = _$AppNotificationImpl;
  const _AppNotification._() : super._();

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

  /// Create a copy of AppNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppNotificationImplCopyWith<_$AppNotificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NotificationPage {
  List<AppNotification> get items => throw _privateConstructorUsedError;
  int get nbNonLues => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get lastPage => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPageCopyWith<NotificationPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPageCopyWith<$Res> {
  factory $NotificationPageCopyWith(
    NotificationPage value,
    $Res Function(NotificationPage) then,
  ) = _$NotificationPageCopyWithImpl<$Res, NotificationPage>;
  @useResult
  $Res call({
    List<AppNotification> items,
    int nbNonLues,
    int currentPage,
    int lastPage,
  });
}

/// @nodoc
class _$NotificationPageCopyWithImpl<$Res, $Val extends NotificationPage>
    implements $NotificationPageCopyWith<$Res> {
  _$NotificationPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nbNonLues = null,
    Object? currentPage = null,
    Object? lastPage = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<AppNotification>,
            nbNonLues: null == nbNonLues
                ? _value.nbNonLues
                : nbNonLues // ignore: cast_nullable_to_non_nullable
                      as int,
            currentPage: null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            lastPage: null == lastPage
                ? _value.lastPage
                : lastPage // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationPageImplCopyWith<$Res>
    implements $NotificationPageCopyWith<$Res> {
  factory _$$NotificationPageImplCopyWith(
    _$NotificationPageImpl value,
    $Res Function(_$NotificationPageImpl) then,
  ) = __$$NotificationPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<AppNotification> items,
    int nbNonLues,
    int currentPage,
    int lastPage,
  });
}

/// @nodoc
class __$$NotificationPageImplCopyWithImpl<$Res>
    extends _$NotificationPageCopyWithImpl<$Res, _$NotificationPageImpl>
    implements _$$NotificationPageImplCopyWith<$Res> {
  __$$NotificationPageImplCopyWithImpl(
    _$NotificationPageImpl _value,
    $Res Function(_$NotificationPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nbNonLues = null,
    Object? currentPage = null,
    Object? lastPage = null,
  }) {
    return _then(
      _$NotificationPageImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<AppNotification>,
        nbNonLues: null == nbNonLues
            ? _value.nbNonLues
            : nbNonLues // ignore: cast_nullable_to_non_nullable
                  as int,
        currentPage: null == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        lastPage: null == lastPage
            ? _value.lastPage
            : lastPage // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$NotificationPageImpl extends _NotificationPage {
  const _$NotificationPageImpl({
    required final List<AppNotification> items,
    required this.nbNonLues,
    required this.currentPage,
    required this.lastPage,
  }) : _items = items,
       super._();

  final List<AppNotification> _items;
  @override
  List<AppNotification> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int nbNonLues;
  @override
  final int currentPage;
  @override
  final int lastPage;

  @override
  String toString() {
    return 'NotificationPage(items: $items, nbNonLues: $nbNonLues, currentPage: $currentPage, lastPage: $lastPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPageImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.nbNonLues, nbNonLues) ||
                other.nbNonLues == nbNonLues) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.lastPage, lastPage) ||
                other.lastPage == lastPage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    nbNonLues,
    currentPage,
    lastPage,
  );

  /// Create a copy of NotificationPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPageImplCopyWith<_$NotificationPageImpl> get copyWith =>
      __$$NotificationPageImplCopyWithImpl<_$NotificationPageImpl>(
        this,
        _$identity,
      );
}

abstract class _NotificationPage extends NotificationPage {
  const factory _NotificationPage({
    required final List<AppNotification> items,
    required final int nbNonLues,
    required final int currentPage,
    required final int lastPage,
  }) = _$NotificationPageImpl;
  const _NotificationPage._() : super._();

  @override
  List<AppNotification> get items;
  @override
  int get nbNonLues;
  @override
  int get currentPage;
  @override
  int get lastPage;

  /// Create a copy of NotificationPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPageImplCopyWith<_$NotificationPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
