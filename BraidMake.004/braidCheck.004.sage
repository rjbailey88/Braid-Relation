import sqlite3
dbname = 'n2p3.004.db'  #current working Dbase

#connect to SQL db
connection = sqlite3.connect(dbname)
c = connection.cursor()

#define program parameters
c.execute('SELECT * FROM attributes')
attributes = c.fetchone()
n = attributes[0]
p = attributes[1]

#Initialize data buffers
fetchbuffer = (0,)    #tuple for single value fetching by matrix number
listbuffer = (0, ',')    #tuple for eigen/det loads
editbuffer = (',', False, 0)    #tuple for three value row edits
rowbufferA = (False, 0, 0, ',', ',')    #tuple for matrix A output from Dbase
rowbufferB = (False, 0, 0, ',', ',')
braidbufferA = ','     #accumulates braid relations as a comma seperated string/loads to dbase
braidbufferB = ','

#initialize variables
hasbraidA = False    #temp variable for braid condition
hasbraidB = False    #temp variable for braid condition
nextmatrix = 0    #first generator of matrix sublist
numberA = 0    #matrix A refnum iterator
numberB = 0    #matrix B refnum iterator
matrixlist = 0    #list of matricies sharing dets and eigs
tempVector = matrix.zero(GF(p),1,n*n)
matrixA = matrix.zero(GF(p),n,n)    #matrix A generated from iterator
matrixB = matrix.zero(GF(p),n,n)    #matrix B generated from iterator
tempInt = 0

c.execute('SELECT MAX(matrixnumber) FROM braidlist')
del fetchbuffer
fetchbuffer = c.fetchone()
matrixNumber = fetchbuffer[0]
nextmatrix = 1

#braid complarisons from complete database
while nextmatrix < matrixNumber:
#load next sublist
    c.execute('SELECT MIN(matrixnumber) FROM braidlist WHERE matrixnumber >= %i AND iscomplete = 0' %nextmatrix)   
    del fetchbuffer
    fetchbuffer = c.fetchone()
    nextmatrix = fetchbuffer[0]
    
    if nextmatrix == None:
        break
    c.execute('SELECT * FROM braidlist WHERE matrixnumber = %i' %nextmatrix)
    del rowbufferA
    rowbufferA = c.fetchone()
    
    del listbuffer
    listbuffer = (rowbufferA[2], rowbufferA[4])
    c.execute('SELECT matrixnumber FROM braidlist WHERE determinant = ? AND eigenvalues = ?', listbuffer) 
    matrixlist = c.fetchall()
    for i in range(0,len(matrixlist)):
        matrixlist[i] = matrixlist[i][0]
    
#Load matrix A from sublist
    for numberA in matrixlist:        
        c.execute('SELECT * FROM braidlist WHERE matrixnumber = %i' %numberA)
        del rowbufferA
        rowbufferA = c.fetchone()
        hasbraidA = rowbufferA[5]
        braidbufferA = rowbufferA[3]

#Load matrix B from sublist
        for numberB in matrixlist:
            if numberB > numberA:
                c.execute('SELECT * FROM braidlist WHERE matrixnumber = %i' %numberB)
                del rowbufferB
                rowbufferB = c.fetchone()
                hasbraidB = rowbufferB[5]
                braidbufferB = rowbufferB[3]
#create matrices from referance values and compare
                tempVector = matrix.zero(GF(p),1,n*n)
                tempInt = numberA
                for i in range(1,n*n+1):
                    tempVector[0,n*n-i], tempInt = divmod(tempInt, p^(n*n-i))
                matrixB = matrix(GF(p),[[tempVector[0,n*row + col] for col in range(0,n)]for row in range (0,n)])
                tempInt = numberB
                tempVector = matrix.zero(GF(p),1,n*n)
                for i in range(1,n*n+1):
                    tempVector[0,n*n-i], tempInt = divmod(tempInt, p^(n*n-i))
                matrixA = matrix(GF(p),[[tempVector[0,n*row + col] for col in range(0,n)]for row in range (0,n)])
                ABA = matrixA*matrixB*matrixA
                BAB = matrixB*matrixA*matrixB
                if ABA == BAB:
                    print ABA
                    print BAB
                    print 'next'
                    braidbufferA = braidbufferA + str(numberB) + ','
                    braidbufferB = braidbufferB + str(numberA) + ','
                    hasbraidA = True
                    hasbraidB = True
                    del editbuffer
                    editbuffer = (braidbufferB, hasbraidB, numberB)
                    c.execute('UPDATE braidlist SET braidrelations = ?, hasbraid = ? WHERE matrixnumber = ?', editbuffer)

#load edited entry for matrix A back into Dbase
        del editbuffer
        editbuffer = (braidbufferA, True, hasbraidA, numberA)
        c.execute('UPDATE braidlist SET braidrelations = ?, iscomplete = ?, hasbraid = ? WHERE matrixnumber = ?', editbuffer)

#set last entry in sublist     
    del editbuffer
    editbuffer = (True, matrixNumber)
    c.execute('UPDATE braidlist SET iscomplete = ? WHERE matrixnumber = ?', editbuffer)
    
    nextmatrix = nextmatrix + 1
        
#commit and close
connection.commit()
c.close()