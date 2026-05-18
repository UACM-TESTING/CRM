from dashboard.db_connection import DatabaseConnection

"""_summary_
     esta clase nos permite crear clientes en sistema
     encapsulara toda la logica relacionada con el cliente
"""
class Cliente:
     
     #constructor del Client
     def __init__(self):
          super.__init__()
     
     #metodo para consultar en bd el Client
     def getClientByID(self):
          pass
     
     #metodo para consultar en bd el Client
     def getClient():
        
        db = DatabaseConnection()
        db.connect()
        cursor = db.cursor
        cursor.execute(
             "SELECT nombre_cliente,apellido_paterno,apellido_materno,"+
             "telefono_celular,correo_cliente FROM cliente WHERE id_cliente = '1';"
          )
        cliente = cursor.fetchall()
        db.close()
        print(cliente)
        return cliente
     
     #metodo para insertar en bd el Client
     def addClient():
          pass
     
     #metodo para inhabilitar el Client en base de datos
     def deleteClient():
          pass
     
     #metodo para actualizar en bd el Client
     def updateClient():
          pass
