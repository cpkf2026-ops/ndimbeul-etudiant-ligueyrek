"""Module 3 — veille des actualités (Tavily, Ollama et lecture des pages mockés) et endpoint."""
import json
from datetime import datetime, timedelta
from pathlib import Path
from unittest import mock

from django.conf import settings
from django.core.cache import cache as cache_django
from django.test import TestCase
from django.utils import timezone

from services import llm_service, tavily_service
from services.models import CreditTavily
from veille import actualites, commun
from veille.models import Actualite
from veille.tasks import veille_actualites

JETON = {'HTTP_X_SERVICE_TOKEN': 'jeton-de-test'}


def _resultats_tavily():
    hier = (timezone.now() - timedelta(hours=5)).strftime('%a, %d %b %Y %H:%M:%S GMT')
    return {'results': [
        {'title': 'Bac 2026 : le taux de réussite national atteint 52 %', 'url': 'https://www.aps.sn/bac-2026-resultats',
         'content': "L'Office du Bac annonce un taux de réussite de 52 % pour la session 2026.",
         'published_date': hier},
        {'title': 'UCAD : reprise des cours le 3 novembre', 'url': 'https://www.ucad.sn/reprise-cours',
         'content': 'Le rectorat annonce la reprise des cours le 3 novembre après la grève.',
         'published_date': hier},
        {'title': 'Lutte : Modou Lô bat Siteu', 'url': 'https://www.seneweb.com/lutte',
         'content': 'Combat de lutte au stade.', 'published_date': hier},
        {'title': 'Article sur un blog', 'url': 'https://monblog.example.com/bac',
         'content': 'Rumeurs sur le bac.', 'published_date': hier},
    ]}


def _faux_mistral(messages, **kwargs):
    page = messages[-1]['content']
    if 'Bac 2026' in page:
        return json.dumps({'pertinent': True, 'titre': 'Bac 2026 : 52 % de réussite',
                           'resume': "L'Office du Bac annonce 52 % de réussite. C'est la session 2026.",
                           'categorie': 'general'})
    if 'UCAD' in page:
        # Chiffre inventé (« 15 000 étudiants ») : le résumé doit être remplacé par la source.
        return json.dumps({'pertinent': True, 'titre': 'UCAD : reprise des cours le 3 novembre',
                           'resume': 'Les 15 000 étudiants reprennent les cours.', 'categorie': 'evenement'})
    if "Bourses d'excellence" in page:
        return json.dumps({'pertinent': True, 'titre': "Bourses d'excellence de la Suisse : appel à candidatures",
                           'resume': "Le ministère annonce l'ouverture des candidatures aux bourses d'excellence.",
                           'categorie': 'bourse'})
    return json.dumps({'pertinent': False})


def _date_flux(heures=5):
    return (timezone.now() - timedelta(hours=heures)).strftime('%a, %d %b %Y %H:%M:%S GMT')


PAGE_VIVANTE = {'accessible': True, 'image': 'https://www.aps.sn/img.jpg', 'date_publication': None}


