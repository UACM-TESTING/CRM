from dashboard.db_connection import DatabaseConnection
from django.contrib.auth import logout as auth_logout
from django.shortcuts import render, redirect
from django.contrib import messages  # framework de alertas de Django
from .models.Cliente import Cliente
from .models.Folio import Folio
from .models.Cuenta import Cuenta  

def dashboard(request):
    return render(request, 'html/dashboard.html')

def login(request):
    if request.method == 'POST':
        # Usamos .get() y .strip() para evitar errores si los campos vienen vacíos
        username = request.POST.get('username', '').strip()
        password = request.POST.get('password', '').strip()
        
        # Validación de que los campos no estén vacíos
        if username and password:
            messages.success(request, f"Inicio de sesión exitoso. ¡Bienvenido, {username}!")
            return redirect('dashboard')
        else:
            messages.error(request, "Error: Por favor, ingresa un usuario y contraseña válidos.")
            return render(request, 'html/login.html')
            
    return render(request, 'html/login.html')

def logout(request):
    auth_logout(request)
    # Alerta informativa al cerrar sesión
    messages.info(request, "Has cerrado sesión de forma segura.")
    return redirect('login')

def account_details(request):
    # Atrapamos el ID y usamos strip() para quitar espacios accidentales al inicio o final
    id_cuenta_buscada = request.GET.get('q', '').strip()
    
    # 1. Validación de campo vacío
    if not id_cuenta_buscada:
        messages.warning(request, "Por favor, ingresa un número de cuenta para buscar.")
        return redirect('dashboard')
        
    # 2. Validación restrictiva: Exactamente 10 dígitos y solo números 
    if not id_cuenta_buscada.isdigit() or len(id_cuenta_buscada) != 10:
        messages.error(request, "Formato inválido: El número de cuenta debe contener exactamente 10 dígitos numéricos.")
        return redirect('dashboard')
    
    detalles_cuenta = [] 
    info_adicional = {} # Diccionario para la Sección 1
    
    # Si pasa las validaciones, instanciamos la clase
    obj_cuenta = Cuenta()
    cuenta_datos = obj_cuenta.getAccount(id_cuenta_buscada)
    
    # 3. Validación de existencia en la Base de Datos
    if not cuenta_datos:
        messages.error(request, f"La cuenta '{id_cuenta_buscada}' no se encontró en los registros del sistema.")
        return redirect('dashboard')
        
    # 4. Si la cuenta existe y todo está bien, lanzamos alerta de éxito
    messages.success(request, f"Cuenta {id_cuenta_buscada} localizada exitosamente.")
    
    # mapeo original de los datos
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

# METODO: Controlador de la Búsqueda Avanzada
def busqueda_avanzada(request):
    if request.method == 'POST':
        # 1. Recuperamos los datos del formulario limpiando espacios en blanco
        nombre = request.POST.get('nombre', '').strip()
        telefono = request.POST.get('telefono', '').strip()
        correo = request.POST.get('correo', '').strip()

        # 2. VALIDACIÓN ESTRICTA: Nombre no puede estar vacío
        if not nombre:
            messages.error(request, "Error: El campo 'Nombre Completo' es obligatorio para la búsqueda avanzada.")
            return redirect('dashboard')

        # 3. Llamada al DAO (Modelo)
        obj_cuenta = Cuenta()
        # Pasamos None si los campos opcionales vienen vacíos
        resultados = obj_cuenta.busqueda_avanzada(
            nombre=nombre,
            telefono=telefono if telefono else None,
            correo=correo if correo else None
        )

        total_encontrados = len(resultados)

        # 4. LÓGICA DE DECISIÓN (Valores Límite: 0, 1, >1)
        
        # Caso 0 resultados
        if total_encontrados == 0:
            messages.error(request, f"No se encontró ninguna cuenta asociada a '{nombre}' con los filtros proporcionados.")
            return redirect('dashboard')

        # Caso Exacto (1 resultado)
        elif total_encontrados == 1:
            id_encontrado = resultados[0]['id_cuenta']
            messages.success(request, f"¡Cliente localizado con éxito! Mostrando la cuenta: {id_encontrado}")
            # Redirección dinámica hacia la cuenta encontrada
            return redirect(f"/account_details/?q={id_encontrado}")

        # Caso Duplicados (>1 resultado)
        else:
            messages.warning(
                request, 
                f"Se encontraron {total_encontrados} cuentas que coinciden con '{nombre}'. "
                f"Por seguridad, ingresa también el Teléfono o Correo para identificar la cuenta exacta."
            )
            return redirect('dashboard')

    # Si se intenta acceder por GET, se rebota al dashboard
    return redirect('dashboard')

def consulta(request):
    pass