// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'actualite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Actualite {
  String get id => throw _privateConstructorUsedError;
  String get titre => throw _privateConstructorUsedError;
  String get contenu => throw _privateConstructorUsedError;
  CategorieActualite get categorie => throw _privateConstructorUsedError;
  String? get sourceUrl => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  DateTime get datePublication => throw _privateConstructorUsedError;
  DateTime? get dateIndexation => throw _privateConstructorUsedError;
  String? get auteur => throw _privateConstructorUsedError;

  /// Niveau de fiabilité de la source vérifié par la veille IA :
  /// 'officiel' (État, université…) ou 'presse' (média reconnu).
  String? get fiabilite => throw _privateConstructorUsedError;

  /// Create a copy of Actualite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActualiteCopyWith<Actualite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActualiteCopyWith<$Res> {
  factory $ActualiteCopyWith(Actualite value, $Res Function(Actualite) then) =
      _$ActualiteCopyWithImpl<$Res, Actualite>;
  @useResult
  $Res call({
    String id,
    String titre,
    String contenu,
    CategorieActualite categorie,
    String? sourceUrl,
    String? imageUrl,
    DateTime datePublication,
    DateTime? dateIndexation,
    String? auteur,
    String? fiabilite,
  });
}

/// @nodoc
class _$ActualiteCopyWithImpl<$Res, $Val extends Actualite>
    implements $ActualiteCopyWith<$Res> {
  _$ActualiteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Actualite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titre = null,
    Object? contenu = null,
    Object? categorie = null,
    Object? sourceUrl = freezed,
    Object? imageUrl = freezed,
    Object? datePublication = null,
    Object? dateIndexation = freezed,
    Object? auteur = freezed,
    Object? fiabilite = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            titre: null == titre
                ? _value.titre
                : titre // ignore: cast_nullable_to_non_nullable
                      as String,
            contenu: null == contenu
                ? _value.contenu
                : contenu // ignore: cast_nullable_to_non_nullable
                      as String,
            categorie: null == categorie
                ? _value.categorie
                : categorie // ignore: cast_nullable_to_non_nullable
                      as CategorieActualite,
            sourceUrl: freezed == sourceUrl
                ? _value.sourceUrl
                : sourceUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            datePublication: null == datePublication
                ? _value.datePublication
                : datePublication // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dateIndexation: freezed == dateIndexation
                ? _value.dateIndexation
                : dateIndexation // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            auteur: freezed == auteur
                ? _value.auteur
                : auteur // ignore: cast_nullable_to_non_nullable
                      as String?,
            fiabilite: freezed == fiabilite
                ? _value.fiabilite
                : fiabilite // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActualiteImplCopyWith<$Res>
    implements $ActualiteCopyWith<$Res> {
  factory _$$ActualiteImplCopyWith(
    _$ActualiteImpl value,
    $Res Function(_$ActualiteImpl) then,
  ) = __$$ActualiteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String titre,
    String contenu,
    CategorieActualite categorie,
    String? sourceUrl,
    String? imageUrl,
    DateTime datePublication,
    DateTime? dateIndexation,
    String? auteur,
    String? fiabilite,
  });
}

/// @nodoc
class __$$ActualiteImplCopyWithImpl<$Res>
    extends _$ActualiteCopyWithImpl<$Res, _$ActualiteImpl>
    implements _$$ActualiteImplCopyWith<$Res> {
  __$$ActualiteImplCopyWithImpl(
    _$ActualiteImpl _value,
    $Res Function(_$ActualiteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Actualite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titre = null,
    Object? contenu = null,
    Object? categorie = null,
    Object? sourceUrl = freezed,
    Object? imageUrl = freezed,
    Object? datePublication = null,
    Object? dateIndexation = freezed,
    Object? auteur = freezed,
    Object? fiabilite = freezed,
  }) {
    return _then(
      _$ActualiteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        titre: null == titre
            ? _value.titre
            : titre // ignore: cast_nullable_to_non_nullable
                  as String,
        contenu: null == contenu
            ? _value.contenu
            : contenu // ignore: cast_nullable_to_non_nullable
                  as String,
        categorie: null == categorie
            ? _value.categorie
            : categorie // ignore: cast_nullable_to_non_nullable
                  as CategorieActualite,
        sourceUrl: freezed == sourceUrl
            ? _value.sourceUrl
            : sourceUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        datePublication: null == datePublication
            ? _value.datePublication
            : datePublication // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dateIndexation: freezed == dateIndexation
            ? _value.dateIndexation
            : dateIndexation // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        auteur: freezed == auteur
            ? _value.auteur
            : auteur // ignore: cast_nullable_to_non_nullable
                  as String?,
        fiabilite: freezed == fiabilite
            ? _value.fiabilite
            : fiabilite // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ActualiteImpl extends _Actualite {
  const _$ActualiteImpl({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.categorie,
    this.sourceUrl,
    this.imageUrl,
    required this.datePublication,
    this.dateIndexation,
    this.auteur,
    this.fiabilite,
  }) : super._();

  @override
  final String id;
  @override
  final String titre;
  @override
  final String contenu;
  @override
  final CategorieActualite categorie;
  @override
  final String? sourceUrl;
  @override
  final String? imageUrl;
  @override
  final DateTime datePublication;
  @override
  final DateTime? dateIndexation;
  @override
  final String? auteur;

  /// Niveau de fiabilité de la source vérifié par la veille IA :
  /// 'officiel' (État, université…) ou 'presse' (média reconnu).
  @override
  final String? fiabilite;

  @override
  String toString() {
    return 'Actualite(id: $id, titre: $titre, contenu: $contenu, categorie: $categorie, sourceUrl: $sourceUrl, imageUrl: $imageUrl, datePublication: $datePublication, dateIndexation: $dateIndexation, auteur: $auteur, fiabilite: $fiabilite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActualiteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.titre, titre) || other.titre == titre) &&
            (identical(other.contenu, contenu) || other.contenu == contenu) &&
            (identical(other.categorie, categorie) ||
                other.categorie == categorie) &&
            (identical(other.sourceUrl, sourceUrl) ||
                other.sourceUrl == sourceUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.datePublication, datePublication) ||
                other.datePublication == datePublication) &&
            (identical(other.dateIndexation, dateIndexation) ||
                other.dateIndexation == dateIndexation) &&
            (identical(other.auteur, auteur) || other.auteur == auteur) &&
            (identical(other.fiabilite, fiabilite) ||
                other.fiabilite == fiabilite));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    titre,
    contenu,
    categorie,
    sourceUrl,
    imageUrl,
    datePublication,
    dateIndexation,
    auteur,
    fiabilite,
  );

  /// Create a copy of Actualite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActualiteImplCopyWith<_$ActualiteImpl> get copyWith =>
      __$$ActualiteImplCopyWithImpl<_$ActualiteImpl>(this, _$identity);
}