class VeilleActualitesTests(TestCase):
    def setUp(self):
        cache_django.clear()
        for fichier in Path(settings.VEILLE_ETAT_DIR).glob('dernier_passage_*'):
            fichier.unlink()
        self.tavily = mock.patch.object(tavily_service, '_get_client').start().return_value
        self.tavily.search.return_value = _resultats_tavily()
        self.llm = mock.patch.object(llm_service, 'generer', side_effect=_faux_mistral).start()
        self.page = mock.patch(
            'veille.recherche_web.extraire_metadonnees_article', return_value=PAGE_VIVANTE,
        ).start()
        self.image = mock.patch(
            'veille.recherche_web.telecharger_image_locale', return_value='/storage/actualites/abc.jpg',
        ).start()
        mock.patch('veille.commun.precharger_modele_veille').start()
        # Flux RSS officiels : vides par défaut (aucun appel réseau dans les tests).
        self.flux = mock.patch('veille.actualites.lire_flux_officiels', return_value=[]).start()
        mock.patch('veille.actualites.texte_article', return_value='').start()
        self.addCleanup(mock.patch.stopall)

    def test_articles_des_flux_officiels_traites_comme_ceux_de_tavily(self):
        self.tavily.search.return_value = {'results': []}
        self.flux.return_value = [{
            'url': 'https://mesrisenegal.sn/actualites/bourses-suisse-2027',
            'titre': "Bourses d'excellence de la Suisse : appel à candidatures pour les étudiants",
            'contenu': "Le ministère annonce l'ouverture des candidatures aux bourses d'excellence.",
            'date_publication': _date_flux(), 'origine': 'flux',
        }]
        stats = actualites.veille_actualites()
        self.assertEqual(stats['flux_officiels'], 1)
        self.assertEqual(stats['creees'], 1)
        self.assertTrue(Actualite.objects.filter(source_url__contains='bourses-suisse-2027').exists())

    def test_flux_limite_par_passage_et_sans_doublon_avec_tavily(self):
        urls_tavily = [r['url'] for r in _resultats_tavily()['results']]
        articles = [{
            'url': f'https://mesrisenegal.sn/actualites/bourse-{i}', 'titre': f"Bourse d'études numéro {i} pour les étudiants",
            'contenu': f"Appel à candidatures pour la bourse d'études {i}.", 'date_publication': _date_flux(),
            'origine': 'flux',
        } for i in range(actualites.MAX_FLUX_PAR_PASSAGE + 3)]
        # Le même article que Tavily (même URL) ne compte qu'une fois.
        articles.append(dict(articles[0], url=urls_tavily[0]))
        self.flux.return_value = articles
        self.tavily.search.return_value = {'results': []}
        stats = actualites.veille_actualites()
        self.assertLessEqual(stats['creees'], actualites.MAX_FLUX_PAR_PASSAGE)

    def test_le_resultat_du_passage_est_enregistre_pour_l_application(self):
        actualites.veille_actualites()
        etat = commun.etat(actualites.NOM)
        self.assertIsNotNone(etat['dernier_passage'])
        self.assertIn('creees', etat['dernier_passage'])
        self.assertIsNotNone(etat['prochain_passage'])

    def test_rattrapage_apres_plusieurs_jours_pc_eteint(self):
        def dernier_passage_il_y_a(**ecart):
            commun.enregistrer_resultat(actualites.NOM, {'mode': 'tavily'})
            fichier = Path(settings.VEILLE_ETAT_DIR) / f'dernier_resultat_{actualites.NOM}.json'
            resultat = json.loads(fichier.read_text(encoding='utf-8'))
            resultat['heure'] = (timezone.now() - timedelta(**ecart)).isoformat()
            fichier.write_text(json.dumps(resultat), encoding='utf-8')

        dernier_passage_il_y_a(hours=2)
        self.assertEqual(commun.fenetre_recherche(actualites.NOM, 'day'), 'day')
        dernier_passage_il_y_a(days=3)
        self.assertEqual(commun.fenetre_recherche(actualites.NOM, 'day'), 'week')
        actualites.veille_actualites()
        self.assertEqual(self.tavily.search.call_args.kwargs['time_range'], 'week')
        dernier_passage_il_y_a(days=10)
        self.assertEqual(commun.fenetre_recherche(actualites.NOM, 'day'), 'month')

    def test_sans_internet_le_creneau_est_libere_et_reessaye_dans_15_min(self):
        with self.settings(VEILLE_VERIFIER_INTERNET=True), \
                mock.patch('veille.commun.internet_disponible', return_value=False):
            stats = actualites.veille_actualites()
            # Le déclenchement suivant (tâche Windows, 15 min plus tard) ne doit pas être bloqué 2 h.
            etat = commun.etat(actualites.NOM)
        self.assertEqual(stats['mode'], 'hors_ligne')
        self.tavily.search.assert_not_called()
        self.assertEqual(etat['dernier_passage']['mode'], 'hors_ligne')
        attente = datetime.fromisoformat(etat['prochain_passage']) - timezone.now()
        self.assertLess(attente, timedelta(minutes=commun.RETRY_HORS_LIGNE_MINUTES + 11))
        with mock.patch('time.time', return_value=commun.time.time() + 16 * 60):
            self.assertNotEqual(actualites.veille_actualites()['mode'], 'ignore')

    def test_un_passage_publie_les_actualites_pertinentes(self):
        stats = actualites.veille_actualites()

        self.assertEqual(stats['creees'], 2)
        self.assertEqual(stats['source'], 1)          # blog inconnu écarté sans appel LLM
        self.assertEqual(stats['non_pertinent'], 1)   # lutte : hors sujet
        self.assertEqual(self.llm.call_count, 3)
        parametres = self.tavily.search.call_args.kwargs
        self.assertEqual((parametres['topic'], parametres['time_range']), ('news', 'day'))
        self.assertIn('aps.sn', parametres['include_domains'])
        self.assertIn('ucad.sn', parametres['include_domains'])
        self.assertEqual(CreditTavily.objects.get().credits_veille, 1)

        bac = Actualite.objects.get(source_url='https://www.aps.sn/bac-2026-resultats')
        self.assertEqual(bac.titre, 'Bac 2026 : 52 % de réussite')
        self.assertEqual(bac.statut, 'publie')
        self.assertEqual(bac.image_url, '/storage/actualites/abc.jpg')
        self.assertEqual(bac.fiabilite, 'presse')
        self.assertIsNotNone(bac.date_publication)
        self.assertIsNotNone(bac.hash_dedoublonnage)

    def test_resume_avec_chiffre_invente_remplace_par_la_source(self):
        stats = actualites.veille_actualites()

        ucad = Actualite.objects.get(source_url='https://www.ucad.sn/reprise-cours')
        self.assertNotIn('15 000', ucad.contenu)
        self.assertIn('reprise des cours le 3 novembre', ucad.contenu)
        self.assertEqual(ucad.categorie, 'evenement')
        self.assertEqual(ucad.fiabilite, 'officiel')
        self.assertEqual(stats['avertissements']['resume_remplace'], 1)

    def test_second_passage_sans_doublon(self):
        actualites.veille_actualites()
        self.llm.reset_mock()

        # Passage suivant forcé : sinon le verrou des 2 h l'ignorerait (voir commun.reserver_passage).
        stats = actualites.veille_actualites(force=True)

        self.assertEqual(stats['creees'], 0)
        self.llm.assert_not_called()
        self.assertEqual(Actualite.objects.count(), 2)

    def test_second_passage_ne_redemande_pas_un_article_rejete(self):
        actualites.veille_actualites()
        self.llm.reset_mock()

        # Passage suivant forcé : sinon le verrou des 2 h l'ignorerait (voir commun.reserver_passage).
        stats = actualites.veille_actualites(force=True)

        self.assertEqual(stats['deja_rejete'], 1)  # l'article de lutte n'est pas renvoyé à Mistral
        self.llm.assert_not_called()

    def test_lien_mort_ecarte_avant_le_llm_et_retente_plus_tard(self):
        self.page.return_value = {'accessible': False}

        stats = actualites.veille_actualites()

        self.assertEqual((stats['lien_mort'], stats['creees']), (3, 0))
        self.llm.assert_not_called()

    def test_article_ancien_ecarte(self):
        vieux = (timezone.now() - timedelta(days=60)).strftime('%a, %d %b %Y %H:%M:%S GMT')
        self.tavily.search.return_value = {'results': [
            {**_resultats_tavily()['results'][0], 'published_date': vieux},
        ]}
        stats = actualites.veille_actualites()
        self.assertEqual(stats['date'], 1)
        self.llm.assert_not_called()

    @mock.patch('veille.pipeline.backfiller_metadonnees_actualites', return_value=0)
    @mock.patch('veille.pipeline.veiller_actualites', return_value={'creees': 4})
    def test_quota_epuise_repli(self, veiller_actualites, _backfill):
        CreditTavily.objects.create(jour=timezone.localdate(), credits_veille=800)

        stats = actualites.veille_actualites()

        self.assertEqual((stats['mode'], stats['creees']), ('repli_sources_gratuites', 4))
        self.tavily.search.assert_not_called()

    def test_tache_celery(self):
        self.assertEqual(veille_actualites.delay().get()['creees'], 2)


