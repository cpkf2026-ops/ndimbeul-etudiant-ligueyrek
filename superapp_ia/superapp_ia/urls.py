from django.urls import include, path

urlpatterns = [
    path('internal/', include('ia.urls')),
    path('internal/', include('recommandations.urls')),
]
