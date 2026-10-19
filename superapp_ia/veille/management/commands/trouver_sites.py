"""
Cherche avec Tavily le site officiel des établissements actifs qui n'en ont pas, le
vérifie, puis l'enregistre (voir veille/sites_officiels.py). 1 crédit par établissement.

Usage :
    python manage.py trouver_sites --essai     # affiche ce qui serait enregistré
    python manage.py trouver_sites             # enregistre les sites confirmés
"""
from django.core.management.base import BaseCommand

from veille import sites_officiels


class Command(BaseCommand):
    help = "Trouve et vérifie le site officiel des établissements qui n'en ont pas encore."

    def add_arguments(self, parser):
        parser.add_argument('--essai', action='store_true', help="N'enregistre rien, affiche seulement.")

    def handle(self, *args, **options):
        trouves = 0
        etablissements = list(sites_officiels.etablissements_sans_site().order_by('nom'))
        for universite in etablissements:
            url, explication = sites_officiels.trouver(universite)
            if url:
                trouves += 1
                if not options['essai']:
                    sites_officiels.enregistrer(universite, url)
                self.stdout.write(self.style.SUCCESS(f'OK  {universite.nom} -> {url}'))
            else:
                self.stdout.write(f'--  {universite.nom} : {explication}')
        action = 'trouvé(s) (essai, rien enregistré)' if options['essai'] else 'enregistré(s)'
        self.stdout.write(f'\n{trouves}/{len(etablissements)} site(s) officiel(s) {action}.')
