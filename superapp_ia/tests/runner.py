"""
Runner de tests : rend temporairement « gérés » les modèles managed=False pour
que Django crée leurs tables dans la base SQLite de test.

Deux modèles pointent parfois vers la même table (ex. `universites`, lue par
recommandations et par veille avec des colonnes différentes) : on crée la table
à partir du modèle qui déclare le plus de colonnes, pour que les deux fonctionnent.
"""
from django.apps import apps
from django.test.runner import DiscoverRunner


class RunnerModelesNonGeres(DiscoverRunner):
    def setup_test_environment(self, **kwargs):
        modele_par_table = {}
        for modele in apps.get_models():
            if modele._meta.managed:
                continue
            table = modele._meta.db_table
            actuel = modele_par_table.get(table)
            if actuel is None or len(modele._meta.fields) > len(actuel._meta.fields):
                modele_par_table[table] = modele

        for modele in modele_par_table.values():
            modele._meta.managed = True
        super().setup_test_environment(**kwargs)
