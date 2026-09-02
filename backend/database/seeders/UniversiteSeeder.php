<?php

namespace Database\Seeders;

use App\Models\Universite;
use Illuminate\Database\Seeder;

/**
 * Catalogue des établissements d'enseignement supérieur et de formation
 * professionnelle du Sénégal (Prompt 5 — « catalogue réellement exhaustif »).
 *
 * Couverture : les 8 universités publiques, les grandes écoles publiques
 * rattachées, le réseau des 6 ISEP, une liste substantielle d'universités et
 * écoles privées reconnues par l'État, et un échantillon représentatif de
 * centres de formation professionnelle et technique (CFPT / lycées techniques /
 * centres régionaux) couvrant l'ensemble des régions.
 *
 * Données publiques de présentation générale (régions, communes, sites
 * officiels, filières phares) — à faire valider/enrichir par la veille IA
 * (Django) et les admins d'établissement en conditions réelles (CDC §7.4).
 * Les images (`image_url`) suivent la règle du Prompt 5 §3 : photo réelle du
 * bâtiment quand elle existe (Wikimedia Commons), sinon repli générique à
 * contexte africain documenté dans CREDITS_IMAGES.md.
 */
class UniversiteSeeder extends Seeder
{
    /** Photos réelles de bâtiments (Wikimedia Commons, CC BY-SA). */
    private const WM = 'https://upload.wikimedia.org/wikipedia/commons/';

    private const IMG_UCAD = self::WM.'thumb/5/5c/UCAD-Dakar.jpg/1280px-UCAD-Dakar.jpg';
    private const IMG_UGB = self::WM.'thumb/1/14/LaTourUGBVueSudOuest.jpg/1280px-LaTourUGBVueSudOuest.jpg';
    private const IMG_ESP = self::WM.'thumb/8/8d/ESPDakar.jpg/1280px-ESPDakar.jpg';
    private const IMG_CESAG = self::WM.'e/ea/CESAG.jpg';
    private const IMG_EPT = self::WM.'7/74/Case_des_polytechniciens_de_l%27%C3%A9cole_polytechnique_de_Thies.jpg';
    private const IMG_ENSA = self::WM.'4/44/Ecole_Nationale_Sup%C3%A9rieure_d%27Agriculture_%28ENSA%29_de_Thi%C3%A8s.jpg';

    /** Replis génériques à contexte africain (licence Unsplash). */
    private const U = 'https://images.unsplash.com/';
    private const IMG_ETUDIANTS = self::U.'photo-1655720348590-c739c860beed?auto=format&fit=crop&w=1200&q=70';
    private const IMG_CAMPUS_1 = self::U.'photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1200&q=70';
    private const IMG_CAMPUS_2 = self::U.'photo-1562774053-701939374585?auto=format&fit=crop&w=1200&q=70';
    private const IMG_AMPHI = self::U.'photo-1524178232363-1fb2b075b655?auto=format&fit=crop&w=1200&q=70';
    private const IMG_BIBLIO = self::U.'photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=1200&q=70';
    private const IMG_DIGITAL = self::U.'photo-1501250987900-211872d97eaa?auto=format&fit=crop&w=1200&q=70';
    private const IMG_BUREAU = self::U.'photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=1200&q=70';
    private const IMG_ENTREPRISE = self::U.'photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=70';
    private const IMG_ATELIER = self::U.'photo-1581092160562-40aa08e78837?auto=format&fit=crop&w=1200&q=70';

    public function run(): void
    {
        foreach ($this->catalogue() as $data) {
            $universite = Universite::create([
                'nom' => $data['nom'],
                'code_unique' => $data['code_unique'],
                'region' => $data['region'],
                'commune' => $data['commune'],
                'type' => $data['type'],
                'site_web_officiel' => $data['site'] ?? null,
                'description' => $data['description'],
                'image_url' => $data['image'] ?? null,
                'statut_actif' => true,
            ]);

            $formationsCreees = [];
            foreach ($data['formations'] ?? [] as $formation) {
                $formationsCreees[] = $universite->formations()->create($formation);
            }

            foreach ($data['bourses'] ?? [] as $bourse) {
                $universite->bourses()->create($bourse + ['devise' => 'XOF', 'source' => 'seeder_demo', 'date_maj' => now()]);
            }

            foreach ($data['logements'] ?? [] as $logement) {
                $universite->logements()->create($logement + ['devise' => 'XOF', 'source' => 'seeder_demo', 'date_maj' => now()]);
            }

            if (! empty($data['frais']) && ! empty($formationsCreees)) {
                $universite->fraisScolarite()->create($data['frais'] + [
                    'formation_id' => $formationsCreees[0]->id,
                    'devise' => 'XOF',
                    'source' => 'seeder_demo',
                    'date_maj' => now(),
                ]);
            }
        }
    }

    /** Raccourci de construction d'une formation. */
    private function f(string $intitule, string $domaine, string $niveau, int $duree, ?array $series = null, float $moyenne = 10, int $capacite = 60): array
    {
        return [
            'intitule' => $intitule,
            'domaine' => $domaine,
            'niveau' => $niveau,
            'duree_annees' => $duree,
            'series_acceptees' => $series,
            'moyenne_minimale' => $moyenne,
            'capacite' => $capacite,
        ];
    }

