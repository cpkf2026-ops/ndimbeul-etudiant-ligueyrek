"""Module 2 — veille des opportunités (Tavily et Ollama mockés) et endpoint de lecture."""
import json
from datetime import date, timedelta
from pathlib import Path
from unittest import mock

from django.conf import settings
from django.core.cache import cache as cache_django
from django.test import TestCase
from django.utils import timezone

from services import llm_service, tavily_service, texte
from services.models import CreditTavily
from veille import commun, opportunites
from veille.models import OffreEmploi
from veille.tasks import veille_opportunites

JETON = {'HTTP_X_SERVICE_TOKEN': 'jeton-de-test'}

RESULTATS_TAVILY = {'results': [
    {'title': 'Stage Développeur Web - Sonatel', 'url': 'https://www.senjob.com/offre/123?utm_source=x',
     'content': "Sonatel recrute un stagiaire développeur web à Dakar, niveau Licence. "
                "Date limite de dépôt : 30 novembre 2026.", 'score': 0.9},
    {'title': 'Bourse Campus France 2027', 'url': 'https://www.campusfrance.org/fr/bourse-2027',
     'content': "Appel à candidatures : bourses d'études pour étudiants sénégalais en master.", 'score': 0.8},
    {'title': 'Senjob : Accueil | portail officiel', 'url': 'https://senjob.com/',
     'content': 'Toutes les offres.', 'score': 0.5},
]}

FICHE_STAGE = {
    'pertinent': True, 'titre': 'Stage Développeur Web', 'organisme': 'Sonatel', 'categorie': 'stage',
    'lieu': 'Dakar', 'date_limite': '2026-11-30', 'domaine': 'Informatique',
    'niveau_requis': 'Licence', 'resume': 'Sonatel propose un stage de développeur web à Dakar.',
}
FICHE_BOURSE = {
    'pertinent': True, 'titre': 'Bourse Campus France 2027', 'organisme': 'Campus France',
    'categorie': 'bourse', 'lieu': 'Paris', 'date_limite': '2026-12-15', 'domaine': None,
    'niveau_requis': 'Master', 'resume': 'Bourses de master pour étudiants sénégalais.',
}


def _ollama_selon_titre(messages, **kwargs):
    """Faux Mistral : renvoie la fiche correspondant à la page envoyée."""
    page = messages[-1]['content']
    return json.dumps(FICHE_STAGE if 'Sonatel' in page else FICHE_BOURSE)


