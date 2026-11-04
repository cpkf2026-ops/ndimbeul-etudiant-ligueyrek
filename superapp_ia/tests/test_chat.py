"""Module 4 — chatbot (Tavily, Ollama et FAISS mockés) et endpoint POST /api/ia/chat/."""
import json
import uuid
from decimal import Decimal
from unittest import mock

from django.core.cache import cache as cache_django
from django.test import SimpleTestCase, TestCase

from ia import chatbot, intentions
from ia.models import ConversationIA
from recommandations.models import Formation
from services import llm_service, tavily_service
from services.models import CreditTavily
from veille.models import Universite

JETON = {'HTTP_X_SERVICE_TOKEN': 'jeton-de-test'}
QUESTION_UCAD = "Quelles sont les conditions pour la licence informatique à l'UCAD ?"


def _flux(*morceaux, erreur=None):
    """Faux streaming Ollama : produit les morceaux puis lève éventuellement une erreur."""
    def generateur(*args, **kwargs):
        yield from morceaux
        if erreur:
            raise erreur
    return generateur


class IntentionsTests(SimpleTestCase):
    def test_detection(self):
        cas = {
            'Salut !': intentions.SALUTATION,
            'bonjour à toi': intentions.SALUTATION,
            'Nanga def ?': intentions.SALUTATION,
            'merci beaucoup': intentions.REMERCIEMENT,
            'Jërëjëf': intentions.REMERCIEMENT,
            'au revoir': intentions.AU_REVOIR,
            'Bonjour, quelles sont les bourses pour la licence ?': intentions.QUESTION,
            'bonjours': intentions.SALUTATION,                 # fautes de frappe réelles
            'Saluuut !': intentions.SALUTATION,
            'merciii': intentions.REMERCIEMENT,
            'aide moi': intentions.AIDE,
            'Aide-moi stp': intentions.AIDE,
            "tu peux m'aider ?": intentions.AIDE,
            'bonjour aide moi': intentions.AIDE,
            'aide moi à choisir une licence en informatique': intentions.QUESTION,
            'Qui a gagné le match de foot hier ?': intentions.HORS_SUJET,
            "Existe-t-il une formation d'entraîneur de foot ?": intentions.QUESTION,
            'Quelle est la date du bac ?': intentions.QUESTION,
        }
        for message, attendu in cas.items():
            with self.subTest(message=message):
                self.assertEqual(intentions.detecter(message), attendu)

    def test_reponse_en_wolof_a_nanga_def(self):
        self.assertIn('Maa ngi fi', intentions.reponse_rapide(intentions.SALUTATION, 'nanga def'))


