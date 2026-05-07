from dashboard import db_connection
import NetworkDevice
"""_summary_
     esta clase nos permite crear clientes en sistema
     encapsulara toda la logica relacionada con el cliente
"""
class Switch(NetworkDevice):
     
     #constructor de la Switch
     def __init__(self):
          super.__init__()
     
     #metodo para consultar en bd la Switch
     def getSwitch(self):
          pass
     
     #metodo para insertar en bd la Switch
     def addSwitch(self):
          pass
     
     #metodo para inhabilitar Switch en base de datos
     def deleteSwitch(self):
          pass
     
     #metodo para actualizar en bd la Switch
     def updateSwitch():
          pass