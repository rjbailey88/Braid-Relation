#Simple database output
#Enter database filename in connect line and run in sage to view ordered database contents

import sqlite3

#connect to SQL db
connection = sqlite3.connect('n2p3.004.db')
c = connection.cursor()

#print database entries
c.execute('SELECT COUNT(matrixnumber) FROM braidlist')
matmax = c.fetchone()
c.execute('SELECT * FROM braidlist ORDER BY matrixnumber')
for i in range(0,matmax[0]):
    print c.fetchone()
c.execute('SELECT * FROM attributes')
attributes = c.fetchone()

#print attributes
print 'Attributes: n = ' + str(attributes[0]) + '  p = ' + str(attributes[1])