class VeilleOpportunitesTests(TestCase):
    def setUp(self):
        cache_django.clear()
        for fichier in Path(settings.VEILLE_ETAT_DIR).glob('dernier_passage_*'):
            fichier.unlink()
        patch_tavily = mock.patch.object(tavily_service, '_get_client')
        self.tavily = patch_tavily.start().return_value
        self.tavily.search.return_value = RESULTATS_TAVILY
        patch_llm = mock.patch.object(llm_service, 'generer', side_effect=_ollama_selon_titre)
        self.llm = patch_llm.start()
        patch_date = mock.patch('django.utils.timezone.localdate', return_value=date(2026, 10, 18))
        patch_date.start()
        mock.patch('veille.commun.precharger_modele_veille').start()
        self.addCleanup(mock.patch.stopall)

    def test_un_passage_cree_les_offres_avec_une_seule_requete_tavily(self):
        stats = opportunites.veille_opportunites()

        self.assertEqual(stats['creees'], 2)
        self.assertEqual(stats['titre_generique'], 1)   # page d'accueil écartée avant le LLM
        self.assertEqual(self.tavily.search.call_count, 1)
        self.assertEqual(self.llm.call_count, 2)
        parametres = self.tavily.search.call_args.kwargs
        self.assertEqual(parametres['max_results'], 10)
        self.assertEqual(parametres['time_range'], 'week')
        self.assertIn('senjob.com', parametres['include_domains'])
        self.assertEqual(CreditTavily.objects.get().credits_veille, 1)

        stage = OffreEmploi.objects.get(type='stage')
        self.assertEqual(stage.intitule, 'Stage Développeur Web')
        self.assertEqual(stage.entreprise, 'Sonatel')
        self.assertEqual(stage.region, 'Dakar')
        self.assertEqual(stage.date_limite, date(2026, 11, 30))
        self.assertEqual(stage.statut, 'active')
        self.assertIsNotNone(stage.date_collecte)
        self.assertEqual(
            stage.hash_dedoublonnage,
            commun.hash_dedoublonnage('https://senjob.com/offre/123', 'stage développeur web sonatel'),
        )

    def test_anti_invention_lieu_et_date_absents_du_texte(self):
        opportunites.veille_opportunites()

        bourse = OffreEmploi.objects.get(type='bourse')
        self.assertEqual(bourse.region, opportunites.NON_PRECISEE)  # « Paris » n'est pas dans la page
        self.assertIsNone(bourse.date_limite)                       # date absente du texte
        self.assertEqual(bourse.domaine, opportunites.NON_PRECISE)

    def test_second_passage_aucun_doublon_et_aucun_appel_llm(self):
        opportunites.veille_opportunites()
        self.llm.reset_mock()

        # Passage suivant forcé : sinon le verrou des 2 h l'ignorerait (voir commun.reserver_passage).
        stats = opportunites.veille_opportunites(force=True)

        self.assertEqual(stats['creees'], 0)
        self.assertEqual(stats['doublon'], 2)
        self.llm.assert_not_called()
        self.assertEqual(OffreEmploi.objects.count(), 2)

    def test_offre_non_pertinente_ou_date_limite_passee_rejetee(self):
        self.llm.side_effect = [
            json.dumps({**FICHE_STAGE, 'date_limite': '2026-09-30',
                        }),
            json.dumps({'pertinent': False}),
        ]
        self.tavily.search.return_value = {'results': [
            {**RESULTATS_TAVILY['results'][0], 'content': 'Sonatel, Dakar : candidatures avant le 30 septembre 2026.'},
            RESULTATS_TAVILY['results'][1],
        ]}

        stats = opportunites.veille_opportunites()

        self.assertEqual((stats['expiree'], stats['non_pertinent'], stats['creees']), (1, 1, 0))

    def test_offre_rejetee_par_le_llm_n_est_pas_retraitee(self):
        self.llm.side_effect = lambda messages, **kw: json.dumps({'pertinent': False})
        opportunites.veille_opportunites()
        self.llm.reset_mock()

        # Passage suivant forcé : sinon le verrou des 2 h l'ignorerait (voir commun.reserver_passage).
        stats = opportunites.veille_opportunites(force=True)

        self.assertEqual(stats['deja_rejete'], 2)
        self.llm.assert_not_called()

    def test_ollama_arrete_interrompt_sans_rien_enregistrer(self):
        self.llm.side_effect = llm_service.LLMIndisponibleError('Ollama arrêté')

        stats = opportunites.veille_opportunites()

        self.assertEqual(stats['llm_indisponible'], 1)
        self.assertEqual(self.llm.call_count, 1)
        self.assertFalse(OffreEmploi.objects.exists())

    @mock.patch('veille.pipeline.veiller_offres', return_value={'creees': 3})
    def test_quota_epuise_repli_sur_sources_gratuites_toutes_les_6h(self, veiller_offres):
        CreditTavily.objects.create(jour=date(2026, 10, 18), credits_veille=800)

        stats = opportunites.veille_opportunites()
        self.assertEqual(stats['mode'], 'repli_sources_gratuites')
        self.assertEqual(stats['creees'], 3)
        self.tavily.search.assert_not_called()

        # Tic de Beat suivant (2 h plus tard) : en mode réduit, la tâche ne fait rien.
        self.assertEqual(opportunites.veille_opportunites()['mode'], 'ignore')
        self.assertEqual(veiller_offres.call_count, 1)

    @mock.patch('veille.pipeline.veiller_offres', return_value={'creees': 0})
    def test_tavily_en_panne_repli(self, veiller_offres):
        self.tavily.search.side_effect = ConnectionError('réseau')
        self.assertEqual(opportunites.veille_opportunites()['mode'], 'repli_sources_gratuites')
        veiller_offres.assert_called_once()

    def test_tache_celery(self):
        self.assertEqual(veille_opportunites.delay().get()['creees'], 2)


class ExpirationTests(TestCase):
    def _offre(self, **champs):
        valeurs = {
            'intitule': 'Offre', 'entreprise': 'X', 'type': 'emploi', 'source_url': f'https://a.sn/{len(champs)}',
            'fiabilite': 'plateforme', 'statut': 'active', 'date_indexation': timezone.now(),
            'date_collecte': timezone.now(), 'date_publication': timezone.localdate(),
        }
        valeurs.update(champs)
        return OffreEmploi.objects.create(**valeurs)

    def test_offres_expirees(self):
        hier = timezone.localdate() - timedelta(days=1)
        depassee = self._offre(source_url='https://a.sn/1', date_limite=hier)
        ancienne_sans_date = self._offre(
            source_url='https://a.sn/2', date_publication=None,
            date_collecte=timezone.now() - timedelta(days=31),
        )
        valide = self._offre(source_url='https://a.sn/3', date_limite=hier + timedelta(days=10))

        self.assertEqual(opportunites.expirer_opportunites(), 2)
        statuts = dict(OffreEmploi.objects.values_list('id', 'statut'))
        self.assertEqual(statuts[depassee.id], 'expiree')
        self.assertEqual(statuts[ancienne_sans_date.id], 'expiree')
        self.assertEqual(statuts[valide.id], 'active')