    private function catalogue(): array
    {
        return [
            // =====================================================================
            // 1. UNIVERSITÉS PUBLIQUES (8)
            // =====================================================================
            [
                'nom' => 'Université Cheikh Anta Diop de Dakar', 'code_unique' => 'UCAD',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.ucad.sn', 'image' => self::IMG_UCAD,
                'description' => 'Plus grande université publique du Sénégal, fondée en 1957 : facultés de médecine, droit, sciences, lettres et grandes écoles rattachées.',
                'formations' => [
                    $this->f('Licence Informatique', 'Informatique', 'licence', 3, ['S1', 'S2', 'S3'], 12, 200),
                    $this->f('Licence Mathématiques-Physique', 'Sciences', 'licence', 3, ['S1', 'S2'], 13, 150),
                    $this->f('Master Data Science', 'Informatique', 'master', 2, null, 12, 40),
                ],
                'bourses' => [
                    ['nom' => 'Bourse nationale d\'excellence', 'organisme' => 'MESRI', 'montant' => 25000, 'conditions' => 'Moyenne générale ≥ 14/20', 'date_limite' => '2026-10-31'],
                ],
                'logements' => [
                    ['nom' => 'Résidence universitaire UCAD I', 'type' => 'residence', 'capacite' => 1200, 'tarif_mensuel' => 15000],
                ],
                'frais' => ['montant' => 5000, 'echeancier' => ['annuel'], 'moyens_paiement' => ['especes', 'orange_money', 'wave']],
            ],
            [
                'nom' => 'Université Gaston Berger de Saint-Louis', 'code_unique' => 'UGB',
                'region' => 'Saint-Louis', 'commune' => 'Saint-Louis', 'type' => 'public',
                'site' => 'https://www.ugb.sn', 'image' => self::IMG_UGB,
                'description' => 'Deuxième université publique du pays, organisée en UFR autonomes et réputée pour ses filières scientifiques et son campus résidentiel.',
                'formations' => [
                    $this->f('Licence Génie Informatique', 'Informatique', 'licence', 3, ['S1', 'S2', 'S3'], 13, 100),
                    $this->f('Licence Sciences Agronomiques', 'Agronomie', 'licence', 3, ['S1', 'S2', 'D'], 12, 80),
                ],
                'bourses' => [
                    ['nom' => 'Bourse régionale Saint-Louis', 'organisme' => 'Conseil régional', 'montant' => 15000, 'conditions' => 'Originaire de la région de Saint-Louis', 'date_limite' => '2026-09-30'],
                ],
                'logements' => [
                    ['nom' => 'Campus résidentiel UGB', 'type' => 'residence', 'capacite' => 4000, 'tarif_mensuel' => 12000],
                ],
                'frais' => ['montant' => 5000, 'echeancier' => ['annuel'], 'moyens_paiement' => ['especes', 'orange_money']],
            ],
            [
                'nom' => 'Université Iba Der Thiam de Thiès', 'code_unique' => 'UIDT',
                'region' => 'Thiès', 'commune' => 'Thiès', 'type' => 'public',
                'site' => 'https://www.univ-thies.sn', 'image' => self::IMG_CAMPUS_1,
                'description' => 'Université pluridisciplinaire de Thiès (santé, sciences et techniques, mines-géologie, agriculture), en forte croissance depuis 2007.',
                'formations' => [
                    $this->f('Licence Génie Civil', 'Ingénierie', 'licence', 3, ['S1', 'S2', 'T'], 11, 90),
                    $this->f('Licence Sciences Infirmières', 'Santé', 'licence', 3, ['S1', 'S2'], 12, 70),
                ],
            ],
            [
                'nom' => 'Université Assane Seck de Ziguinchor', 'code_unique' => 'UASZ',
                'region' => 'Ziguinchor', 'commune' => 'Ziguinchor', 'type' => 'public',
                'site' => 'https://www.univ-zig.sn', 'image' => self::IMG_CAMPUS_2,
                'description' => 'Université publique de la Casamance : lettres, sciences économiques, sciences et technologies, agroforesterie.',
                'formations' => [
                    $this->f('Licence Agroforesterie', 'Environnement', 'licence', 3, ['S1', 'S2', 'D'], 10, 60),
                    $this->f('Licence Lettres Modernes', 'Lettres', 'licence', 3, ['L', 'S1'], 10, 80),
                ],
            ],
            [
                'nom' => 'Université Alioune Diop de Bambey', 'code_unique' => 'UADB',
                'region' => 'Diourbel', 'commune' => 'Bambey', 'type' => 'public',
                'site' => 'https://www.uadb.edu.sn', 'image' => self::IMG_AMPHI,
                'description' => 'Université orientée agro-sylvo-pastoral, sciences de la santé et STEG, au cœur du bassin arachidier.',
                'formations' => [
                    $this->f('Licence Agroalimentaire', 'Agronomie', 'licence', 3, ['S1', 'S2', 'D'], 10, 70),
                    $this->f('Licence Sciences de la Santé Communautaire', 'Santé', 'licence', 3, ['S1', 'S2'], 11, 60),
                ],
            ],
            [
                'nom' => 'Université du Sine Saloum El Hadji Ibrahima Niasse', 'code_unique' => 'USSEIN',
                'region' => 'Kaolack', 'commune' => 'Kaolack', 'type' => 'public',
                'site' => 'https://www.ussein.sn', 'image' => self::IMG_CAMPUS_1,
                'description' => 'Université multi-sites (Kaolack, Fatick, Kaffrine) spécialisée dans l\'agriculture, l\'agroalimentaire, la santé et le développement territorial.',
                'formations' => [
                    $this->f('Licence Agronomie', 'Agronomie', 'licence', 3, ['S1', 'S2', 'D'], 10, 80),
                    $this->f('Licence Gestion des Entreprises Agricoles', 'Management', 'licence', 3, ['S2', 'G'], 10, 60),
                ],
            ],
            [
                'nom' => 'Université Amadou Mahtar Mbow de Diamniadio', 'code_unique' => 'UAM',
                'region' => 'Dakar', 'commune' => 'Diamniadio', 'type' => 'public',
                'site' => 'https://www.uam.edu.sn', 'image' => self::IMG_ETUDIANTS,
                'description' => 'Université de nouvelle génération au pôle de Diamniadio, centrée sur les sciences, l\'ingénierie, le numérique et la biotechnologie.',
                'formations' => [
                    $this->f('Licence Génie Logiciel et Systèmes d\'Information', 'Informatique', 'licence', 3, ['S1', 'S2', 'S3'], 12, 90),
                    $this->f('Licence Génie Électrique et Énergies Renouvelables', 'Ingénierie', 'licence', 3, ['S1', 'S2', 'T'], 11, 70),
                ],
            ],
            [
                'nom' => 'Université Numérique Cheikh Hamidou Kane (ex-UVS)', 'code_unique' => 'UN-CHK',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.unchk.sn', 'image' => self::IMG_DIGITAL,
                'description' => 'Université 100 % numérique, organisée en Espaces Numériques Ouverts (ENO) répartis dans toutes les régions — formations à distance.',
                'formations' => [
                    $this->f('Licence Développement Web et Mobile', 'Informatique', 'licence', 3, ['S1', 'S2', 'S3', 'L'], 10, 500),
                    $this->f('Licence Sciences de l\'Éducation', 'Éducation', 'licence', 3, null, 10, 400),
                ],
                'bourses' => [
                    ['nom' => 'Bourse numérique inclusion', 'organisme' => 'MESRI', 'montant' => 10000, 'conditions' => 'Zone rurale, connectivité limitée', 'date_limite' => '2026-11-15'],
                ],
                'frais' => ['montant' => 5000, 'echeancier' => ['annuel'], 'moyens_paiement' => ['orange_money', 'wave']],
            ],

            // =====================================================================
            // 2. GRANDES ÉCOLES PUBLIQUES
            // =====================================================================
            [
                'nom' => 'École Supérieure Polytechnique de Dakar (UCAD)', 'code_unique' => 'ESP',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.esp.sn', 'image' => self::IMG_ESP,
                'description' => 'Grande école d\'ingénieurs rattachée à l\'UCAD, très sélective : génie informatique, génie civil, génie électrique, gestion.',
                'formations' => [
                    $this->f('Diplôme d\'Ingénieur de Conception en Génie Informatique', 'Informatique', 'master', 5, ['S1', 'S2', 'S3'], 15, 45),
                    $this->f('DUT Génie Électrique', 'Ingénierie', 'bts', 2, ['S1', 'S2', 'T'], 12, 60),
                ],
            ],
            [
                'nom' => 'École Polytechnique de Thiès', 'code_unique' => 'EPT',
                'region' => 'Thiès', 'commune' => 'Thiès', 'type' => 'public',
                'site' => 'https://www.ept.sn', 'image' => self::IMG_EPT,
                'description' => 'École d\'ingénieurs publique de référence : génie civil, génie mécanique, génie électromécanique, génie chimique et biologie appliquée.',
                'formations' => [
                    $this->f('Diplôme d\'Ingénieur Génie Civil', 'Ingénierie', 'master', 5, ['S1', 'S2'], 15, 40),
                    $this->f('Diplôme d\'Ingénieur Génie Mécanique', 'Ingénierie', 'master', 5, ['S1', 'S2'], 15, 35),
                ],
            ],
            [
                'nom' => 'École Nationale Supérieure d\'Agriculture de Thiès', 'code_unique' => 'ENSA',
                'region' => 'Thiès', 'commune' => 'Thiès', 'type' => 'public',
                'site' => 'https://www.ensa.sn', 'image' => self::IMG_ENSA,
                'description' => 'École d\'ingénieurs agronomes rattachée à l\'Université de Thiès, spécialisée en productions végétales, animales et génie rural.',
                'formations' => [
                    $this->f('Diplôme d\'Ingénieur Agronome', 'Agronomie', 'master', 5, ['S1', 'S2', 'D'], 14, 50),
                ],
            ],
            [
                'nom' => 'École Nationale d\'Administration', 'code_unique' => 'ENA-SN',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.ena.sn', 'image' => self::IMG_BUREAU,
                'description' => 'École de formation des hauts fonctionnaires de l\'État : administration générale, diplomatie, douanes, impôts, magistrature.',
                'formations' => [
                    $this->f('Cycle A — Administration Générale', 'Administration publique', 'master', 2, null, 12, 80),
                ],
            ],
            [
                'nom' => 'Centre Africain d\'Études Supérieures en Gestion (CESAG)', 'code_unique' => 'CESAG',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.cesag.sn', 'image' => self::IMG_CESAG,
                'description' => 'École de management interétatique de la zone UEMOA/BCEAO : finance, banque, audit-contrôle, marketing, santé publique.',
                'formations' => [
                    $this->f('Master Banque et Finance', 'Finance', 'master', 2, null, 12, 60),
                    $this->f('Master Audit et Contrôle de Gestion', 'Management', 'master', 2, null, 12, 50),
                ],
            ],
            [
                'nom' => 'École Normale Supérieure d\'Enseignement Technique et Professionnel (UCAD)', 'code_unique' => 'ENSETP',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.ucad.sn', 'image' => self::IMG_ATELIER,
                'description' => 'Forme les professeurs de l\'enseignement technique et professionnel et les cadres de la formation : génie mécanique, économie familiale et sociale, biotechnologies.',
                'formations' => [
                    $this->f('Licence Professeur d\'Enseignement Technique', 'Éducation', 'licence', 3, ['S1', 'S2', 'T', 'G'], 11, 60),
                ],
            ],
            [
                'nom' => 'École Nationale de la Statistique et de l\'Analyse Économique Pierre Ndiaye', 'code_unique' => 'ENSAE',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.ensae.sn', 'image' => self::IMG_BUREAU,
                'description' => 'École de la statistique publique : ingénieurs statisticiens économistes, ingénieurs des travaux statistiques, data science.',
                'formations' => [
                    $this->f('Ingénieur Statisticien Économiste', 'Économie', 'master', 3, ['S1', 'S2'], 14, 30),
                ],
            ],
            [
                'nom' => 'Faculté des Sciences et Technologies de l\'Éducation et de la Formation (FASTEF, UCAD)', 'code_unique' => 'FASTEF',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.ucad.sn', 'image' => self::IMG_AMPHI,
                'description' => 'Ex-École Normale Supérieure : formation initiale et continue des professeurs de collège et de lycée et des inspecteurs de l\'éducation.',
                'formations' => [
                    $this->f('CAES — Certificat d\'Aptitude à l\'Enseignement Secondaire', 'Éducation', 'master', 1, null, 12, 200),
                ],
            ],
            [
                'nom' => 'École des Bibliothécaires, Archivistes et Documentalistes (EBAD, UCAD)', 'code_unique' => 'EBAD',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.ebad.ucad.sn', 'image' => self::IMG_BIBLIO,
                'description' => 'Référence régionale des métiers de l\'information documentaire : bibliothéconomie, archivistique, gestion de l\'information numérique.',
                'formations' => [
                    $this->f('Licence Sciences de l\'Information Documentaire', 'Documentation', 'licence', 3, null, 10, 90),
                ],
            ],
            [
                'nom' => 'École Nationale de Développement Sanitaire et Social', 'code_unique' => 'ENDSS',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.endss.sn', 'image' => self::IMG_ETUDIANTS,
                'description' => 'Forme les infirmiers, sages-femmes, techniciens supérieurs de santé et travailleurs sociaux de la fonction publique.',
                'formations' => [
                    $this->f('Diplôme d\'État d\'Infirmier', 'Santé', 'licence', 3, ['S1', 'S2'], 12, 120),
                    $this->f('Diplôme d\'État de Sage-Femme', 'Santé', 'licence', 3, ['S1', 'S2'], 13, 60),
                ],
            ],
            [
                'nom' => 'Centre d\'Études des Sciences et Techniques de l\'Information (CESTI, UCAD)', 'code_unique' => 'CESTI',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.cesti.sn', 'image' => self::IMG_ETUDIANTS,
                'description' => 'Plus ancienne école de journalisme d\'Afrique de l\'Ouest francophone : presse écrite, radio, télévision, journalisme numérique.',
                'formations' => [
                    $this->f('Licence Journalisme', 'Communication', 'licence', 3, ['L', 'S2', 'ES'], 12, 40),
                ],
            ],
            [
                'nom' => 'Institut de Technologie Alimentaire', 'code_unique' => 'ITA',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.ita.sn', 'image' => self::IMG_ATELIER,
                'description' => 'Institut public de recherche-formation en transformation et conservation des produits agricoles et halieutiques.',
                'formations' => [
                    $this->f('Licence Professionnelle Technologie Alimentaire', 'Agroalimentaire', 'licence', 3, ['S1', 'S2', 'D'], 11, 40),
                ],
            ],
            [
                'nom' => 'Institut Supérieur de Formation Agricole et Rurale de Bambey (ISFAR)', 'code_unique' => 'ISFAR',
                'region' => 'Diourbel', 'commune' => 'Bambey', 'type' => 'public',
                'site' => 'https://www.uadb.edu.sn', 'image' => self::IMG_CAMPUS_1,
                'description' => 'Ex-ENCR, rattaché à l\'UADB : forme les techniciens supérieurs et ingénieurs des travaux agricoles, de l\'élevage et des eaux et forêts.',
                'formations' => [
                    $this->f('Licence Professionnelle Productions Végétales', 'Agronomie', 'licence', 3, ['S1', 'S2', 'D'], 10, 50),
                ],
            ],

            // =====================================================================
            // 3. RÉSEAU DES ISEP (6)
            // =====================================================================
            [
                'nom' => 'Institut Supérieur d\'Enseignement Professionnel de Thiès', 'code_unique' => 'ISEP-THIES',
                'region' => 'Thiès', 'commune' => 'Thiès', 'type' => 'public',
                'site' => 'https://www.isepthies.sn', 'image' => 'assets/images/isep_thies_atelier.jpg',
                'description' => 'Premier ISEP du réseau (2014) : maintenance industrielle, électrotechnique, froid et climatisation, gestion, tourisme.',
                'formations' => [
                    $this->f('BTS Maintenance Industrielle', 'Industrie', 'bts', 2, ['S1', 'S3', 'T', 'F'], 10, 60),
                    $this->f('BTS Froid et Climatisation', 'Industrie', 'bts', 2, ['S1', 'T', 'F'], 10, 40),
                ],
                'frais' => ['montant' => 50000, 'echeancier' => ['annuel'], 'moyens_paiement' => ['especes', 'orange_money', 'wave']],
            ],
            [
                'nom' => 'Institut Supérieur d\'Enseignement Professionnel de Diamniadio (Amadou Traoré)', 'code_unique' => 'ISEP-DMN',
                'region' => 'Dakar', 'commune' => 'Diamniadio', 'type' => 'public',
                'site' => 'https://www.isep-diamniadio.sn', 'image' => self::IMG_ATELIER,
                'description' => 'ISEP du pôle de Diamniadio spécialisé dans la technologie et la mécanique automobile, l\'électronique et le numérique.',
                'formations' => [
                    $this->f('BTS Développement Web et Mobile', 'Informatique', 'bts', 2, ['S1', 'S2', 'S3', 'T'], 10, 60),
                    $this->f('BTS Maintenance Automobile', 'Industrie', 'bts', 2, ['S1', 'T', 'F'], 10, 50),
                ],
                'frais' => ['montant' => 50000, 'echeancier' => ['annuel'], 'moyens_paiement' => ['especes', 'orange_money', 'wave']],
            ],
            [
                'nom' => 'Institut Supérieur d\'Enseignement Professionnel de Richard-Toll', 'code_unique' => 'ISEP-RT',
                'region' => 'Saint-Louis', 'commune' => 'Richard-Toll', 'type' => 'public',
                'site' => 'https://www.isep.sn', 'image' => self::IMG_CAMPUS_1,
                'description' => 'ISEP orienté agriculture irriguée, agro-industrie et maintenance des équipements agricoles dans la vallée du fleuve Sénégal.',
                'formations' => [
                    $this->f('BTS Productions Agricoles', 'Agronomie', 'bts', 2, ['S1', 'S2', 'D', 'T'], 10, 50),
                    $this->f('BTS Agro-industrie', 'Agroalimentaire', 'bts', 2, ['S1', 'S2', 'T'], 10, 40),
                ],
            ],
            [
                'nom' => 'Institut Supérieur d\'Enseignement Professionnel de Matam', 'code_unique' => 'ISEP-MAT',
                'region' => 'Matam', 'commune' => 'Matam', 'type' => 'public',
                'site' => 'https://www.isep.sn', 'image' => self::IMG_CAMPUS_2,
                'description' => 'ISEP de la région de Matam : élevage, agriculture, énergies renouvelables et entrepreneuriat rural.',
                'formations' => [
                    $this->f('BTS Élevage et Productions Animales', 'Agronomie', 'bts', 2, ['S1', 'S2', 'D'], 10, 40),
                    $this->f('BTS Énergies Renouvelables', 'Ingénierie', 'bts', 2, ['S1', 'S2', 'T'], 10, 40),
                ],
            ],
            [
                'nom' => 'Institut Supérieur d\'Enseignement Professionnel de Bignona', 'code_unique' => 'ISEP-BIG',
                'region' => 'Ziguinchor', 'commune' => 'Bignona', 'type' => 'public',
                'site' => 'https://www.isep.sn', 'image' => self::IMG_CAMPUS_2,
                'description' => 'ISEP de la Casamance : arboriculture fruitière, transformation des produits locaux, tourisme durable et froid.',
                'formations' => [
                    $this->f('BTS Transformation des Produits Agroalimentaires', 'Agroalimentaire', 'bts', 2, ['S1', 'S2', 'D', 'T'], 10, 40),
                    $this->f('BTS Tourisme et Hôtellerie', 'Tourisme', 'bts', 2, ['L', 'S2', 'G'], 10, 40),
                ],
            ],
            [
                'nom' => 'Institut Supérieur d\'Enseignement Professionnel de Mbacké', 'code_unique' => 'ISEP-MBK',
                'region' => 'Diourbel', 'commune' => 'Mbacké', 'type' => 'public',
                'site' => 'https://www.isep-mbacke.sn', 'image' => self::IMG_ATELIER,
                'description' => 'ISEP de Mbacké : bâtiment et travaux publics, énergie solaire, gestion commerciale et numérique.',
                'formations' => [
                    $this->f('BTS Bâtiment et Travaux Publics', 'BTP', 'bts', 2, ['S1', 'S2', 'T', 'F'], 10, 50),
                    $this->f('BTS Gestion Commerciale', 'Commerce', 'bts', 2, ['G', 'L', 'S2'], 10, 50),
                ],
            ],

            // =====================================================================
            // 4. UNIVERSITÉS & ÉCOLES PRIVÉES RECONNUES PAR L'ÉTAT
            // =====================================================================
            [
                'nom' => 'Université Catholique de l\'Afrique de l\'Ouest — Unité Universitaire à Dakar', 'code_unique' => 'UCAO-UUD',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.ucao-uud.sn', 'image' => self::IMG_CAMPUS_1,
                'description' => 'Établissement privé reconnu : droit, économie-gestion, informatique, philosophie et théologie.',
                'formations' => [
                    $this->f('Licence Droit', 'Droit', 'licence', 3, ['L', 'S2', 'ES'], 11, 120),
                    $this->f('Licence Informatique de Gestion', 'Informatique', 'licence', 3, ['S1', 'S2', 'G'], 10, 80),
                ],
                'frais' => ['montant' => 700000, 'echeancier' => ['annuel', 'trimestriel'], 'moyens_paiement' => ['virement', 'wave', 'orange_money']],
            ],
            [
                'nom' => 'Université Amadou Hampâté Bâ', 'code_unique' => 'UAHB',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.uahb.sn', 'image' => self::IMG_BUREAU,
                'description' => 'Université privée reconnue : sciences juridiques et politiques, sciences économiques et de gestion, communication.',
                'formations' => [
                    $this->f('Licence Sciences Politiques', 'Sciences politiques', 'licence', 3, ['L', 'S2', 'ES'], 10, 90),
                ],
            ],
            [
                'nom' => 'Université Dakar Bourguiba', 'code_unique' => 'UDB',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.udb.sn', 'image' => self::IMG_BUREAU,
                'description' => 'Université privée pluridisciplinaire : gestion, droit, informatique, communication et langues.',
                'formations' => [
                    $this->f('Licence Gestion des Entreprises', 'Management', 'licence', 3, ['G', 'L', 'S2'], 10, 120),
                ],
            ],
            [
                'nom' => 'Université du Sahel', 'code_unique' => 'UNIS',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.unis.sn', 'image' => self::IMG_BIBLIO,
                'description' => 'Université privée reconnue : environnement, agrobusiness, sciences de la santé, gestion et technologies.',
                'formations' => [
                    $this->f('Licence Gestion de l\'Environnement', 'Environnement', 'licence', 3, ['S1', 'S2', 'L'], 10, 70),
                ],
            ],
            [
                'nom' => 'Université Privée Kocc Barma de Saint-Louis', 'code_unique' => 'UKB',
                'region' => 'Saint-Louis', 'commune' => 'Saint-Louis', 'type' => 'prive',
                'site' => 'https://www.ukb.sn', 'image' => self::IMG_CAMPUS_2,
                'description' => 'Établissement privé du nord du pays : management, informatique, tourisme et agrobusiness.',
                'formations' => [
                    $this->f('Licence Informatique', 'Informatique', 'licence', 3, ['S1', 'S2', 'S3'], 10, 60),
                ],
            ],
            [
                'nom' => 'Institut Supérieur de Management (ISM Dakar)', 'code_unique' => 'ISM',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.groupeism.sn', 'image' => self::IMG_BUREAU,
                'description' => 'Groupe privé de référence en management, avec des campus en régions : gestion, finance, marketing, ingénierie informatique.',
                'formations' => [
                    $this->f('Licence Gestion des Entreprises', 'Management', 'licence', 3, ['S2', 'G', 'L'], 10, 150),
                    $this->f('Master Finance d\'Entreprise', 'Finance', 'master', 2, null, 11, 60),
                ],
                'logements' => [
                    ['nom' => 'Partenariat résidences privées Sacré-Cœur', 'type' => 'partenaire', 'capacite' => 100, 'tarif_mensuel' => 60000],
                ],
                'frais' => ['montant' => 1200000, 'echeancier' => ['annuel', 'trimestriel'], 'moyens_paiement' => ['especes', 'virement', 'wave', 'orange_money']],
            ],
            [
                'nom' => 'Institut Africain de Management (IAM)', 'code_unique' => 'IAM',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.iam.sn', 'image' => self::IMG_BUREAU,
                'description' => 'École privée de commerce et de management fondée par Moustapha Guirassy : marketing, finance, management de projets, IA.',
                'formations' => [
                    $this->f('Licence Marketing Digital', 'Marketing', 'licence', 3, ['S2', 'L', 'ES', 'G'], 10, 150),
                ],
                'frais' => ['montant' => 950000, 'echeancier' => ['annuel'], 'moyens_paiement' => ['virement', 'cheque']],
            ],
            [
                'nom' => 'BEM Dakar — Business School', 'code_unique' => 'BEM',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.bem.sn', 'image' => self::IMG_ENTREPRISE,
                'description' => 'Ex-Bordeaux École de Management : programmes Bachelor et Master en management, finance et business international.',
                'formations' => [
                    $this->f('Bachelor Management International', 'Management', 'licence', 3, ['S2', 'L', 'G'], 10, 100),
                ],
            ],
            [
                'nom' => 'Groupe Sup de Co Dakar', 'code_unique' => 'SUPDECO',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.supdeco.sn', 'image' => self::IMG_ENTREPRISE,
                'description' => 'Grande école de commerce privée : programme Grande École, Bachelors en gestion, logistique, banque-assurance, RH.',
                'formations' => [
                    $this->f('Bachelor Transport et Logistique', 'Logistique', 'licence', 3, ['S2', 'G', 'L'], 10, 90),
                ],
            ],
            [
                'nom' => 'Institut Supérieur d\'Entreprise et de Gestion (ISEG)', 'code_unique' => 'ISEG',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.iseg.sn', 'image' => self::IMG_BUREAU,
                'description' => 'Réseau privé implanté à Dakar et en régions : gestion, informatique, communication, banque-finance.',
                'formations' => [
                    $this->f('Licence Banque et Finance', 'Finance', 'licence', 3, ['S2', 'G', 'L'], 10, 100),
                ],
            ],
            [
                'nom' => 'École Supérieure Multinationale des Télécommunications (ESMT)', 'code_unique' => 'ESMT',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.esmt.sn', 'image' => self::IMG_DIGITAL,
                'description' => 'École interétatique des télécommunications et du numérique : réseaux, cybersécurité, télécoms, data et IoT.',
                'formations' => [
                    $this->f('Licence Réseaux et Télécommunications', 'Télécommunications', 'licence', 3, ['S1', 'S2', 'S3', 'T'], 11, 80),
                    $this->f('Master Cybersécurité', 'Informatique', 'master', 2, null, 12, 40),
                ],
            ],
            [
                'nom' => 'HEC Dakar — Hautes Études Commerciales', 'code_unique' => 'HEC-DKR',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.hecdakar.sn', 'image' => self::IMG_ENTREPRISE,
                'description' => 'École de commerce privée : comptabilité-finance, management, commerce international et entrepreneuriat.',
                'formations' => [
                    $this->f('Licence Comptabilité, Contrôle, Audit', 'Finance', 'licence', 3, ['G', 'S2', 'L'], 10, 80),
                ],
            ],
            [
                'nom' => 'Institut Supérieur d\'Informatique (ISI)', 'code_unique' => 'ISI',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.isi.sn', 'image' => self::IMG_DIGITAL,
                'description' => 'École privée spécialisée dans les technologies de l\'information : génie logiciel, réseaux, sécurité, systèmes d\'information.',
                'formations' => [
                    $this->f('Licence Génie Logiciel', 'Informatique', 'licence', 3, ['S1', 'S2', 'S3', 'T'], 10, 120),
                    $this->f('Master Systèmes d\'Information et Réseaux', 'Informatique', 'master', 2, null, 11, 50),
                ],
            ],
            [
                'nom' => 'Institut Privé de Gestion (IPG)', 'code_unique' => 'IPG',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.ipg.sn', 'image' => self::IMG_BUREAU,
                'description' => 'École privée de gestion et de management : ressources humaines, marketing, gestion de projet, comptabilité.',
                'formations' => [
                    $this->f('Licence Gestion des Ressources Humaines', 'Management', 'licence', 3, ['G', 'L', 'S2'], 10, 90),
                ],
            ],
            [
                'nom' => 'AFI — l\'Université de l\'Entreprise', 'code_unique' => 'AFI-UE',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.afi-ue.sn', 'image' => self::IMG_ENTREPRISE,
                'description' => 'Établissement privé agréé : management, finance-comptabilité, informatique et communication, en licence et master.',
                'formations' => [
                    $this->f('Licence Management des Organisations', 'Management', 'licence', 3, ['G', 'S2', 'L'], 10, 100),
                ],
            ],
            [
                'nom' => 'Dakar Business School', 'code_unique' => 'DBS',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.dbs.sn', 'image' => self::IMG_ENTREPRISE,
                'description' => 'Business school privée : management, finance, marketing digital et business analytics.',
                'formations' => [
                    $this->f('Bachelor Business Analytics', 'Management', 'licence', 3, ['S1', 'S2', 'G'], 10, 60),
                ],
            ],
            [
                'nom' => 'Centre d\'Études Diplomatiques et Stratégiques de Dakar (CEDS)', 'code_unique' => 'CEDS-DKR',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.ceds.sn', 'image' => self::IMG_BIBLIO,
                'description' => 'Établissement privé spécialisé en relations internationales, géopolitique, défense et intelligence économique.',
                'formations' => [
                    $this->f('Master Relations Internationales', 'Sciences politiques', 'master', 2, null, 12, 40),
                ],
            ],
            [
                'nom' => 'Pigier Sénégal', 'code_unique' => 'PIGIER',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.pigier.sn', 'image' => self::IMG_BUREAU,
                'description' => 'Réseau privé de formation tertiaire : secrétariat de direction, comptabilité, commerce, tourisme, communication.',
                'formations' => [
                    $this->f('BTS Assistant de Gestion PME-PMI', 'Commerce', 'bts', 2, ['G', 'L', 'S2'], 10, 80),
                ],
            ],
            [
                'nom' => 'Université Euro-Afrique', 'code_unique' => 'UEA',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'prive',
                'site' => 'https://www.uea.sn', 'image' => self::IMG_BIBLIO,
                'description' => 'Université privée : sciences de la santé, gestion, informatique et sciences juridiques.',
                'formations' => [
                    $this->f('Licence Analyses Biomédicales', 'Santé', 'licence', 3, ['S1', 'S2'], 11, 60),
                ],
            ],

            // =====================================================================
            // 5. CENTRES DE FORMATION PROFESSIONNELLE ET TECHNIQUE
            // =====================================================================
            [
                'nom' => 'Centre de Formation Professionnelle et Technique Sénégal-Japon (CFPT-SJ)', 'code_unique' => 'CFPT-SJ',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.cfptsj.sn', 'image' => self::IMG_ATELIER,
                'description' => 'Pôle de référence de la coopération sénégalo-japonaise pour les métiers de l\'industrie : électromécanique, maintenance, structures métalliques, froid.',
                'formations' => [
                    $this->f('BTS Électromécanique', 'Industrie', 'bts', 2, ['S1', 'S3', 'T', 'F'], 11, 48),
                    $this->f('BTS Maintenance des Engins Lourds', 'Industrie', 'bts', 2, ['S1', 'T', 'F'], 11, 36),
                ],
            ],
            [
                'nom' => 'Lycée Technique Industriel Maurice Delafosse', 'code_unique' => 'LTID-DELAFOSSE',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.education.sn', 'image' => self::IMG_ATELIER,
                'description' => 'Lycée technique industriel historique de Dakar : électrotechnique, mécanique, construction métallique, génie civil.',
                'formations' => [
                    $this->f('Baccalauréat Technique F3 — Électrotechnique', 'Industrie', 'bts', 3, ['3e'], 10, 90),
                    $this->f('BT Construction Métallique', 'Industrie', 'bts', 2, ['3e', 'T'], 10, 48),
                ],
            ],
            [
                'nom' => 'Lycée Technique Commercial Maurice Delafosse', 'code_unique' => 'LTC-DELAFOSSE',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.education.sn', 'image' => self::IMG_BUREAU,
                'description' => 'Lycée technique commercial de Dakar : comptabilité-gestion, secrétariat bureautique, action commerciale.',
                'formations' => [
                    $this->f('Baccalauréat Technique G — Techniques Quantitatives de Gestion', 'Commerce', 'bts', 3, ['3e'], 10, 120),
                ],
            ],
            [
                'nom' => 'Lycée Technique André Peytavin de Saint-Louis', 'code_unique' => 'LT-PEYTAVIN',
                'region' => 'Saint-Louis', 'commune' => 'Saint-Louis', 'type' => 'public',
                'site' => 'https://www.education.sn', 'image' => self::IMG_CAMPUS_2,
                'description' => 'Grand lycée technique du nord : filières industrielles (électricité, mécanique, froid) et tertiaires (gestion, secrétariat).',
                'formations' => [
                    $this->f('Baccalauréat Technique F1 — Construction Mécanique', 'Industrie', 'bts', 3, ['3e'], 10, 60),
                ],
            ],
            [
                'nom' => 'Centre d\'Enseignement et de Développement Technique G15 (CEDT G15)', 'code_unique' => 'CEDT-G15',
                'region' => 'Dakar', 'commune' => 'Guédiawaye', 'type' => 'public',
                'site' => 'https://www.cedt-g15.sn', 'image' => self::IMG_ATELIER,
                'description' => 'Centre technique de Guédiawaye : électricité, mécanique automobile, menuiserie métallique et bois, froid.',
                'formations' => [
                    $this->f('CAP Mécanique Automobile', 'Industrie', 'bts', 2, ['3e'], 10, 40),
                    $this->f('BEP Électrotechnique', 'Industrie', 'bts', 2, ['3e'], 10, 40),
                ],
            ],
            [
                'nom' => 'Centre National de Qualification Professionnelle de Dakar (CNQP)', 'code_unique' => 'CNQP',
                'region' => 'Dakar', 'commune' => 'Pikine', 'type' => 'public',
                'site' => 'https://www.cnqp.sn', 'image' => self::IMG_ATELIER,
                'description' => 'Centre de qualification et de perfectionnement aux métiers du bâtiment, de l\'industrie et de l\'énergie, y compris pour adultes en reconversion.',
                'formations' => [
                    $this->f('Certificat de Qualification Professionnelle — Plomberie', 'BTP', 'bts', 1, null, 10, 30),
                    $this->f('Certificat de Qualification Professionnelle — Installation Solaire', 'Énergie', 'bts', 1, null, 10, 30),
                ],
            ],
            [
                'nom' => 'Centre de Formation Professionnelle de Thiès', 'code_unique' => 'CFP-THIES',
                'region' => 'Thiès', 'commune' => 'Thiès', 'type' => 'public',
                'site' => 'https://www.formationprofessionnelle.gouv.sn', 'image' => self::IMG_CAMPUS_1,
                'description' => 'Centre régional : bâtiment, électricité, mécanique, coupe-couture, transformation agroalimentaire.',
                'formations' => [
                    $this->f('CAP Maçonnerie', 'BTP', 'bts', 2, ['3e'], 10, 40),
                ],
            ],
            [
                'nom' => 'Centre de Formation Professionnelle de Kaolack', 'code_unique' => 'CFP-KAOLACK',
                'region' => 'Kaolack', 'commune' => 'Kaolack', 'type' => 'public',
                'site' => 'https://www.formationprofessionnelle.gouv.sn', 'image' => self::IMG_CAMPUS_1,
                'description' => 'Centre régional du Saloum : métiers du bâtiment, froid, mécanique deux-roues, habillement et restauration.',
                'formations' => [
                    $this->f('CAP Froid et Climatisation', 'Industrie', 'bts', 2, ['3e'], 10, 30),
                ],
            ],
            [
                'nom' => 'Centre de Formation Professionnelle de Ziguinchor', 'code_unique' => 'CFP-ZIG',
                'region' => 'Ziguinchor', 'commune' => 'Ziguinchor', 'type' => 'public',
                'site' => 'https://www.formationprofessionnelle.gouv.sn', 'image' => self::IMG_CAMPUS_2,
                'description' => 'Centre régional de la Casamance : bois, bâtiment, électricité, transformation des fruits et légumes, tourisme.',
                'formations' => [
                    $this->f('CAP Menuiserie Bois', 'Artisanat', 'bts', 2, ['3e'], 10, 30),
                ],
            ],
            [
                'nom' => 'Centre Régional de Formation Professionnelle de Louga', 'code_unique' => 'CFP-LOUGA',
                'region' => 'Louga', 'commune' => 'Louga', 'type' => 'public',
                'site' => 'https://www.formationprofessionnelle.gouv.sn', 'image' => self::IMG_ATELIER,
                'description' => 'Centre régional : électricité bâtiment, énergie solaire, mécanique automobile, élevage et maraîchage.',
                'formations' => [
                    $this->f('CAP Électricité Bâtiment', 'BTP', 'bts', 2, ['3e'], 10, 30),
                ],
            ],
            [
                'nom' => 'Centre de Formation Professionnelle de Tambacounda', 'code_unique' => 'CFP-TAMBA',
                'region' => 'Tambacounda', 'commune' => 'Tambacounda', 'type' => 'public',
                'site' => 'https://www.formationprofessionnelle.gouv.sn', 'image' => self::IMG_CAMPUS_1,
                'description' => 'Centre régional du Sénégal oriental : bâtiment, mécanique, agriculture et transformation des céréales.',
                'formations' => [
                    $this->f('CAP Mécanique Générale', 'Industrie', 'bts', 2, ['3e'], 10, 30),
                ],
            ],
            [
                'nom' => 'Centre de Formation aux Métiers du Tourisme, de l\'Hôtellerie et de la Restauration de Saly', 'code_unique' => 'CFMTHR-SALY',
                'region' => 'Thiès', 'commune' => 'Saly Portudal', 'type' => 'public',
                'site' => 'https://www.formationprofessionnelle.gouv.sn', 'image' => self::IMG_ENTREPRISE,
                'description' => 'Centre de la Petite Côte dédié à l\'hôtellerie-restauration : cuisine, service, réception, gestion hôtelière.',
                'formations' => [
                    $this->f('BT Hôtellerie-Restauration', 'Tourisme', 'bts', 2, ['3e', 'L', 'G'], 10, 48),
                ],
            ],
            [
                'nom' => 'École Nationale de Formation en Économie Familiale et Sociale', 'code_unique' => 'ENFEFS',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.education.sn', 'image' => self::IMG_ETUDIANTS,
                'description' => 'Forme les enseignants et animateurs en économie familiale et sociale : alimentation-nutrition, textile-habillement, développement communautaire.',
                'formations' => [
                    $this->f('Licence Professionnelle Économie Familiale et Sociale', 'Éducation', 'licence', 3, ['L', 'S2', 'G'], 10, 40),
                ],
            ],
            [
                'nom' => 'Centre de Formation Professionnelle Horticole de Cambérène', 'code_unique' => 'CFPH-CAMBERENE',
                'region' => 'Dakar', 'commune' => 'Dakar', 'type' => 'public',
                'site' => 'https://www.cfph.sn', 'image' => self::IMG_CAMPUS_1,
                'description' => 'Centre spécialisé en horticulture, maraîchage, floriculture et aménagement paysager.',
                'formations' => [
                    $this->f('CAP Horticulture', 'Agronomie', 'bts', 2, ['3e', 'D'], 10, 40),
                ],
            ],
            [
                'nom' => 'Centre Sectoriel de Formation Professionnelle aux Métiers du Numérique de Diamniadio', 'code_unique' => 'CSFP-NUM',
                'region' => 'Dakar', 'commune' => 'Diamniadio', 'type' => 'public',
                'site' => 'https://www.senum.sn', 'image' => self::IMG_DIGITAL,
                'description' => 'Centre sectoriel dédié aux métiers du numérique : développement, data, cybersécurité, support et réseaux, en partenariat public-privé.',
                'formations' => [
                    $this->f('Certificat Développeur Full-Stack', 'Informatique', 'bts', 1, null, 10, 60),
                    $this->f('Certificat Administrateur Systèmes et Réseaux', 'Informatique', 'bts', 1, null, 10, 40),
                ],
            ],
            [
                'nom' => 'Centre de Formation Professionnelle de Kaffrine', 'code_unique' => 'CFP-KAFFRINE',
                'region' => 'Kaffrine', 'commune' => 'Kaffrine', 'type' => 'public',
                'site' => 'https://www.formationprofessionnelle.gouv.sn', 'image' => self::IMG_CAMPUS_2,
                'description' => 'Centre régional : bâtiment, énergie solaire, mécanique agricole, transformation des produits locaux.',
                'formations' => [
                    $this->f('CAP Maintenance des Équipements Agricoles', 'Industrie', 'bts', 2, ['3e', 'D'], 10, 30),
                ],
            ],
        ];
    }
}
