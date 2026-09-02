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
      imageUrl: AppImages.bibliotheque,
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
      site: 'https://univ-thies.sn',
      image: AppImages.campusGeneric1,
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
      site: 'https://univ-zig.sn',
      image: AppImages.campusGeneric2,
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
      image: AppImages.campusAerial,
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
      image: AppImages.campusGeneric1,
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
      site: 'https://uam.edu.sn',
      image: AppImages.etudiantsDakar,
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
      image: AppImages.digitalLearning,
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
      image: AppImages.bureau2,
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
      site: 'https://ucad.sn',
      image: AppImages.isepThiesAtelier,
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
      image: AppImages.bureau1,
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
      image: AppImages.amphi,
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
      image: AppImages.bibliotheque,
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
      site: 'https://endss.sn',
      image: AppImages.etudiantEtude,
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
      site: 'https://cesti.sn',
      image: AppImages.etudiantsGroupe,
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
      image: AppImages.isepThiesAtelier,
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
      site: 'https://uadb.edu.sn',
      image: AppImages.campusGeneric1,
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
      site: 'https://isepthies.sn',
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
      site: 'https://isep.sn',
      image: AppImages.campusGeneric1,
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
      site: 'https://isep.sn',
      image: AppImages.campusGeneric2,
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
      image: AppImages.campusGeneric2,
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
      image: AppImages.isepThiesAtelier,
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
      site: 'https://ucao-uud.sn',
      image: AppImages.campusGeneric1,
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
      site: 'https://uahb.sn',
      image: AppImages.bureau2,
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
      site: 'https://udb.sn',
      image: AppImages.bureau1,
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
      site: 'https://unis.sn',
      image: AppImages.bibliotheque,
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
      image: AppImages.campusGeneric2,
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
      image: AppImages.bureau1,
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
      site: 'https://iam.sn',
      image: AppImages.bureau2,
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
      image: AppImages.entreprise1,
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
      image: AppImages.entreprise2,
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
      site: 'https://iseg.sn',
      image: AppImages.bureau1,
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
      image: AppImages.digitalLearning,
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
      site: 'https://hecdakar.sn',
      image: AppImages.entreprise1,
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
      site: 'https://isi.sn',
      image: AppImages.digitalLearning,
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
      site: 'https://ipg.sn',
      image: AppImages.bureau2,
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
      image: AppImages.entreprise2,
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
      site: 'https://dbs.sn',
      image: AppImages.entreprise1,
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
      site: 'https://ceds.sn',
      image: AppImages.bibliotheque,
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
      site: 'https://pigier.sn',
      image: AppImages.bureau1,
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
      site: 'https://uea.sn',
      image: AppImages.bibliotheque,
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
      image: AppImages.isepThiesAtelier,
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
      site: 'https://education.sn',
      image: AppImages.isepThiesAtelier,
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
      site: 'https://education.sn',
      image: AppImages.bureau1,
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
      site: 'https://education.sn',
      image: AppImages.campusGeneric2,
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
      site: 'https://cedt-g15.sn',
      image: AppImages.isepThiesAtelier,
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
      site: 'https://cnqp.sn',
      image: AppImages.isepThiesAtelier,
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
      site: 'https://formationprofessionnelle.gouv.sn',
      image: AppImages.campusGeneric1,
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
      site: 'https://formationprofessionnelle.gouv.sn',
      image: AppImages.campusGeneric1,
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
      site: 'https://formationprofessionnelle.gouv.sn',
      image: AppImages.campusGeneric2,
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
      site: 'https://formationprofessionnelle.gouv.sn',
      image: AppImages.isepThiesAtelier,
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
      site: 'https://formationprofessionnelle.gouv.sn',
      image: AppImages.campusGeneric1,
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
      site: 'https://formationprofessionnelle.gouv.sn',
      image: AppImages.entreprise1,
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
      site: 'https://education.sn',
      image: AppImages.etudiantEtude,
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
      site: 'https://cfph.sn',
      image: AppImages.campusGeneric1,
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
      site: 'https://senum.sn',
      image: AppImages.digitalLearning,
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
      site: 'https://formationprofessionnelle.gouv.sn',
      image: AppImages.campusGeneric2,
      description:
          'Centre régional : bâtiment, énergie solaire, mécanique agricole, '
          'transformation des produits locaux.',
      formations: const [
        ('CAP Maintenance des Équipements Agricoles', 'Industrie', NiveauFormation.bts, 2, ['3e', 'D'], 10, 30),
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
    required String site,
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
