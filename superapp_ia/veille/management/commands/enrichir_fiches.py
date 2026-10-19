"""
Enrichit les fiches des établissements actifs sans site officiel (description + image),
en deux temps (voir veille/fiches_etablissements.py) :

    python manage.py enrichir_fiches                      # écrit logs/fiches_propositions.json
    python manage.py enrichir_fiches --appliquer FICHIER  # applique les décisions relues
"""
import json

from django.core.management.base import BaseCommand

from veille import fiches_etablissements, sites_officiels


class Command(BaseCommand):
    help = "Propose (puis applique après relecture) description et image des fiches sans site."

    def add_arguments(self, parser):
        parser.add_argument('--appliquer', metavar='FICHIER',
                            help="Fichier JSON de décisions relues : [{id, description?, image?}]")

    def handle(self, *args, **options):
        if options['appliquer']:
            with open(options['appliquer'], encoding='utf-8') as fichier:
                decisions = json.load(fichier)
            nb = fiches_etablissements.appliquer(decisions)
            self.stdout.write(self.style.SUCCESS(f'{nb} fiche(s) mise(s) à jour.'))
            return

        propositions = []
        etablissements = list(sites_officiels.etablissements_sans_site().order_by('nom'))
        for i, universite in enumerate(etablissements, start=1):
            proposition = fiches_etablissements.collecter(universite)
            propositions.append(proposition)
            fiches_etablissements.ecrire_propositions(propositions)  # sauvegarde au fil de l'eau
            etat = 'description' if proposition.get('description_proposee') else 'pas de description'
            self.stdout.write(f"{i}/{len(etablissements)} {universite.nom} : {etat}, "
                              f"{len(proposition.get('images') or [])} image(s)")
        self.stdout.write(f'\nPropositions écrites dans {fiches_etablissements.FICHIER_PROPOSITIONS}')
