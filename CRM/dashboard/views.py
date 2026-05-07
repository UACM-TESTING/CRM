from django.contrib.auth import logout as auth_logout
from django.shortcuts import render, redirect
from .models import Cuenta, Plan

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
    # Obtenemos el parámetro 'q' de la URL (el número de cuenta)
    query = request.GET.get('q')
    cuenta_encontrada = None
    
    if query:
        try:
            # Buscamos la cuenta por su número (PK)
            # Usamos select_related para traer también los datos del Cliente y la OLT de un solo golpe
            cuenta_encontrada = Cuenta.objects.select_related('id_cliente', 'id_olt', 'id_plan').get(num_cuenta=query)
        # Atrapamos DoesNotExist si no existe, y ValueError si el usuario teclea letras en vez de números
        except (Cuenta.DoesNotExist, ValueError):
            cuenta_encontrada = None

    return render(request, 'html/account_details.html', {'cuenta': cuenta_encontrada})

def consulta(request):
    planes_disponibles = Plan.objects.all()
    return render(request, 'html/consulta.html', context={'planes': planes_disponibles})