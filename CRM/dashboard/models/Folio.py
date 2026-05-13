from dashboard import db_connection

"""_summary_
     esta clase nos permite crear y gestionar folios en sistema
     encapsulara toda la logica relacionada con los tickets/folios
"""
class Folio:
     
     #constructor del Ticket
     def __init__(self):
          pass
     
     #metodo para consultar un Ticket específico
     def getTicket(self):
          pass
     
     #metodo para consultar todos los Tickets de una cuenta
     def getTickets(self, id_cuenta_buscar):
          lista_folios = []
          try:
               db = db_connection.DatabaseConnection()
               conexion = db.connect()
               cursor = conexion.cursor()
               
               # Traemos las columnas en el orden que el HTML las espera
               sql = """
                    SELECT 
                        id_folio, area_origen, falla, falla_especifica, 
                        solucion, descripcion, id_empleado, id_cuenta, fecha_alta
                    FROM folio
                    WHERE id_cuenta = %s
                    ORDER BY id_folio DESC;
               """
               
               cursor.execute(sql, (id_cuenta_buscar,))
               lista_folios = cursor.fetchall()
                    
          except Exception as e:
               print(f"Error en Folio.getTickets: {e}")
          finally:
               if 'cursor' in locals() and cursor is not None:
                    cursor.close()
               if 'conexion' in locals() and conexion is not None:
                    conexion.close()
                    
          return lista_folios
     
     #metodo para insertar en bd el Ticket
     def addTicket(self):
          pass
     
     #metodo para inhabilitar Ticket en base de datos
     def deleteTicket(self):
          pass
     
     #metodo para actualizar el Ticket (se agregó 'self')
     def updateTicket(self):
          pass