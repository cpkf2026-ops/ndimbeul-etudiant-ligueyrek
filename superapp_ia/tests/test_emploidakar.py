"""Offres d'emploidakar.com : lecture de la liste et de l'annonce, sans appel réseau."""
from datetime import timedelta
from unittest import mock

import httpx
from django.test import TestCase
from django.utils import timezone

from veille import emploidakar
from veille.models import OffreEmploi


def _li(slug, titre, entreprise, lieu, types, jours):
    jour = (timezone.localdate() - timedelta(days=jours)).isoformat()
    classes = ' '.join(f'job-type-{t}' for t in types)
    return f"""<li class="post-1 job_listing type-job_listing {classes}">
      <a href="https://www.emploidakar.com/offre-demploi/{slug}/">
        <div class="position"><h3>{titre}</h3><div class="company"><strong>{entreprise}</strong></div></div>
        <div class="location">{lieu}</div>
        <ul class="meta"><li class="date"><time datetime="{jour}">Publié</time></li></ul>
      </a></li>"""


LISTE = ''.join([
    _li('agent-transit', 'Agent de Transit Terrain', 'Tough Guy Logistiques', "Cité de l'Émergence, Dakar", ['cdd', 'cdi'], 0),
    _li('stage-compta', 'Stagiaire comptable', 'Sonatel', 'Thiès, Sénégal', ['stage'], 1),
    _li('vieille-offre', 'Offre trop ancienne', 'X', 'Dakar', ['cdi'], 60),
])
ANNONCE = ("<html><body><div class='job_description'><p>Tough Guy Logistiques recrute un agent de transit "
           "terrain pour le Port Autonome de Dakar. Deux ans d'expérience minimum.</p>"
           "<p>M'envoyer des offres similaires par mail</p></div></body></html>")


def _reponse(url, **kwargs):
    requete = httpx.Request('GET', url)
    if 'jm-ajax' in url:
        return httpx.Response(200, json={'html': LISTE}, request=requete)
    return httpx.Response(200, text=ANNONCE, request=requete)


@mock.patch('veille.emploidakar.time.sleep')
@mock.patch('veille.emploidakar.httpx.get', side_effect=_reponse)
@mock.patch('veille.emploidakar.httpx.post', side_effect=_reponse)
class EmploiDakarTests(TestCase):
    def test_lecture_de_la_liste(self, *_):
        offres = emploidakar.lire_liste()
        self.assertEqual(offres[0]['titre'], 'Agent de Transit Terrain')
        self.assertEqual(offres[0]['entreprise'], 'Tough Guy Logistiques')
        self.assertEqual(offres[0]['types'], {'cdd', 'cdi'})

    def test_offres_recentes_creees_sans_les_anciennes(self, *_):
        stats = {}
        self.assertEqual(emploidakar.veiller(stats), 2)
        transit = OffreEmploi.objects.get(intitule='Agent de Transit Terrain')
        self.assertEqual(transit.type, 'emploi')
        self.assertEqual(transit.region, 'Dakar')
        self.assertEqual(transit.source, 'emploidakar.com')
        self.assertNotIn("M'envoyer", transit.description)
        self.assertEqual(OffreEmploi.objects.get(intitule='Stagiaire comptable').type, 'stage')
        self.assertFalse(OffreEmploi.objects.filter(intitule='Offre trop ancienne').exists())

    def test_second_passage_sans_doublon_ni_relecture(self, _post, get, _sleep):
        emploidakar.veiller()
        get.reset_mock()
        self.assertEqual(emploidakar.veiller(), 0)
        get.assert_not_called()  # les annonces déjà connues ne sont pas relues

    def test_site_indisponible_sans_erreur(self, post, *_):
        post.side_effect = httpx.ConnectError('hors ligne')
        stats = {}
        self.assertEqual(emploidakar.veiller(stats), 0)
        self.assertIn('emploidakar_erreur', stats)


LISTE_SENJOB = """<table><tr class="leadsCycleBg rollover"><td>
  <a href="https://senjob.com/sn/jobseekers/technicien-polyvalent-kolda_e_164525.html">Technicien Polyvalent (H/F) / KOLDA</a>
  </td><td> Kolda </td><td> Publi&eacute;: 26&nbsp;Oct.</td><td> Expire: 08&nbsp;Nov.</td></tr>
<tr class="leadsCycleBg rollover"><td>
  <a href="https://senjob.com/sn/jobseekers/stagiaire-communication_e_164600.html">Stagiaire communication</a>
  </td><td> Dakar </td><td> Publi&eacute;: 29&nbsp;Oct.</td></tr></table>"""
PAGE_SENJOB = ("<html><body>Référence 164525 Localisation Kolda / Sénégal Expiration 08 Novembre 2099 "
               "Description de l'offre Le projet recrute un technicien polyvalent pour accompagner les "
               "femmes rurales dans leurs activités d'élevage à Fafacourou. Partagez cette offre ces offres "
               "aussi pourraient vous intéresser</body></html>")


def _reponse_senjob(url, **kwargs):
    requete = httpx.Request('GET', url)
    return httpx.Response(200, text=LISTE_SENJOB if 'offres-d-emploi' in url else PAGE_SENJOB, request=requete)


@mock.patch('veille.senjob.time.sleep')
@mock.patch('veille.senjob.httpx.get', side_effect=_reponse_senjob)
class SenjobTests(TestCase):
    def test_lecture_et_enregistrement(self, *_):
        from veille import senjob
        stats = {}
        self.assertEqual(senjob.veiller(stats), 2)
        technicien = OffreEmploi.objects.get(intitule__startswith='Technicien Polyvalent')
        self.assertEqual(technicien.region, 'Kolda')
        self.assertEqual(technicien.date_limite.isoformat(), '2099-11-08')
        self.assertNotIn('Partagez', technicien.description)
        self.assertEqual(OffreEmploi.objects.get(intitule='Stagiaire communication').type, 'stage')

    def test_meme_offre_deja_publiee_par_un_autre_site(self, *_):
        from veille import offres_directes, senjob
        OffreEmploi.objects.create(
            intitule='Technicien polyvalent H/F Kolda', entreprise='Non précisé', type='emploi',
            source_url='https://www.emploidakar.com/offre-demploi/technicien/', statut='active',
            date_indexation=timezone.now())
        self.assertTrue(offres_directes.deja_publiee('Technicien Polyvalent (H/F) / KOLDA'))
        stats = {}
        senjob.veiller(stats)
        self.assertEqual(stats.get('senjob_doublon'), 1)
