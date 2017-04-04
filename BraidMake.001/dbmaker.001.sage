import sqlite3

connection = sqlite3.connect('braid.001.db')
c = connection.cursor()
c.execute('''CREATE TABLE braidlist(iscomplete BOOLEAN, matrixnumber INT, determinant INT, braidrelations VARCHAR(1000))''')