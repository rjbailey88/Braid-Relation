#Simple database output
#Enter database filename in connect line and run in sage to view ordered database contents

import sqlite3

connection = sqlite3.connect('n2p5.002.db')
c = connection.cursor()
c.execute('SELECT max(matrixnumber) FROM braidlist')
matmax = c.fetchone()
c.execute('SELECT * FROM braidlist ORDER BY matrixnumber')
for i in range(0,matmax[0]):
    print c.fetchone()