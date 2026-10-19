/// Organismes OFFICIELS du logement étudiant (cités universitaires), affichés
/// sur l'accueil à la place d'annonces de logement inventées.
///
/// Chaque lien a été vérifié (site joignable, page officielle) le 12/10/2026.
/// Aucun prix ni aucune note : ces informations changent chaque année et ne
/// sont publiées de façon fiable que par les organismes eux-mêmes.
class OrganismeLogement {
  const OrganismeLogement({
    required this.universite,
    required this.ville,
    required this.organisme,
    required this.description,
    required this.siteOfficiel,
  });

  final String universite;
  final String ville;
  final String organisme;
  final String description;
  final String siteOfficiel;
}

const List<OrganismeLogement> kOrganismesLogement = [
  OrganismeLogement(
    universite: 'UCAD',
    ville: 'Dakar',
    organisme: 'COUD — Centre des Œuvres Universitaires de Dakar',
    description:
        'Chambres en cité universitaire attribuées par codification en début '
        'd\'année. Le site du COUD étant en construction, passer par le site de l\'UCAD.',
    siteOfficiel: 'https://www.ucad.sn',
  ),
  OrganismeLogement(
    universite: 'UASZ',
    ville: 'Ziguinchor',
    organisme: 'CROUS de Ziguinchor',
    description:
        'Hébergement, codification et restauration des étudiants de '
        'l\'Université Assane Seck.',
    siteOfficiel: 'https://www.crousz.sn',
  ),
  OrganismeLogement(
    universite: 'UGB',
    ville: 'Saint-Louis',
    organisme: 'Services sociaux de l\'UGB',
    description:
        'Logement sur le campus de Sanar : informations et calendrier de '
        'codification publiés par l\'université.',
    siteOfficiel: 'https://www.ugb.sn',
  ),
  OrganismeLogement(
    universite: 'UADB',
    ville: 'Bambey',
    organisme: 'Services sociaux de l\'UADB',
    description:
        'Hébergement des étudiants de l\'Université Alioune Diop : '
        'informations publiées par l\'université.',
    siteOfficiel: 'https://www.uadb.edu.sn',
  ),
];

/// Mots-clés qui identifient une actualité sur le logement étudiant, parmi
/// celles collectées par la veille IA.
const List<String> kMotsClesLogement = [
  'logement',
  'codification',
  'coud',
  'crous',
  'cité universitaire',
  'cités universitaires',
  'pavillon',
  'hébergement',
  'résidence universitaire',
  'chambres',
  'campus social',
];