class OpportunitesApiTests(TestCase):
    def setUp(self):
        maintenant = timezone.now()
        for i, (type_offre, statut) in enumerate([('stage', 'active'), ('stage', 'active'),
                                                  ('emploi', 'active'), ('stage', 'expiree')]):
            OffreEmploi.objects.create(
                intitule=f'Offre {i}', entreprise='Org', type=type_offre, region='Dakar',
                source_url=f'https://senjob.com/{i}', statut=statut, resume=f'Résumé {i}',
                date_indexation=maintenant, date_collecte=maintenant - timedelta(hours=i),
            )

    def test_filtre_par_categorie_et_exclut_les_expirees(self):
        reponse = self.client.get('/api/ia/opportunites/?categorie=stage&page=1', **JETON)

        self.assertEqual(reponse.status_code, 200)
        corps = reponse.json()
        self.assertEqual(corps['total'], 2)
        self.assertEqual(corps['page'], 1)
        self.assertEqual([o['titre'] for o in corps['resultats']], ['Offre 0', 'Offre 1'])
        self.assertEqual(
            set(corps['resultats'][0]),
            {'id', 'titre', 'organisme', 'categorie', 'lieu', 'domaine', 'niveau_requis', 'date_limite',
             'resume', 'url_source', 'source', 'fiabilite', 'date_publication', 'date_collecte'},
        )

    def test_pagination(self):
        corps = self.client.get('/api/ia/opportunites/?par_page=2&page=2', **JETON).json()
        self.assertEqual((corps['total'], corps['nb_pages'], len(corps['resultats'])), (3, 2, 1))

    def test_categorie_inconnue_400(self):
        reponse = self.client.get('/api/ia/opportunites/?categorie=vacances', **JETON)
        self.assertEqual(reponse.status_code, 400)
        self.assertIn('categorie', reponse.json()['details'])

    def test_jeton_obligatoire(self):
        self.assertEqual(self.client.get('/api/ia/opportunites/').status_code, 401)


class OutilsExtractionTests(TestCase):
    AUJOURD_HUI = date(2026, 10, 18)

    def test_date_limite_par_regles(self):
        cas = {
            'Envoyez votre CV avant le 15 novembre 2026.': date(2026, 11, 15),
            "Date limite de dépôt : 1er décembre 2026": date(2026, 12, 1),
            "Candidatures jusqu'au samedi 5 janvier": date(2027, 1, 5),  # prochaine occurrence
            'Clôture des inscriptions : 20/11/2026': date(2026, 11, 20),
            'Publié le 15 octobre 2026, poste à Dakar.': None,         # date de publication ≠ limite
            'Avant le 31 février 2027': None,
        }
        for texte, attendu in cas.items():
            with self.subTest(texte=texte):
                self.assertEqual(opportunites.date_limite_dans_texte(texte, self.AUJOURD_HUI), attendu)

    def test_nettoyer_titre(self):
        self.assertEqual(
            opportunites.nettoyer_titre('Avis de recrutement : stagiaire comptable'), 'Stagiaire comptable',
        )
        self.assertEqual(opportunites.nettoyer_titre('Concours ENA 2026'), 'Concours ENA 2026')

    def test_resume_limite_a_deux_phrases(self):
        phrases = 'Première phrase. Deuxième phrase ! Troisième phrase.'
        self.assertEqual(texte.resume_court(phrases, max_phrases=2), 'Première phrase. Deuxième phrase !')

    def test_chiffres_inventes(self):
        source = 'Plus de 4 200 jeunes formés à Saint-Louis en 2026.'
        self.assertEqual(texte.chiffres_inventes('4200 jeunes formés en 2026.', source), set())
        self.assertEqual(texte.chiffres_inventes('3000 bourses en 2026.', source), {'3000'})

    def test_date_oubliee_par_le_modele_retrouvee(self):
        resultat = {'titre': 'Stage comptable', 'url': 'https://senjob.com/1',
                    'contenu': 'Banque Atlantique, Dakar. Envoyez CV avant le 15 novembre 2026.'}
        fiche = {'pertinent': True, 'titre': 'Stage comptable', 'categorie': 'stage'}
        champs, motif, avertissements = opportunites.valider_fiche(resultat, fiche, self.AUJOURD_HUI)
        self.assertIsNone(motif)
        self.assertEqual(champs['date_limite'], date(2026, 11, 15))
        self.assertIn('date_limite_par_regles', avertissements)


