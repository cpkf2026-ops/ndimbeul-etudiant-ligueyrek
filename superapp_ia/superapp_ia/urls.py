from django.urls import include, path

urlpatterns = [
    # API du service IA (cahier des charges : /api/ia/...).
    path('api/ia/', include('services.urls')),
    path('api/ia/', include('veille.urls')),
    path('api/ia/', include('recommandations.urls_api')),
    path('api/ia/', include('ia.urls_api')),
    # Anciennes routes, conservées le temps de migrer le client Laravel.
    path('internal/', include('ia.urls')),
    path('internal/', include('recommandations.urls')),
]