class ChatbotTests(TestCase):
    def setUp(self):
        cache_django.clear()
        self.tavily = mock.patch.object(tavily_service, '_get_client').start().return_value
        self.tavily.search.return_value = {'results': []}
        self.flux = mock.patch.object(llm_service, 'generer_stream').start()
        self.flux.side_effect = _flux('La licence informatique de l’UCAD accepte les séries S1 et S2 [1].')
        mock.patch('ia.rag_pipeline.rechercher', return_value=[]).start()
        self.addCleanup(mock.patch.stopall)

        ucad = Universite.objects.create(nom='UCAD', code_unique='UCAD', type='public', region='Dakar',
                                         site_web_officiel='https://ucad.sn', statut_actif=True)
        for intitule in ('Licence Informatique', 'Master Informatique'):
            Formation.objects.create(
                id=str(uuid.uuid4()), universite_id=ucad.id, intitule=intitule, domaine='Informatique',
                niveau='licence', series_acceptees=['S1', 'S2'], moyenne_minimale=Decimal('12'),
            )

    def test_salutation_sans_recherche_ni_llm(self):
        resultat = chatbot.repondre('Bonjour !')

        self.assertEqual(resultat['intention'], intentions.SALUTATION)
        self.assertEqual(resultat['sources'], [])
        self.flux.assert_not_called()
        self.tavily.search.assert_not_called()

    def test_hors_sujet_recentre_poliment(self):
        resultat = chatbot.repondre('Donne-moi une recette de thieb')
        self.assertEqual(resultat['intention'], intentions.HORS_SUJET)
        self.assertIn('orientation', resultat['reponse'])
        self.flux.assert_not_called()

    def test_question_repondue_depuis_la_base_sans_tavily(self):
        resultat = chatbot.repondre(QUESTION_UCAD)

        self.assertIn('S1 et S2 [1]', resultat['reponse'])
        self.assertEqual(resultat['sources'][0]['url'], 'https://ucad.sn')
        self.assertFalse(resultat['recherche_web'])
        self.tavily.search.assert_not_called()
        self.assertGreaterEqual(resultat['temps_ms'], 0)
        prompt = self.flux.call_args.args[0][-1]['content']
        self.assertIn('Licence Informatique', prompt)
        self.assertEqual(self.flux.call_args.kwargs['num_predict'], 100)

    def test_tavily_quand_la_base_ne_suffit_pas(self):
        self.tavily.search.return_value = {'results': [{
            'title': 'Calendrier universitaire UGB 2026-2027', 'url': 'https://www.ugb.sn/calendrier',
            'content': 'La rentrée universitaire à l’UGB est fixée au 3 novembre.',
        }]}
        self.flux.side_effect = _flux('La rentrée à l’UGB est fixée au 3 novembre [1].')

        resultat = chatbot.repondre('Quand est la rentrée universitaire à Saint-Louis ?')

        self.assertTrue(resultat['recherche_web'])
        self.assertEqual(resultat['sources'], [{'titre': 'Calendrier universitaire UGB 2026-2027',
                                                'url': 'https://www.ugb.sn/calendrier'}])
        parametres = self.tavily.search.call_args.kwargs
        self.assertEqual((parametres['search_depth'], parametres['max_results']), ('basic', 5))
        self.assertLessEqual(parametres['timeout'], 8)
        self.assertIn('campusen.sn', parametres['include_domains'])
        self.assertEqual(CreditTavily.objects.get().credits_interactif, 1)

    def test_rien_trouve_reponse_honnete_avec_liens_officiels(self):
        resultat = chatbot.repondre('Quel est le montant de la bourse de mobilité au Canada ?')

        self.assertIn("Je n'ai rien trouvé de fiable sur « montant bourse mobilite canada »", resultat['reponse'])
        self.assertIn('https://mesrisenegal.sn', resultat['reponse'])  # thème « bourse »
        self.assertIn('information_introuvable', resultat['avertissements'])
        self.flux.assert_not_called()

    def test_liens_et_citations_inventes_supprimes(self):
        self.flux.side_effect = _flux('Voir https://faux-site.com et https://ucad.sn [1] [9].')
        reponse = chatbot.repondre(QUESTION_UCAD)['reponse']

        self.assertNotIn('faux-site', reponse)
        self.assertIn('https://ucad.sn', reponse)
        self.assertNotIn('[9]', reponse)

    def test_chiffre_invente_reponse_de_secours(self):
        self.flux.side_effect = _flux('Les frais sont de 250 000 FCFA par an [1].')
        resultat = chatbot.repondre(QUESTION_UCAD)

        self.assertNotIn('250', resultat['reponse'])
        # Secours : les phrases utiles de la source, citée [1] (le lien est dans `sources`).
        self.assertIn('moyenne minimale : 12.00/20. [1]', resultat['reponse'])
        self.assertEqual(resultat['sources'][0]['url'], 'https://ucad.sn')
        self.assertIn('chiffre_non_source', resultat['avertissements'])

    def test_delai_depasse_garde_les_phrases_completes(self):
        self.flux.side_effect = _flux(
            'La licence accepte les séries S1 et S2 [1].', ' Il faut aussi', erreur=llm_service.LLMTimeoutError('25 s'),
        )
        resultat = chatbot.repondre(QUESTION_UCAD)

        self.assertEqual(resultat['reponse'], 'La licence accepte les séries S1 et S2 [1].')
        self.assertIn('reponse_tronquee', resultat['avertissements'])

    def test_ollama_arrete_reponse_de_secours_avec_liens(self):
        self.flux.side_effect = _flux(erreur=llm_service.LLMIndisponibleError('Ollama arrêté'))
        resultat = chatbot.repondre(QUESTION_UCAD)

        self.assertIn("Voici ce que j'ai trouvé", resultat['reponse'])
        self.assertIn('séries acceptées : S1, S2', resultat['reponse'])

    def test_question_frequente_servie_par_le_cache(self):
        chatbot.repondre(QUESTION_UCAD)
        seconde = chatbot.repondre(QUESTION_UCAD.upper())

        self.assertTrue(seconde['depuis_cache'])
        self.assertEqual(self.flux.call_count, 1)

    def test_visiteur_historique_limite_aux_5_derniers_messages(self):
        historique = [{'role': 'user' if i % 2 == 0 else 'assistant', 'contenu': f'message {i}'} for i in range(8)]
        resultat = chatbot.repondre(QUESTION_UCAD, historique=historique)

        messages_llm = self.flux.call_args.args[0]
        self.assertEqual([m['content'] for m in messages_llm[1:-1]], [f'message {i}' for i in range(3, 8)])
        self.assertFalse(resultat['depuis_cache'])
        self.assertIsNone(resultat['conversation_id'])

    def test_utilisateur_connecte_conversation_enregistree(self):
        premier = chatbot.repondre('Salut', utilisateur_id='u-1')
        chatbot.repondre(QUESTION_UCAD, utilisateur_id='u-1', conversation_id=premier['conversation_id'])

        conversation = ConversationIA.objects.get(id=premier['conversation_id'])
        self.assertEqual([m['role'] for m in conversation.messages], ['user', 'assistant'] * 2)
        # La 2e question avait un historique : elle n'a pas été mise en cache.
        self.assertFalse(chatbot.repondre(QUESTION_UCAD)['depuis_cache'])


