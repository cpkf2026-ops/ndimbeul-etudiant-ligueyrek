"""Sécurité X-Service-Token, endpoint de santé, sources de confiance, cache."""
from unittest import mock

from django.test import SimpleTestCase, TestCase, override_settings

from services import cache, sources
from services.models import SourceConfiance

JETON = {'HTTP_X_SERVICE_TOKEN': 'jeton-de-test'}
OLLAMA_OK = {
    'disponible': True,
    'modele_veille': {'nom': 'mistral:7b-instruct', 'installe': True},
    'modele_rapide': {'nom': 'qwen2.5:3b-instruct', 'installe': True},
}


@mock.patch('services.llm_service.etat', return_value=OLLAMA_OK)
class SecuriteEtSanteTests(TestCase):
    def test_sans_jeton_401(self, _etat):
        reponse = self.client.get('/api/ia/sante/')
        self.assertEqual(reponse.status_code, 401)
        self.assertEqual(reponse.json()['erreur'], 'non_autorise')

    def test_mauvais_jeton_401(self, _etat):
        reponse = self.client.get('/api/ia/sante/', HTTP_X_SERVICE_TOKEN='faux')
        self.assertEqual(reponse.status_code, 401)

    def test_ancien_en_tete_toujours_accepte(self, _etat):
        reponse = self.client.get('/api/ia/sante/', HTTP_X_INTERNAL_KEY='jeton-de-test')
        self.assertEqual(reponse.status_code, 200)

    @override_settings(LARAVEL_SHARED_TOKEN='')
    def test_jeton_non_configure_500(self, _etat):
        reponse = self.client.get('/api/ia/sante/', **JETON)
        self.assertEqual(reponse.status_code, 500)

    def test_sante_detaille_chaque_brique(self, _etat):
        reponse = self.client.get('/api/ia/sante/', **JETON)

        self.assertEqual(reponse.status_code, 200)
        corps = reponse.json()
        self.assertEqual(corps['statut'], 'ok')
        self.assertEqual(corps['base_donnees'], 'ok')
        self.assertTrue(corps['tavily']['cle_configuree'])
        self.assertEqual(corps['tavily']['credits']['restants'], 1000)

    def test_ollama_arrete_503(self, etat):
        etat.return_value = {'disponible': False, 'detail': 'connexion refusée'}
        reponse = self.client.get('/api/ia/sante/', **JETON)
        self.assertEqual(reponse.status_code, 503)
        self.assertEqual(reponse.json()['statut'], 'degrade')


class SourcesConfianceTests(TestCase):
    def test_valeurs_par_defaut_si_table_vide(self):
        domaines = sources.domaines(sources.ORIENTATION)
        self.assertIn('campusen.sn', domaines)
        self.assertIn('ucad.sn', domaines)

    def test_la_base_remplace_les_valeurs_par_defaut(self):
        SourceConfiance.objects.create(domaine='senjob.com', categorie='emploi')
        SourceConfiance.objects.create(domaine='anpej.sn', categorie='emploi', actif=False)

        self.assertEqual(sources.domaines(sources.EMPLOI), ['senjob.com'])

    def test_sans_doublon_entre_categories(self):
        domaines = sources.domaines(sources.EMPLOI, sources.ACTUALITES)
        self.assertEqual(len(domaines), len(set(domaines)))

    def test_chargement_idempotent(self):
        premiere_fois = sources.charger_valeurs_par_defaut()
        self.assertGreater(premiere_fois, 0)
        self.assertEqual(sources.charger_valeurs_par_defaut(), 0)


class CacheTests(TestCase):
    def test_meme_cle_malgre_casse_accents_ponctuation(self):
        self.assertEqual(
            cache.cle('chat', 'Quelles sont les DATES du Bac ?!'),
            cache.cle('chat', 'quelles sont les dates du bac'),
        )

    def test_lecture_ecriture(self):
        cle = cache.cle('chat', 'bonjour')
        cache.ecrire(cle, {'reponse': 'Salut'}, 60)
        self.assertEqual(cache.lire(cle), {'reponse': 'Salut'})

    def test_redis_arrete_ne_casse_rien(self):
        with mock.patch('services.cache.cache.get', side_effect=ConnectionError('Redis arrêté')):
            self.assertIsNone(cache.lire('ia:chat:x'))


class CommandesManageTests(TestCase):
    def test_toutes_les_commandes_du_projet_se_chargent(self):
        """Une erreur de syntaxe dans une commande (ex. `veiller`) ne serait sinon vue
        qu'au moment de la lancer, puisque les autres tests ne l'importent pas."""
        from django.core.management import get_commands, load_command_class

        commandes = {nom: app for nom, app in get_commands().items()
                     if app in ('ia', 'veille', 'services', 'recommandations')}
        self.assertIn('veiller', commandes)
        for nom, app in commandes.items():
            with self.subTest(commande=nom):
                load_command_class(app, nom)


class SitesOfficielsTests(SimpleTestCase):
    def test_identifiants_du_nom(self):
        from veille.sites_officiels import identifiants
        self.assertEqual(identifiants('Dakar Institute of Technology (DIT)'), {'dit'})
        self.assertEqual(identifiants('ECPI - École de Formation Professionnelle (Prépa & BTS)'), {'ecpi'})

    def test_adresse_retenue_seulement_si_le_domaine_porte_le_nom(self):
        from veille.sites_officiels import adresse_candidate
        resultats = [
            {'url': 'https://www.facebook.com/ditdakar'},       # réseau social : exclu
            {'url': 'https://editions-dakar.sn/dit'},            # « dit » au milieu d'un mot : exclu
            {'url': 'https://www.leadersenegalais.com/dit'},     # annuaire : exclu
            {'url': 'https://dit.sn/formations'},                # le site officiel
        ]
        self.assertEqual(adresse_candidate('Dakar Institute of Technology (DIT)', resultats), 'https://dit.sn')
        self.assertIsNone(adresse_candidate('ASAFIN', [{'url': 'https://senjob.com/asafin'}]))
