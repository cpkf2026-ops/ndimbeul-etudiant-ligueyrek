"""
Vérifie la configuration Gemini : clé présente, modèle accessible, réponse avec outils.

    python manage.py tester_gemini
    python manage.py tester_gemini --question "Quelles écoles de journalisme à Dakar ?"

La clé n'est jamais affichée.
"""
import time

import httpx
from django.conf import settings
from django.core.management.base import BaseCommand

from ia import agent
from services import cache, gemini_service


class Command(BaseCommand):
    help = 'Teste la clé Gemini et le chatbot à outils.'

    def add_arguments(self, parser):
        parser.add_argument('--question', default="Quels sont les frais d'inscription à l'UGB ?")

    def handle(self, *args, **options):
        if not settings.GEMINI_API_KEY:
            self.stderr.write("GEMINI_API_KEY absente de superapp_ia/.env : ajoute la ligne GEMINI_API_KEY=ta_cle.")
            return
        self.stdout.write(f'Clé trouvée ({len(settings.GEMINI_API_KEY)} caractères). Modèle : {settings.GEMINI_MODEL}')
        # Test manuel : on lève une éventuelle pause (quota) posée par un essai précédent.
        cache.ecrire('ia:gemini:pause', None, 1)

        reponse = httpx.get('https://generativelanguage.googleapis.com/v1beta/models',
                            headers={'x-goog-api-key': settings.GEMINI_API_KEY}, timeout=15)
        if reponse.status_code != 200:
            self.stderr.write(f'Clé refusée par Google (HTTP {reponse.status_code}) : {reponse.text[:200]}')
            return
        modeles = [m['name'].removeprefix('models/') for m in reponse.json().get('models', [])
                   if 'generateContent' in m.get('supportedGenerationMethods', [])]
        flash = [m for m in modeles if 'flash' in m and 'image' not in m and 'tts' not in m]
        self.stdout.write(self.style.SUCCESS(f'Clé valide. Modèles « flash » disponibles : {", ".join(flash[:8])}'))
        if settings.GEMINI_MODEL not in modeles:
            self.stderr.write(f'Le modèle {settings.GEMINI_MODEL} n\'est pas disponible avec cette clé : '
                              f'mets GEMINI_MODEL=<un des modèles ci-dessus> dans .env.')
            return

        self.stdout.write(f'\nQuestion : {options["question"]}')
        debut = time.monotonic()
        resultat = agent.repondre(options['question'], {}, [], time.monotonic() + 40)
        if resultat is None:
            self.stderr.write('Pas de réponse de l\'agent (voir logs/ia.log) : le chatbot local prendra le relais.')
            return
        self.stdout.write(self.style.SUCCESS(f'Réponse en {time.monotonic() - debut:.1f} s :\n') + resultat['reponse'])
        for s in resultat['sources']:
            self.stdout.write(f"  source : {s['titre']} — {s['url']}")
        _ = gemini_service  # (module importé pour vérifier qu'il se charge)