abstract class _Actualite extends Actualite {
  const factory _Actualite({
    required final String id,
    required final String titre,
    required final String contenu,
    required final CategorieActualite categorie,
    final String? sourceUrl,
    final String? imageUrl,
    required final DateTime datePublication,
    final DateTime? dateIndexation,
    final String? auteur,
    final String? fiabilite,
  }) = _$ActualiteImpl;
  const _Actualite._() : super._();

  @override
  String get id;
  @override
  String get titre;
  @override
  String get contenu;
  @override
  CategorieActualite get categorie;
  @override
  String? get sourceUrl;
  @override
  String? get imageUrl;
  @override
  DateTime get datePublication;
  @override
  DateTime? get dateIndexation;
  @override
  String? get auteur;

  /// Niveau de fiabilité de la source vérifié par la veille IA :
  /// 'officiel' (État, université…) ou 'presse' (média reconnu).
  @override
  String? get fiabilite;

  /// Create a copy of Actualite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActualiteImplCopyWith<_$ActualiteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ActualitePage {
  List<Actualite> get items => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get lastPage => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Create a copy of ActualitePage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActualitePageCopyWith<ActualitePage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActualitePageCopyWith<$Res> {
  factory $ActualitePageCopyWith(
    ActualitePage value,
    $Res Function(ActualitePage) then,
  ) = _$ActualitePageCopyWithImpl<$Res, ActualitePage>;
  @useResult
  $Res call({List<Actualite> items, int currentPage, int lastPage, int total});
}

/// @nodoc
class _$ActualitePageCopyWithImpl<$Res, $Val extends ActualitePage>
    implements $ActualitePageCopyWith<$Res> {
  _$ActualitePageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActualitePage
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
                      as List<Actualite>,
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
abstract class _$$ActualitePageImplCopyWith<$Res>
    implements $ActualitePageCopyWith<$Res> {
  factory _$$ActualitePageImplCopyWith(
    _$ActualitePageImpl value,
    $Res Function(_$ActualitePageImpl) then,
  ) = __$$ActualitePageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Actualite> items, int currentPage, int lastPage, int total});
}

/// @nodoc
class __$$ActualitePageImplCopyWithImpl<$Res>
    extends _$ActualitePageCopyWithImpl<$Res, _$ActualitePageImpl>
    implements _$$ActualitePageImplCopyWith<$Res> {
  __$$ActualitePageImplCopyWithImpl(
    _$ActualitePageImpl _value,
    $Res Function(_$ActualitePageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActualitePage
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
      _$ActualitePageImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<Actualite>,
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

class _$ActualitePageImpl extends _ActualitePage {
  const _$ActualitePageImpl({
    required final List<Actualite> items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  }) : _items = items,
       super._();

  final List<Actualite> _items;
  @override
  List<Actualite> get items {
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
    return 'ActualitePage(items: $items, currentPage: $currentPage, lastPage: $lastPage, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActualitePageImpl &&
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

  /// Create a copy of ActualitePage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActualitePageImplCopyWith<_$ActualitePageImpl> get copyWith =>
      __$$ActualitePageImplCopyWithImpl<_$ActualitePageImpl>(this, _$identity);
}

abstract class _ActualitePage extends ActualitePage {
  const factory _ActualitePage({
    required final List<Actualite> items,
    required final int currentPage,
    required final int lastPage,
    required final int total,
  }) = _$ActualitePageImpl;
  const _ActualitePage._() : super._();

  @override
  List<Actualite> get items;
  @override
  int get currentPage;
  @override
  int get lastPage;
  @override
  int get total;

  /// Create a copy of ActualitePage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActualitePageImplCopyWith<_$ActualitePageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
