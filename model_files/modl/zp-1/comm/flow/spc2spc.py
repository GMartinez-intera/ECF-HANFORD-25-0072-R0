####  ASSUMES RECTILINEAR GRID

class RectGrid():
    import numpy as np
    import math
    X0 = 0.0
    Y0 = 0.0
    ISIBND = False
    IBND = None
    THETA = 0.0
    NROW = 0
    NCOL = 0
    DELR = None
    DELC = None
    X = None
    Y = None
    NE_X = None
    NE_Y = None
    NW_X = None
    NW_Y = None
    SW_X = None
    SW_Y = None
    SE_X = None
    SE_Y = None
    LIST_ROWS = None 
    LIST_COLS = None
    LIST_CNT = None


    def readSPC(self, fileName):
        import numpy as np
        with open(fileName,'r') as f:
            data = f.readline()
            self.NROW, self.NCOL = data.split()
            self.ISIBND = False
            self.NROW = int(self.NROW)
            self.NCOL = int(self.NCOL)
            # DECLARE ARRAY SIZES
            self.DELC = np.zeros((self.NCOL))
            self.DELR = np.zeros((self.NROW))
            self.X = np.zeros((self.NROW,self.NCOL))
            self.Y = np.zeros((self.NROW,self.NCOL))
            self.NE_X = np.zeros((self.NROW,self.NCOL))
            self.NE_Y = np.zeros((self.NROW,self.NCOL))
            self.NW_X = np.zeros((self.NROW,self.NCOL))
            self.NW_Y = np.zeros((self.NROW,self.NCOL))
            self.SE_X = np.zeros((self.NROW,self.NCOL))
            self.SE_Y = np.zeros((self.NROW,self.NCOL))
            self.SW_X = np.zeros((self.NROW,self.NCOL))
            self.SW_Y = np.zeros((self.NROW,self.NCOL))
            self.SW_Y = np.zeros((self.NROW,self.NCOL))
            self.IBND = np.zeros((self.NROW,self.NCOL))
            data = f.readline()
            self.X0, self.Y0, self.THETA = data.split()
            self.X0 = float(self.X0)
            self.Y0 = float(self.Y0)
            self.THETA = float(self.THETA)
            self.LIST_ROWS = [[[] for i in range(self.NCOL)] for j in range(self.NROW)]
            self.LIST_COLS = [[[] for i in range(self.NCOL)] for j in range(self.NROW)]
            self.LIST_CNT = [[0 for i in range(self.NCOL)] for j in range(self.NROW)]
            data = f.readlines()
            dcount = 0
            for line in data:
                words = line.split()
                for word in words:
                    if dcount < (self.NCOL + self.NROW):
                      if dcount < self.NCOL:
                        #print(word + "," +str(float(word)) + "\n")
                        self.DELC[dcount] = float(word)
                      else:
                        self.DELR[(dcount-self.NCOL)] = float(word)
                    dcount+=1
            self.calcCoord()
            
    def setIBND(self,fileName):
      self.ISIBND = True
      tmparray = []
      with open(fileName, 'r') as f:
        data = f.readlines()
        for line in data:
            words = line.split()
            for word in words:
              tmparray.append(float(word))
      #print (tmparray)
      acount = 0
      for bbb in range(int(self.NROW)):
        for ccc in range(int(self.NCOL)):
          #print (str(bbb) + " " + str(ccc) + " " + str(acount) + "\n")
          self.IBND[bbb, ccc] = float(tmparray[acount])
          acount += 1    
 
    def calcCoord(self):
      import numpy
      import math
      # Make grid eastings
      for ppp in range(0,self.NCOL):
        if ppp == 0:
          self.X[:,ppp] = (float(self.DELC[ppp])/2) 
          self.NE_X[:,ppp] = self.DELC[ppp] 
          self.NW_X[:,ppp] = 0.0
          self.SE_X[:,ppp] = self.DELC[ppp]
          self.SW_X[:,ppp] = 0.0
        else:
          self.X[:,ppp] = (self.DELC[ppp]/2)+(self.DELC[ppp-1]/2) + self.X[0,ppp-1]
          self.NE_X[:,ppp] = self.NE_X[0,ppp-1] +self.DELC[ppp]
          self.NW_X[:,ppp] = self.NE_X[0,ppp-1] 
          self.SE_X[:,ppp] = self.NE_X[0,ppp-1] +self.DELC[ppp] 
          self.SW_X[:,ppp] = self.NE_X[0,ppp-1]
      # Make grid Northing
      Y_len = 0
      for ppp in range(self.NROW-1,-1,-1):
        if ppp == (self.NROW-1):
          self.Y[ppp,:] = (self.DELR[ppp]/2) 
          self.SE_Y[ppp,:] = 0.0 
          self.SW_Y[ppp,:] = 0.0 
          self.NE_Y[ppp,:] = self.DELR[ppp]
          self.NW_Y[ppp,:] = self.DELR[ppp]
        else:
          self.Y[ppp,:] = self.Y[ppp+1,0]+((self.DELR[ppp]/2)+(self.DELR[ppp+1]/2)) 
          self.SE_Y[ppp,:] = self.NE_Y[ppp+1,0]
          self.SW_Y[ppp,:] = self.NW_Y[ppp+1,0]
          self.NE_Y[ppp,:] = self.NE_Y[ppp+1,0] + self.DELR[ppp]
          self.NW_Y[ppp,:] = self.NW_Y[ppp+1,0] + self.DELR[ppp]
        Y_len += self.DELR[ppp]

      self.Y0 -= Y_len
      # Rotate
      for iii in range(0,self.NROW):
        for jjj in range(0,self.NCOL):
          tmpX = self.X[iii,jjj]
          tmpY = self.Y[iii,jjj]
          self.X[iii,jjj]=(tmpX*math.cos(self.THETA*math.pi/180)-tmpY*math.sin(self.THETA*math.pi/180))+self.X0
          self.Y[iii,jjj]=(tmpX*math.sin(self.THETA*math.pi/180)+tmpY*math.cos(self.THETA*math.pi/180))+self.Y0
          tmpX = self.NE_X[iii,jjj]
          tmpY = self.NE_Y[iii,jjj]
          self.NE_X[iii,jjj]=(tmpX*math.cos(self.THETA*math.pi/180)-tmpY*math.sin(self.THETA*math.pi/180))+self.X0
          self.NE_Y[iii,jjj]=(tmpX*math.sin(self.THETA*math.pi/180)+tmpY*math.cos(self.THETA*math.pi/180))+self.Y0
          tmpX = self.NW_X[iii,jjj]
          tmpY = self.NW_Y[iii,jjj]
          self.NW_X[iii,jjj]=(tmpX*math.cos(self.THETA*math.pi/180)-tmpY*math.sin(self.THETA*math.pi/180))+self.X0
          self.NW_Y[iii,jjj]=(tmpX*math.sin(self.THETA*math.pi/180)+tmpY*math.cos(self.THETA*math.pi/180))+self.Y0
          tmpX = self.SE_X[iii,jjj]
          tmpY = self.SE_Y[iii,jjj]
          self.SE_X[iii,jjj]=(tmpX*math.cos(self.THETA*math.pi/180)-tmpY*math.sin(self.THETA*math.pi/180))+self.X0
          self.SE_Y[iii,jjj]=(tmpX*math.sin(self.THETA*math.pi/180)+tmpY*math.cos(self.THETA*math.pi/180))+self.Y0
          tmpX = self.SW_X[iii,jjj]
          tmpY = self.SW_Y[iii,jjj]
          self.SW_X[iii,jjj]=(tmpX*math.cos(self.THETA*math.pi/180)-tmpY*math.sin(self.THETA*math.pi/180))+self.X0
          self.SW_Y[iii,jjj]=(tmpX*math.sin(self.THETA*math.pi/180)+tmpY*math.cos(self.THETA*math.pi/180))+self.Y0

        
    def printtempcoord(self):
      gridfile = open("C:/temp/gridfile.txt",'w')
      vertfile = open("C:/temp/vertfile.txt",'w')
      gridfile.write('X,Y\n')
      vertfile.write('X,Y\n')
      for iii in range(0,self.NROW):
        for jjj in range(0,self.NCOL):
          gridfile.write(str(self.X[iii,jjj]) + ',' + str(self.Y[iii,jjj])+'\n')
          vertfile.write(str(self.NW_X[iii,jjj]) + ',' + str(self.NW_Y[iii,jjj])+'\n')
          if (iii == (self.NROW-1)):
            vertfile.write(str(self.SW_X[iii,jjj]) + ',' + str(self.SW_Y[iii,jjj])+'\n')
        vertfile.write(str(self.NE_X[iii,jjj]) + ',' + str(self.NE_Y[iii,jjj])+'\n')
      vertfile.write(str(self.SE_X[iii,jjj]) + ',' + str(self.SE_Y[iii,jjj])+'\n')
      gridfile.close()
      vertfile.close()


    def calcNewRealArray(self,spc2,fileName,fileName2,cType,vType):    # The cType is the type of conversion
      import numpy                                                     #   1. Pick value at the center
      import math                                                      #   2. Arithmetic Mean
                                                                       #   3. Harmonic Mean
      parray = numpy.zeros((spc2.NROW,spc2.NCOL))                      #   4. Geometric Mean
      #print(str(spc2.NROW) + " " + str(spc2.NCOL) + "\n")             #   5. Majority
      tmparray = []
      with open(fileName, 'r') as f:
        data = f.readlines()
        for line in data:
            words = line.split()
            for word in words:
              tmparray.append(float(word))
      #print (tmparray)
      acount = 0
      for bbb in range(int(spc2.NROW)):
        for ccc in range(int(spc2.NCOL)):
          #print (str(bbb) + " " + str(ccc) + " " + str(acount) + "\n")
          parray[bbb, ccc] = float(tmparray[acount])
          acount += 1    
      blnWarningGiven = False
      outfile = open(fileName2,'w') 
      for iii in range(0,self.NROW):                
        for jjj in range(0,self.NCOL):              

          if (iii == 53 and jjj == 52):
            iii = iii
          newList = []
          newVal = 0
          newCnt = 0
          if ((self.IBND[iii,jjj] != 0) or (self.ISIBND != True)):
            for lll in range(self.LIST_CNT[iii][jjj]):
              tmpI = self.LIST_ROWS[iii][jjj][lll]
              tmpJ = self.LIST_COLS[iii][jjj][lll]
              if ((spc2.IBND[tmpI,tmpJ] != 0) or (spc2.ISIBND != True)):
                if cType == 1:
                  if (((spc2.NW_X[tmpI,tmpJ] <= self.X[iii,jjj]) and (spc2.NE_X[tmpI,tmpJ] >= self.X[iii,jjj])) and
                       ((spc2.SW_Y[tmpI,tmpJ] <= self.Y[iii,jjj]) and (spc2.NW_Y[tmpI,tmpJ] >= self.Y[iii,jjj]))): 
                    newVal += parray[tmpI,tmpJ]
                    newCnt +=1
                elif cType == 2:
                  newVal += parray[tmpI,tmpJ]
                  newCnt +=1
                elif cType == 3:
                  tmpVal = parray[tmpI,tmpJ]
                  if (tmpVal != 0):
                    newVal += (1/tmpVal)
                    newCnt +=1
                  else:
                    if (blnWarningGiven == False):
                      print ('A value in the array is zero and a harmonic mean was selected. All zero values less than or equal to zero will be ingnored\n')
                      blnWarningGiven = True
                elif cType == 5:
                  newList.append(parray[tmpI,tmpJ])
                  newVal = (parray[tmpI,tmpJ])
                  #print (str(newVal) + "  " + str(newList.count) + " " + str(newCnt) + " " + str(newList))
                  newCnt +=1
                else:
                  tmpVal = parray[tmpI,tmpJ]
                  if (tmpVal > 0):
                    newVal += math.log10(parray[self.LIST_ROWS[iii][jjj][lll],self.LIST_COLS[iii][jjj][lll]])
                    newCnt +=1
                  else:
                    if (blnWarningGiven == False):
                      print ('A value in the array is zero and a geoemetric mean was selected. All zero values less than or equal to zero will be ingnored\n')
                      blnWarningGiven = True
            if (newCnt > 0):
 #           if (newCnt > 1):
              #print(str(newCnt) + " " + str(newVal))
              if (cType == 2): 
                newVal = newVal/newCnt
              elif (cType == 3): 
                newVal = newCnt/newVal
              elif cType == 5:
                newVal = max(set(newList),key=newList.count) 
                #print (str(newVal) + "  " + str(newList.count) + " " + str(newCnt) + " " + str(newList))
              elif cType == 4: 
                newVal = 10**(newVal/newCnt)

          if (vType == "LONG"): 
            if (newVal >=0):
              outfile.write("  {:2d}".format(int(newVal)))
            else:
              outfile.write(" {:2d}".format(int(newVal)))
            if ((jjj+1)%25 ==0):
              outfile.write('\n')
          else: 
            if (newVal >=0):
              outfile.write("  {:8.6e}".format(newVal))
            else:
              outfile.write(" {:8.6e}".format(newVal))
            if ((jjj+1)%7 ==0):
              outfile.write('\n')
        outfile.write('\n')
      outfile.close() 


    def createCELL_LIST(self,spc2,cell_radius):
      import math 
        # USE BISECTION TO CREATE THE CELLS THAT RELATE TO THE SECOND
      for iii in range(0,self.NROW):
        for jjj in range(0,self.NCOL):
          cUpper = spc2.NCOL-1
          cLower = 0 
          rLower = spc2.NROW-1
          rUpper = 0 
          # Search through the columns
          if (iii == 53 and jjj == 52):
            iii = iii

          blnFinished = False
          while (blnFinished != True):
              cMid = math.floor((cUpper+cLower)/2)
              if cMid == cLower:
                  cMid = cLower+1
              if (self.NW_X[iii,jjj] <= spc2.X[0,cMid]):
                  cUpper = cMid
              elif (self.NE_X[iii,jjj] >= spc2.X[0,cMid]):
                  cLower = cMid
              if (((self.NW_X[iii,jjj] <= spc2.X[0,cLower]) and (self.NE_X[iii,jjj] >= spc2.X[0,cUpper])) or
                  ((cLower+1) == cUpper)):
                  blnFinished = True 

          # Search through the rows
          blnFinished = False
          while (blnFinished != True):
              rMid = math.floor((rUpper+rLower)/2)
              if rMid == rUpper:
                  rMid = rUpper+1
              if (self.NW_Y[iii,jjj] >= spc2.Y[rMid,0]):
                  rLower = rMid
              elif (self.SW_Y[iii,jjj] <= spc2.Y[rMid,0]):
                  rUpper = rMid
              if (((self.NW_Y[iii,jjj] <= spc2.Y[rLower,0]) and (self.SW_Y[iii,jjj] >= spc2.Y[rUpper,0])) or
                  ((rUpper+1) == rLower)):
                  blnFinished = True 
                  
          rUpper -= cell_radius
          rLower += cell_radius
          cUpper += cell_radius
          cLower -= cell_radius

          if ((rUpper) < 0):
            rUpper = 0
          if ((rLower) >= spc2.NROW):
            rLower = spc2.NROW -1
          if ((cUpper) >= spc2.NCOL):
            cUpper = spc2.NCOL -1
          if ((cLower) < 0):
            cLower = 0

          for ii in range(rUpper,rLower+1): 
            for jj in range(cLower,cUpper+1): 
              if (((self.NW_X[iii,jjj] <= spc2.X[ii,jj]) and (self.NE_X[iii,jjj] >= spc2.X[ii,jj])) and
                   ((self.SW_Y[iii,jjj] <= spc2.Y[ii,jj]) and (self.NW_Y[iii,jjj] >= spc2.Y[ii,jj]))): 
                self.LIST_ROWS[iii][jjj].append(ii)
                self.LIST_COLS[iii][jjj].append(jj)
                self.LIST_CNT[iii][jjj] += 1
              elif (((spc2.NW_X[ii,jj] <= self.X[iii,jjj]) and (spc2.NE_X[ii,jj] >= self.X[iii,jjj])) and
                     ((spc2.SW_Y[ii,jj] <= self.Y[iii,jjj]) and (spc2.NW_Y[ii,jj] >= self.Y[iii,jjj]))): 
                self.LIST_ROWS[iii][jjj].append(ii)
                self.LIST_COLS[iii][jjj].append(jj)
                self.LIST_CNT[iii][jjj] += 1