class ChatApiTests(TestCase):
    @mock.patch('ia.chatbot.repondre', return_value={'reponse': 'ok', 'sources': [], 'temps_ms': 12})
    def test_reponse_json(self, repondre):
        reponse = self.client.post('/api/ia/chat/', data={'message': '  Salut  '},
                                   content_type='application/json', **JETON)
        self.assertEqual(reponse.status_code, 200)
        self.assertEqual(reponse.json(), {'reponse': 'ok', 'sources': [], 'temps_ms': 12})
        self.assertEqual(repondre.call_args.kwargs['message'], 'Salut')

    def test_message_obligatoire(self):
        reponse = self.client.post('/api/ia/chat/', data={}, content_type='application/json', **JETON)
        self.assertEqual(reponse.status_code, 400)
        self.assertIn('message', reponse.json()['details'])

    def test_jeton_obligatoire(self):
        self.assertEqual(self.client.post('/api/ia/chat/', data={'message': 'x'}).status_code, 401)


class RechercheBaseTests(TestCase):
    def setUp(self):
        ucad = Universite.objects.create(nom='Université Cheikh Anta Diop', code_unique='UCAD', type='public',
                                         site_web_officiel='https://ucad.sn', statut_actif=True)
        campusen = Universite.objects.create(nom='Campusen', code_unique='C', type='public',
                                             site_web_officiel='https://campusen.sn', statut_actif=True)
        for universite, intitule in ((ucad, 'Licence Informatique'), (campusen, 'Licence Informatique'),
                                     (ucad, 'Intelligence artificielle')):
            Formation.objects.create(id=str(uuid.uuid4()), universite_id=universite.id, intitule=intitule,
                                     domaine='Informatique', niveau='licence')

    @mock.patch('ia.rag_pipeline.rechercher', return_value=[])
    def test_le_sigle_retrouve_la_bonne_fiche_en_premier(self, _faiss):
        documents = chatbot.chercher_dans_la_base("Conditions de la licence informatique à l'UCAD ?")
        self.assertEqual(documents[0]['titre'], 'Licence Informatique (Université Cheikh Anta Diop)')

    @mock.patch('ia.rag_pipeline.rechercher', return_value=[])
    def test_mots_generiques_ne_diluent_pas_la_pertinence(self, _faiss):
        documents = chatbot.chercher_dans_la_base('Quelles formations en intelligence artificielle existent ?')
        self.assertIn('Intelligence artificielle (Université Cheikh Anta Diop)', [d['titre'] for d in documents])

    def test_sigle_trop_court_ignore_pour_les_liens(self):
        self.assertNotIn('https://campusen.sn', chatbot.liens_officiels("c'est quoi l'UCAD")[:1])
        self.assertEqual(chatbot.liens_officiels("c'est quoi l'UCAD")[0], 'https://ucad.sn')


