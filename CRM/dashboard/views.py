from dashboard.db_connection import DatabaseConnection
from django.contrib.auth import logout as auth_logout
from django.shortcuts import render, redirect
from .models.Cliente import Cliente
from .models.Folio import Folio

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
    
    
    return render(
        request, 
        "html/account_details.html",
        context={
            "tickets": Folio.getTickets(),
            "cliente":Cliente.getClient()
        }
    )

def consulta(request):
    pass