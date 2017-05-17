import sqlite3
#current working Dbase
dbname = 'n2p3.004.db'  #current working Dbase

#connect to SQL db
connection = sqlite3.connect(dbname)
c = connection.cursor()

#matrix variables
c.execute('SELECT * FROM attributes')
attributes = c.fetchone()
n = attributes[0]
p = attributes[1]

#matrix search number
searchnumber = 12

#initialize buffer tuples
existsbuffer = 0,
matrixbuffer = (False, 0, 0, ',', ',', False) 

#some variables
i = 0
j = 0
k = 0
tempVector = matrix.zero(GF(p),1,n*n)
matrixA = matrix.zero(GF(p),1,n*n)
tempInt = 0
tempString = '0'
tempeigen = ','

c.execute('SELECT count(1) from braidlist WHERE matrixnumber = %i' %searchnumber)
del existsbuffer
existsbuffer = c.fetchone()
if existsbuffer[0] == 1:
    c.execute('SELECT * from braidlist WHERE matrixnumber = %i' %searchnumber)
    del matrixbuffer
    matrixbuffer = c.fetchone()
    tempInt = matrixbuffer[1]
    for i in range(1,n*n+1):
        tempVector[0,n*n-i], tempInt = divmod(tempInt, p^(n*n-i))
    matrixA = matrix(GF(p),[[tempVector[0,n*row + col] for col in range(0,n)]for row in range (0,n)])
    print ('Matrix #%i:' %matrixbuffer[1])
    print matrixA
    if len(matrixbuffer[4]) > 1:
        print ('Has determinants: %s' %matrixbuffer[4])
    else:
        print ('Determinant not computed.')
    if matrixbuffer[0] == 1:
        if matrixbuffer[5] == 1:
            print 'Shares braid relation with:'
            #print matrixbuffer[3]
            for j in range(1,len(matrixbuffer[3])):
                if matrixbuffer[3][j] == ',':
                    tempInt = int(tempString)
                    tempString = '0'
                    tempVector = matrix.zero(GF(p),1,n*n)
                    matrixA = matrix.zero(GF(p),1,n*n)
                    print ('#%i' %tempInt)
                    for k in range(1,n*n+1):
                        tempVector[0,n*n-k], tempInt = divmod(tempInt, p^(n*n-k))
                    matrixA = matrix(GF(p),[[tempVector[0,n*row + col] for col in range(0,n)]for row in range (0,n)])
                    print matrixA
                else:
                    tempString = tempString + matrixbuffer[3][j]
        else:
            print 'Has no computed braid relations.'
else:
    print 'Entry does not exist!'