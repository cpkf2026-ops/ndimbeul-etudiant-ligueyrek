from django.urls import path

from . import views

urlpatterns = [
    path('opportunites/', views.OpportuniteListView.as_view(), name='ia-opportunites'),
    path('actualites/', views.ActualiteListView.as_view(), name='ia-actualites'),
    path('veille/etat/', views.VeilleEtatView.as_view(), name='ia-veille-etat'),
    path('back-office/etablissement/', views.RechercheEtablissementView.as_view(), name='ia-bo-etablissement'),
    path('back-office/lien/', views.AnalyseLienView.as_view(), name='ia-bo-lien'),
    path('back-office/publier/', views.PublicationView.as_view(), name='ia-bo-publier'),
]
