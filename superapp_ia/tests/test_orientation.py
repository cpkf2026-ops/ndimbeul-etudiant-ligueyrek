"""Module 1 — orientation (Tavily, Ollama et embeddings mockés) et endpoint POST."""
import uuid
import zlib
from decimal import Decimal
from unittest import mock

import numpy as np
from django.core.cache import cache as cache_django
from django.test import SimpleTestCase, TestCase

from recommandations import orientation
from recommandations.models import Formation, Recommandation
from services import cache, llm_service, tavily_service
from services.models import CreditTavily
from veille.models import Universite

JETON = {'HTTP_X_SERVICE_TOKEN': 'jeton-de-test'}
PROFIL = {'serie_bac': 'S2', 'moyenne': Decimal('13.5'), 'passions': ['informatique', 'programmation'],
          'ville': None}


def _faux_encodeur(texte_a_encoder):
    """Sac de mots déterministe : deux textes qui partagent des mots sont « proches »."""
    vecteur = np.zeros(64)
    for mot in cache.normaliser_texte(texte_a_encoder).split():
        vecteur[zlib.crc32(mot.encode()) % 64] += 1
    norme = np.linalg.norm(vecteur)
    return vecteur / norme if norme else vecteur


def _universite(nom, type_, region, site=None):
    return Universite.objects.create(
        nom=nom, code_unique=nom.upper().replace(' ', '_'), type=type_, region=region,
        site_web_officiel=site, statut_actif=True,
    )


def _formation(universite, intitule, domaine, series=None, moyenne=None, debouches=None):
    return Formation.objects.create(
        id=str(uuid.uuid4()), universite_id=universite.id, intitule=intitule, domaine=domaine,
        niveau='licence', series_acceptees=series, moyenne_minimale=moyenne, debouches=debouches,
    )


