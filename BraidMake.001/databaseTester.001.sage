import sqlite3

connection = sqlite3.connect('braid.001.db')
c = connection.cursor()
c.execute('SELECT * FROM braidlist ORDER BY matrixnumber')
print c.fetchall()