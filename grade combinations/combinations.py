import itertools
import numpy
import pandas as pd
import matplotlib.pyplot as plt

oldgrades=[0,3,5,6,7,8,9,10,11,13]
newgrades=[-2,0,0,2,4,7,7,10,12,12]
# Empty pandas dataframe
xaxis=numpy.arange(0, 13, 0.1)
df = pd.DataFrame(index=numpy.arange(0, 13, 0.1))
# loop over number of pregrades
for nr in range(8):
# Empty lists
	combilist=[]
	gpapre=[]
	gpapost=[]
	gradesbefore=[]

	for x in list(itertools.combinations_with_replacement(enumerate(oldgrades), nr)):
		index=[y[0] for y in x]
		grades=[y[1] for y in x]
		gpapost.append(round(numpy.mean([newgrades[i] for i in index]),1))
		gpapre.append(round(numpy.mean(grades),1))
		gradesbefore.append(grades)

	MyRawdata=pd.DataFrame({'gpapre':gpapre,'gpapost':gpapost,'gradesbefore':gradesbefore})
	minvals=MyRawdata.groupby(gpapre)['gpapost'].min()
	maxvals=MyRawdata.groupby(gpapre)['gpapost'].max()
	median=MyRawdata.groupby(gpapre)['gpapost'].median()
	count=MyRawdata.groupby(gpapre)['gpapost'].size()
	Mydif=pd.DataFrame({"Dif "+str(nr):maxvals-minvals,"Count "+str(nr):count,"Median":median})
	label="Order:"
	df=pd.concat([df, Mydif	], axis=1)

writer =  pd.ExcelWriter('output.xlsx')
df.to_excel(writer,'Sheet1')
writer.save()