class ActualitesApiTests(TestCase):
    def setUp(self):
        maintenant = timezone.now()
        donnees = [('bourse', 'publie', 1), ('general', 'publie', 2), ('bourse', 'publie', 3),
                   ('bourse', 'archive', 0)]
        for i, (categorie, statut, age_jours) in enumerate(donnees):
            Actualite.objects.create(
                titre=f'Actu {i}', contenu=f'Résumé {i}', categorie=categorie, statut=statut,
                source_url=f'https://aps.sn/{i}', source_nom='APS', fiabilite='presse',
                date_publication=maintenant - timedelta(days=age_jours),
            )

    def test_liste_publiees_les_plus_recentes_d_abord(self):
        reponse = self.client.get('/api/ia/actualites/?page=1', **JETON)

        self.assertEqual(reponse.status_code, 200)
        corps = reponse.json()
        self.assertEqual(corps['total'], 3)
        self.assertEqual([a['titre'] for a in corps['resultats']], ['Actu 0', 'Actu 1', 'Actu 2'])
        self.assertEqual(
            set(corps['resultats'][0]),
            {'id', 'titre', 'resume', 'categorie', 'url_source', 'image_url', 'source', 'fiabilite',
             'date_publication'},
        )

    def test_filtre_categorie(self):
        corps = self.client.get('/api/ia/actualites/?categorie=bourse', **JETON).json()
        self.assertEqual(corps['total'], 2)

    def test_categorie_inconnue_400(self):
        self.assertEqual(self.client.get('/api/ia/actualites/?categorie=sport', **JETON).status_code, 400)


