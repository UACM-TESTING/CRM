from django.shortcuts import render, redirect
from django.contrib.auth import logout as auth_logout

def dashboard(request):
    return render(request, 'dashboard.html')

def login(request):
    
    if request.method == 'POST':
        username = request.POST['username']
        password = request.POST['password']
        return redirect('dashboard')
    return render(request, 'login.html')

def logout(request):
    auth_logout(request)
    return redirect('login')

def account_details(request):
    return render(request, 'account_details.html')