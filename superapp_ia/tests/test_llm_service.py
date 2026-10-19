"""Client Ollama (mocké) : corps de requête, JSON, délais dépassés, Ollama arrêté."""
from unittest import mock

import httpx
from django.test import SimpleTestCase

from services import llm_service


def _reponse_ollama(contenu, eval_count=42):
    reponse = mock.Mock()
    reponse.json.return_value = {'message': {'content': contenu}, 'eval_count': eval_count}
    reponse.raise_for_status.return_value = None
    return reponse


class LLMServiceTests(SimpleTestCase):
    def setUp(self):
        patcher = mock.patch.object(llm_service, 'get_client')
        self.client_http = patcher.start().return_value
        self.addCleanup(patcher.stop)

    def test_generer_envoie_les_options_et_renvoie_le_texte(self):
        self.client_http.post.return_value = _reponse_ollama('  Bonjour !  ')

        texte = llm_service.generer(
            [{'role': 'user', 'content': 'Salut'}], modele='mistral:7b-instruct', num_predict=300,
        )

        self.assertEqual(texte, 'Bonjour !')
        corps = self.client_http.post.call_args.kwargs['json']
        self.assertEqual(corps['model'], 'mistral:7b-instruct')
        self.assertFalse(corps['stream'])
        self.assertFalse(corps['think'])
        self.assertEqual(corps['options']['num_predict'], 300)
        self.assertNotIn('format', corps)

    def test_generer_json_tolere_un_bloc_markdown(self):
        self.client_http.post.return_value = _reponse_ollama('```json\n{"titre": "Stage DevOps"}\n```')

        donnees = llm_service.generer_json([], modele='mistral:7b-instruct')

        self.assertEqual(donnees, {'titre': 'Stage DevOps'})
        self.assertEqual(self.client_http.post.call_args.kwargs['json']['format'], 'json')

    def test_extraire_json_texte_autour(self):
        self.assertEqual(
            llm_service.extraire_json('Voici le résultat : [{"a": 1}] Bonne journée'), [{'a': 1}],
        )

    def test_json_inexploitable(self):
        self.client_http.post.return_value = _reponse_ollama('Désolé, je ne sais pas.')
        with self.assertRaises(llm_service.LLMReponseInvalideError):
            llm_service.generer_json([], modele='m')

    def test_delai_depasse(self):
        self.client_http.post.side_effect = httpx.ReadTimeout('trop long')
        with self.assertRaises(llm_service.LLMTimeoutError):
            llm_service.generer([], modele='m', timeout=10)

    def test_ollama_arrete(self):
        self.client_http.post.side_effect = httpx.ConnectError('connexion refusée')
        with self.assertRaises(llm_service.LLMIndisponibleError) as contexte:
            llm_service.generer([], modele='mistral:7b-instruct')
        self.assertNotIsInstance(contexte.exception, llm_service.LLMTimeoutError)
        self.assertIn('ollama serve', str(contexte.exception))
