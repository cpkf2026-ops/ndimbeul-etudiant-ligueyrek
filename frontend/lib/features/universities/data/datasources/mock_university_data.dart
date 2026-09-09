import '../models/bourse_model.dart';
import '../models/contact_model.dart';
import '../models/formation_model.dart';
import '../models/frais_scolarite_model.dart';
import '../models/logement_model.dart';
import '../models/universite_model.dart';
import '../../../../shared/constants/app_images.dart';
import '../../domain/entities/formation.dart';
import '../../domain/entities/logement.dart';
import '../../domain/entities/universite.dart';

/// Une filière décrite de façon concise, développée en [FormationModel] par
/// [MockUniversityData._u] : (intitulé, domaine, niveau, durée, séries, moyenne, capacité).
typedef _Filiere = (String, String, NiveauFormation, int, List<String>?, double, int);

/// Catalogue mocké des établissements d'enseignement supérieur et de formation
/// professionnelle du Sénégal (Prompt 5 — « catalogue réellement exhaustif »).
///
/// Couverture : les 8 universités publiques, les grandes écoles publiques
/// rattachées, le réseau des 6 ISEP, une liste substantielle d'universités et
/// écoles privées reconnues par l'État, et un échantillon représentatif de
/// centres de formation professionnelle et technique couvrant l'ensemble des
/// régions. Miroir exact du `UniversiteSeeder` Laravel (mêmes établissements,
/// mêmes codes, même ordre). Images : photo réelle du bâtiment quand elle
/// existe, sinon repli générique à contexte africain (voir CREDITS_IMAGES.md).
abstract final class MockUniversityData {
  static final List<UniversiteModel> universites = [
    // =======================================================================
    // 1. UNIVERSITÉS PUBLIQUES (8) — les 4 premières gardent une fiche riche
    //    (bourses / logements / frais), le reste une fiche de présentation.
    // =======================================================================
    UniversiteModel(
      id: 'univ_ucad',
      nom: 'Université Cheikh Anta Diop de Dakar (UCAD)',
      codeUnique: 'UCAD',
      region: 'Dakar',
      commune: 'Fann-Point E-Amitié',
      type: EtablissementType.public,
      siteWebOfficiel: 'https://ucad.sn',
      imageUrl: AppImages.campusUcadReal,
      description:
          'Plus grande université publique du Sénégal, fondée en 1957. Elle regroupe '
          'plusieurs facultés (médecine, droit, sciences, lettres) et grandes écoles (ESP, FASEG).',
      contact: const ContactModel(email: 'contact@ucad.sn', telephone: '+221 33 824 60 81'),
      formations: [
        FormationModel(
          id: 'form_ucad_1',
          universiteId: 'univ_ucad',
          intitule: 'Licence Informatique',
          domaine: 'Informatique',
          niveau: NiveauFormation.licence,
          dureeAnnees: 3,
          seriesAcceptees: const ['S1', 'S2', 'S3'],
          moyenneMinimale: 12,
          capacite: 200,
          debouches: 'Développeur, administrateur systèmes, data analyst',
        ),
        FormationModel(
          id: 'form_ucad_2',
          universiteId: 'univ_ucad',
          intitule: 'Licence Économie-Gestion',
          domaine: 'Économie',
          niveau: NiveauFormation.licence,
          dureeAnnees: 3,
          seriesAcceptees: const ['S2', 'L', 'ES'],
          moyenneMinimale: 11,
          capacite: 350,
        ),
        FormationModel(
          id: 'form_ucad_3',
          universiteId: 'univ_ucad',
          intitule: 'Master Droit des Affaires',
          domaine: 'Droit',
          niveau: NiveauFormation.master,
          dureeAnnees: 2,
          moyenneMinimale: 13,
          capacite: 80,
        ),
      ],
      bourses: [
        BourseModel(
          id: 'bourse_ucad_1',
          universiteId: 'univ_ucad',
          nom: 'Bourse d\'excellence UCAD',
          organisme: 'Ministère de l\'Enseignement supérieur',
          montant: 480000,
          conditions: 'Moyenne générale ≥ 14/20, ressources familiales limitées',
          demarches: 'Dépôt de dossier auprès de la DBFC en début d\'année académique',
          dateLimite: DateTime(2026, 10, 31),
          source: 'DBFC — Direction des Bourses',
          dateMaj: DateTime(2026, 7, 1),
        ),
      ],
      logements: [
        LogementModel(
          id: 'log_ucad_1',
          universiteId: 'univ_ucad',
          nom: 'Cité universitaire UCAD (Campus social)',
          type: TypeLogement.residence,
          capacite: 8000,
          tarifMensuel: 15000,
          contact: 'oeuvres.sociales@ucad.sn',
          source: 'COUD — Centre des Œuvres Universitaires de Dakar',
          dateMaj: DateTime(2026, 6, 15),
        ),
      ],
      fraisScolarite: [
        FraisScolariteModel(
          id: 'frais_ucad_1',
          universiteId: 'univ_ucad',
          montant: 15000,
          moyensPaiement: const ['Espèces', 'Orange Money', 'Virement bancaire'],
          source: 'Service de la scolarité UCAD',
          dateMaj: DateTime(2026, 6, 1),
        ),
      ],
    ),
    UniversiteModel(
      id: 'univ_ugb',
      nom: 'Université Gaston Berger de Saint-Louis (UGB)',
      codeUnique: 'UGB',
      region: 'Saint-Louis',
      commune: 'Sanar',
      type: EtablissementType.public,
      siteWebOfficiel: 'https://ugb.sn',
      imageUrl: AppImages.campusUgbReal,
      description:
          'Deuxième université publique du pays, réputée pour ses filières scientifiques '
          'et sa vie de campus organisée en UFR autonomes.',
      contact: const ContactModel(email: 'contact@ugb.sn', telephone: '+221 33 961 16 91'),
      formations: [
        FormationModel(
          id: 'form_ugb_1',
          universiteId: 'univ_ugb',
          intitule: 'Licence Mathématiques-Informatique',
          domaine: 'Informatique',
          niveau: NiveauFormation.licence,
          dureeAnnees: 3,
          seriesAcceptees: const ['S1', 'S2'],
          moyenneMinimale: 12,
          capacite: 120,
        ),
        FormationModel(
          id: 'form_ugb_2',
          universiteId: 'univ_ugb',
          intitule: 'Master Agroéconomie',
          domaine: 'Agronomie',
          niveau: NiveauFormation.master,
          dureeAnnees: 2,
          moyenneMinimale: 12,
          capacite: 40,
        ),
      ],
      bourses: [
        BourseModel(
          id: 'bourse_ugb_1',
          universiteId: 'univ_ugb',
          nom: 'Bourse régionale Saint-Louis',
          organisme: 'Conseil régional de Saint-Louis',
          montant: 300000,
          conditions: 'Résidents de la région de Saint-Louis, mérite académique',
          dateLimite: DateTime(2026, 9, 30),
          source: 'Conseil régional',
          dateMaj: DateTime(2026, 7, 5),
        ),
      ],
      logements: [
        LogementModel(
          id: 'log_ugb_1',
          universiteId: 'univ_ugb',
          nom: 'Campus résidentiel UGB',
          type: TypeLogement.residence,
          capacite: 4000,
          tarifMensuel: 12000,
          source: 'Direction des affaires estudiantines UGB',
          dateMaj: DateTime(2026, 6, 20),
        ),
      ],
      fraisScolarite: [
        FraisScolariteModel(
          id: 'frais_ugb_1',
          universiteId: 'univ_ugb',
          montant: 15000,
          moyensPaiement: const ['Espèces', 'Wave'],
          source: 'Scolarité UGB',
          dateMaj: DateTime(2026, 6, 1),
        ),
      ],
    ),
    UniversiteModel(
      id: 'univ_isep_dmn',
      nom: 'ISEP de Diamniadio (Amadou Traoré)',
      codeUnique: 'ISEP-DMN',
      region: 'Dakar',
      commune: 'Diamniadio',
      type: EtablissementType.public,
      siteWebOfficiel: 'https://isep-diamniadio.sn',
      imageUrl: AppImages.aucunePhoto,
      description:
          'Institut professionnalisant à taille humaine du pôle de Diamniadio, spécialisé '
          'dans la technologie automobile, l\'électronique et le numérique (BTS, licences pro).',
      contact: const ContactModel(email: 'contact@isep-diamniadio.sn', telephone: '+221 33 000 00 00'),
      formations: [
        FormationModel(
          id: 'form_isep_dmn_1',
          universiteId: 'univ_isep_dmn',
          intitule: 'BTS Développement Web et Mobile',
          domaine: 'Informatique',
          niveau: NiveauFormation.bts,
          dureeAnnees: 2,
          seriesAcceptees: const ['S1', 'S2', 'S3', 'T'],
          moyenneMinimale: 10,
          capacite: 60,
          debouches: 'Développeur front/back, intégrateur, technicien d\'applications',
        ),
        FormationModel(
          id: 'form_isep_dmn_2',
          universiteId: 'univ_isep_dmn',
          intitule: 'BTS Maintenance Automobile',
          domaine: 'Industrie',
          niveau: NiveauFormation.bts,
          dureeAnnees: 2,
          seriesAcceptees: const ['S1', 'T', 'F'],
          moyenneMinimale: 10,
          capacite: 50,
        ),
      ],
      bourses: const [],
      logements: [
        LogementModel(
          id: 'log_isep_dmn_1',
          universiteId: 'univ_isep_dmn',
          nom: 'Résidence partenaire Diamniadio',
          type: TypeLogement.partenaire,
          capacite: 300,
          tarifMensuel: 35000,
          source: 'Partenaire privé référencé ISEP',
          dateMaj: DateTime(2026, 5, 20),
        ),
      ],
      fraisScolarite: [
        FraisScolariteModel(
          id: 'frais_isep_dmn_1',
          universiteId: 'univ_isep_dmn',
          montant: 50000,
          moyensPaiement: const ['Virement bancaire', 'Orange Money'],
          source: 'Agence comptable ISEP',
          dateMaj: DateTime(2026, 6, 10),
        ),
      ],
    ),
    UniversiteModel(
      id: 'univ_esp',
      nom: 'École Supérieure Polytechnique de Dakar (ESP)',
      codeUnique: 'ESP',
      region: 'Dakar',
      commune: 'Fann',
      type: EtablissementType.public,
      siteWebOfficiel: 'https://esp.sn',
      imageUrl: AppImages.campusEspReal,
      description:
          'Grande école d\'ingénieurs rattachée à l\'UCAD, très sélective, formant des '
          'ingénieurs de conception et de travaux dans plusieurs filières techniques.',
      contact: const ContactModel(email: 'contact@esp.sn', telephone: '+221 33 889 10 30'),
      formations: [
        FormationModel(
          id: 'form_esp_1',
          universiteId: 'univ_esp',
          intitule: 'Ingénieur Génie Informatique',
          domaine: 'Informatique',
          niveau: NiveauFormation.master,
          dureeAnnees: 5,
          seriesAcceptees: const ['S1', 'S2', 'S3'],
          moyenneMinimale: 15,
          capacite: 45,
          debouches: 'Ingénieur systèmes, ingénieur logiciel senior',
        ),
      ],
      bourses: const [],
      logements: const [],
      fraisScolarite: const [],
    ),

    // Universités publiques — fiches de présentation
    _u(
      id: 'univ_uidt',
      nom: 'Université Iba Der Thiam de Thiès (UIDT)',
      code: 'UIDT',
      region: 'Thiès',
      commune: 'Thiès',
      type: EtablissementType.public,
      site: 'https://www.uidt.sn',
      image: AppImages.uidtReal,
      description:
          'Université pluridisciplinaire de Thiès (santé, sciences et techniques, '
          'mines-géologie, agriculture), en forte croissance depuis 2007.',
      formations: const [
        ('Licence Génie Civil', 'Ingénierie', NiveauFormation.licence, 3, ['S1', 'S2', 'T'], 11, 90),
        ('Licence Sciences Infirmières', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 12, 70),
      ],
    ),
    _u(
      id: 'univ_uasz',
      nom: 'Université Assane Seck de Ziguinchor (UASZ)',
      code: 'UASZ',
      region: 'Ziguinchor',
      commune: 'Ziguinchor',
      type: EtablissementType.public,
      site: 'https://uasz.sn',
      image: AppImages.uaszReal,
      description:
          'Université publique de la Casamance : lettres, sciences économiques, '
          'sciences et technologies, agroforesterie.',
      formations: const [
        ('Licence Agroforesterie', 'Environnement', NiveauFormation.licence, 3, ['S1', 'S2', 'D'], 10, 60),
        ('Licence Lettres Modernes', 'Lettres', NiveauFormation.licence, 3, ['L', 'S1'], 10, 80),
      ],
    ),
    _u(
      id: 'univ_uadb',
      nom: 'Université Alioune Diop de Bambey (UADB)',
      code: 'UADB',
      region: 'Diourbel',
      commune: 'Bambey',
      type: EtablissementType.public,
      site: 'https://uadb.edu.sn',
      image: AppImages.uadbReal,
      description:
          'Université orientée agro-sylvo-pastoral, sciences de la santé et STEG, '
          'au cœur du bassin arachidier.',
      formations: const [
        ('Licence Agroalimentaire', 'Agronomie', NiveauFormation.licence, 3, ['S1', 'S2', 'D'], 10, 70),
        ('Licence Sciences de la Santé Communautaire', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 11, 60),
      ],
    ),
    _u(
      id: 'univ_ussein',
      nom: 'Université du Sine Saloum El Hadji Ibrahima Niasse (USSEIN)',
      code: 'USSEIN',
      region: 'Kaolack',
      commune: 'Kaolack',
      type: EtablissementType.public,
      site: 'https://ussein.sn',
      image: AppImages.aucunePhoto,
      description:
          'Université multi-sites (Kaolack, Fatick, Kaffrine) spécialisée dans '
          'l\'agriculture, l\'agroalimentaire, la santé et le développement territorial.',
      formations: const [
        ('Licence Agronomie', 'Agronomie', NiveauFormation.licence, 3, ['S1', 'S2', 'D'], 10, 80),
        ('Licence Gestion des Entreprises Agricoles', 'Management', NiveauFormation.licence, 3, ['S2', 'G'], 10, 60),
      ],
    ),
    _u(
      id: 'univ_uam',
      nom: 'Université Amadou Mahtar Mbow de Diamniadio (UAM)',
      code: 'UAM',
      region: 'Dakar',
      commune: 'Diamniadio',
      type: EtablissementType.public,
      site: 'https://uam.sn',
      image: AppImages.uamReal,
      description:
          'Université de nouvelle génération au pôle de Diamniadio, centrée sur les '
          'sciences, l\'ingénierie, le numérique et la biotechnologie.',
      formations: const [
        ('Licence Génie Logiciel et Systèmes d\'Information', 'Informatique', NiveauFormation.licence, 3, ['S1', 'S2', 'S3'], 12, 90),
        ('Licence Génie Électrique et Énergies Renouvelables', 'Ingénierie', NiveauFormation.licence, 3, ['S1', 'S2', 'T'], 11, 70),
      ],
    ),
    _u(
      id: 'univ_unchk',
      nom: 'Université Numérique Cheikh Hamidou Kane (ex-UVS)',
      code: 'UN-CHK',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://unchk.sn',
      image: AppImages.unchkReal,
      description:
          'Université 100 % numérique, organisée en Espaces Numériques Ouverts (ENO) '
          'répartis dans toutes les régions — formations à distance.',
      formations: const [
        ('Licence Développement Web et Mobile', 'Informatique', NiveauFormation.licence, 3, ['S1', 'S2', 'S3', 'L'], 10, 500),
        ('Licence Sciences de l\'Éducation', 'Éducation', NiveauFormation.licence, 3, null, 10, 400),
      ],
    ),

    // =======================================================================
    // 2. GRANDES ÉCOLES PUBLIQUES
    // =======================================================================
    _u(
      id: 'univ_ept',
      nom: 'École Polytechnique de Thiès (EPT)',
      code: 'EPT',
      region: 'Thiès',
      commune: 'Thiès',
      type: EtablissementType.public,
      site: 'https://ept.sn',
      image: AppImages.eptThiesReal,
      description:
          'École d\'ingénieurs publique de référence : génie civil, génie mécanique, '
          'génie électromécanique, génie chimique et biologie appliquée.',
      formations: const [
        ('Diplôme d\'Ingénieur Génie Civil', 'Ingénierie', NiveauFormation.master, 5, ['S1', 'S2'], 15, 40),
        ('Diplôme d\'Ingénieur Génie Mécanique', 'Ingénierie', NiveauFormation.master, 5, ['S1', 'S2'], 15, 35),
      ],
    ),
    _u(
      id: 'univ_ensa',
      nom: 'École Nationale Supérieure d\'Agriculture de Thiès (ENSA)',
      code: 'ENSA',
      region: 'Thiès',
      commune: 'Thiès',
      type: EtablissementType.public,
      site: 'https://ensa.sn',
      image: AppImages.ensaThiesReal,
      description:
          'École d\'ingénieurs agronomes rattachée à l\'Université de Thiès, spécialisée '
          'en productions végétales, animales et génie rural.',
      formations: const [
        ('Diplôme d\'Ingénieur Agronome', 'Agronomie', NiveauFormation.master, 5, ['S1', 'S2', 'D'], 14, 50),
      ],
    ),
    _u(
      id: 'univ_ena',
      nom: 'École Nationale d\'Administration (ENA)',
      code: 'ENA-SN',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://ena.sn',
      image: AppImages.aucunePhoto,
      description:
          'École de formation des hauts fonctionnaires de l\'État : administration '
          'générale, diplomatie, douanes, impôts, magistrature.',
      formations: const [
        ('Cycle A — Administration Générale', 'Administration publique', NiveauFormation.master, 2, null, 12, 80),
      ],
    ),
    _u(
      id: 'univ_cesag',
      nom: 'Centre Africain d\'Études Supérieures en Gestion (CESAG)',
      code: 'CESAG',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://cesag.sn',
      image: AppImages.campusCesagReal,
      description:
          'École de management interétatique de la zone UEMOA/BCEAO : finance, banque, '
          'audit-contrôle, marketing, santé publique.',
      formations: const [
        ('Master Banque et Finance', 'Finance', NiveauFormation.master, 2, null, 12, 60),
        ('Master Audit et Contrôle de Gestion', 'Management', NiveauFormation.master, 2, null, 12, 50),
      ],
    ),
    _u(
      id: 'univ_ensetp',
      nom: 'École Normale Supérieure d\'Enseignement Technique et Professionnel (ENSETP)',
      code: 'ENSETP',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://ensetp.ucad.sn',
      image: AppImages.aucunePhoto,
      description:
          'Forme les professeurs de l\'enseignement technique et professionnel et les '
          'cadres de la formation : génie mécanique, économie familiale et sociale, biotechnologies.',
      formations: const [
        ('Licence Professeur d\'Enseignement Technique', 'Éducation', NiveauFormation.licence, 3, ['S1', 'S2', 'T', 'G'], 11, 60),
      ],
    ),
    _u(
      id: 'univ_ensae',
      nom: 'École Nationale de la Statistique et de l\'Analyse Économique Pierre Ndiaye (ENSAE)',
      code: 'ENSAE',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://ensae.sn',
      image: AppImages.aucunePhoto,
      description:
          'École de la statistique publique : ingénieurs statisticiens économistes, '
          'ingénieurs des travaux statistiques, data science.',
      formations: const [
        ('Ingénieur Statisticien Économiste', 'Économie', NiveauFormation.master, 3, ['S1', 'S2'], 14, 30),
      ],
    ),
    _u(
      id: 'univ_fastef',
      nom: 'Faculté des Sciences et Technologies de l\'Éducation et de la Formation (FASTEF)',
      code: 'FASTEF',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://ucad.sn',
      image: AppImages.aucunePhoto,
      description:
          'Ex-École Normale Supérieure : formation initiale et continue des professeurs '
          'de collège et de lycée et des inspecteurs de l\'éducation.',
      formations: const [
        ('CAES — Certificat d\'Aptitude à l\'Enseignement Secondaire', 'Éducation', NiveauFormation.master, 1, null, 12, 200),
      ],
    ),
    _u(
      id: 'univ_ebad',
      nom: 'École des Bibliothécaires, Archivistes et Documentalistes (EBAD)',
      code: 'EBAD',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://ebad.ucad.sn',
      image: AppImages.ebadReal,
      description:
          'Référence régionale des métiers de l\'information documentaire : '
          'bibliothéconomie, archivistique, gestion de l\'information numérique.',
      formations: const [
        ('Licence Sciences de l\'Information Documentaire', 'Documentation', NiveauFormation.licence, 3, null, 10, 90),
      ],
    ),
    _u(
      id: 'univ_endss',
      nom: 'École Nationale de Développement Sanitaire et Social (ENDSS)',
      code: 'ENDSS',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://endss.ucad.sn',
      image: AppImages.aucunePhoto,
      description:
          'Forme les infirmiers, sages-femmes, techniciens supérieurs de santé et '
          'travailleurs sociaux de la fonction publique.',
      formations: const [
        ('Diplôme d\'État d\'Infirmier', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 12, 120),
        ('Diplôme d\'État de Sage-Femme', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 13, 60),
      ],
    ),
    _u(
      id: 'univ_cesti',
      nom: 'Centre d\'Études des Sciences et Techniques de l\'Information (CESTI)',
      code: 'CESTI',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://cesti.ucad.sn',
      image: AppImages.cestiReal,
      description:
          'Plus ancienne école de journalisme d\'Afrique de l\'Ouest francophone : '
          'presse écrite, radio, télévision, journalisme numérique.',
      formations: const [
        ('Licence Journalisme', 'Communication', NiveauFormation.licence, 3, ['L', 'S2', 'ES'], 12, 40),
      ],
    ),
    _u(
      id: 'univ_ita',
      nom: 'Institut de Technologie Alimentaire (ITA)',
      code: 'ITA',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://ita.sn',
      image: AppImages.itaReal,
      description:
          'Institut public de recherche-formation en transformation et conservation '
          'des produits agricoles et halieutiques.',
      formations: const [
        ('Licence Professionnelle Technologie Alimentaire', 'Agroalimentaire', NiveauFormation.licence, 3, ['S1', 'S2', 'D'], 11, 40),
      ],
    ),
    _u(
      id: 'univ_isfar',
      nom: 'Institut Supérieur de Formation Agricole et Rurale de Bambey (ISFAR)',
      code: 'ISFAR',
      region: 'Diourbel',
      commune: 'Bambey',
      type: EtablissementType.public,
      site: 'https://uadb.edu.sn/ufr-et-instituts/institut-superieur-de-formation-agricole-et-rural',
      image: AppImages.isfarReal,
      description:
          'Ex-ENCR, rattaché à l\'UADB : forme les techniciens supérieurs et ingénieurs '
          'des travaux agricoles, de l\'élevage et des eaux et forêts.',
      formations: const [
        ('Licence Professionnelle Productions Végétales', 'Agronomie', NiveauFormation.licence, 3, ['S1', 'S2', 'D'], 10, 50),
      ],
    ),

    // =======================================================================
    // 3. RÉSEAU DES ISEP (6) — Diamniadio décrit plus haut
    // =======================================================================
    _u(
      id: 'univ_isep_thies',
      nom: 'ISEP de Thiès',
      code: 'ISEP-THIES',
      region: 'Thiès',
      commune: 'Thiès',
      type: EtablissementType.public,
      site: 'https://www.isep-thies.sn',
      image: AppImages.isepThiesAtelier,
      description:
          'Premier ISEP du réseau (2014) : maintenance industrielle, électrotechnique, '
          'froid et climatisation, gestion, tourisme.',
      formations: const [
        ('BTS Maintenance Industrielle', 'Industrie', NiveauFormation.bts, 2, ['S1', 'S3', 'T', 'F'], 10, 60),
        ('BTS Froid et Climatisation', 'Industrie', NiveauFormation.bts, 2, ['S1', 'T', 'F'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_isep_rt',
      nom: 'ISEP de Richard-Toll',
      code: 'ISEP-RT',
      region: 'Saint-Louis',
      commune: 'Richard-Toll',
      type: EtablissementType.public,
      site: 'https://iseprichardtoll.sn',
      image: AppImages.aucunePhoto,
      description:
          'ISEP orienté agriculture irriguée, agro-industrie et maintenance des '
          'équipements agricoles dans la vallée du fleuve Sénégal.',
      formations: const [
        ('BTS Productions Agricoles', 'Agronomie', NiveauFormation.bts, 2, ['S1', 'S2', 'D', 'T'], 10, 50),
        ('BTS Agro-industrie', 'Agroalimentaire', NiveauFormation.bts, 2, ['S1', 'S2', 'T'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_isep_mat',
      nom: 'ISEP de Matam',
      code: 'ISEP-MAT',
      region: 'Matam',
      commune: 'Matam',
      type: EtablissementType.public,
      site: 'https://isepmatam.sn',
      image: AppImages.isepMatamReal,
      description:
          'ISEP de la région de Matam : élevage, agriculture, énergies renouvelables '
          'et entrepreneuriat rural.',
      formations: const [
        ('BTS Élevage et Productions Animales', 'Agronomie', NiveauFormation.bts, 2, ['S1', 'S2', 'D'], 10, 40),
        ('BTS Énergies Renouvelables', 'Ingénierie', NiveauFormation.bts, 2, ['S1', 'S2', 'T'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_isep_big',
      nom: 'ISEP de Bignona',
      code: 'ISEP-BIG',
      region: 'Ziguinchor',
      commune: 'Bignona',
      type: EtablissementType.public,
      site: 'https://isep.sn',
      image: AppImages.aucunePhoto,
      description:
          'ISEP de la Casamance : arboriculture fruitière, transformation des produits '
          'locaux, tourisme durable et froid.',
      formations: const [
        ('BTS Transformation des Produits Agroalimentaires', 'Agroalimentaire', NiveauFormation.bts, 2, ['S1', 'S2', 'D', 'T'], 10, 40),
        ('BTS Tourisme et Hôtellerie', 'Tourisme', NiveauFormation.bts, 2, ['L', 'S2', 'G'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_isep_mbk',
      nom: 'ISEP de Mbacké',
      code: 'ISEP-MBK',
      region: 'Diourbel',
      commune: 'Mbacké',
      type: EtablissementType.public,
      site: 'https://isep-mbacke.sn',
      image: AppImages.aucunePhoto,
      description:
          'ISEP de Mbacké : bâtiment et travaux publics, énergie solaire, gestion '
          'commerciale et numérique.',
      formations: const [
        ('BTS Bâtiment et Travaux Publics', 'BTP', NiveauFormation.bts, 2, ['S1', 'S2', 'T', 'F'], 10, 50),
        ('BTS Gestion Commerciale', 'Commerce', NiveauFormation.bts, 2, ['G', 'L', 'S2'], 10, 50),
      ],
    ),

    // =======================================================================
    // 4. UNIVERSITÉS & ÉCOLES PRIVÉES RECONNUES PAR L'ÉTAT
    // =======================================================================
    _u(
      id: 'univ_ucao_uud',
      nom: 'Université Catholique de l\'Afrique de l\'Ouest — Unité de Dakar (UCAO-UUD)',
      code: 'UCAO-UUD',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://www.st-michel.sn',
      image: AppImages.ucaoUudReal,
      description:
          'Établissement privé reconnu : droit, économie-gestion, informatique, '
          'philosophie et théologie.',
      formations: const [
        ('Licence Droit', 'Droit', NiveauFormation.licence, 3, ['L', 'S2', 'ES'], 11, 120),
        ('Licence Informatique de Gestion', 'Informatique', NiveauFormation.licence, 3, ['S1', 'S2', 'G'], 10, 80),
      ],
    ),
    _u(
      id: 'univ_uahb',
      nom: 'Université Amadou Hampâté Bâ (UAHB)',
      code: 'UAHB',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://univ.uahb.sn',
      image: AppImages.uahbReal,
      description:
          'Université privée reconnue : sciences juridiques et politiques, sciences '
          'économiques et de gestion, communication.',
      formations: const [
        ('Licence Sciences Politiques', 'Sciences politiques', NiveauFormation.licence, 3, ['L', 'S2', 'ES'], 10, 90),
      ],
    ),
    _u(
      id: 'univ_udb',
      nom: 'Université Dakar Bourguiba (UDB)',
      code: 'UDB',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://www.udb-sn.com',
      image: AppImages.udbReal,
      description:
          'Université privée pluridisciplinaire : gestion, droit, informatique, '
          'communication et langues.',
      formations: const [
        ('Licence Gestion des Entreprises', 'Management', NiveauFormation.licence, 3, ['G', 'L', 'S2'], 10, 120),
      ],
    ),
    _u(
      id: 'univ_unis',
      nom: 'Université du Sahel',
      code: 'UNIS',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://www.sahel.education',
      image: AppImages.unisReal,
      description:
          'Université privée reconnue : environnement, agrobusiness, sciences de la '
          'santé, gestion et technologies.',
      formations: const [
        ('Licence Gestion de l\'Environnement', 'Environnement', NiveauFormation.licence, 3, ['S1', 'S2', 'L'], 10, 70),
      ],
    ),
    _u(
      id: 'univ_ukb',
      nom: 'Université Privée Kocc Barma de Saint-Louis (UKB)',
      code: 'UKB',
      region: 'Saint-Louis',
      commune: 'Saint-Louis',
      type: EtablissementType.prive,
      site: 'https://ukb.sn',
      image: AppImages.ukbReal,
      description:
          'Établissement privé du nord du pays : management, informatique, tourisme '
          'et agrobusiness.',
      formations: const [
        ('Licence Informatique', 'Informatique', NiveauFormation.licence, 3, ['S1', 'S2', 'S3'], 10, 60),
      ],
    ),
    _u(
      id: 'univ_ism',
      nom: 'Institut Supérieur de Management (ISM Dakar)',
      code: 'ISM',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://groupeism.sn',
      image: AppImages.aucunePhoto,
      description:
          'Groupe privé de référence en management, avec des campus en régions : '
          'gestion, finance, marketing, ingénierie informatique.',
      formations: const [
        ('Licence Gestion des Entreprises', 'Management', NiveauFormation.licence, 3, ['S2', 'G', 'L'], 10, 150),
        ('Master Finance d\'Entreprise', 'Finance', NiveauFormation.master, 2, null, 11, 60),
      ],
    ),
    _u(
      id: 'univ_iam',
      nom: 'Institut Africain de Management (IAM)',
      code: 'IAM',
      region: 'Dakar',
      commune: 'Mermoz',
      type: EtablissementType.prive,
      site: 'https://groupeiam.com',
      image: AppImages.iamReal,
      description:
          'École privée de commerce et de management : marketing, finance, management '
          'de projets, intelligence artificielle appliquée.',
      formations: const [
        ('Licence Marketing Digital', 'Marketing', NiveauFormation.licence, 3, ['S2', 'L', 'ES', 'G'], 10, 150),
      ],
    ),
    _u(
      id: 'univ_bem',
      nom: 'BEM Dakar — Business School',
      code: 'BEM',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://bem.sn',
      image: AppImages.aucunePhoto,
      description:
          'Ex-Bordeaux École de Management : programmes Bachelor et Master en '
          'management, finance et business international.',
      formations: const [
        ('Bachelor Management International', 'Management', NiveauFormation.licence, 3, ['S2', 'L', 'G'], 10, 100),
      ],
    ),
    _u(
      id: 'univ_supdeco',
      nom: 'Groupe Sup de Co Dakar',
      code: 'SUPDECO',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://supdeco.sn',
      image: AppImages.aucunePhoto,
      description:
          'Grande école de commerce privée : programme Grande École, Bachelors en '
          'gestion, logistique, banque-assurance, RH.',
      formations: const [
        ('Bachelor Transport et Logistique', 'Logistique', NiveauFormation.licence, 3, ['S2', 'G', 'L'], 10, 90),
      ],
    ),
    _u(
      id: 'univ_iseg',
      nom: 'Institut Supérieur d\'Entreprise et de Gestion (ISEG)',
      code: 'ISEG',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Réseau privé implanté à Dakar et en régions : gestion, informatique, '
          'communication, banque-finance.',
      formations: const [
        ('Licence Banque et Finance', 'Finance', NiveauFormation.licence, 3, ['S2', 'G', 'L'], 10, 100),
      ],
    ),
    _u(
      id: 'univ_esmt',
      nom: 'École Supérieure Multinationale des Télécommunications (ESMT)',
      code: 'ESMT',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://esmt.sn',
      image: AppImages.esmtReal,
      description:
          'École interétatique des télécommunications et du numérique : réseaux, '
          'cybersécurité, télécoms, data et IoT.',
      formations: const [
        ('Licence Réseaux et Télécommunications', 'Télécommunications', NiveauFormation.licence, 3, ['S1', 'S2', 'S3', 'T'], 11, 80),
        ('Master Cybersécurité', 'Informatique', NiveauFormation.master, 2, null, 12, 40),
      ],
    ),
    _u(
      id: 'univ_hec_dkr',
      nom: 'HEC Dakar — Hautes Études Commerciales',
      code: 'HEC-DKR',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'École de commerce privée : comptabilité-finance, management, commerce '
          'international et entrepreneuriat.',
      formations: const [
        ('Licence Comptabilité, Contrôle, Audit', 'Finance', NiveauFormation.licence, 3, ['G', 'S2', 'L'], 10, 80),
      ],
    ),
    _u(
      id: 'univ_isi',
      nom: 'Institut Supérieur d\'Informatique (ISI)',
      code: 'ISI',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://www.groupeisi.com',
      image: AppImages.isiReal,
      description:
          'École privée spécialisée dans les technologies de l\'information : génie '
          'logiciel, réseaux, sécurité, systèmes d\'information.',
      formations: const [
        ('Licence Génie Logiciel', 'Informatique', NiveauFormation.licence, 3, ['S1', 'S2', 'S3', 'T'], 10, 120),
        ('Master Systèmes d\'Information et Réseaux', 'Informatique', NiveauFormation.master, 2, null, 11, 50),
      ],
    ),
    _u(
      id: 'univ_ipg',
      nom: 'Institut Privé de Gestion (IPG)',
      code: 'IPG',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://ipg-isti.com',
      image: AppImages.ipgReal,
      description:
          'École privée de gestion et de management : ressources humaines, marketing, '
          'gestion de projet, comptabilité.',
      formations: const [
        ('Licence Gestion des Ressources Humaines', 'Management', NiveauFormation.licence, 3, ['G', 'L', 'S2'], 10, 90),
      ],
    ),
    _u(
      id: 'univ_afi_ue',
      nom: 'AFI — l\'Université de l\'Entreprise',
      code: 'AFI-UE',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://afi-ue.sn',
      image: AppImages.afiUeReal,
      description:
          'Établissement privé agréé : management, finance-comptabilité, informatique '
          'et communication, en licence et master.',
      formations: const [
        ('Licence Management des Organisations', 'Management', NiveauFormation.licence, 3, ['G', 'S2', 'L'], 10, 100),
      ],
    ),
    _u(
      id: 'univ_dbs',
      nom: 'Dakar Business School (DBS)',
      code: 'DBS',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Business school privée : management, finance, marketing digital et '
          'business analytics.',
      formations: const [
        ('Bachelor Business Analytics', 'Management', NiveauFormation.licence, 3, ['S1', 'S2', 'G'], 10, 60),
      ],
    ),
    _u(
      id: 'univ_ceds_dkr',
      nom: 'Centre d\'Études Diplomatiques et Stratégiques de Dakar (CEDS)',
      code: 'CEDS-DKR',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://cedsdakar.org',
      image: AppImages.cedsDkrReal,
      description:
          'Établissement privé spécialisé en relations internationales, géopolitique, '
          'défense et intelligence économique.',
      formations: const [
        ('Master Relations Internationales', 'Sciences politiques', NiveauFormation.master, 2, null, 12, 40),
      ],
    ),
    _u(
      id: 'univ_pigier',
      nom: 'Pigier Sénégal',
      code: 'PIGIER',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Réseau privé de formation tertiaire : secrétariat de direction, '
          'comptabilité, commerce, tourisme, communication.',
      formations: const [
        ('BTS Assistant de Gestion PME-PMI', 'Commerce', NiveauFormation.bts, 2, ['G', 'L', 'S2'], 10, 80),
      ],
    ),
    _u(
      id: 'univ_uea',
      nom: 'Université Euro-Afrique (UEA)',
      code: 'UEA',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Université privée : sciences de la santé, gestion, informatique et '
          'sciences juridiques.',
      formations: const [
        ('Licence Analyses Biomédicales', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 11, 60),
      ],
    ),

    // =======================================================================
    // 5. CENTRES DE FORMATION PROFESSIONNELLE ET TECHNIQUE
    // =======================================================================
    _u(
      id: 'univ_cfpt_sj',
      nom: 'Centre de Formation Professionnelle et Technique Sénégal-Japon (CFPT-SJ)',
      code: 'CFPT-SJ',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://cfptsj.sn',
      image: AppImages.cfptSjReal,
      description:
          'Pôle de référence de la coopération sénégalo-japonaise pour les métiers de '
          'l\'industrie : électromécanique, maintenance, structures métalliques, froid.',
      formations: const [
        ('BTS Électromécanique', 'Industrie', NiveauFormation.bts, 2, ['S1', 'S3', 'T', 'F'], 11, 48),
        ('BTS Maintenance des Engins Lourds', 'Industrie', NiveauFormation.bts, 2, ['S1', 'T', 'F'], 11, 36),
      ],
    ),
    _u(
      id: 'univ_ltid_delafosse',
      nom: 'Lycée Technique Industriel Maurice Delafosse',
      code: 'LTID-DELAFOSSE',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://ltidelafosse.net',
      image: AppImages.aucunePhoto,
      description:
          'Lycée technique industriel historique de Dakar : électrotechnique, '
          'mécanique, construction métallique, génie civil.',
      formations: const [
        ('Baccalauréat Technique F3 — Électrotechnique', 'Industrie', NiveauFormation.bts, 3, ['3e'], 10, 90),
        ('BT Construction Métallique', 'Industrie', NiveauFormation.bts, 2, ['3e', 'T'], 10, 48),
      ],
    ),
    _u(
      id: 'univ_ltc_delafosse',
      nom: 'Lycée Technique Commercial Maurice Delafosse',
      code: 'LTC-DELAFOSSE',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Lycée technique commercial de Dakar : comptabilité-gestion, secrétariat '
          'bureautique, action commerciale.',
      formations: const [
        ('Baccalauréat Technique G — Techniques Quantitatives de Gestion', 'Commerce', NiveauFormation.bts, 3, ['3e'], 10, 120),
      ],
    ),
    _u(
      id: 'univ_lt_peytavin',
      nom: 'Lycée Technique André Peytavin de Saint-Louis',
      code: 'LT-PEYTAVIN',
      region: 'Saint-Louis',
      commune: 'Saint-Louis',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Grand lycée technique du nord : filières industrielles (électricité, '
          'mécanique, froid) et tertiaires (gestion, secrétariat).',
      formations: const [
        ('Baccalauréat Technique F1 — Construction Mécanique', 'Industrie', NiveauFormation.bts, 3, ['3e'], 10, 60),
      ],
    ),
    _u(
      id: 'univ_cedt_g15',
      nom: 'Centre d\'Enseignement et de Développement Technique G15 (CEDT G15)',
      code: 'CEDT-G15',
      region: 'Dakar',
      commune: 'Guédiawaye',
      type: EtablissementType.public,
      site: 'https://cedtleg15.com',
      image: AppImages.cedtG15Real,
      description:
          'Centre technique de Guédiawaye : électricité, mécanique automobile, '
          'menuiserie métallique et bois, froid.',
      formations: const [
        ('CAP Mécanique Automobile', 'Industrie', NiveauFormation.bts, 2, ['3e'], 10, 40),
        ('BEP Électrotechnique', 'Industrie', NiveauFormation.bts, 2, ['3e'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_cnqp',
      nom: 'Centre National de Qualification Professionnelle de Dakar (CNQP)',
      code: 'CNQP',
      region: 'Dakar',
      commune: 'Pikine',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Centre de qualification et de perfectionnement aux métiers du bâtiment, de '
          'l\'industrie et de l\'énergie, y compris pour adultes en reconversion.',
      formations: const [
        ('Certificat de Qualification — Plomberie', 'BTP', NiveauFormation.bts, 1, null, 10, 30),
        ('Certificat de Qualification — Installation Solaire', 'Énergie', NiveauFormation.bts, 1, null, 10, 30),
      ],
    ),
    _u(
      id: 'univ_cfp_thies',
      nom: 'Centre de Formation Professionnelle de Thiès',
      code: 'CFP-THIES',
      region: 'Thiès',
      commune: 'Thiès',
      type: EtablissementType.public,
      site: 'https://formation.gouv.sn',
      image: AppImages.aucunePhoto,
      description:
          'Centre régional : bâtiment, électricité, mécanique, coupe-couture, '
          'transformation agroalimentaire.',
      formations: const [
        ('CAP Maçonnerie', 'BTP', NiveauFormation.bts, 2, ['3e'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_cfp_kaolack',
      nom: 'Centre de Formation Professionnelle de Kaolack',
      code: 'CFP-KAOLACK',
      region: 'Kaolack',
      commune: 'Kaolack',
      type: EtablissementType.public,
      site: 'https://formation.gouv.sn',
      image: AppImages.aucunePhoto,
      description:
          'Centre régional du Saloum : métiers du bâtiment, froid, mécanique '
          'deux-roues, habillement et restauration.',
      formations: const [
        ('CAP Froid et Climatisation', 'Industrie', NiveauFormation.bts, 2, ['3e'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_cfp_zig',
      nom: 'Centre de Formation Professionnelle de Ziguinchor',
      code: 'CFP-ZIG',
      region: 'Ziguinchor',
      commune: 'Ziguinchor',
      type: EtablissementType.public,
      site: 'https://formation.gouv.sn',
      image: AppImages.aucunePhoto,
      description:
          'Centre régional de la Casamance : bois, bâtiment, électricité, '
          'transformation des fruits et légumes, tourisme.',
      formations: const [
        ('CAP Menuiserie Bois', 'Artisanat', NiveauFormation.bts, 2, ['3e'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_cfp_louga',
      nom: 'Centre Régional de Formation Professionnelle de Louga',
      code: 'CFP-LOUGA',
      region: 'Louga',
      commune: 'Louga',
      type: EtablissementType.public,
      site: 'https://formation.gouv.sn',
      image: AppImages.aucunePhoto,
      description:
          'Centre régional : électricité bâtiment, énergie solaire, mécanique '
          'automobile, élevage et maraîchage.',
      formations: const [
        ('CAP Électricité Bâtiment', 'BTP', NiveauFormation.bts, 2, ['3e'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_cfp_tamba',
      nom: 'Centre de Formation Professionnelle de Tambacounda',
      code: 'CFP-TAMBA',
      region: 'Tambacounda',
      commune: 'Tambacounda',
      type: EtablissementType.public,
      site: 'https://formation.gouv.sn',
      image: AppImages.aucunePhoto,
      description:
          'Centre régional du Sénégal oriental : bâtiment, mécanique, agriculture et '
          'transformation des céréales.',
      formations: const [
        ('CAP Mécanique Générale', 'Industrie', NiveauFormation.bts, 2, ['3e'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_cfmthr_saly',
      nom: 'Centre de Formation aux Métiers du Tourisme, de l\'Hôtellerie et de la Restauration de Saly',
      code: 'CFMTHR-SALY',
      region: 'Thiès',
      commune: 'Saly Portudal',
      type: EtablissementType.public,
      site: 'https://formation.gouv.sn',
      image: AppImages.aucunePhoto,
      description:
          'Centre de la Petite Côte dédié à l\'hôtellerie-restauration : cuisine, '
          'service, réception, gestion hôtelière.',
      formations: const [
        ('BT Hôtellerie-Restauration', 'Tourisme', NiveauFormation.bts, 2, ['3e', 'L', 'G'], 10, 48),
      ],
    ),
    _u(
      id: 'univ_enfefs',
      nom: 'École Nationale de Formation en Économie Familiale et Sociale (ENFEFS)',
      code: 'ENFEFS',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://enfefs.com',
      image: AppImages.enfefsReal,
      description:
          'Forme les enseignants et animateurs en économie familiale et sociale : '
          'alimentation-nutrition, textile-habillement, développement communautaire.',
      formations: const [
        ('Licence Professionnelle Économie Familiale et Sociale', 'Éducation', NiveauFormation.licence, 3, ['L', 'S2', 'G'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_cfph_camberene',
      nom: 'Centre de Formation Professionnelle Horticole de Cambérène',
      code: 'CFPH-CAMBERENE',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://www.formation.cfph.sn',
      image: AppImages.aucunePhoto,
      description:
          'Centre spécialisé en horticulture, maraîchage, floriculture et '
          'aménagement paysager.',
      formations: const [
        ('CAP Horticulture', 'Agronomie', NiveauFormation.bts, 2, ['3e', 'D'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_csfp_num',
      nom: 'Centre Sectoriel de Formation aux Métiers du Numérique de Diamniadio',
      code: 'CSFP-NUM',
      region: 'Dakar',
      commune: 'Diamniadio',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Centre sectoriel dédié aux métiers du numérique : développement, data, '
          'cybersécurité, support et réseaux, en partenariat public-privé.',
      formations: const [
        ('Certificat Développeur Full-Stack', 'Informatique', NiveauFormation.bts, 1, null, 10, 60),
        ('Certificat Administrateur Systèmes et Réseaux', 'Informatique', NiveauFormation.bts, 1, null, 10, 40),
      ],
    ),
    _u(
      id: 'univ_cfp_kaffrine',
      nom: 'Centre de Formation Professionnelle de Kaffrine',
      code: 'CFP-KAFFRINE',
      region: 'Kaffrine',
      commune: 'Kaffrine',
      type: EtablissementType.public,
      site: 'https://formation.gouv.sn',
      image: AppImages.aucunePhoto,
      description:
          'Centre régional : bâtiment, énergie solaire, mécanique agricole, '
          'transformation des produits locaux.',
      formations: const [
        ('CAP Maintenance des Équipements Agricoles', 'Industrie', NiveauFormation.bts, 2, ['3e', 'D'], 10, 30),
      ],
    ),

    // =======================================================================
    // 6. ÉTABLISSEMENTS COMPLÉMENTAIRES — couverture nationale (recherche web
    //    vérifiée établissement par établissement : site officiel testé,
    //    photo réelle uniquement quand trouvée et confirmée chargeable,
    //    sinon AppImages.aucunePhoto plutôt qu'un repli générique trompeur).
    // =======================================================================
    _u(
      id: 'univ_enfm',
      nom: 'École Nationale de Formation Maritime',
      code: 'ENFM',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://enfm.sn',
      image: 'https://enfm.sn/assets/images/enfm/ecole.jpg',
      description:
          'École publique historique (1964) formant le personnel navigant marchand et de pêche.',
      formations: const [
        ('BTS Navigation et Sécurité Maritime', 'Maritime', NiveauFormation.bts, 2, ['S1', 'S2', 'T'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_cnftpa',
      nom: 'Centre National de Formation des Techniciens des Pêches et de l\'Aquaculture',
      code: 'CNFTPA',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://www.cnftpa.sn',
      image: AppImages.aucunePhoto,
      description:
          'Centre public (décret 2009) de formation aux métiers de la pêche et de l\'aquaculture.',
      formations: const [
        ('BTS Techniques des Pêches et Aquaculture', 'Agroalimentaire', NiveauFormation.bts, 2, ['S1', 'S2', 'D'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_dit',
      nom: 'Dakar Institute of Technology (DIT)',
      code: 'DIT',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://dit.sn',
      image: AppImages.ditReal,
      description:
          'Première école d\'ingénieurs d\'Afrique de l\'Ouest spécialisée en IA et Big Data (2019).',
      formations: const [
        ('Licence Big Data et Intelligence Artificielle', 'Informatique', NiveauFormation.licence, 3, ['S1', 'S2', 'S3'], 12, 60),
      ],
    ),
    _u(
      id: 'univ_estm',
      nom: 'École Supérieure de Technologie et de Management (ESTM)',
      code: 'ESTM',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://estm.sn',
      image: AppImages.aucunePhoto,
      description:
          'École privée de technologie et management fondée en 2001, plus de 10 000 diplômés.',
      formations: const [
        ('Licence Télécommunications et Réseaux', 'Télécommunications', NiveauFormation.licence, 3, ['S1', 'S2', 'T'], 10, 80),
      ],
    ),
    _u(
      id: 'univ_iist',
      nom: 'Institut International des Sciences et Technologies (IIST)',
      code: 'IIST',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Institut privé (fin années 1990) accrédité CAMES, du BTS au Master.',
      formations: const [
        ('BTS Informatique de Gestion', 'Informatique', NiveauFormation.bts, 2, ['S2', 'G', 'L'], 10, 60),
      ],
    ),
    _u(
      id: 'univ_ejicom',
      nom: 'École Supérieure de Journalisme, des Métiers de l\'Internet et de la Communication (E-JICOM)',
      code: 'E-JICOM',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://ejicom.com',
      image: AppImages.ejicomReal,
      description:
          'Référence panafricaine en formation journalisme/communication/numérique depuis 2011.',
      formations: const [
        ('Licence Journalisme et Métiers du Numérique', 'Communication', NiveauFormation.licence, 3, ['L', 'S2', 'ES'], 11, 60),
      ],
    ),
    _u(
      id: 'univ_cuad',
      nom: 'Collège Universitaire d\'Architecture de Dakar (CUAD)',
      code: 'CUAD',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://cuad.archi',
      image: AppImages.aucunePhoto,
      description: 'École privée d\'architecture créée en 2008.',
      formations: const [
        ('Licence Architecture', 'Architecture', NiveauFormation.licence, 3, ['S2', 'L', 'ES'], 11, 50),
      ],
    ),
    _u(
      id: 'univ_ismod',
      nom: 'Institut des Sciences et Métiers de la Mode (ISMOD)',
      code: 'ISMOD',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Institut privé agréé de stylisme, modélisme et accessoires de mode.',
      formations: const [
        ('BTS Stylisme et Modélisme', 'Mode', NiveauFormation.bts, 2, ['L', 'S2'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_enfht',
      nom: 'École Nationale de Formation Hôtelière et Touristique (ENFHT)',
      code: 'ENFHT',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.public,
      site: 'https://enfht.sn',
      image: AppImages.aucunePhoto,
      description: 'École publique historique (1959) de référence en hôtellerie-tourisme.',
      formations: const [
        ('BTS Gestion Hôtelière', 'Tourisme', NiveauFormation.bts, 2, ['L', 'S2', 'G'], 10, 60),
      ],
    ),
    _u(
      id: 'univ_ehsm',
      nom: 'École Hôtelière Sainte-Marthe de Dakar',
      code: 'EHSM',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'École privée agréée (1999) en hôtellerie-restauration.',
      formations: const [
        ('BTS Cuisine et Arts Culinaires', 'Tourisme', NiveauFormation.bts, 2, ['L', 'S2'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_marmitons',
      nom: 'Institut Supérieur Les Marmitons',
      code: 'MARMITONS',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://ecolelesmarmitons.com',
      image: AppImages.marmitonsReal,
      description:
          'Institut privé de référence en gastronomie, hôtellerie et tourisme depuis 2006.',
      formations: const [
        ('BTS Cuisine et Pâtisserie', 'Tourisme', NiveauFormation.bts, 2, ['L', 'S2'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_iss',
      nom: 'Institut Santé Services — Université Docteur Daouda Sow (ISS)',
      code: 'ISS',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://www.issante.sn',
      image: AppImages.issReal,
      description:
          'Établissement privé de santé fondé en 1987, 3 campus (Dakar, Kaolack, Ziguinchor).',
      formations: const [
        ('Licence Sciences Infirmières', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 11, 80),
      ],
    ),
    _u(
      id: 'univ_iasm',
      nom: 'Institut Africain de Santé Moderne (IASM)',
      code: 'IASM',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://iasmsante.com',
      image: AppImages.aucunePhoto,
      description: 'Institut privé de santé agréé ANAQ-Sup (2014/2016).',
      formations: const [
        ('Licence Sage-Femme', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 11, 50),
      ],
    ),
    _u(
      id: 'univ_odc_ecsa',
      nom: 'Orange Digital Center Sénégal / École du Code Sonatel Academy',
      code: 'ODC-ECSA',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://orangedigitalcenter.sn',
      image: AppImages.odcReal,
      description:
          'Centre de formation numérique gratuite et d\'accompagnement de start-up, 1ère école de code gratuite d\'Afrique de l\'Ouest.',
      formations: const [
        ('Certificat Développeur Web/Mobile', 'Informatique', NiveauFormation.bts, 1, null, 10, 100),
      ],
    ),
    _u(
      id: 'univ_simplon',
      nom: 'Simplon Sénégal',
      code: 'SIMPLON',
      region: 'Dakar',
      commune: 'Dakar',
      type: EtablissementType.prive,
      site: 'https://simplon.sn',
      image: AppImages.aucunePhoto,
      description:
          'École inclusive et gratuite des métiers du numérique, implantée en 2017 (antennes Pikine, Ouakam, Bargny, Popenguine).',
      formations: const [
        ('Certificat Développeur Web/Mobile', 'Informatique', NiveauFormation.bts, 1, null, 10, 80),
      ],
    ),
    _u(
      id: 'univ_ltfxn',
      nom: 'Lycée Technique Professionnel Monseigneur François Xavier Ndione',
      code: 'LTFXN',
      region: 'Thiès',
      commune: 'Thiès',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Lycée technique public de référence (2006, coopération Sénégal-Luxembourg), 2500 élèves.',
      formations: const [
        ('BT Mécanique Générale', 'Industrie', NiveauFormation.bts, 3, ['3e'], 10, 60),
      ],
    ),
    _u(
      id: 'univ_isem_mbour',
      nom: 'Institut Supérieur d\'Études Paramédicales (ISEM)',
      code: 'ISEM',
      region: 'Thiès',
      commune: 'Mbour',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Institut privé paramédical fondé en 2007.',
      formations: const [
        ('Diplôme Infirmier d\'État', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_esup_sante',
      nom: 'ESUP Santé — École Supérieure de Formation Professionnelle en Santé',
      code: 'ESUP-SANTE',
      region: 'Saint-Louis',
      commune: 'Saint-Louis',
      type: EtablissementType.prive,
      site: 'https://esupsante.com',
      image:
          'https://esupsante.com/_astro/facade-campus.D5mDGPaW_Z1sgD6t.avif',
      description:
          'Institut privé de santé, plus de 15 ans d\'existence à Saint-Louis, accrédité ANAQ-Sup.',
      formations: const [
        ('Licence Sciences Infirmières', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 11, 50),
      ],
    ),
    _u(
      id: 'univ_crfp_stlouis',
      nom: 'Centre Régional de Formation Professionnelle de Saint-Louis',
      code: 'CRFP-STLOUIS',
      region: 'Saint-Louis',
      commune: 'Saint-Louis',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Centre public de formation professionnelle (1964), sous tutelle de l\'ONFP.',
      formations: const [
        ('CAP Froid et Climatisation', 'Industrie', NiveauFormation.bts, 2, ['3e'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_ussein_fatick',
      nom: 'USSEIN — Campus de Fatick',
      code: 'USSEIN-FATICK',
      region: 'Fatick',
      commune: 'Fatick',
      type: EtablissementType.public,
      site: 'https://www.ussein.sn',
      image: AppImages.aucunePhoto,
      description:
          'Campus pédagogique de l\'USSEIN, réceptionné en 2026, environ 400 étudiants.',
      formations: const [
        ('Licence Ressources Halieutiques', 'Agronomie', NiveauFormation.licence, 3, ['S1', 'S2', 'D'], 10, 50),
      ],
    ),
    _u(
      id: 'univ_ussein_kaffrine',
      nom: 'USSEIN — Campus de Kaffrine',
      code: 'USSEIN-KAFFRINE',
      region: 'Kaffrine',
      commune: 'Kaffrine',
      type: EtablissementType.public,
      site: 'https://www.ussein.sn',
      image: AppImages.aucunePhoto,
      description: 'Campus pédagogique de l\'USSEIN, nouveaux bâtiments réceptionnés en 2026.',
      formations: const [
        ('Licence Sciences Agronomiques', 'Agronomie', NiveauFormation.licence, 3, ['S1', 'S2', 'D'], 10, 50),
      ],
    ),
    _u(
      id: 'univ_ltp_fatick',
      nom: 'Lycée Technique et Professionnel de Fatick',
      code: 'LTP-FATICK',
      region: 'Fatick',
      commune: 'Fatick',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Lycée technique régional formant au bac technique et à l\'insertion professionnelle.',
      formations: const [
        ('BT Installation Panneaux Solaires Photovoltaïques', 'Énergie', NiveauFormation.bts, 3, ['3e'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_cfp_foundiougne',
      nom: 'Centre de Formation Professionnelle de Foundiougne',
      code: 'CFP-FOUNDIOUGNE',
      region: 'Fatick',
      commune: 'Foundiougne',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Centre public créé en 1982.',
      formations: const [
        ('CAP Aviculture', 'Agronomie', NiveauFormation.bts, 2, ['3e', 'D'], 10, 25),
      ],
    ),
    _u(
      id: 'univ_ltcean',
      nom: 'Lycée Technique Commercial Elhadji Abdoulaye Niass de Kaolack',
      code: 'LTCEAN',
      region: 'Kaolack',
      commune: 'Kaolack',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Lycée technique et commercial de référence.',
      formations: const [
        ('BT Techniques Quantitatives de Gestion', 'Commerce', NiveauFormation.bts, 3, ['3e'], 10, 60),
      ],
    ),
    _u(
      id: 'univ_isi_kaolack',
      nom: 'Institut Supérieur d\'Informatique — Campus Kaolack',
      code: 'ISI-KAOLACK',
      region: 'Kaolack',
      commune: 'Kaolack',
      type: EtablissementType.prive,
      site: 'https://isikaolack.com',
      image: AppImages.aucunePhoto,
      description: 'Établissement privé en informatique, management et réseaux.',
      formations: const [
        ('Licence Génie Logiciel', 'Informatique', NiveauFormation.licence, 3, ['S1', 'S2', 'S3'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_ism_kaolack',
      nom: 'ISM — Campus Kaolack',
      code: 'ISM-KAOLACK',
      region: 'Kaolack',
      commune: 'Kaolack',
      type: EtablissementType.prive,
      site: 'https://www.groupeism.sn',
      image: AppImages.aucunePhoto,
      description: 'Antenne régionale du Groupe ISM.',
      formations: const [
        ('Licence Management', 'Management', NiveauFormation.licence, 3, ['S2', 'G', 'L'], 10, 60),
      ],
    ),
    _u(
      id: 'univ_iss_kaolack',
      nom: 'Institut Santé Services — Campus Kaolack',
      code: 'ISS-KAOLACK',
      region: 'Kaolack',
      commune: 'Kaolack',
      type: EtablissementType.prive,
      site: 'https://www.issante.sn',
      image: AppImages.aucunePhoto,
      description: 'Institut de formation santé depuis 1987, campus HLM Bongres.',
      formations: const [
        ('Diplôme Infirmier d\'État', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_crfs_kaolack',
      nom: 'Centre Régional de Formation en Santé de Kaolack',
      code: 'CRFS-KAOLACK',
      region: 'Kaolack',
      commune: 'Kaolack',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Centre public de formation paramédicale, concours national annuel.',
      formations: const [
        ('Diplôme Infirmier d\'État', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_ism_zig',
      nom: 'ISM — Campus Ziguinchor',
      code: 'ISM-ZIG',
      region: 'Ziguinchor',
      commune: 'Ziguinchor',
      type: EtablissementType.prive,
      site: 'https://www.ismcasamance.sn',
      image: AppImages.aucunePhoto,
      description: 'Campus ISM ouvert en 2005/2006, plus de 3500 apprenants formés depuis.',
      formations: const [
        ('Licence Management', 'Management', NiveauFormation.licence, 3, ['S2', 'G', 'L'], 10, 60),
      ],
    ),
    _u(
      id: 'univ_iss_zig',
      nom: 'Institut Santé Services — Campus Ziguinchor',
      code: 'ISS-ZIG',
      region: 'Ziguinchor',
      commune: 'Ziguinchor',
      type: EtablissementType.prive,
      site: 'https://univ.issante.org/campus-de-ziguinchor',
      image: AppImages.issZigReal,
      description: 'Campus santé, quartier Boucotte Sud.',
      formations: const [
        ('Diplôme Infirmier d\'État', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_cnftefcpn',
      nom: 'Centre National de Formation des Techniciens des Eaux, Forêts, Chasses et des Parcs Nationaux',
      code: 'CNFTEFCPN',
      region: 'Ziguinchor',
      commune: 'Djibélor',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Centre national créé en 1963, dispose d\'une forêt d\'application.',
      formations: const [
        ('BTS Eaux et Forêts', 'Environnement', NiveauFormation.bts, 2, ['S1', 'S2', 'D'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_crfs_zig',
      nom: 'Centre Régional de Formation en Santé de Ziguinchor',
      code: 'CRFS-ZIG',
      region: 'Ziguinchor',
      commune: 'Ziguinchor',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Centre public de formation paramédicale régionale.',
      formations: const [
        ('Diplôme Infirmier d\'État', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_ism_kolda',
      nom: 'ISM — Campus Kolda',
      code: 'ISM-KOLDA',
      region: 'Kolda',
      commune: 'Kolda',
      type: EtablissementType.prive,
      site: 'https://www.ismcasamance.sn',
      image: AppImages.aucunePhoto,
      description: 'Extension casamançaise du Groupe ISM ouverte en 2013.',
      formations: const [
        ('Licence Management', 'Management', NiveauFormation.licence, 3, ['S2', 'G', 'L'], 10, 50),
      ],
    ),
    _u(
      id: 'univ_letfp_kolda',
      nom: 'Lycée d\'Enseignement Technique et de Formation Professionnelle de Kolda',
      code: 'LETFP-KOLDA',
      region: 'Kolda',
      commune: 'Kolda',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Abrite le plus grand centre STEG du Sénégal pour le bac technique.',
      formations: const [
        ('BT Électrotechnique', 'Industrie', NiveauFormation.bts, 3, ['3e'], 10, 50),
      ],
    ),
    _u(
      id: 'univ_cfp_kolda',
      nom: 'Centre de Formation Professionnelle de Kolda',
      code: 'CFP-KOLDA',
      region: 'Kolda',
      commune: 'Kolda',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Centre de référence, partenaire du projet Pacifa (conduite/entretien engins agricoles).',
      formations: const [
        ('CAP Conduite et Maintenance des Engins Agricoles', 'Industrie', NiveauFormation.bts, 2, ['3e', 'D'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_crfs_kolda',
      nom: 'Centre Régional de Formation en Santé de Kolda',
      code: 'CRFS-KOLDA',
      region: 'Kolda',
      commune: 'Kolda',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Centre public de formation paramédicale régionale.',
      formations: const [
        ('Diplôme Infirmier d\'État', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_ya_salam',
      nom: 'Institut de Formation en Santé Ya Salam',
      code: 'YA-SALAM',
      region: 'Kolda',
      commune: 'Kolda',
      type: EtablissementType.prive,
      site: 'https://institutsanteyasalamkolda.com',
      image: AppImages.aucunePhoto,
      description: 'Institut privé de formation paramédicale de courte durée.',
      formations: const [
        ('Certificat Aide-Soignant', 'Santé', NiveauFormation.bts, 1, null, 10, 30),
      ],
    ),
    _u(
      id: 'univ_ltimk',
      nom: 'Lycée Technique Industriel et Minier Mamba Guirassy de Kédougou',
      code: 'LTIMK',
      region: 'Kédougou',
      commune: 'Kédougou',
      type: EtablissementType.public,
      site: 'https://www.ltimk.com',
      image: AppImages.ltimkReal,
      description:
          'Lycée créé en 1998, environ 500 élèves, partenariats avec Sabodala Gold Operations et PMC.',
      formations: const [
        ('BT Formation Minière', 'Industrie', NiveauFormation.bts, 3, ['3e'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_cfp_kedougou',
      nom: 'Centre de Formation Professionnelle de Kédougou',
      code: 'CFP-KEDOUGOU',
      region: 'Kédougou',
      commune: 'Kédougou',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Centre régional public de formation professionnelle.',
      formations: const [
        ('CAP Métiers Techniques', 'Industrie', NiveauFormation.bts, 2, ['3e'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_isfomm',
      nom: 'Institut Sénégalais de Formation aux Métiers de la Mine (ISFOMM)',
      code: 'ISFOMM',
      region: 'Kédougou',
      commune: 'Kédougou',
      type: EtablissementType.prive,
      site: 'https://isfomm.com',
      image: AppImages.isfommReal,
      description: 'Institut agréé (MFPT/ONFP) formant aux métiers miniers et para-miniers.',
      formations: const [
        ('BTS Métiers de la Mine', 'Industrie', NiveauFormation.bts, 2, ['S1', 'S2', 'T'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_cfp_sedhiou',
      nom: 'Centre de Formation Professionnelle de Sédhiou',
      code: 'CFP-SEDHIOU',
      region: 'Sédhiou',
      commune: 'Sédhiou',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Centre public fondé en 1974, seul établissement de formation professionnelle recensé pour Sédhiou.',
      formations: const [
        ('CAP Électricité et Énergie Solaire', 'Énergie', NiveauFormation.bts, 2, ['3e'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_cefam_louga',
      nom: 'Centre de Formation et d\'Appui aux Métiers de Louga',
      code: 'CEFAM-LOUGA',
      region: 'Louga',
      commune: 'Louga',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Centre public créé en 2010, distinct du Centre Régional de Formation Professionnelle de Louga.',
      formations: const [
        ('CAP Graphisme et BTP', 'BTP', NiveauFormation.bts, 2, ['3e'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_cfp_matam',
      nom: 'Centre de Formation Professionnelle de Matam',
      code: 'CFP-MATAM',
      region: 'Matam',
      commune: 'Matam',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Centre public régional de formation professionnelle.',
      formations: const [
        ('CAP Métiers Techniques', 'Industrie', NiveauFormation.bts, 2, ['3e'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_cfpac_matam',
      nom: 'Centre de Formation Professionnelle Agnam Civol',
      code: 'CFPAC-MATAM',
      region: 'Matam',
      commune: 'Agnam Civol',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Centre public créé en 2014, vocation agricole.',
      formations: const [
        ('CAP Horticulture et Maraîchage', 'Agronomie', NiveauFormation.bts, 2, ['3e', 'D'], 10, 25),
      ],
    ),
    _u(
      id: 'univ_letfp_tamba',
      nom: 'Lycée d\'Enseignement Technique et de Formation Professionnelle de Tambacounda',
      code: 'LETFP-TAMBA',
      region: 'Tambacounda',
      commune: 'Tambacounda',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Centre d\'examen régional du bac technique (génie civil, plomberie).',
      formations: const [
        ('BT Génie Civil', 'BTP', NiveauFormation.bts, 3, ['3e'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_iitem_tamba',
      nom: 'Institut International des Technologies et du Management de Tambacounda (IITEM)',
      code: 'IITEM-TAMBA',
      region: 'Tambacounda',
      commune: 'Tambacounda',
      type: EtablissementType.prive,
      site: 'https://iitem-tamba.com',
      image: AppImages.aucunePhoto,
      description: 'Institut privé, formations courtes et diplômantes.',
      formations: const [
        ('BTS Comptabilité-Gestion', 'Finance', NiveauFormation.bts, 2, ['G', 'S2'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_iseg_tamba',
      nom: 'ISEG — Campus Tambacounda',
      code: 'ISEG-TAMBA',
      region: 'Tambacounda',
      commune: 'Tambacounda',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Antenne régionale du réseau ISEG.',
      formations: const [
        ('BTS Entrepreneuriat et Gestion', 'Management', NiveauFormation.bts, 2, ['G', 'S2'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_crfs_tamba',
      nom: 'Centre Régional de Formation en Santé de Tambacounda',
      code: 'CRFS-TAMBA',
      region: 'Tambacounda',
      commune: 'Tambacounda',
      type: EtablissementType.public,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Centre public de formation paramédicale régionale.',
      formations: const [
        ('Diplôme Infirmier d\'État', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 10, 30),
      ],
    ),
    _u(
      id: 'univ_ucak',
      nom: 'Université Cheikh Ahmadoul Khadim (UCAK)',
      code: 'UCAK',
      region: 'Diourbel',
      commune: 'Touba',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description:
          'Université privée fondée en 2023, environ 1100 étudiants, premiers diplômés en 2026.',
      formations: const [
        ('Licence Sciences Islamiques', 'Sciences religieuses', NiveauFormation.licence, 3, ['L'], 10, 100),
      ],
    ),
    _u(
      id: 'univ_isest',
      nom: 'Institut Supérieur d\'Excellence en Santé de Touba Al Mountakha (ISEST)',
      code: 'ISEST',
      region: 'Diourbel',
      commune: 'Touba',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Institut privé de formation en santé axé sur la pratique clinique.',
      formations: const [
        ('Licence Sciences Infirmières', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_if3s',
      nom: 'Institut de Formation en Santé Serigne Saliou Mbacké (IF3S)',
      code: 'IF3S',
      region: 'Diourbel',
      commune: 'Touba',
      type: EtablissementType.prive,
      site: null,
      image: AppImages.aucunePhoto,
      description: 'Institut privé de formation paramédicale.',
      formations: const [
        ('Diplôme Infirmier d\'État', 'Santé', NiveauFormation.licence, 3, ['S1', 'S2'], 10, 40),
      ],
    ),
    _u(
      id: 'univ_cefas_touba',
      nom: 'CEFAS — Campus Touba-Mbacké',
      code: 'CEFAS-TOUBA',
      region: 'Diourbel',
      commune: 'Touba-Mbacké',
      type: EtablissementType.prive,
      site: 'https://cefas-senegal.com',
      image: AppImages.aucunePhoto,
      description: 'Antenne régionale de CEFAS (5 campus Dakar + 3 régionaux).',
      formations: const [
        ('BTS Management', 'Management', NiveauFormation.bts, 2, ['G', 'S2'], 10, 40),
      ],
    ),
  ];

  /// Construit un [UniversiteModel] à partir de champs concis + une liste de
  /// [_Filiere] — évite ~30 lignes de boilerplate par établissement.
  static UniversiteModel _u({
    required String id,
    required String nom,
    required String code,
    required String region,
    required String commune,
    required EtablissementType type,
    // Null = aucun site officiel connu/fonctionnel (voir rapport catalogue) —
    // à afficher clairement comme tel plutôt que de laisser un lien mort.
    String? site,
    required String image,
    required String description,
    String? email,
    String? telephone,
    List<_Filiere> formations = const [],
  }) {
    return UniversiteModel(
      id: id,
      nom: nom,
      codeUnique: code,
      region: region,
      commune: commune,
      type: type,
      siteWebOfficiel: site,
      imageUrl: image,
      description: description,
      contact: (email == null && telephone == null)
          ? null
          : ContactModel(email: email, telephone: telephone),
      formations: [
        for (final (i, f) in formations.indexed)
          FormationModel(
            id: '${id}_f${i + 1}',
            universiteId: id,
            intitule: f.$1,
            domaine: f.$2,
            niveau: f.$3,
            dureeAnnees: f.$4,
            seriesAcceptees: f.$5,
            moyenneMinimale: f.$6,
            capacite: f.$7,
          ),
      ],
      bourses: const [],
      logements: const [],
      fraisScolarite: const [],
    );
  }

  /// Extrait à plat toutes les formations de toutes les universités —
  /// utilisé par le datasource mocké de recherche de formations.
  static List<FormationModel> get toutesLesFormations => universites
      .expand((u) => u.formations.map((f) => f.copyWith(universiteNom: u.nom)))
      .toList();

  static UniversiteModel universiteDe(String universiteId) =>
      universites.firstWhere((u) => u.id == universiteId);
}
