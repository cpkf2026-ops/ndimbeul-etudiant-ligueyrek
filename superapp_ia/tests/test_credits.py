"""Compteur de crédits Tavily et bascule en mode réduit (§ 4)."""
from datetime import timedelta

from django.test import TestCase
from django.utils import timezone

from services import credits
from services.models import CreditTavily


class CreditsTavilyTests(TestCase):
    def test_enregistrer_cumule_sur_la_ligne_du_jour(self):
        credits.enregistrer(1, credits.VEILLE)
        credits.enregistrer(1, credits.VEILLE)
        credits.enregistrer(1, credits.INTERACTIF)

        ligne = CreditTavily.objects.get(jour=timezone.localdate())
        self.assertEqual(ligne.credits_veille, 2)
        self.assertEqual(ligne.credits_interactif, 1)
        self.assertEqual(ligne.nb_requetes, 3)

    def test_credits_du_mois_ignore_le_mois_precedent(self):
        mois_dernier = timezone.localdate().replace(day=1) - timedelta(days=1)
        CreditTavily.objects.create(jour=mois_dernier, credits_veille=500)
        credits.enregistrer(1, credits.INTERACTIF)

        self.assertEqual(credits.credits_du_mois(), {'veille': 0, 'interactif': 1, 'total': 1})

    def test_la_veille_s_arrete_avant_la_reserve_interactive(self):
        # Limite 1000, réserve 200 : la veille est bloquée à 800, le chat continue.
        CreditTavily.objects.create(jour=timezone.localdate(), credits_veille=800)

        self.assertTrue(credits.quota_atteint(credits.VEILLE))
        self.assertTrue(credits.mode_reduit())
        self.assertFalse(credits.quota_atteint(credits.INTERACTIF))

    def test_tout_est_bloque_a_la_limite_mensuelle(self):
        CreditTavily.objects.create(jour=timezone.localdate(), credits_veille=800, credits_interactif=200)

        self.assertTrue(credits.quota_atteint(credits.INTERACTIF))
        self.assertEqual(credits.etat()['restants'], 0)
