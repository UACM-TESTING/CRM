import psycopg2
from psycopg2 import OperationalError
from django.conf import settings

class DatabaseConnection:

    def __init__(self):
        self.connection = None
        self.cursor = None

    def connect(self):
        db = settings.DATABASES['default']
        self.connection = psycopg2.connect(
            dbname=db['NAME'],
            user=db['USER'],
            password=db['PASSWORD'],
            host=db['HOST'],
            port=db['PORT'],
        )
        self.cursor = self.connection.cursor()
        return self.connection  

    def fetchall(self, query):
        self.cursor.execute(query)
        return self.cursor.fetchall()

    def close(self):
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()