from django.contrib.auth import logout as auth_logout
from .db_connection import DatabaseConnection
from django.shortcuts import render, redirect
from .models import Producto

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
    return render(request, 'html/account_details.html')

def consulta(request):
    
    database = DatabaseConnection()
    database.connect()
    # print("Conexión establecida" + str(database.connection))
    
    lista = database.fetchall("SELECT * FROM productos;")
    productos = []
    for x in range(len(lista)):
        productos.append(lista[x])
        print(productos)
    return render(request, 'html/consulta.html', context={'productos': productos})