from django.urls import path

from . import views

urlpatterns = [
    path('opportunites/', views.OpportuniteListView.as_view(), name='ia-opportunites'),
    path('actualites/', views.ActualiteListView.as_view(), name='ia-actualites'),
]