class ReglesQualiteActualitesTests(TestCase):
    """Cas réels rencontrés lors de la première veille Tavily (18/10/2026)."""

    def _article(self, titre, contenu):
        return {'titre': titre, 'contenu': contenu, 'url': 'https://senego.com/x'}

    def test_article_hors_education_rejete_meme_si_le_modele_l_accepte(self):
        article = self._article('Négociations formelles entre la Confédération AES et la CEDEAO à Dakar',
                                'Les deux organisations ont ouvert leurs premières négociations à Dakar.')
        fiche = {'pertinent': True, 'titre': 'Négociations AES-CEDEAO', 'resume': 'Négociations à Dakar.',
                 'categorie': 'general'}
        self.assertEqual(actualites.valider_fiche(article, fiche)[1], 'hors_education')

    def test_phrase_inventee_sans_chiffre_retiree_du_resume(self):
        article = self._article('Réforme du baccalauréat au Sénégal',
                                'Le ministère annonce une réforme du baccalauréat et de ses épreuves.')
        fiche = {'pertinent': True, 'titre': 'Réforme du baccalauréat', 'categorie': 'general',
                 'resume': 'Le ministère annonce une réforme du baccalauréat. '
                           'Ce peut être concernant le concours fonction publique ou la diaspora.'}
        champs, motif, avertissements = actualites.valider_fiche(article, fiche)
        self.assertIsNone(motif)
        self.assertEqual(champs['contenu'], 'Le ministère annonce une réforme du baccalauréat.')
        self.assertIn('phrase_non_sourcee_retiree', avertissements)


class ReportAuDemarrageTests(TestCase):
    """Au lancement de l'application, la veille attend que le PC ait fini de démarrer."""

    def test_veille_reportee_juste_apres_le_demarrage(self):
        from django.test import override_settings

        from veille import tasks

        with override_settings(VEILLE_DELAI_DEMARRAGE_MINUTES=10), \
                mock.patch.object(tasks.veille_actualites, 'apply_async') as replanifier, \
                mock.patch('veille.actualites.veille_actualites') as passage:
            resultat = tasks.veille_actualites.run()
        self.assertEqual(resultat['mode'], 'reporte')
        passage.assert_not_called()
        self.assertGreater(replanifier.call_args.kwargs['countdown'], 0)