class PertinenceWebTests(TestCase):
    @mock.patch('ia.rag_pipeline.rechercher', return_value=[])
    @mock.patch.object(tavily_service, '_get_client')
    def test_resultat_web_hors_sujet_ecarte(self, client_tavily, _faiss):
        client_tavily.return_value.search.return_value = {'results': [
            {'title': 'Les élèves reprennent l’école après les inondations', 'url': 'https://france24.com/a',
             'content': 'Après une semaine d’inondations, les élèves ont repris les cours.'},
            {'title': 'Concours ENA : ouverture des inscriptions', 'url': 'https://fonctionpublique.gouv.sn/ena',
             'content': 'Les inscriptions au concours direct de l’ENA sont ouvertes.'},
        ]}
        documents = chatbot._chercher_sur_le_web(
            'Quand ont lieu les inscriptions au concours de l ENA ?', [], 10**12, [],
        )
        self.assertEqual([d['url'] for d in documents], ['https://fonctionpublique.gouv.sn/ena'])


class AllegementTests(TestCase):
    @mock.patch('ia.rag_pipeline.rechercher', side_effect=AssertionError('FAISS ne doit pas être appelé'))
    def test_le_chatbot_ne_charge_pas_faiss_ni_torch(self, _faiss):
        """FAISS charge torch (~1 Go de RAM) : il bloquait un PC de 10 Go (18/10/2026)."""
        self.assertEqual(chatbot.chercher_dans_la_base('Licence informatique UCAD'), [])

    def test_la_veille_des_universites_n_est_plus_planifiee(self):
        from django.conf import settings
        taches = {entree['task'] for entree in settings.CELERY_BEAT_SCHEDULE.values()}
        self.assertEqual(taches, {'veille.tasks.veille_actualites', 'veille.tasks.veille_opportunites'})


class DocumentsImportesTests(TestCase):
    def test_document_importe_retrouve_par_mots_cles_sans_torch(self):
        from ia import rag_local
        from ia.models import DocumentRAG, SourceDonnee

        source = SourceDonnee.objects.create(type='pdf', url_ou_chemin='guide.pdf', categorie='bourses')
        DocumentRAG.objects.create(
            source=source, titre='Guide des bourses UCAD',
            contenu_texte="Introduction générale. La bourse d'excellence UCAD est attribuée aux bacheliers "
                          "ayant obtenu une mention. Autres informations administratives.",
        )
        with mock.patch('ia.embeddings.get_model', side_effect=AssertionError('torch ne doit pas être chargé')):
            documents = rag_local.rechercher_documents("Comment obtenir la bourse d'excellence UCAD ?")
        self.assertEqual(documents[0]['titre'], 'Guide des bourses UCAD')
        self.assertIn("bourse d'excellence UCAD", documents[0]['texte'])


class ChatStreamingApplicationTests(TestCase):
    """POST /internal/chat : la route que l'application Flutter utilise (via Laravel)."""

    def _flux(self, corps):
        reponse = self.client.post('/internal/chat', data=corps, content_type='application/json', **JETON)
        return reponse.status_code, b''.join(reponse.streaming_content).decode('utf-8')

    def test_salutation_reponse_instantanee_au_format_sse(self):
        statut, flux = self._flux({'message': 'Bonjour'})
        self.assertEqual(statut, 200)
        evenements = [json.loads(ligne[5:]) for ligne in flux.splitlines() if ligne.startswith('data:')]
        self.assertIn(evenements[0]['token'], intentions._REPONSES[intentions.SALUTATION])
        self.assertTrue(evenements[-1]['done'])
        self.assertEqual(evenements[-1]['sources'], [])

    def test_questions_differentes_reponses_differentes(self):
        _, salut = self._flux({'message': 'salut'})
        _, merci = self._flux({'message': 'merci beaucoup'})
        _, hors_sujet = self._flux({'message': 'donne moi une recette de thieb'})
        self.assertEqual(len({salut, merci, hors_sujet}), 3)

    def test_historique_sans_le_flux_brut_enregistre_par_laravel(self):
        conversation = ConversationIA.objects.create(utilisateur_id='u-9', messages=[
            {'role': 'user', 'contenu': 'Quelles bourses ?'},
            {'role': 'assistant', 'contenu': 'data: {"token": "texte technique"}\n\ndata: {"done": true}'},
        ])
        with mock.patch.object(llm_service, 'generer_stream', side_effect=_flux('Réponse.')) as flux, \
                mock.patch('ia.chatbot.chercher_dans_la_base', return_value=[{'titre': 'Doc', 'texte': 'Bourses UCAD.', 'url': None}, {'titre': 'Doc2', 'texte': 'Bourses.', 'url': None}]):
            chatbot.repondre('Et pour la licence ?', conversation_id=str(conversation.id), utilisateur_id='u-9')
        contenus = [m['content'] for m in flux.call_args.args[0]]
        self.assertNotIn('texte technique', ' '.join(contenus))
        self.assertIn('Quelles bourses ?', contenus)