class OrientationTests(TestCase):
    def setUp(self):
        cache_django.clear()
        mock.patch('recommandations.scoring.encoder_texte', side_effect=_faux_encodeur).start()
        mock.patch('recommandations.scoring.encoder_textes',
                   side_effect=lambda textes: np.array([_faux_encodeur(t) for t in textes])).start()
        mock.patch('recommandations.orientation.encoder_texte', side_effect=_faux_encodeur).start()
        self.tavily = mock.patch.object(tavily_service, '_get_client').start().return_value
        self.llm = mock.patch.object(llm_service, 'generer').start()
        self.addCleanup(mock.patch.stopall)

        ucad = _universite('UCAD', 'public', 'Dakar', 'https://ucad.sn')
        ugb = _universite('UGB', 'public', 'Saint-Louis', 'https://ugb.sn')
        ism = _universite('ISM', 'prive', 'Dakar')
        self.info = _formation(ucad, 'Licence Informatique', 'Informatique programmation', ['S1', 'S2'],
                               Decimal('12'), 'développeur, administrateur réseau, data analyst')
        _formation(ugb, 'Licence Génie logiciel', 'Informatique programmation')
        _formation(ism, 'BTS Informatique de gestion', 'Informatique')
        _formation(ucad, 'Doctorat de médecine', 'Santé', ['S1', 'S2'], Decimal('15'))  # moyenne trop basse
        _formation(ugb, 'Licence Lettres modernes', 'Lettres', ['L1', 'L2'])          # série incompatible

    def _metiers_llm(self, *metiers):
        self.llm.return_value = '\n'.join(f"{m['nom']} | {m['source']}" for m in metiers)

    def test_formations_filtrees_par_serie_et_moyenne(self):
        self._metiers_llm()
        reponse = orientation.recommander(PROFIL)

        noms = [f['nom'] for f in reponse['formations']]
        self.assertNotIn('Doctorat de médecine', noms)
        self.assertNotIn('Licence Lettres modernes', noms)
        self.assertEqual(len(noms), 3)
        informatique = next(f for f in reponse['formations'] if f['nom'] == 'Licence Informatique')
        self.assertIn('série S2', informatique['justification'])
        self.assertIn('13.5/20', informatique['justification'])
        self.assertEqual(informatique['source'], 'https://ucad.sn')
        for bloc in ('formations', 'universites', 'metiers'):
            for element in reponse[bloc]:
                self.assertTrue(0 <= element['score'] <= 100, element)

    def test_universites_publiques_et_privees_avec_lien(self):
        self._metiers_llm()
        universites = orientation.recommander(PROFIL)['universites']

        self.assertEqual({u['type'] for u in universites}, {'public', 'prive'})
        ism = next(u for u in universites if u['nom'] == 'ISM')
        self.assertEqual(ism['source'], orientation.LIEN_CAMPUSEN)  # pas de site connu
        self.assertIn('Établissement privé', ism['justification'])

    def test_metiers_absents_de_leur_source_ecartes(self):
        self._metiers_llm(
            {'nom': 'Développeur', 'source': 1, 'justification': 'Tu aimes la programmation.'},
            {'nom': 'Pilote de ligne', 'source': 1, 'justification': 'Inventé.'},
            {'nom': 'Administrateur réseau', 'source': 1, 'justification': 'Gagne 900 000 FCFA.'},
            {'nom': 'Data analyst', 'source': 7, 'justification': 'Source inexistante.'},
        )
        reponse = orientation.recommander(PROFIL)

        noms = [m['nom'] for m in reponse['metiers']]
        self.assertIn('Développeur', noms)
        self.assertNotIn('Pilote de ligne', noms)
        # Data analyst revient par le repli « base » (source 7 invalide), pas par le LLM.
        self.assertIn('Data analyst', noms)
        admin = next(m for m in reponse['metiers'] if m['nom'] == 'Administrateur réseau')
        # Le texte libre du modèle (« 900 000 FCFA ») n'est jamais repris : justification construite.
        self.assertNotIn('900', admin['justification'])
        self.assertIn('« Licence Informatique »', admin['justification'])
        self.assertIn('ta passion pour', admin['justification'])
        self.tavily.search.assert_not_called()          # 3 débouchés en base : pas de Tavily

    def test_tavily_quand_la_base_ne_cite_pas_assez_de_metiers(self):
        Formation.objects.filter(id=self.info.id).update(debouches=None)
        self.tavily.search.return_value = {'results': [{
            'title': 'Les métiers du numérique au Sénégal', 'url': 'https://www.senjob.com/metiers-numerique',
            'content': 'Le numérique recrute : développeur web, ingénieur cybersécurité, chef de projet digital.',
        }]}
        self._metiers_llm(
            {'nom': 'Développeur web', 'source': 1, 'justification': 'Lié à ta passion pour la programmation.'},
            {'nom': 'Ingénieur cybersécurité', 'source': 1, 'justification': 'Lié à l’informatique.'},
        )

        reponse = orientation.recommander(PROFIL)

        self.assertEqual([m['source'] for m in reponse['metiers']], ['https://www.senjob.com/metiers-numerique'] * 2)
        self.assertTrue(all(50 <= m['score'] <= 100 for m in reponse['metiers']))
        parametres = self.tavily.search.call_args.kwargs
        self.assertIn('facebook.com', parametres['exclude_domains'])
        self.assertLessEqual(parametres['timeout'], 8)
        self.assertEqual(CreditTavily.objects.get().credits_interactif, 1)

        # Autre profil, mêmes passions : la recherche web est réutilisée (cache 30 jours).
        orientation.recommander({**PROFIL, 'moyenne': Decimal('16')})
        self.assertEqual(self.tavily.search.call_count, 1)

    def test_reponse_mise_en_cache(self):
        self._metiers_llm({'nom': 'Développeur', 'source': 1, 'justification': 'Tu aimes coder.'})
        premiere = orientation.recommander(PROFIL)
        seconde = orientation.recommander({**PROFIL, 'passions': ['Programmation', 'INFORMATIQUE']})

        self.assertFalse(premiere['depuis_cache'])
        self.assertTrue(seconde['depuis_cache'])
        self.assertEqual(self.llm.call_count, 1)

    def test_ollama_arrete_repli_sur_les_debouches_en_base(self):
        self.llm.side_effect = llm_service.LLMIndisponibleError('Ollama arrêté')

        reponse = orientation.recommander(PROFIL)

        self.assertEqual(
            [m['nom'] for m in reponse['metiers']], ['Développeur', 'Administrateur réseau', 'Data analyst'],
        )
        self.assertIn('llm_indisponible', reponse['avertissements'])
        self.assertFalse(orientation.recommander(PROFIL)['depuis_cache'])  # réponse dégradée non cachée


