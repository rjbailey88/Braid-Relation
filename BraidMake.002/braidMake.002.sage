import sqlite3
dbname = 'n2p3.002.db'  #current working Dbase

#define program parameters
n = 2
p = 3

#connect to SQL db
connection = sqlite3.connect(dbname)
c = connection.cursor()

#Initialize data buffers
rowbuffer = (False, 0, 0, ',')    #row initialization values
fetchbuffer = (0,)    #tuple for single value fetching by matrix number
editbuffer = (',', False, 0)    #tuple for three value row edits
rowbufferA = (False, 0, 0, ',')    #tuple for matrix A output from Dbase
rowbufferB = (False, 0, 0, ',')    #tuple for matrix B output from Dbase
braidbuffer = ','    #accumulates braid relations as a comma seperated string/loads to dbase

#initialize temporary variables
det = 0    #temporary determinant variable
vectorPosition = 0   #vector iterator
matrixNumber = 0    #matrix iterator
numberA = 0    #matrix A refnum iterator
numberB = 0    #matrix B refnum iterator
matrixA = matrix.zero(n,n)    #matrix A generated from iterator
matrixB = matrix.zero(n,n)    #matrix B generated from iterator
tempVector = matrix.zero(1,n*n)    #temporary vector for simple iteration

#Begin Matrix generation and basic sorting
for matrixNumber in range(1,p^(n*n)):
    vectorPosition = 0
    tempVector[0,vectorPosition] = mod(tempVector[0,vectorPosition] + 1,p)    
    
#Next matrix generated   
    while tempVector[0,vectorPosition]==0:
        vectorPosition = vectorPosition + 1
        tempVector[0,vectorPosition] = mod(tempVector[0,vectorPosition]+1,p) 

#vector to matrix
    tempMatrix = matrix([[tempVector[0,n*row + col] for col in range(0,n)]for row in range (0,n)])
    det = mod(tempMatrix.determinant(), p)   #FIXME check determinant operation/mod operation
    
#load database with matrix attributes   
    if det == 0:  #FIXME reexamine conditional structure
        del rowbuffer
        rowbuffer = (True, int(matrixNumber), int(det), ',')
        c.execute('INSERT INTO braidlist VALUES (?,?,?,?)', rowbuffer)
        continue
    else:
        del rowbuffer
        rowbuffer = (False, int(matrixNumber), int(det), ',')
        c.execute('INSERT INTO braidlist VALUES (?,?,?,?)', rowbuffer) 
        continue

#commit changes
connection.commit()

#reinitialize variables for braid comparison loop
tempVector = matrix.zero(1,n*n)
tempInt = 0

#braid complarisons from complete database
for numberA in range (1, matrixNumber):
    
    #load matrix A
    del fetchbuffer
    fetchbuffer = (numberA,)
    c.execute('SELECT * FROM braidlist WHERE matrixnumber = ?', fetchbuffer)
    del rowbufferA
    rowbufferA = c.fetchone()
    
#check if entry is valid for braid comparison
    if rowbufferA[0] == 0:   
        braidbuffer = ','
        
#load matrix B
        for numberB in range(numberA + 1, matrixNumber):
            del fetchbuffer
            fetchbuffer = (numberB,)
            c.execute('SELECT * FROM braidlist WHERE matrixnumber = ?', fetchbuffer)
            del rowbufferB
            rowbufferB = c.fetchone()
            if rowbufferB[0] == 0 and rowbufferB[2] == rowbufferA[2]:
                
#create matrices from referance values and compare
                tempVector = matrix.zero(1,n*n)
                tempInt = numberA
                for i in range(1,n*n+1):
                    tempVector[0,n*n-i], tempInt = divmod(tempInt, p^(n*n-i))
                matrixB = matrix([[tempVector[0,n*row + col] for col in range(0,n)]for row in range (0,n)])
                tempInt = numberB
                tempVector = matrix.zero(1,n*n)
                for i in range(1,n*n+1):
                    tempVector[0,n*n-i], tempInt = divmod(tempInt, p^(n*n-i))
                matrixA = matrix([[tempVector[0,n*row + col] for col in range(0,n)]for row in range (0,n)])
                #print ('matrixA = ', matrixA) #testline
                #print ('matrixB = ', matrixB) #testline
                #print matrixA*matrixB*matrixA
                #print matrixB*matrixA*matrixB
                ABA = matrixA*matrixB*matrixA
                BAB = matrixB*matrixA*matrixB
                modABA = matrix([[int(mod(ABA[row,col],p)) for col in range(0,n)] for row in range (0,n)])
                modBAB = matrix([[int(mod(BAB[row,col],p)) for col in range(0,n)] for row in range (0,n)])
                if modABA == modBAB: 
                    braidbuffer = braidbuffer + str(numberB) + ','
        
#load edited entry for matrix A back into Dbase
        del editbuffer
        editbuffer = (braidbuffer, True, numberA)
        c.execute('UPDATE braidlist SET braidrelations = ?, iscomplete = ? WHERE matrixnumber = ?;', editbuffer)

#set last table entry (cannot have braid relations)
del editbuffer
editbuffer = (',', True, numberB)
c.execute('UPDATE braidlist SET braidrelations = ?, iscomplete = ? WHERE matrixnumber = ?;', editbuffer)
#commit and close
connection.commit()
c.close()