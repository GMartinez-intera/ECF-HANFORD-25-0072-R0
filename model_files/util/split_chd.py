def is_number(n):
    try:
        float(n)   # Type-casting the string to `float`.
                   # If string is not a valid `float`, 
                   # it'll raise `ValueError` exception
    except ValueError:
        return False
    return True


import os
import sys
oldid = "JJJJJ"
blnAppend = sys.argv[2]
outfile = open('./deleteme.txt', "w")
with open(sys.argv[1], 'r') as f:
    for line in f:
        tmpLine = line.split()
        if oldid != tmpLine[0]:
          outfile.close()
          if (blnAppend == 'a'):
            outfile = open('./csv/'+tmpLine[0]+".txt", "a")
          else:
            outfile = open('./csv/'+tmpLine[0]+".txt", "w")
            outfile.write("Year,Elevation\n")
        if is_number(tmpLine[3]):
          outfile.write(tmpLine[1][-4:] + "," + tmpLine[3] + '\n')
        else:
          outfile.write(tmpLine[1][-4:] + ",-9999.000\n")
        oldid = tmpLine[0]
        #print(line.split())
