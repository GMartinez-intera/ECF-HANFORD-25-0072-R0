'''
Author:         Edward Momotok
Date:           December 2022
Company:        Intera Inc.
Usage:          open cell data file, layer ref files, layer ibnd files, and build a well cell package

'''


import pandas as pd
import argparse
import json


params = {}
botData = {}
bndData = {}
currentCount = 0
single = ""
well_dict = {}

def createWellDictionary():
    
    for position, well_id in enumerate(params["wellID"]):
        well_dict[well_id] = position
    return well_dict




def whichWell(row):
    well_id = row[params["wellColumn"]]
    return well_dict.get(well_id)


#this function finds if argument is a chd cell and adds it to the chd package
def isFlooded(row, elevations, tracker):
    global single #chd package for single stress period
    global currentCount #current count of how many chd cells in current stress period
    global params

    trow = int(row[params["rowColumn"]]) #current row
    tcol = int(row[params["columnColumn"]]) #current column
    wellElevation = elevations[int(row["wellfileposition"])][tracker]#corresponding wells' elevation of the current cell
    wellFilePosition = int(row["wellfileposition"])


 

    columns = params["numCol"] 
    position = columns*(trow-1) + tcol - 1 #given a column and row, where is the cell in the ibnd and data files
    

    active = []
    if params["specifiedLayer"] == 'True':
        sLayer = int(row[params["specifiedLayerColumn"]])
        if bndData[sLayer-1][position] == 1:
            active.append(sLayer)

    elif params["specifiedLayer"] == 'False':
        active = findAllActive(position)


    for i in active:
        elevation = botData[i-1][position]
        if wellElevation >= elevation:
            wellElevation = wellElevation + 0.00000000001
            currentCount += 1
            #single = single + "\n%10d%10d%10d%#10.2f%#10.2f  %d" % (i, trow, tcol, wellElevation, wellElevation, wellFilePosition)
            single = single + "\n%10d%10d%10d%#10.3f%#10.3f" % (i, trow, tcol, wellElevation, wellElevation)


#this function finds if argument is a chd cell and adds it to the chd package
def isFlooded2(row, elevations, tracker):
    global single #chd package for single stress period
    global currentCount #current count of how many chd cells in current stress period
    global params

    trow = int(row[params["rowColumn"]]) #current row
    tcol = int(row[params["columnColumn"]]) #current column
    wellElevation = elevations[int(row["wellfileposition"])][tracker]#corresponding wells' elevation of the current cell
    wellElevation2 = elevations[int(row["wellfileposition"])][tracker+1]#corresponding wells' elevation of the current cell
    wellFilePosition = int(row["wellfileposition"])


 

    columns = params["numCol"] 
    position = columns*(trow-1) + tcol - 1 #given a column and row, where is the cell in the ibnd and data files
    

    active = []
    if params["specifiedLayer"] == 'True':
        sLayer = int(row[params["specifiedLayerColumn"]])
        if bndData[sLayer-1][position] == 1:
            active.append(sLayer)

    elif params["specifiedLayer"] == 'False':
        active = findAllActive(position)


    for i in active:
        elevation = botData[i-1][position]
        if wellElevation >= elevation:
            wellElevation = wellElevation + 0.00000000001
            currentCount += 1
            #single = single + "\n%10d%10d%10d%#10.2f%#10.2f  %d" % (i, trow, tcol, wellElevation, wellElevation, wellFilePosition)
            single = single + "\n%10d%10d%10d%#10.3f%#10.3f" % (i, trow, tcol, wellElevation, wellElevation2)


def findAllActive(position):
    active = []
    for i in reversed(range(params["numLayers"])):
        if bndData[i][position] == 1:
            active.append(i+1)
    return active


#reads in input files into lists
def readInputFiles():
    params["bot_ref_files"].sort()
    params["ibnd_inf_files"].sort()

    i = 0
    for file in params["bot_ref_files"]:
        readFile(file, i, False)
        i +=1
    
    if i != params["numLayers"]:
        print("error: there needs to be %d bot_ref_files in param.json\n" % (params["numLayers"]))
        quit()
    i = 0
    for file in params["ibnd_inf_files"]:
        readFile(file, i, True)
        i +=1
    if i != params["numLayers"]:
        print("error: there needs to be %d ibnd_inf_files in param.json\n" % (params["numLayers"]))
        quit()


    
    
#reads in individual files
def readFile(filePath, i , ibndOrNot):
    fFile = open(filePath, "r")
    data = fFile.read()
    splitData = data.split()
    if ibndOrNot == True:     
        bndData[i] = [float(a) for a in splitData]
        if len(bndData[i]) != params["numRows"] * params["numCol"]:
            print("\nnumber of entries in file: \"%s\" does not match number of rows and columns specified in param.json\n\n" % (filePath))
            quit()
    else:
        botData[i] = [float(a) for a in splitData]
        if len(botData[i]) != params["numRows"] * params["numCol"]:
            print("\nnumber of entries in file \"%s\" does not match number of rows and columns specified in param.json\n\n" % (filePath))
            quit()


def main():
    global params
   
    parser = argparse.ArgumentParser()
    parser.add_argument("--c", help="file with cell info", required=True)
    parser.add_argument("--o", help="desired output file", required=True)
    args = parser.parse_args()

    with open('param_chd.json', "r") as paramFile:
        params = json.load(paramFile)

    readInputFiles()
    

    times = {}
    elevations = {}
    i = 0

    #reads in hydraulic head elevation files
    for file in params["well_files"]:
        stressPeriods_df = pd.read_csv(file)
        times[i] = stressPeriods_df.iloc[:,params["timeColumn"]].tolist()
        elevations[i] = stressPeriods_df.iloc[:,params["elevationColumn"]].tolist()
        if len(times[i]) != params["numStressPeriods"]:
            print("\nNumber of stress periods in \"%s\" does not match param specification" % (file))
            print(times[i])
            quit()
        if len(elevations[i]) != params["numStressPeriods"]:
            print("\nNumber of stress periods in \"%s\" does not match param specification" % (file))
            quit()
        i += 1



    if i != params["numWells"]:
        print("\nThere needs to be %d well files in param.json\n\n" % (params["numWells"]))
        quit()

    #this reads in the grid location file into memory
    
    abcFilePath = args.c
    abc_df = pd.read_csv(abcFilePath)#, header = 0)
   
    abc_df = abc_df.dropna(how='all')
    global single 
    global currentCount
    final = "%10d%10d" % (params["maxChdCells"], params["cbbUnitNumber"])

    well_dict = createWellDictionary()
    abc_df['wellfileposition'] = abc_df.apply(whichWell, axis = 1)
    
    #runs program for all stress periods
    for tracker in range(0, len(elevations[0])):
        currentCount = 0
        single = ""
        if (tracker < (len(elevations[0])-1)):
          abc_df.apply(isFlooded2, elevations = elevations, tracker = tracker, axis = 1)
        else:
          abc_df.apply(isFlooded, elevations = elevations, tracker = tracker, axis = 1)
        #final = final + "\n%10d                                                             #sp: %d  #%s: %d" % (currentCount, tracker + 1, stressPeriods_df.columns[params["timeColumn"]], times[0][tracker])
        final = final + "\n%10d                 Stress Period:                %-15dYear:        %s " % (currentCount, tracker + 1, times[0][tracker])
        final = final + single
   

    with open(args.o, "w") as text_file:
        text_file.write(final)


main()

