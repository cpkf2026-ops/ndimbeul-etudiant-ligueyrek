// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminUserModelImpl _$$AdminUserModelImplFromJson(Map<String, dynamic> json) =>
    _$AdminUserModelImpl(
      id: json['id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      role: _roleFromJson(json['role'] as String?),
      region: json['region'] as String?,
      statut: json['statut'] == null
          ? UserStatut.actif
          : _statutFromJson(json['statut'] as String?),
      dateInscription: json['date_inscription'] == null
          ? null
          : DateTime.parse(json['date_inscription'] as String),
      dateDerniereConnexion: json['date_derniere_connexion'] == null
          ? null
          : DateTime.parse(json['date_derniere_connexion'] as String),
    );

Map<String, dynamic> _$$AdminUserModelImplToJson(
  _$AdminUserModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'prenom': instance.prenom,
  'email': instance.email,
  'role': _roleToJson(instance.role),
  'region': instance.region,
  'statut': _statutToJson(instance.statut),
  'date_inscription': instance.dateInscription?.toIso8601String(),
  'date_derniere_connexion': instance.dateDerniereConnexion?.toIso8601String(),
};
