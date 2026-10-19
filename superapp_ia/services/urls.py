from django.urls import path

from . import views

urlpatterns = [
    path('sante/', views.SanteView.as_view(), name='ia-sante'),
]