class ClassementEtNettoyageTests(SimpleTestCase):
    """Cas réels du test par l'application (18/10/2026)."""

    def test_forme_proche_du_mot_comptee(self):
        mots = chatbot._mots_importants('Y a-t-il des offres de stage en comptabilité ?')
        comptabilite = {'titre': 'Stage en Comptabilité et finance',
                        'texte': 'Une société offre des postes de stagiaire en comptabilité.'}
        achats = {'titre': 'Stagiaire Achats', 'texte': 'We are hiring! offres de stage, Dakar.'}
        self.assertGreater(chatbot._nb_mots_trouves(comptabilite, mots), chatbot._nb_mots_trouves(achats, mots))

    def test_faux_renvoi_lien_supprime(self):
        reponse = chatbot._nettoyer('Moyenne minimale de 12/20 [1]. Consulte le site officiel [lien].', [{'url': None}], [])
        self.assertEqual(reponse, 'Moyenne minimale de 12/20 [1]. Consulte le site officiel.')


class ComprehensionMessagesReelsTests(TestCase):
    """Messages réels envoyés depuis l'application le 18/10/2026."""

    def test_intentions(self):
        cas = {
            "merci c'est gentile": intentions.REMERCIEMENT,
            'merci, top !': intentions.REMERCIEMENT,
            "j'ai pas compris": intentions.PAS_COMPRIS,
            'je comprends pas': intentions.PAS_COMPRIS,
            'merci pour les infos sur la licence de droit ?': intentions.QUESTION,
        }
        for message, attendu in cas.items():
            with self.subTest(message=message):
                self.assertEqual(intentions.detecter(message), attendu)

    def test_lien_du_site_repondu_depuis_la_base(self):
        Universite.objects.create(nom='Université Gaston Berger de Saint-Louis (UGB)', code_unique='GBSLU',
                                  type='public', site_web_officiel='https://www.ugb.sn/', statut_actif=True)
        with mock.patch.object(tavily_service, '_get_client') as tavily, \
                mock.patch.object(llm_service, 'generer_stream') as llm:
            resultat = chatbot.repondre("c'est quoi le lien du site de l'UGB ?")
        self.assertIn('https://www.ugb.sn/', resultat['reponse'])
        tavily.assert_not_called()
        llm.assert_not_called()

    def test_introuvable_reprend_les_mots_de_la_question(self):
        reponse = chatbot._introuvable('Quel est le montant de la bourse au Canada ?', ['https://campusen.sn'])
        self.assertIn('« montant bourse canada »', reponse)


