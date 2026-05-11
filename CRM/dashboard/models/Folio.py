from dashboard.db_connection import DatabaseConnection

"""_summary_
     esta clase nos permite crear una cuentas en sistema
     encapsulara toda la logica relacionada con la cuenta
"""
class Folio:
     
     #constructor del Ticket
     # def __init__(self):
          # pass
          
     #metodo para consultar todos los Tickets
     # si tienes problemas con la carga de la pagina por problemas
     #de permisos sobre las tablas de base de datos, usa los comandos
     #que vienen hasta abajo del script.sql
     def getTickets():
        db = DatabaseConnection()
        db.connect()
        cursor = db.cursor
        cursor.execute("SELECT * FROM folio WHERE id_cuenta = '1000000000';")
        folios = cursor.fetchall()
        db.close()
        return folios
     
     #metodo para insertar en bd la Switch
     def addTicket():
          pass
     
     #metodo para inhabilitar Switch en base de datos
     def deleteTicket():
          pass
     
     #metodo para actualizar el Ticket
     def updateTicket():
          pass