class ExtraitPertinentTests(TestCase):
    def test_garde_les_phrases_qui_repondent_a_la_question(self):
        source = ("L'université a été fondée en 1957. Elle compte plusieurs facultés. "
                  "Les inscriptions au concours de l'ENA ouvrent le 3 novembre. Le campus est vaste.")
        extrait = texte.extrait_pertinent(source, ['inscriptions', 'concours', 'ena'], 90)
        self.assertEqual(extrait, "Les inscriptions au concours de l'ENA ouvrent le 3 novembre.")

    def test_texte_court_inchange(self):
        self.assertEqual(texte.extrait_pertinent('Court.', ['x'], 100), 'Court.')


class MoisInventesTests(TestCase):
    def test_mois_absent_de_la_source_detecte(self):
        source = "Les inscriptions au concours de l'ENA sont ouvertes."
        self.assertEqual(texte.chiffres_inventes('Inscriptions généralement en janvier et février.', source),
                         {'janvier', 'fevrier'})
        self.assertEqual(texte.chiffres_inventes('Clôture le 3 novembre.', 'Date limite : 3 novembre.'), set())


class ReglesQualiteOffresTests(TestCase):
    AUJOURD_HUI = date(2026, 10, 18)

    def test_page_sans_possibilite_de_postuler_rejetee(self):
        resultat = {'titre': 'Direction des Bourses | MESRI SÉNÉGAL', 'url': 'https://mesrisenegal.sn/bourses',
                    'contenu': "La Direction des Bourses gère les bourses d'études des étudiants."}
        fiche = {'pertinent': True, 'titre': 'Direction des Bourses', 'categorie': 'bourse'}
        self.assertEqual(opportunites.valider_fiche(resultat, fiche, self.AUJOURD_HUI)[1], 'pas_de_candidature')

    def test_vraie_annonce_acceptee(self):
        resultat = {'titre': 'Sonatel recrute un stagiaire', 'url': 'https://senjob.com/1',
                    'contenu': 'Envoyez votre CV avant le 15 novembre 2026.'}
        fiche = {'pertinent': True, 'titre': 'Stagiaire', 'categorie': 'stage'}
        self.assertIsNone(opportunites.valider_fiche(resultat, fiche, self.AUJOURD_HUI)[1])


class DoublonsEtPagesDeListeTests(TestCase):
    """Cas réels du passage « offre de stage Sénégal » (18/10/2026)."""
    AUJOURD_HUI = date(2026, 10, 18)

    def test_page_de_liste_rejetee(self):
        resultat = {'titre': 'Senjob', 'url': 'https://senjob.com/sn/offres', 'contenu': 'Tous les jobs et stages, postulez.'}
        fiche = {'pertinent': True, 'titre': "Recrutement et offres d'emploi", 'categorie': 'emploi'}
        self.assertEqual(opportunites.valider_fiche(resultat, fiche, self.AUJOURD_HUI)[1], 'page_de_liste')

    def test_meme_annonce_a_deux_adresses(self):
        OffreEmploi.objects.create(
            intitule='Stagiaire Achats', entreprise='X', type='stage', source_url='https://senjob.com/a',
            resume='We are hiring! | offres de stage Lieu : VDN', statut='active', date_indexation=timezone.now(),
        )
        self.assertTrue(opportunites._meme_annonce_deja_publiee(
            {'intitule': 'stagiaire achats', 'resume': 'We are hiring! offres de stage Lieu : VDN'}))
        self.assertFalse(opportunites._meme_annonce_deja_publiee(
            {'intitule': 'Stagiaire Achats', 'resume': 'Une autre entreprise recrute.'}))


class VerrouDesDeuxHeuresTests(TestCase):
    """Celery Beat et la tâche Windows peuvent déclencher la veille : jamais deux fois en 2 h."""

    def setUp(self):
        for fichier in Path(settings.VEILLE_ETAT_DIR).glob('dernier_passage_*'):
            fichier.unlink()

    def test_second_declenchement_ignore_puis_autorise_apres_2h(self):
        self.assertTrue(commun.reserver_passage('test'))
        self.assertFalse(commun.reserver_passage('test'))          # autre déclencheur, 1 s après
        with mock.patch('veille.commun.time.time', return_value=commun.time.time() + 2 * 3600):
            self.assertTrue(commun.reserver_passage('test'))       # 2 h plus tard

    def test_commande_manuelle_passe_toujours(self):
        self.assertTrue(commun.reserver_passage('test'))
        self.assertTrue(commun.reserver_passage('test', force=True))