class ReponsesInstantaneesDepuisLaBaseTests(TestCase):
    """Questions de tous les jours : réponse exacte depuis la base, sans LLM ni Tavily."""

    def setUp(self):
        from django.utils import timezone
        from veille.models import Actualite, OffreEmploi
        maintenant = timezone.now()
        Actualite.objects.create(titre='Réforme du baccalauréat', contenu='…', categorie='general',
                                 statut='publie', source_nom='lesoleil.sn', source_url='https://lesoleil.sn/bac',
                                 date_publication=maintenant)
        Actualite.objects.create(titre='Bourses de mobilité 2027', contenu='…', categorie='bourse',
                                 statut='publie', source_url='https://aps.sn/bourses', date_publication=maintenant)
        for intitule, type_offre in (('Stagiaire comptable', 'stage'), ('Stagiaire achats', 'stage'),
                                     ('Développeur web', 'emploi')):
            OffreEmploi.objects.create(intitule=intitule, entreprise='X', type=type_offre, region='Dakar',
                                       source_url=f'https://senjob.com/{intitule}', statut='active',
                                       date_indexation=maintenant, date_collecte=maintenant)
        Universite.objects.create(nom='Université Iba Der Thiam de Thiès', code_unique='UIDT', type='public',
                                  region='Thiès', statut_actif=True)
        Universite.objects.create(nom='ISM Dakar', code_unique='ISM', type='prive', region='Dakar', statut_actif=True)

    def _repondre(self, question):
        with mock.patch.object(tavily_service, '_get_client') as tavily, \
                mock.patch.object(llm_service, 'generer_stream') as llm:
            resultat = chatbot.repondre(question)
        tavily.assert_not_called()
        llm.assert_not_called()
        return resultat

    def test_dernieres_actualites(self):
        resultat = self._repondre('Quelles sont les dernières actualités ?')
        self.assertIn('Réforme du baccalauréat (lesoleil.sn', resultat['reponse'])
        self.assertIn('https://lesoleil.sn/bac', [s['url'] for s in resultat['sources']])

    def test_actualites_filtrees_par_categorie(self):
        resultat = self._repondre('quoi de neuf sur les bourses ?')
        self.assertIn('Bourses de mobilité 2027', resultat['reponse'])
        self.assertNotIn('Réforme du baccalauréat', resultat['reponse'])

    def test_offres_de_stage_filtrees_par_domaine(self):
        resultat = self._repondre('Y a-t-il des offres de stage en comptabilité ?')
        self.assertIn('Stagiaire comptable', resultat['reponse'])
        self.assertNotIn('achats', resultat['reponse'])
        self.assertNotIn('Développeur', resultat['reponse'])

    def test_etablissements_par_ville_et_statut(self):
        self.assertIn('Iba Der Thiam', self._repondre('Quelles universités à Thiès ?')['reponse'])
        resultat = self._repondre('liste des écoles privées à Dakar')
        self.assertIn('ISM Dakar', resultat['reponse'])
        self.assertNotIn('Thiam', resultat['reponse'])

    def test_question_d_explication_laissee_a_la_recherche_complete(self):
        from ia import reponses_base
        self.assertIsNone(reponses_base.repondre("Comment préparer le concours de l'ENA ?"))


class BaseSuffisanteTests(SimpleTestCase):
    def test_fiche_qui_ne_couvre_que_le_nom_de_l_etablissement_insuffisante(self):
        mots = chatbot._mots_importants("Quand a lieu la rentrée universitaire 2026 à l'UGB ?")
        fiche_ugb = {'titre': 'Université Gaston Berger (UGB)', 'texte': 'UGB — établissement public, Saint-Louis.'}
        self.assertFalse(chatbot._base_suffisante([fiche_ugb], mots))

    def test_fiche_qui_couvre_la_question_suffisante(self):
        mots = chatbot._mots_importants("Conditions pour la licence informatique à l'UCAD ?")
        fiche = {'titre': 'Licence Informatique (UCAD)', 'texte': 'Licence Informatique — à UCAD. Séries S1, S2.'}
        self.assertTrue(chatbot._base_suffisante([fiche], mots))


