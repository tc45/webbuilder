from django.urls import path
from . import views

app_name = 'devices'

urlpatterns = [
    path('', views.index, name='index'),
]