@mock.patch('recommandations.orientation.recommander', return_value={'metiers': [], 'temps_ms': 5})
class OrientationApiTests(TestCase):
    def test_entree_valide(self, recommander):
        reponse = self.client.post(
            '/api/ia/orientation/',
            data={'serie_bac': ' s2 ', 'moyenne': 13.5, 'passions': ['informatique'], 'ville': 'Thiès'},
            content_type='application/json', **JETON,
        )
        self.assertEqual(reponse.status_code, 200)
        donnees = recommander.call_args.args[0]
        self.assertEqual(donnees['serie_bac'], 'S2')
        self.assertEqual(donnees['moyenne'], Decimal('13.50'))

    def test_entree_invalide_400(self, recommander):
        reponse = self.client.post(
            '/api/ia/orientation/', data={'serie_bac': 'S2', 'moyenne': 25, 'passions': []},
            content_type='application/json', **JETON,
        )
        self.assertEqual(reponse.status_code, 400)
        self.assertEqual(set(reponse.json()['details']), {'moyenne', 'passions'})
        recommander.assert_not_called()

    def test_jeton_obligatoire(self, recommander):
        self.assertEqual(self.client.post('/api/ia/orientation/').status_code, 401)


class HistoriqueTests(TestCase):
    @mock.patch('recommandations.orientation.encoder_texte', side_effect=_faux_encodeur)
    @mock.patch('recommandations.scoring.encoder_textes',
                side_effect=lambda textes: np.array([_faux_encodeur(t) for t in textes]))
    @mock.patch('recommandations.scoring.encoder_texte', side_effect=_faux_encodeur)
    @mock.patch.object(llm_service, 'generer', return_value='AUCUN')
    def test_utilisateur_id_trace_les_formations(self, *_mocks):
        cache_django.clear()
        ucad = _universite('UCAD', 'public', 'Dakar')
        _formation(ucad, 'Licence Informatique', 'Informatique', debouches='développeur, testeur, intégrateur')

        orientation.recommander({**PROFIL, 'utilisateur_id': 'u-123'})

        self.assertEqual(Recommandation.objects.filter(utilisateur_id='u-123').count(), 1)


class LectureMetiersTests(TestCase):
    def test_formats_tolerés(self):
        from recommandations.prompts import lire_metiers
        reponse = "1. Développeur web | 3\n- Data analyst | [1]\nPhrase parasite sans numéro\nAUCUN"
        self.assertEqual(lire_metiers(reponse), [{'nom': 'Développeur web', 'source': 3},
                                                 {'nom': 'Data analyst', 'source': 1}])


class RecommandationsApplicationTests(TestCase):
    """POST /internal/recommendations (écran Orientation de l'application)."""

    @mock.patch('recommandations.scoring.encoder_textes',
                side_effect=lambda textes: np.array([_faux_encodeur(t) for t in textes]))
    @mock.patch('recommandations.scoring.encoder_texte', side_effect=_faux_encodeur)
    @mock.patch.object(llm_service, 'generer', side_effect=AssertionError('le LLM ne doit pas être appelé'))
    def test_explications_instantanees_sans_llm(self, *_mocks):
        ucad = _universite('UCAD', 'public', 'Dakar', 'https://ucad.sn')
        _formation(ucad, 'Doctorat de médecine', 'Santé médecine', ['S1', 'S2'], Decimal('12'))
        reponse = self.client.post(
            '/internal/recommendations', content_type='application/json', **JETON,
            data={'utilisateur_id': 'u-1', 'profil': {'serie_bac': 'S2', 'moyenne_generale': 14,
                                                       'passions': ['médecine'], 'mobilite': True}},
        )
        self.assertEqual(reponse.status_code, 200)
        explication = reponse.json()['data'][0]['explication']
        self.assertIn('série S2', explication)
        self.assertIn('ta moyenne (14/20) atteint le minimum demandé (12/20)', explication)


