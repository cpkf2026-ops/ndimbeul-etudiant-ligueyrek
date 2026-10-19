"""Ajout assisté du back-office : doublons, publication, lecture des dates limites."""
from django.test import TestCase

from veille import back_office
from veille.models import Actualite, OffreEmploi, Universite


class BackOfficeTests(TestCase):
    def setUp(self):
        Universite.objects.create(nom='Université Kocc Barma (UKB)', code_unique='UKB', region='Saint-Louis',
                                  commune='Saint-Louis', statut_actif=True)

    def test_etablissement_deja_present_signale(self):
        proches = back_office.etablissements_proches('Universite Kocc Barma de Saint-Louis')
        self.assertEqual(proches[0]['nom'], 'Université Kocc Barma (UKB)')

    def test_etablissement_sans_ressemblance_non_signale(self):
        self.assertEqual(back_office.etablissements_proches('Institut Supérieur de Santé de Kaolack'), [])

    def test_publication_etablissement_code_genere_et_statut_vide_par_defaut(self):
        cree = back_office.publier_etablissement({'nom': 'Institut Test de Kaolack (ITK)', 'region': 'Kaolack'})
        u = Universite.objects.get(id=cree['id'])
        self.assertEqual(u.code_unique, 'ITK')
        self.assertIsNone(u.type)  # jamais « public » par défaut

    def test_publication_refuse_un_doublon(self):
        with self.assertRaises(back_office.PublicationRefusee):
            back_office.publier_etablissement({'nom': 'Université Kocc Barma (UKB)'})

    def test_actualite_publiee_comme_celles_de_la_veille(self):
        back_office.publier_actualite({'titre': 'Concours d\'entrée à l\'ENA 2027', 'resume': 'Ouverture du concours.',
                                       'categorie': 'concours'})
        a = Actualite.objects.get()
        self.assertEqual(a.statut, 'publie')
        self.assertEqual(a.fiabilite, back_office.FIABILITE_ADMIN)
        self.assertEqual(len(a.hash_dedoublonnage), 64)
        with self.assertRaises(back_office.PublicationRefusee):
            back_office.publier_actualite({'titre': 'Concours d\'entrée à l\'ENA 2027', 'resume': 'Encore.'})

    def test_offre_exige_un_lien(self):
        with self.assertRaises(back_office.PublicationRefusee):
            back_office.publier_offre({'titre': 'Stage comptable'})
        back_office.publier_offre({'titre': 'Stage comptable', 'source_url': 'https://exemple.sn/stage', 'type': 'stage'})
        self.assertEqual(OffreEmploi.objects.get().statut, 'active')

    def test_date_limite_lue_dans_le_texte(self):
        self.assertEqual(back_office._date_limite('Date limite de dépôt : 15 novembre 2026.'), '2026-11-15')
        self.assertEqual(back_office._date_limite('à envoyer au plus tard le 03/12/2026'), '2026-12-03')
        self.assertIsNone(back_office._date_limite('Candidatures ouvertes toute l\'année.'))

    def test_lien_invalide_refuse(self):
        with self.assertRaises(ValueError):
            back_office.analyser_lien('pas-un-lien', 'actualite')
