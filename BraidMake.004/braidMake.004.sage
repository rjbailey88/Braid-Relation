import sqlite3
dbname = 'n2p3.004.db'  #current working Dbase

#define program parameters
n = 2
p = 3

#connect to SQL db
connection = sqlite3.connect(dbname)
c = connection.cursor()
c.execute('''CREATE TABLE braidlist(iscomplete BOOLEAN, matrixnumber INT, determinant TINYINT, braidrelations VARCHAR(4000),  eigenvalues VARCHAR(300), hasbraid BOOLEAN)''')

c.execute('''CREATE TABLE attributes(n TINYINT, p TINYINT)''')

#Initialize data buffers
attributebuffer = (int(n),int(p))
rowbuffer = (False, 0, 0, ',', ',', False)    #row initialization values

#initialize temporary variables
i = 0    #iterator
det = 0    #temporary determinant variable
eig = 0    #temporary eigenlist
eigstring = ','    #temporary eigenstring
vectorPosition = 0   #vector iterator
matrixNumber = 0    #matrix iterator
tempVector = matrix.zero(GF(p),1,n*n)    #temporary vector for simple iteration
tempMatrix = matrix.zero(GF(p),n,n)

#add attribute n,p values to table
c.execute("INSERT INTO attributes VALUES (?,?)", attributebuffer)

#Begin Matrix generation and basic sorting
for matrixNumber in range(1,p^(n*n)):
    vectorPosition = 0
    tempVector[0,vectorPosition] = tempVector[0,vectorPosition] + 1    
    
#Next matrix generated   
    while tempVector[0,vectorPosition]==0:
        vectorPosition = vectorPosition + 1
        tempVector[0,vectorPosition] = tempVector[0,vectorPosition]+1 
        
#vector to matrix
    tempMatrix = matrix(GF(p),[[tempVector[0,n*row + col] for col in range(0,n)]for row in range (0,n)])
    det = tempMatrix.determinant()   #FIXME check determinant operation/mod operation
    
#load database with matrix attributes   
    if det == 0:  #FIXME reexamine conditional structure
        continue
    else:
        eigstring = ','
        eig = tempMatrix.eigenvalues()
        eig.sort()
        for i in range(0,len(eig)):
            eigstring = eigstring + str(eig[i]) + ','
        del rowbuffer
        rowbuffer = (int(matrixNumber), int(det), ',', eigstring)
        c.execute("INSERT INTO braidlist VALUES (0,?,?,?,?,0)", rowbuffer)
        continue

#commit change
connection.commit()
c.close()