import sqlite3

connection = sqlite3.connect('n2p3.002.db')
c = connection.cursor()
c.execute('''CREATE TABLE braidlist(iscomplete BOOLEAN, matrixnumber INT, determinant TINYINT, braidrelations VARCHAR(4000))''')