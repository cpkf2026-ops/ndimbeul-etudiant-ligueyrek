"""Client Tavily (mocké) : paramètres envoyés, normalisation, crédits, erreurs."""
from unittest import mock

from django.test import TestCase, override_settings
from django.utils import timezone
from tavily.errors import UsageLimitExceededError

from services import tavily_service
from services.models import CreditTavily

REPONSE_TAVILY = {
    'results': [
        {'title': ' Concours ENA 2026 ', 'url': 'https://www.aps.sn/concours-ena',
         'content': 'Les inscriptions sont ouvertes…', 'score': 0.91,
         'published_date': 'Sat, 17 Oct 2026 10:00:00 GMT'},
        {'title': 'Sans URL', 'url': '', 'content': 'ignoré'},
    ],
}


class TavilyServiceTests(TestCase):
    def setUp(self):
        patcher = mock.patch.object(tavily_service, '_get_client')
        self.client_tavily = patcher.start().return_value
        self.addCleanup(patcher.stop)

    def test_recherche_normalise_et_compte_un_credit(self):
        self.client_tavily.search.return_value = REPONSE_TAVILY

        resultats = tavily_service.rechercher(
            'concours Sénégal', module='opportunites', topic='news', time_range='day',
            include_domains=['aps.sn'], max_results=10,
        )

        self.assertEqual(resultats, [{
            'titre': 'Concours ENA 2026', 'url': 'https://www.aps.sn/concours-ena',
            'contenu': 'Les inscriptions sont ouvertes…', 'score': 0.91,
            'date_publication': 'Sat, 17 Oct 2026 10:00:00 GMT',
        }])
        parametres = self.client_tavily.search.call_args.kwargs
        self.assertEqual(parametres['search_depth'], 'basic')
        self.assertEqual(parametres['timeout'], 8)
        self.assertEqual(parametres['include_domains'], ['aps.sn'])
        self.assertNotIn('country', parametres)  # réservé au topic "general"

        ligne = CreditTavily.objects.get(jour=timezone.localdate())
        self.assertEqual((ligne.credits_veille, ligne.credits_interactif), (1, 0))

    def test_le_chat_est_compte_en_interactif(self):
        self.client_tavily.search.return_value = {'results': []}
        tavily_service.rechercher('bourses UCAD', module='chat')

        self.assertEqual(self.client_tavily.search.call_args.kwargs['country'], 'senegal')
        self.assertEqual(CreditTavily.objects.get().credits_interactif, 1)

    def test_quota_atteint_aucun_appel_tavily(self):
        CreditTavily.objects.create(jour=timezone.localdate(), credits_veille=800)

        with self.assertRaises(tavily_service.QuotaTavilyAtteintError):
            tavily_service.rechercher('offres', module='opportunites')
        self.client_tavily.search.assert_not_called()

    def test_erreur_reseau_leve_indisponible_sans_compter_de_credit(self):
        self.client_tavily.search.side_effect = TimeoutError('8 s dépassées')

        with self.assertRaises(tavily_service.TavilyIndisponibleError):
            tavily_service.rechercher('bac 2026', module='chat')
        self.assertFalse(CreditTavily.objects.exists())

    def test_quota_epuise_cote_tavily(self):
        self.client_tavily.search.side_effect = UsageLimitExceededError('limit')

        with self.assertRaises(tavily_service.QuotaTavilyAtteintError):
            tavily_service.rechercher('bac 2026', module='chat')

    @override_settings(TAVILY_API_KEY='')
    def test_cle_absente(self):
        with self.assertRaises(tavily_service.TavilyIndisponibleError):
            tavily_service.rechercher('bac 2026', module='chat')
        self.client_tavily.search.assert_not_called()
