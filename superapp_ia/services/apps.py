from django.apps import AppConfig


class ServicesConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'services'
    verbose_name = 'Socle IA (Tavily, Ollama, crédits, cache, sources)'
