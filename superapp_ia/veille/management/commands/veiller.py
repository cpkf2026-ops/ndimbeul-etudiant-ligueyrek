"""
Lance la veille internet immédiatement (sans attendre le prochain passage de
Celery Beat) — pratique pour tester/peupler l'appli tout de suite.

Usage :
    python manage.py veiller                   # actualités + offres + universités
    python manage.py veiller --actualites       # actualités seulement
    python manage.py veiller --offres           # offres seulement
    python manage.py veiller --universites      # universités seulement
    python manage.py veiller --offres --universites   # plusieurs à la fois
"""
from django.core.management.base import BaseCommand

from veille import pipeline


class Command(BaseCommand):
    help = "Lance la veille internet (recherche web + classification LLM) immédiatement."

    def add_arguments(self, parser):
        parser.add_argument('--actualites', action='store_true', help='Actualités uniquement.')
        parser.add_argument('--offres', action='store_true', help='Offres (emploi/stage/bourse) uniquement.')
        parser.add_argument('--universites', action='store_true', help='Universités/instituts uniquement.')
        parser.add_argument(
            '--formations', action='store_true',
            help="Recherche les vraies filières des établissements qui n'en ont encore aucune.",
        )
        parser.add_argument(
            '--seed', action='store_true',
            help="Charge uniquement le socle fiable d'universités connues (pas de recherche web).",
        )
        parser.add_argument(
            '--logos', action='store_true',
            help="Va chercher le vrai logo (og:image) des universités actives qui n'en ont pas.",
        )
        parser.add_argument(
            '--actualites-meta', action='store_true',
            help="Va chercher la vraie image et date/heure des actualités qui n'en ont pas.",
        )

    def handle(self, *args, **options):
        if options['seed']:
            self.stdout.write('Chargement du socle fiable d\'universités...')
            nb = pipeline.charger_seed_universites()
            self.stdout.write(self.style.SUCCESS(f'  -> {nb} université(s) créée(s) depuis le socle.'))
            return

        if options['logos']:
            self.stdout.write('Recherche des logos officiels...')
            nb = pipeline.backfiller_logos_universites()
            self.stdout.write(self.style.SUCCESS(f'  -> {nb} logo(s) trouvé(s).'))
            return

        if options['actualites_meta']:
            self.stdout.write('Recherche des vraies images/dates des actualités...')
            nb = pipeline.backfiller_metadonnees_actualites()
            self.stdout.write(self.style.SUCCESS(f'  -> {nb} actualité(s) enrichie(s).'))
            return

        if options['formations']:
            self.stdout.write('Recherche des vraies filières des établissements...')
            traites, creees = pipeline.veiller_formations()
            self.stdout.write(self.style.SUCCESS(
                f'  -> {traites} établissement(s) traité(s), {creees} formation(s) créée(s).'
            ))
            return

        # Aucun flag = tout ; sinon, seulement ce qui est explicitement demandé.
        aucun_flag = not any([options['actualites'], options['offres'], options['universites']])

        if aucun_flag or options['actualites']:
            self.stdout.write('Veille actualités en cours...')
            stats = pipeline.veiller_actualites()
            self.stdout.write(self.style.SUCCESS(f'  -> {pipeline.resume_stats(stats)}'))
            self.stdout.write('Recherche des vraies images/dates manquantes...')
            nb_meta = pipeline.backfiller_metadonnees_actualites()
            self.stdout.write(self.style.SUCCESS(f'  -> {nb_meta} actualité(s) enrichie(s).'))
            self.stdout.write('Déduplication des actualités...')
            nb_dup = pipeline.dedupliquer_actualites_similaires()
            self.stdout.write(self.style.SUCCESS(f'  -> {nb_dup} doublon(s) archivé(s).'))
            self.stdout.write('Archivage des actualités anciennes ou non fiables...')
            nb_arch = pipeline.archiver_actualites_obsoletes()
            self.stdout.write(self.style.SUCCESS(f'  -> {nb_arch} actualité(s) archivée(s).'))

        if aucun_flag or options['offres']:
            self.stdout.write('Veille offres (emploi/stage/bourse/concours) en cours...')
            stats = pipeline.veiller_offres()
            self.stdout.write(self.style.SUCCESS(f'  -> {pipeline.resume_stats(stats)}'))
            self.stdout.write('Expiration des offres dépassées, anciennes ou non vérifiées...')
            nb_exp = pipeline.archiver_offres_obsoletes()
            self.stdout.write(self.style.SUCCESS(f'  -> {nb_exp} offre(s) expirée(s).'))

        if aucun_flag or options['universites']:
            self.stdout.write('Veille universités/instituts en cours...')
            nb = pipeline.veiller_universites()
            self.stdout.write(self.style.SUCCESS(f'  -> {nb} université(s)/institut(s) créé(s).'))
            self.stdout.write('Recherche des logos officiels...')
            nb_logos = pipeline.backfiller_logos_universites()
            self.stdout.write(self.style.SUCCESS(f'  -> {nb_logos} logo(s) trouvé(s).'))