class LogiqueDesReponsesTests(TestCase):
    """Cas réels relevés le 21/10/2026 : le chatbot répondait, mais pas à la question posée."""

    def setUp(self):
        cache_django.clear()
        self.uadb = Universite.objects.create(
            nom='Université Alioune Diop de Bambey', code_unique='UADB', type='public', region='Diourbel',
            commune='Bambey', site_web_officiel='https://www.uadb.edu.sn', statut_actif=True)
        Universite.objects.create(nom='Dakar Institute of Technology (DIT)', code_unique='DIOTD', type='prive',
                                  region='Dakar', site_web_officiel='https://dit.sn', statut_actif=True)

    def test_le_verbe_dit_n_est_pas_le_sigle_dit(self):
        r = chatbot._site_demande("j'ai dit je veux le lien du site de l'université de Bambey")
        self.assertIn('Alioune Diop de Bambey', r['reponse'])
        self.assertIn('uadb.edu.sn', r['reponse'])

    def test_cette_universite_reprend_l_etablissement_de_la_conversation(self):
        historique = [
            {'role': 'user', 'contenu': 'Quelles filières avec un bac S2 ?'},
            {'role': 'assistant', 'contenu': 'Voici…', 'sources': [{'titre': self.uadb.nom, 'url': None}]},
        ]
        r = chatbot._site_demande('le lien du site de cet université', historique)
        self.assertIn('uadb.edu.sn', r['reponse'])

    def test_etablissement_sans_site_reponse_honnete(self):
        Universite.objects.create(nom='Université Kocc Barma', code_unique='UKB', type='prive', statut_actif=True)
        r = chatbot._site_demande('le site de l université Kocc Barma')
        self.assertIn("pas de site officiel", r['reponse'])

    def test_filieres_par_serie_et_moyenne(self):
        Formation.objects.create(id=str(uuid.uuid4()), universite_id=self.uadb.id, intitule='Licence Agronomie', niveau='licence',
                                 series_acceptees=['S2'], moyenne_minimale=Decimal('11'))
        Formation.objects.create(id=str(uuid.uuid4()), universite_id=self.uadb.id, intitule='Licence Lettres', niveau='licence',
                                 series_acceptees=['L'], moyenne_minimale=Decimal('10'))
        Formation.objects.create(id=str(uuid.uuid4()), universite_id=self.uadb.id, intitule='Médecine', niveau='doctorat',
                                 series_acceptees=['S2'], moyenne_minimale=Decimal('15'))
        r = chatbot._formations_pour_bac('Quelles filières avec un bac S2 et 13 de moyenne ?', {})
        self.assertIn('Licence Agronomie', r['reponse'])
        self.assertNotIn('Licence Lettres', r['reponse'])   # série L seulement
        self.assertNotIn('Médecine', r['reponse'])          # 15 demandé, 13 obtenu

    def test_question_sans_serie_ni_moyenne_non_concernee(self):
        self.assertIsNone(chatbot._formations_pour_bac('Comment obtenir une bourse ?', {}))


class FiabiliteDesReponsesTests(TestCase):
    """Sujet sensible sans information vérifiée : on le dit et on donne les contacts."""

    def setUp(self):
        cache_django.clear()
        self.ugb = Universite.objects.create(
            nom='Université Gaston Berger de Saint-Louis (UGB)', code_unique='UGB', type='public',
            region='Saint-Louis', commune='Saint-Louis', telephone_contact='+221 33 961 23 56',
            email_contact='contact@ugb.edu.sn', statut_actif=True)
        Universite.objects.create(nom='Université Assane Seck de Ziguinchor (UASZ)', code_unique='UASZ',
                                  type='public', region='Ziguinchor', statut_actif=True)

    def test_frais_sans_info_verifiee_renvoi_vers_l_etablissement(self):
        r = chatbot._question_factuelle("Frais d'inscription à l'UGB ?", [], 10 ** 12, [])
        self.assertIn("pas d'information vérifiée", r['reponse'])
        self.assertIn('+221 33 961 23 56', r['reponse'])
        self.assertIn('contact@ugb.edu.sn', r['reponse'])
        self.assertNotIn('Ziguinchor', r['reponse'])

    def test_question_de_contact(self):
        r = chatbot._question_factuelle("Comment contacter l'UGB ?", [], 10 ** 12, [])
        self.assertIn('Coordonnées', r['reponse'])
        self.assertIn('contact@ugb.edu.sn', r['reponse'])

    def test_question_sans_etablissement_non_concernee(self):
        self.assertIsNone(chatbot._question_factuelle("Quels sont les frais d'inscription en général ?", [], 10 ** 12, []))


