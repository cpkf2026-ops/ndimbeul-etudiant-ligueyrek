"""
Lance la veille internet immédiatement (sans attendre le prochain passage de
Celery Beat) — pratique pour tester/peupler l'appli tout de suite.

Usage :
    python manage.py veiller                   # actualités + offres + universités
    python manage.py veiller --planifie         # tâche Windows toutes les 2 h (respecte le verrou)
    python manage.py veiller --actualites       # actualités via Tavily + Mistral (module 3)
    python manage.py veiller --actualites-gratuites  # actualités via les sources gratuites
    python manage.py veiller --opportunites     # offres via Tavily + Mistral (module 2)
    python manage.py veiller --offres           # offres via les sources gratuites (repli)
    python manage.py veiller --universites      # universités seulement
    python manage.py veiller --offres --universites   # plusieurs à la fois
"""
from django.core.management.base import BaseCommand

from veille import actualites, opportunites, pipeline


class Command(BaseCommand):
    help = "Lance la veille internet (recherche web + classification LLM) immédiatement."

    def add_arguments(self, parser):
        parser.add_argument(
            '--planifie', action='store_true',
            help='Passage planifié (tâche Windows toutes les 2 h) : offres + actualités, '
                 'ignoré si un passage a déjà eu lieu il y a moins de 2 h.',
        )
        parser.add_argument(
            '--actualites', action='store_true',
            help='Actualités via Tavily + Mistral (module 3), même en mode réduit.',
        )
        parser.add_argument(
            '--actualites-gratuites', action='store_true',
            help="Actualités via les sources gratuites (flux d'actualités), sans Tavily.",
        )
        parser.add_argument(
            '--opportunites', action='store_true',
            help='Offres via Tavily + Mistral (module 2), même en mode réduit.',
        )
        parser.add_argument(
            '--offres', action='store_true',
            help="Offres via les sources gratuites (flux d'actualités), sans Tavily.",
        )
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
        if options['planifie']:
            # Lancé toutes les 2 h par le Planificateur de tâches Windows (veille_planifiee.ps1),
            # même quand l'application est fermée. Sans « force » : si Celery Beat vient déjà
            # de faire le passage, celui-ci est ignoré (aucun crédit Tavily dépensé deux fois).
            stats_offres = opportunites.veille_opportunites()
            self.stdout.write(f'Opportunités : {stats_offres}')
            stats_actus = actualites.veille_actualites()
            self.stdout.write(f'Actualités : {stats_actus}')
            if stats_actus.get('mode') != 'ignore':
                pipeline.dedupliquer_actualites_similaires()
                pipeline.archiver_actualites_obsoletes()
            return

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
        aucun_flag = not any([
            options['actualites'], options['actualites_gratuites'], options['offres'],
            options['opportunites'], options['universites'],
        ])

        if aucun_flag or options['actualites']:
            self.stdout.write('Veille actualités (Tavily + Mistral) en cours...')
            stats = actualites.veille_actualites(force=True)
            self.stdout.write(self.style.SUCCESS(f'  -> {stats}'))
            nb_dup = pipeline.dedupliquer_actualites_similaires()
            nb_arch = pipeline.archiver_actualites_obsoletes()
            self.stdout.write(self.style.SUCCESS(f'  -> {nb_dup} doublon(s) et {nb_arch} ancienne(s) archivée(s).'))

        if options['actualites_gratuites']:
            self.stdout.write('Veille actualités (sources gratuites) en cours...')
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

        if aucun_flag or options['opportunites']:
            self.stdout.write('Veille opportunités (Tavily + Mistral) en cours...')
            stats = opportunites.veille_opportunites(force=True)
            self.stdout.write(self.style.SUCCESS(f'  -> {stats}'))

        if options['offres']:
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
