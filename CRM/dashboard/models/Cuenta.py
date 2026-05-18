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
               # Agregamos c.descuento y los campos de la tabla domicilio
               sql = """
                    SELECT 
                        c.id_cuenta, c.cuenta_activa, c.fecha_corte, c.telefono_fijo,
                        c.fecha_activacion, c.fecha_limite, c.descuento,
                        cl.nombre_cliente, cl.apellido_paterno, cl.correo_cliente, cl.telefono_celular,
                        p.nombre_plan, p.precio_plan,
                        o.nombre_olt, o.region_olt,
                        d.calle, d.num_casa, d.colonia, d.delegacion, d.cp, d.ciudad, d.estado, d.lote
                    FROM cuenta c
                    INNER JOIN cliente cl ON c.id_cliente = cl.id_cliente
                    INNER JOIN plan p ON c.id_plan = p.id_plan
                    INNER JOIN olt o ON c.id_olt = o.id_olt
                    LEFT JOIN domicilio d ON c.id_cuenta = d.id_cuenta
                    WHERE c.id_cuenta = %s;
               """
               
               cursor.execute(sql, (id_cuenta_buscar,))
               fila = cursor.fetchone()
               
               if fila:
                    # Lógica estructural para construir la dirección dinámica si existe en la BD
                    direccion_formateada = 'Sin dirección registrada en sistema.'
                    if fila[15]:  # Si d.calle no es nulo, armamos la cadena completa
                         num_casa = f" No. {fila[16]}" if fila[16] else ""
                         lote_info = f", Lote {fila[22]}" if fila[22] and fila[22] != 'N/A' else ""
                         direccion_formateada = f"{fila[15]}{num_casa}{lote_info}, Col. {fila[17]}, {fila[18]}, C.P. {fila[19]}, {fila[20]}, {fila[21]}"

                    # Mapeamos el resultado adaptando los índices por las nuevas columnas agregadas
                    datos_cuenta = {
                        'id_cuenta': fila[0],
                        'estatus': 'ACTIVA' if fila[1] else 'INACTIVA',
                        'fecha_corte': fila[2],
                        'telefono_fijo': fila[3],
                        'fecha_activacion': fila[4],
                        'fecha_limite': fila[5],
                        'descuento': fila[6], # Almacena el entero del descuento (0, 10, 20 o 30)
                        'nombre_completo': f"{fila[7]} {fila[8]}",
                        'correo': fila[9],
                        'celular': fila[10],
                        'plan': fila[11],
                        'precio_plan': float(fila[12]), # Cast a float para poder realizar operaciones matemáticas en la vista
                        'nodo': fila[13],
                        'region': fila[14],
                        'direccion': direccion_formateada, # Dirección real unificada
                        # MODIFICADO: Se ajusta el comentario para reflejar la nueva lógica matemática del sistema
                        'saldo': 0.00 # Se inicializa en 0.00, el saldo real con descuentos se calcula dinámicamente en el controlador (views.py)
                    }
                    
          except Exception as e:
               print(f"Error en Cuenta.getAccount: {e}")
          finally:
               if 'cursor' in locals() and cursor is not None:
                    cursor.close()
               if 'conexion' in locals() and conexion is not None:
                    conexion.close()
                    
          return datos_cuenta
     
     # METODO: Búsqueda avanzada 
     def busqueda_avanzada(self, nombre, telefono=None, correo=None):
          """
          Busca cuentas que coincidan con el nombre (obligatorio) 
          y opcionalmente con el teléfono o correo (filtros extra).
          """
          resultados = []
          try:
               db = db_connection.DatabaseConnection()
               conexion = db.connect()
               cursor = conexion.cursor()
               
               # Consulta base: Concatenamos nombre y apellido para buscar coincidencias parciales (ILIKE)
               sql = """
                   SELECT cu.id_cuenta 
                   FROM cuenta cu
                   INNER JOIN cliente cl ON cu.id_cliente = cl.id_cliente
                   WHERE (cl.nombre_cliente || ' ' || cl.apellido_paterno) ILIKE %s
               """
               # El % a los lados permite buscar por ejemplo "Roberto" y encontrar "Roberto Díaz"
               params = [f"%{nombre}%"]

               # Si se proporcionó teléfono, filtramos por celular o por teléfono fijo
               if telefono:
                   sql += " AND (cl.telefono_celular = %s OR cu.telefono_fijo = %s)"
                   params.extend([telefono, telefono])

               if correo:
                   sql += " AND cl.correo_cliente ILIKE %s"
                   params.append(f"%{correo}%")

               cursor.execute(sql, tuple(params))
               filas = cursor.fetchall()
               
               # Guardamos los IDs encontrados en la lista de resultados
               for fila in filas:
                   resultados.append({
                       'id_cuenta': fila[0]
                   })

          except Exception as e:
               print(f"Error en Cuenta.busqueda_avanzada: {e}")
          finally:
               if 'cursor' in locals() and cursor is not None:
                    cursor.close()
               if 'conexion' in locals() and conexion is not None:
                    conexion.close()

          return resultados

     # METODO: Actualiza el porcentaje de descuento de una cuenta en la base de datos
     def actualizar_descuento(self, id_cuenta, descuento):
          """
          Ejecuta un UPDATE en PostgreSQL para asignar el porcentaje de descuento a una cuenta.
          Retorna True si la actualización fue exitosa, False en caso contrario.
          """
          exito = False
          try:
               db = db_connection.DatabaseConnection()
               conexion = db.connect()
               cursor = conexion.cursor()
               
               # Consulta parametrizada para evitar inyecciones SQL
               sql = "UPDATE cuenta SET descuento = %s WHERE id_cuenta = %s"
               cursor.execute(sql, (descuento, id_cuenta))
               
               # Obligatorio: Aplicar un commit para que los cambios se guarden físicamente en la BD
               conexion.commit()
               
               # Validamos si la consulta realmente modificó algún registro
               if cursor.rowcount > 0:
                    exito = True

          except Exception as e:
               print(f"Error en Cuenta.actualizar_descuento: {e}")
               # En caso de error, hacemos un rollback para mantener la integridad de la base de datos
               if 'conexion' in locals() and conexion is not None:
                    conexion.rollback()
          finally:
               if 'cursor' in locals() and cursor is not None:
                    cursor.close()
               if 'conexion' in locals() and conexion is not None:
                    conexion.close()
                    
          return exito

     def addAccount(self):
          pass
     
     def deleteAccount(self):
          pass
     
     def updateAccount(self):
          pass

     #Comentario de prueba