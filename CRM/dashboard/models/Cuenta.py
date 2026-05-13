from dashboard import db_connection

"""_summary_
     esta clase nos permite gestionar cuentas en el sistema.
     encapsula toda la lógica de acceso a datos mediante SQL puro.
"""
class Cuenta:
     
     def __init__(self):
          pass
     
     def getAccount(self, id_cuenta_buscar):
          datos_cuenta = None
          try:
               db = db_connection.DatabaseConnection()
               conexion = db.connect()
               cursor = conexion.cursor()
               
               # Traemos las columnas en el orden que el HTML las espera
               sql = """
                    SELECT 
                        c.id_cuenta, c.cuenta_activa, c.fecha_corte, c.telefono_fijo,
                        c.fecha_activacion, c.fecha_limite,
                        cl.nombre_cliente, cl.apellido_paterno, cl.correo_cliente, cl.telefono_celular,
                        p.nombre_plan, p.precio_plan,
                        o.nombre_olt, o.region_olt
                    FROM cuenta c
                    INNER JOIN cliente cl ON c.id_cliente = cl.id_cliente
                    INNER JOIN plan p ON c.id_plan = p.id_plan
                    INNER JOIN olt o ON c.id_olt = o.id_olt
                    WHERE c.id_cuenta = %s;
               """
               
               cursor.execute(sql, (id_cuenta_buscar,))
               fila = cursor.fetchone()
               
               if fila:
                    # Mapeamos el resultado y agregamos valores por defecto para el esqueleto
                    datos_cuenta = {
                        'id_cuenta': fila[0],
                        'estatus': 'ACTIVA' if fila[1] else 'INACTIVA',
                        'fecha_corte': fila[2],
                        'telefono_fijo': fila[3],
                        'fecha_activacion': fila[4],
                        'fecha_limite': fila[5],
                        'nombre_completo': f"{fila[6]} {fila[7]}",
                        'correo': fila[8],
                        'celular': fila[9],
                        'plan': fila[10],
                        'precio_plan': fila[11], #lo usamos para el costo mensual
                        'nodo': fila[12],
                        'region': fila[13],
                        # Datos simulados para mantener el diseño de la Sección 1:
                        'direccion': 'Sin dirección registrada en sistema.',
                        'saldo': 0.00
                    }
                    
          except Exception as e:
               print(f"Error en Cuenta.getAccount: {e}")
          finally:
               if 'cursor' in locals() and cursor is not None:
                    cursor.close()
               if 'conexion' in locals() and conexion is not None:
                    conexion.close()
                    
          return datos_cuenta
     
     def addAccount(self):
          pass
     
     def deleteAccount(self):
          pass
     
     def updateAccount(self):
          pass

     #Comentario de prueba