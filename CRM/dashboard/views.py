from dashboard.db_connection import DatabaseConnection
from django.contrib.auth import logout as auth_logout
from django.shortcuts import render, redirect
from .models.Cliente import Cliente
from .models.Folio import Folio
from .models.Cuenta import Cuenta  

def dashboard(request):
    return render(request, 'html/dashboard.html')

def login(request):
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        return redirect('dashboard')
    return render(request, 'html/login.html')

def logout(request):
    auth_logout(request)
    return redirect('login')

def account_details(request):
    # Atrapamos el ID que el usuario haya escrito en el buscador (ej: ?id_cuenta=1000000000)
    id_cuenta_buscada = request.GET.get('q')
    
    detalles_cuenta = [] 
    info_adicional = {} # Diccionario para la Sección 1
    
    # Si sí hay un ID, vamos a la base de datos
    if id_cuenta_buscada:
        obj_cuenta = Cuenta()
        cuenta_datos = obj_cuenta.getAccount(id_cuenta_buscada)
        
        if cuenta_datos:
            detalles_cuenta = [
                {'etiqueta': 'CLIENTE', 'valor': cuenta_datos.get('nombre_completo'), 'icono': 'bi-person-circle', 'color': '#6f42c1'},
                {'etiqueta': 'CUENTA', 'valor': cuenta_datos.get('id_cuenta'), 'icono': 'bi-person-badge', 'color': '#6f42c1'},
                {'etiqueta': 'ESTATUS', 'valor': cuenta_datos.get('estatus'), 'icono': 'bi-plug-fill', 'color': '#198754' if cuenta_datos.get('estatus') == 'ACTIVA' else '#dc3545'},
                {'etiqueta': 'CORREO', 'valor': cuenta_datos.get('correo'), 'icono': 'bi-envelope', 'color': '#6f42c1'},
                {'etiqueta': 'CELULAR', 'valor': cuenta_datos.get('celular'), 'icono': 'bi-phone', 'color': '#007bff'},
                {'etiqueta': 'TEL. FIJO', 'valor': cuenta_datos.get('telefono_fijo'), 'icono': 'bi-telephone-fill', 'color': '#007bff'},
                {'etiqueta': 'PLAN', 'valor': cuenta_datos.get('plan'), 'icono': 'bi-box-seam', 'color': '#fd7e14'},
                {'etiqueta': 'FECHA ALTA', 'valor': cuenta_datos.get('fecha_activacion'), 'icono': 'bi-calendar-check', 'color': '#6c757d'},
                {'etiqueta': 'FECHA CORTE', 'valor': cuenta_datos.get('fecha_corte'), 'icono': 'bi-calendar-x', 'color': '#dc3545'},
                {'etiqueta': 'LÍMITE PAGO', 'valor': cuenta_datos.get('fecha_limite'), 'icono': 'bi-calendar-event', 'color': '#ffc107'},
                {'etiqueta': 'REGIÓN', 'valor': cuenta_datos.get('region'), 'icono': 'bi-geo-alt-fill', 'color': '#17a2b8'},
                {'etiqueta': 'NODO / OLT', 'valor': cuenta_datos.get('nodo'), 'icono': 'bi-router', 'color': '#17a2b8'}
            ]
            
            # Empaquetamos los nuevos datos de dirección y saldo
            info_adicional = {
                'domicilio': cuenta_datos.get('direccion', 'No registrada'),
                'saldo': cuenta_datos.get('saldo', 0.0),
                'costo_plan': cuenta_datos.get('precio_plan', 0.0),
            }
    
    # Instanciamos la clase Folio
    obj_folio = Folio()
    lista_tickets = []
    
    # Si buscamos una cuenta válida, le pasamos el ID para traer solo sus tickets
    if id_cuenta_buscada:
         lista_tickets = obj_folio.getTickets(id_cuenta_buscada)
    
    # Enviamos todo al HTML
    return render(
        request, 
        "html/account_details.html",
        context={
            "detalles_cuenta": detalles_cuenta,
            "tickets": lista_tickets,
            "info_adicional": info_adicional # Enviamos la información de la Sección 1
        }
    )

def consulta(request):
    pass