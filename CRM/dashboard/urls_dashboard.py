from django.urls import path
from . import views

urlpatterns = [
    path('dashboard/', views.dashboard, name='dashboard'),
    path('account_details/', views.account_details, name='account_details'),
    path('busqueda_avanzada/', views.busqueda_avanzada, name='busqueda_avanzada'), 
    path('login/', views.login, name='login'),
    path('logout/', views.logout, name='logout'),
    path('aplicar_descuento/', views.aplicar_descuento, name='aplicar_descuento'),
    path('crear_folio/', views.crear_folio, name='crear_folio'),
]