from django.core.management.base import BaseCommand

from services import sources


class Command(BaseCommand):
    help = 'Remplit la table sources_confiance avec les sources par défaut (sans écraser l\'existant).'

    def handle(self, *args, **options):
        crees = sources.charger_valeurs_par_defaut()
        self.stdout.write(self.style.SUCCESS(f'{crees} source(s) de confiance ajoutée(s).'))
