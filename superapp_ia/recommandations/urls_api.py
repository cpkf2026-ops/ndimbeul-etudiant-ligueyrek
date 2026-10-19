from django.urls import path

from . import views

urlpatterns = [
    path('orientation/', views.OrientationView.as_view(), name='ia-orientation'),
]