class ExpansionMetiersTests(SimpleTestCase):
    """Métiers mal connus du modèle d'embeddings : le profil est enrichi des domaines qui y mènent."""

    def test_douanier_enrichi_avec_ses_domaines(self):
        from recommandations.scoring import _texte_profil

        texte = _texte_profil({'passions': ['Douane'], 'metiers_envisages': ['douanier']})
        self.assertIn('commerce international', texte)
        self.assertIn('logistique', texte)

    def test_metier_connu_non_modifie(self):
        from recommandations.scoring import _texte_profil

        self.assertEqual(_texte_profil({'passions': ['informatique'], 'metiers_envisages': []}), 'informatique')


class ThesaurusDomainesTests(SimpleTestCase):
    """Les métiers, passions et matières sont traduits en domaines d'études."""

    def test_metiers_courants(self):
        from recommandations.domaines import domaines_du_texte

        attendus = {'douanier': 'douane_commerce_international', 'médecin': 'sante', 'avocate': 'droit',
                    'développeur web': 'informatique', 'journaliste': 'communication_journalisme',
                    'agronome': 'agriculture_environnement', 'pilote': 'aeronautique', 'comptable': 'finance_comptabilite'}
        for terme, domaine in attendus.items():
            self.assertIn(domaine, domaines_du_texte(terme), terme)

    def test_pas_de_faux_rapprochement(self):
        from recommandations.domaines import domaines_du_texte

        self.assertNotIn('securite_defense', domaines_du_texte('Licence Qualité, Hygiène, Sécurité & Environnement'))
        self.assertEqual(domaines_du_texte('jeux vidéo'), {'informatique'})


class ClassementParDomaineTests(TestCase):
    """Le classement suit le projet de l'élève (et non plus la seule région)."""

    def setUp(self):
        from recommandations.models import Formation
        from veille.models import Universite as U

        self.thies = U.objects.create(nom='Institut de Thiès', code_unique='IT1', region='Thiès', commune='Thiès',
                                      type='prive', statut_actif=True)
        self.dakar = U.objects.create(nom='École de Dakar', code_unique='ED1', region='Dakar', commune='Dakar',
                                      type='public', statut_actif=True)
        for u, intitule in [(self.thies, 'Infirmier d\'État'), (self.thies, 'Puériculteur'),
                            (self.dakar, 'Licence Commerce International'), (self.dakar, 'Licence Transport Logistique')]:
            Formation.objects.create(id=str(uuid.uuid4()), universite_id=u.id, intitule=intitule, niveau='licence')

    def _profil(self, **autres):
        return {'serie_bac': 'S2', 'moyenne_generale': 13, 'region_cible': 'Thiès', 'mobilite': False,
                'pref_public_prive': 'indifferent', 'passions': [], 'matieres_fortes': [], **autres}

    def test_le_metier_passe_avant_la_region(self):
        from recommandations.scoring import generer_recommandations

        r = generer_recommandations(self._profil(metiers_envisages=['douanier']), limite=4)
        self.assertEqual(r[0]['formation'].intitule, 'Licence Commerce International')
        self.assertIn('Douane, transit et commerce international', r[0]['domaines_communs'])

    def test_domaine_voisin_quand_le_domaine_exact_manque(self):
        from recommandations.scoring import generer_recommandations

        r = generer_recommandations(self._profil(metiers_envisages=['pilote']), limite=4)
        self.assertEqual(r[0]['formation'].intitule, 'Licence Transport Logistique')
        self.assertTrue(r[0]['voisins'])
        self.assertTrue(r[0]['voisins'][0]['aucune_exacte'])

    def test_preference_public_prise_en_compte(self):
        from recommandations.scoring import POIDS_STATUT, generer_recommandations

        r = generer_recommandations(self._profil(metiers_envisages=['douanier'], pref_public_prive='public'), limite=1)
        self.assertEqual(r[0]['details']['statut'], POIDS_STATUT)