class EtablissementsParDomaineTests(TestCase):
    """« Où étudier X ? » : tous les établissements du domaine, pas toujours les mêmes."""

    def setUp(self):
        cache_django.clear()
        self.ecole_dakar = Universite.objects.create(nom='École de Journalisme de Dakar', code_unique='EJD1',
                                                     type='prive', region='Dakar', commune='Dakar', statut_actif=True,
                                                     domaines=['Journalisme et reportage'])
        self.ecole_thies = Universite.objects.create(nom='Institut Médias de Thiès', code_unique='IMT1',
                                                     type='public', region='Thiès', commune='Thiès', statut_actif=True,
                                                     domaines=['Communication', 'Techniques audiovisuelles'])
        self.autre = Universite.objects.create(nom='Grande Université de Dakar', code_unique='GUD1', type='public',
                                               region='Dakar', commune='Dakar', statut_actif=True,
                                               domaines=['Médecine'])

    def test_domaine_demande_et_variete(self):
        r = chatbot._etablissements_pour_un_domaine('Quelles écoles de journalisme au Sénégal ?')
        self.assertIn('École de Journalisme de Dakar', r['reponse'])
        self.assertIn('Institut Médias de Thiès', r['reponse'])
        self.assertNotIn('Grande Université de Dakar', r['reponse'])   # médecine : hors sujet

    def test_ville_et_statut_respectes(self):
        r = chatbot._etablissements_pour_un_domaine('Écoles de journalisme privées à Dakar')
        self.assertIn('École de Journalisme de Dakar', r['reponse'])
        self.assertNotIn('Thiès', r['reponse'])

    def test_question_sans_domaine_non_concernee(self):
        self.assertIsNone(chatbot._etablissements_pour_un_domaine('Bonjour, comment ça va ?'))


class ConversationReelle29OctobreTests(TestCase):
    """Conversation réelle du 29/10/2026 : merci, remarques et « est-ce fiable ? » partaient
    dans la recherche ; « pour » faisait croire à une question sur Iprosi."""

    def setUp(self):
        cache_django.clear()
        Universite.objects.create(
            nom='Institut Professionnel pour la Sécurité Informatique (Iprosi Dakar)', code_unique='IPROSI',
            region='Dakar', statut_actif=True)
        Universite.objects.create(
            nom='Université Gaston Berger de Saint-Louis (UGB)', code_unique='UGB', type='public',
            region='Saint-Louis', site_web_officiel='https://www.ugb.sn', statut_actif=True)

    def test_intentions_des_messages_de_la_conversation(self):
        cas = {
            'ok je vois merci pour votre reponse': intentions.REMERCIEMENT,
            "j'ais dit merci pour ta reponse precedent je n'est pas poser un autre question": intentions.REMERCIEMENT,
            'est ce que cet infos est fiable et vrais': intentions.FIABILITE,
            "bon je vois que y'as pas de concordence genre de logique au reponse que tu me donne": intentions.AVIS,
            "ont dirait que y'a des limites a tes reponses ?": intentions.AVIS,
            'merci, et pour les bourses ?': intentions.QUESTION,
            'Quelles sont les sources officielles pour les bourses ?': intentions.QUESTION,
            "limite d'âge pour la bourse ?": intentions.QUESTION,
        }
        for message, attendu in cas.items():
            with self.subTest(message=message):
                self.assertEqual(intentions.detecter(message), attendu)

    def test_pour_n_est_pas_un_mot_distinctif(self):
        from ia import etablissements_chat
        self.assertIsNone(etablissements_chat.trouver('ok je vois merci pour votre reponse'))
        self.assertIsNotNone(etablissements_chat.trouver("frais d'inscription chez Iprosi"))

    def test_est_ce_fiable_indique_la_source_de_la_reponse_precedente(self):
        historique = [
            {'role': 'user', 'contenu': "Frais d'inscription à l'UGB ?"},
            {'role': 'assistant', 'contenu': 'Inscription : 25.000 F',
             'sources': [{'titre': 'Certificat de Capacité en Droit | UGB', 'url': 'https://www.ugb.sn/fr/capacite'}]},
        ]
        r = chatbot.repondre('est ce que cet infos est fiable et vrais', historique=historique)
        self.assertEqual(r['intention'], intentions.FIABILITE)
        self.assertIn("site officiel de l'établissement", r['reponse'])
        self.assertIn('https://www.ugb.sn/fr/capacite', r['reponse'])

    def test_offres_dans_une_ville_sans_offre(self):
        from django.utils import timezone
        from veille.models import OffreEmploi
        OffreEmploi.objects.create(intitule='Comptable', entreprise='X', type='emploi', region='Dakar',
                                   source_url='https://senjob.com/c', statut='active',
                                   date_indexation=timezone.now(), date_collecte=timezone.now())
        r = chatbot.repondre('je veux savoir si ya des emploie disponible actuellement a thies')
        self.assertIn('Thiès', r['reponse'])
        self.assertIn('Comptable', r['reponse'])
