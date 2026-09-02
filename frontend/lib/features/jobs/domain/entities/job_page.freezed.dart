// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$JobPage {
  List<OffreEmploi> get items => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get lastPage => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Create a copy of JobPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobPageCopyWith<JobPage> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobPageCopyWith<$Res> {
  factory $JobPageCopyWith(JobPage value, $Res Function(JobPage) then) =
      _$JobPageCopyWithImpl<$Res, JobPage>;
  @useResult
  $Res call({
    List<OffreEmploi> items,
    int currentPage,
    int lastPage,
    int total,
  });
}

/// @nodoc
class _$JobPageCopyWithImpl<$Res, $Val extends JobPage>
    implements $JobPageCopyWith<$Res> {
  _$JobPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? lastPage = null,
    Object? total = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<OffreEmploi>,
            currentPage: null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            lastPage: null == lastPage
                ? _value.lastPage
                : lastPage // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JobPageImplCopyWith<$Res> implements $JobPageCopyWith<$Res> {
  factory _$$JobPageImplCopyWith(
    _$JobPageImpl value,
    $Res Function(_$JobPageImpl) then,
  ) = __$$JobPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<OffreEmploi> items,
    int currentPage,
    int lastPage,
    int total,
  });
}

/// @nodoc
class __$$JobPageImplCopyWithImpl<$Res>
    extends _$JobPageCopyWithImpl<$Res, _$JobPageImpl>
    implements _$$JobPageImplCopyWith<$Res> {
  __$$JobPageImplCopyWithImpl(
    _$JobPageImpl _value,
    $Res Function(_$JobPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? lastPage = null,
    Object? total = null,
  }) {
    return _then(
      _$JobPageImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<OffreEmploi>,
        currentPage: null == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        lastPage: null == lastPage
            ? _value.lastPage
            : lastPage // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$JobPageImpl extends _JobPage {
  const _$JobPageImpl({
    required final List<OffreEmploi> items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  }) : _items = items,
       super._();

  final List<OffreEmploi> _items;
  @override
  List<OffreEmploi> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int currentPage;
  @override
  final int lastPage;
  @override
  final int total;

  @override
  String toString() {
    return 'JobPage(items: $items, currentPage: $currentPage, lastPage: $lastPage, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobPageImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.lastPage, lastPage) ||
                other.lastPage == lastPage) &&
            (identical(other.total, total) || other.total == total));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    currentPage,
    lastPage,
    total,
  );

  /// Create a copy of JobPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobPageImplCopyWith<_$JobPageImpl> get copyWith =>
      __$$JobPageImplCopyWithImpl<_$JobPageImpl>(this, _$identity);
}

abstract class _JobPage extends JobPage {
  const factory _JobPage({
    required final List<OffreEmploi> items,
    required final int currentPage,
    required final int lastPage,
    required final int total,
  }) = _$JobPageImpl;
  const _JobPage._() : super._();

  @override
  List<OffreEmploi> get items;
  @override
  int get currentPage;
  @override
  int get lastPage;
  @override
  int get total;

  /// Create a copy of JobPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobPageImplCopyWith<_$JobPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
