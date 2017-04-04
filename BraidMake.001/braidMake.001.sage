import sqlite3

#connect to SQL db
connection = sqlite3.connect('braid.001.db')
c = connection.cursor()

#Initialize data buffers
rowbuffer = (False, 0, 0, '')

#define program parameters
n = 2
p = 5

#initialize temporary variables
det = 0
vectorPosition = 0

#ring = GF(p)  #BLAAAAAAAAAAAARG!!!!!! FIXME!!!!!!!!
#ring.order()
#ring = Integers(3)

tempVector = matrix.zero(1,n*n)    #temporary vector for simple iteration
#positionList = [0]*(p-1)    #sorting list position tracker for each determinant
#sortingList = matrix.zero(n,n,p-1,1)   #sorting list matrix (row, col, det, mat#)

#tempVector[0,0] = 4  #Testline

#Begin Matrix generation and basic sorting
for matrixNumber in range(1,p^(n*n-1)):
    vectorPosition = 0
    tempVector[0,vectorPosition] = mod(tempVector[0,vectorPosition] + 1,p)    
    
#Next matrix generated   
    while tempVector[0,vectorPosition]==0:
        vectorPosition = vectorPosition + 1
        tempVector[0,vectorPosition] = mod(tempVector[0,vectorPosition]+1,p) 

#vector to matrix
    tempMatrix = matrix([[tempVector[0,n*row + col] for col in range(0,n)]for row in range (0,n)])
    det = mod(tempMatrix.determinant(), p)   #FIXME check determinant operation/mod operation
    
    #FIXME reexamine conditional structure
    if det == 0:
        del rowbuffer
        rowbuffer = (True, int(matrixNumber), int(det), '')
        print rowbuffer  #Testline
        c.execute('INSERT INTO braidlist VALUES (?,?,?,?)', rowbuffer)
        #connection.commit()
        continue
    else:
        del rowbuffer
        rowbuffer = (False, int(matrixNumber), int(det), '')
        print rowbuffer #Testline
        c.execute('INSERT INTO braidlist VALUES (?,?,?,?)', rowbuffer) 
        #connection.commit()
        continue

connection.commit()
#print(tempMatrix) #Testline
#print("----") #Testline
