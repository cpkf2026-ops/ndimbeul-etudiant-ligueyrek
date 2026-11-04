"""Chatbot à outils (Gemini simulé) : appel d'outils, contrôles de fiabilité, repli local."""
from unittest import mock

import httpx
from django.core.cache import cache as cache_django
from django.test import TestCase, override_settings
from django.utils import timezone

from ia import agent, chatbot
from services import gemini_service
from veille.models import OffreEmploi, Universite


def _reponse_http(contenu, statut=200):
    return httpx.Response(statut, json={'candidates': [{'content': contenu}]} if statut == 200 else {'error': {}},
                          request=httpx.Request('POST', 'https://gemini'))


def _appel(outil, **args):
    return {'role': 'model', 'parts': [{'functionCall': {'name': outil, 'args': args}}]}


def _texte(t):
    return {'role': 'model', 'parts': [{'text': t}]}


@override_settings(GEMINI_API_KEY='cle-de-test', GEMINI_MAX_ETAPES=4)
class AgentGeminiTests(TestCase):
    def setUp(self):
        cache_django.clear()
        self.ugb = Universite.objects.create(
            nom='Université Gaston Berger de Saint-Louis (UGB)', code_unique='UGB', type='public',
            region='Saint-Louis', commune='Saint-Louis', site_web_officiel='https://www.ugb.sn',
            telephone_contact='+221 33 961 19 06', statut_actif=True)
        OffreEmploi.objects.create(intitule='Stage comptable', entreprise='Sonatel', type='stage', region='Dakar',
                                   source_url='https://senjob.com/stage-comptable', statut='active',
                                   date_indexation=timezone.now(), date_limite=timezone.localdate())

    def _gemini(self, *contenus):
        return mock.patch('services.gemini_service.httpx.post',
                          side_effect=[_reponse_http(c) for c in contenus])

    def test_gemini_appelle_un_outil_puis_repond_avec_la_source(self):
        with self._gemini(_appel('chercher_offres', type='stage'),
                          _texte('Voici un stage disponible : Stage comptable chez Sonatel, à Dakar.')) as post:
            r = chatbot.repondre('y a du taf pour un stagiaire en compta ?')
        self.assertEqual(r.get('moteur'), 'gemini')
        self.assertIn('Stage comptable', r['reponse'])
        self.assertEqual(r['sources'][0]['url'], 'https://senjob.com/stage-comptable')
        # Le 2e appel transmet le résultat de l'outil à Gemini.
        envoye = next(p['functionResponse'] for c in post.call_args_list[1].kwargs['json']['contents']
                      for p in c['parts'] if 'functionResponse' in p)
        self.assertEqual(envoye['name'], 'chercher_offres')
        self.assertEqual(envoye['response']['resultat']['offres'][0]['entreprise'], 'Sonatel')

    def test_chiffre_invente_deux_fois_refuse_et_repli_sur_le_chatbot_local(self):
        with self._gemini(_appel('fiche_etablissement', nom='UGB'),
                          _texte("Les frais d'inscription à l'UGB sont de 75 000 F."),
                          _texte("Les frais sont d'environ 75 000 F.")):
            r = chatbot.repondre("frais d'inscription UGB")
        self.assertNotEqual(r.get('moteur'), 'gemini')
        self.assertNotIn('75 000', r['reponse'])

    def test_chiffre_invente_corrige_par_la_reecriture(self):
        with self._gemini(_appel('fiche_etablissement', nom='UGB'),
                          _texte("Les frais d'inscription à l'UGB sont de 75 000 F."),
                          _texte("Je n'ai pas les frais vérifiés de l'UGB : consulte https://www.ugb.sn.")) as post:
            r = chatbot.repondre("frais d'inscription UGB")
        self.assertEqual(r.get('moteur'), 'gemini')
        self.assertNotIn('75 000', r['reponse'])
        consigne = next(p['text'] for c in post.call_args_list[2].kwargs['json']['contents']
                        for p in c['parts'] if 'Contrôle de fiabilité' in p.get('text', ''))
        self.assertIn('75000', consigne.replace(' ', ''))

    def test_moyenne_sur_20_et_numeros_de_liste_acceptes(self):
        with self._gemini(_texte("Avec 13/20 en S2 :\n1. Une licence d'informatique\n2. Une école d'ingénieurs")):
            r = chatbot.repondre("j'ai eu 13 de moyenne en S2, je fais quoi ?")
        self.assertEqual(r.get('moteur'), 'gemini')

    def test_date_iso_des_outils_acceptee_ecrite_en_toutes_lettres(self):
        jour = timezone.localdate()
        mois = agent._MOIS[jour.month - 1]
        with self._gemini(_appel('chercher_offres', type='stage'),
                          _texte(f'Stage comptable chez Sonatel, date limite le {jour.day} {mois}.')):
            r = chatbot.repondre('des stages en compta ?')
        self.assertEqual(r.get('moteur'), 'gemini')

    def test_lien_invente_retire(self):
        with self._gemini(_appel('fiche_etablissement', nom='UGB'),
                          _texte("Site de l'UGB : https://www.ugb.sn ; inscriptions sur https://faux-site.com/inscription")):
            r = chatbot.repondre("site de l'UGB et inscription")
        self.assertIn('https://www.ugb.sn', r['reponse'])
        self.assertNotIn('faux-site.com', r['reponse'])

    def test_quota_atteint_pause_et_repli(self):
        with mock.patch('services.gemini_service.httpx.post', return_value=_reponse_http({}, statut=429)) as post:
            r1 = chatbot.repondre('où étudier le droit ?')
            r2 = chatbot.repondre('où étudier la médecine ?')
        self.assertNotEqual(r1.get('moteur'), 'gemini')
        self.assertTrue(r2['reponse'])
        # Modèle principal puis modèle de secours, tous deux au quota ; ensuite en pause : plus d'appel.
        self.assertEqual(post.call_count, 2)
        self.assertFalse(gemini_service.disponible())

    def test_merci_reste_instantane_sans_gemini(self):
        with mock.patch('services.gemini_service.httpx.post') as post:
            chatbot.repondre('merci beaucoup')
        post.assert_not_called()

    def test_outil_fiche_donne_les_contacts(self):
        fiche = agent.fiche_etablissement('UGB')
        self.assertEqual(fiche['telephone'], '+221 33 961 19 06')
        self.assertEqual(fiche['site_officiel'], 'https://www.ugb.sn')

    def test_outil_etablissements_par_ville(self):
        r = agent.chercher_etablissements(ville='Saint-Louis')
        self.assertEqual(r['total'], 1)


class SansCleGeminiTests(TestCase):
    def test_sans_cle_le_chatbot_local_repond(self):
        with mock.patch('services.gemini_service.httpx.post') as post:
            r = chatbot.repondre('Bonjour, où étudier le droit ?')
        post.assert_not_called()
        self.assertTrue(r['reponse'])
